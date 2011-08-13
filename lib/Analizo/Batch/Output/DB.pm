package Analizo::Batch::Output::DB;
use strict;
use warnings;
use base qw( Analizo::Batch::Output );
use DBI;
use Digest::SHA1 qw(sha1_hex);

sub database($) {
  my ($self) = @_;
  my $db = $self->file || 'output.sqlite3';
  if ($db =~ /^dbi:/) {
    return $db;
  } else {
    return 'dbi:SQLite:' . $db;
  }
}

sub push($$) {
  my ($self, $job) = @_;

  my $project_id = $self->_add_project($job->project_name);

  my $developer_id = $self->_add_developer($job);

  my $commit_id = $self->_add_commit($job, $project_id, $developer_id);

  $self->_add_modules($job, $commit_id, $project_id);
}

sub flush($) {
  my ($self) = @_;
  $self->{dbh}->disconnect();
}

sub _find_row_id($$@) {
  my ($self, $sql, @data) = @_;
  my $statement_id = 'st_find_' . sha1_hex($sql); # is this SHA1 needed at all?

  $self->{$statement_id} ||= $self->{dbh}->prepare($sql);
  my $list = $self->{dbh}->selectall_arrayref($self->{$statement_id}, {}, @data);
  if (scalar(@$list) == 0) {
    return undef;
  } else {
    return $list->[0]->[0];
  }
}

sub _add_project($$) {
  my ($self, $project) = @_;
  $self->{st_add_project}   ||= $self->{dbh}->prepare('INSERT INTO projects (name) values(?)');

  my $project_id = $self->_find_project($project);
  if (! $project_id) {
    $self->{st_add_project}->execute($project);
    $project_id = $self->_find_project($project);
  }

  return $project_id;
}

sub _find_project($$) {
  my ($self, $project) = @_;
  return $self->_find_row_id('SELECT id from projects where name = ?', $project);
}

sub _add_developer($$) {
  my ($self, $job) = @_;

  my $metadata = $job->metadata_hashref();
  my $name  = $metadata->{author_name};
  my $email = $metadata->{author_email};

  # FIXME unstested
  if (!$name || !$email) {
    return undef;
  }

  $self->{st_add_developer} ||= $self->{dbh}->prepare('INSERT INTO developers (name,email) VALUES (?,?)');
  my $developer_id = $self->_find_developer($name, $email);
  if (! $developer_id) {
    $self->{st_add_developer}->execute($name, $email);
    $developer_id = $self->_find_developer($name, $email);
  }

  return $developer_id;
}

sub _find_developer($$$) {
  my ($self, $name, $email) = @_;
  return $self->_find_row_id('SELECT id FROM developers WHERE name = ? AND email = ?', $name, $email);
}

sub _add_commit($$$$) {
  my ($self, $job, $project_id, $developer_id) = @_;
  my $metadata = $job->metadata_hashref;
  my $previous_commit_id = $metadata->{previous_commit_id};
  my $date = $metadata->{author_date};
  $self->{st_insert_commit} ||= $self->{dbh}->prepare('INSERT INTO commits (id, project_id,developer_id,previous_commit_id,date) VALUES(?,?,?,?,?)');
  $self->{st_insert_commit}->execute($job->id, $project_id, $developer_id, $previous_commit_id, $date);
  return $job->id;
}

sub _add_modules($$$$) {
  my ($self, $job, $commit_id, $project_id) = @_;
  my $metadata = $job->metadata_hashref();

  if ($metadata->{changed_files}) {
    my @modules = ();
    for my $file (@{$metadata->{changed_files}}) {
      my $module = $job->model->module_by_file($file);
      next unless $module; # not all files correspond to modules!
      unless(grep { $_ eq $module } @modules) { # do not process one module more than once per commit
        CORE::push @modules, $module;
        my $module_id = $self->_add_module($module, $project_id);
        my $module_version_id = $self->_add_module_version($module_id, $commit_id);
        $self->_add_metrics($job, $module, $module_version_id);
      }
    }
  }
}

sub _add_module($$$) {
  my ($self, $module, $project_id) = @_;

  my $module_id = $self->_find_module($module, $project_id);
  if (!$module_id) {
    $self->{st_add_module} ||= $self->{dbh}->prepare('INSERT INTO modules (name, project_id) values (?,?)');
    $self->{st_add_module}->execute($module, $project_id);
    $module_id = $self->_find_module($module, $project_id);
  }

  return $module_id;
}

sub _find_module($$$) {
  my ($self, $module, $project_id) = @_;
  return $self->_find_row_id('SELECT id FROM modules WHERE name = ? AND project_id = ?', $module, $project_id);
}

sub _add_module_version {
  my ($self, $module_id, $commit_id) = @_;
  $self->{st_add_module_version} ||= $self->{dbh}->prepare('INSERT INTO module_versions (module_id) VALUES (?)');
  $self->{st_add_module_version}->execute($module_id);

  my $module_version_id = $self->_find_row_id('SELECT max(id) from module_versions WHERE module_id = ?', $module_id);

  $self->{st_link_commit_and_module_version} ||= $self->{dbh}->prepare('INSERT INTO commits_module_versions (commit_id,module_version_id) VALUES (?,?)');
  $self->{st_link_commit_and_module_version}->execute($commit_id, $module_version_id);

  return $module_version_id;
}

sub _add_metrics($$$$) {
  my ($self, $job, $module, $module_version_id) = @_;
  my ($summary, $details) = $job->metrics->data();
  # $details is an ARRAY reference containing one HASH reference for each module
  # We need to find the one we are looking for
  my @metrics = grep { $_->{_module} eq $module } @$details;
  if (scalar(@metrics)) {
    my %metrics = %{$metrics[0]};
    for my $metric (keys(%metrics)) {
      next if $metric =~ /^_/;
      $self->_add_metric($module_version_id, $metric, $metrics{$metric});
    }
  }
}

sub _add_metric($$$$) {
  my ($self, $module_version_id, $metric, $value) = @_;
  $self->{st_add_metric} ||= $self->{dbh}->prepare('INSERT INTO metrics (module_version_id, name, value) VALUES(?,?,?)');
  $self->{st_add_metric}->execute($module_version_id, $metric, $value);
}

# Initializes the database
#
# TODO the current approach of feeding DDL SQL statements directly to the
# database handle might not be good enough, since the SQL being written might
# not be portable to other databases than SQLite. It would be nice to have
# something similar to the rails migrations DSL here.
sub initialize($) {
  my ($self) = @_;
  $self->{dbh} = DBI->connect($self->database, undef, undef, { RaiseError => 1});
  # assume that if there is a table called `analizo_metadata`, then the database was already initialized
  if (!grep { $_ =~ /analizo_metadata/ } $self->{dbh}->tables()) {
    for my $statement (ddl_statements()) {
      $self->{dbh}->do($statement);
    }
  }
}

my $DDL_INITIALIZED = 0;
my @DDL_STATEMENTS = ();
sub ddl_statements($) {
  if (!$DDL_INITIALIZED) {
    my $sql = '';
    while (my $line = <DATA>) {
      $sql .= $line;
      if ($line =~ /;\s*$/) {
        # SQL statement is ready
        CORE::push @DDL_STATEMENTS, $sql;
        $sql = '';
      }
    }
    $DDL_INITIALIZED = 1;
  }
  return @DDL_STATEMENTS;
}

1;

__DATA__

/* Analizo DB output schema definition */

CREATE TABLE analizo_metadata (
  key CHAR(100),
  value CHAR(100)
);

CREATE TABLE projects (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name CHAR(250)
);

CREATE TABLE developers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name CHAR(250),
  email CHAR(250)
);

CREATE TABLE commits (
  id CHAR(40) PRIMARY KEY,
  previous_commit_id CHAR(40),
  project_id INTEGER,
  date INTEGER,
  developer_id CHAR(40)
);
CREATE INDEX commits_project_id ON commits (project_id);

CREATE TABLE modules (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  project_id INTEGER,
  name CHAR(250)
);
CREATE UNIQUE INDEX modules_project_id_name ON modules(project_id, name);

CREATE TABLE module_versions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  module_id INTEGER
);

CREATE TABLE commits_module_versions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  commit_id CHAR(40),
  module_version_id INTEGER,
  status CHAR(30)
);
CREATE INDEX commits_module_versions_commit_id ON commits_module_versions (commit_id);

CREATE TABLE metrics (
  module_version_id INTEGER,
  name CHAR(100),
  value NUMERIC,
  PRIMARY KEY (module_version_id, name)
);

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
  unless ($self->_find_row_id('SELECT id FROM commits where id = ?', $job->id)) {
    my $metadata = $job->metadata_hashref;
    my $previous_commit_id = $metadata->{previous_commit_id};
    my $date = $metadata->{author_date};
    $self->{st_insert_commit} ||= $self->{dbh}->prepare('INSERT INTO commits (id, project_id,developer_id,previous_commit_id,date) VALUES(?,?,?,?,?)');
    $self->{st_insert_commit}->execute($job->id, $project_id, $developer_id, $previous_commit_id, $date);
  }
  return $job->id;
}

sub _add_modules($$$$) {
  my ($self, $job, $commit_id, $project_id) = @_;
  my $metadata = $job->metadata_hashref();

  my %module_versions = ();
  if ($metadata->{files}) {
    for my $file (keys(%{$metadata->{files}})) {
      my $module = $job->model->module_by_file($file);
      next unless $module;
      unless($module_versions{$module}) {
        my $module_id = $self->_add_module($module, $project_id);

        my $module_files = $job->model->files($module);
        my @file_ids = map { $metadata->{files}->{$_} } sort(@$module_files);

        my $module_version_id = _module_version_id(@file_ids);

        my $metrics = $job->metrics->metrics_for($module);

        $self->_add_module_version($commit_id, $module_id, $module_version_id, %$metrics);
        $module_versions{$module} = $module_version_id;
      }
    }
  }

  if ($metadata->{changed_files}) {
    my %already_marked = ();
    for my $file (keys(%{$metadata->{changed_files}})) {
      my $module = $job->model->module_by_file($file);
      next unless $module; # not all files correspond to modules!
      next if $already_marked{$module};
      $already_marked{$module} = 1;

      my $module_version_id = $module_versions{$module};

      my $module_files = $job->model->files($module);
      my @statuses = map { $metadata->{changed_files}->{$_} || 'K' } @$module_files;
      my $statuses = join('', @statuses);

      if ($statuses =~ /^A+$/) {
        $self->_mark_as_added($commit_id, $module_version_id);
      } elsif ($statuses !~ /^D+$/) {
        $self->_mark_as_modified($commit_id, $module_version_id);
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

sub _module_version_id {
  my @file_ids = @_;
  my $module_version_id;
  if (scalar(@file_ids) == 1) {
    $module_version_id = $file_ids[0];
  } else {
    $module_version_id = sha1_hex(join('', @file_ids));
  }
  return $module_version_id;
}

sub _add_module_version {
  my ($self, $commit_id, $module_id, $module_version_id, %metrics) = @_;
  my $module_version_already_exists = $self->_find_row_id('SELECT id from module_versions WHERE module_id = ? AND id = ?', $module_id, $module_version_id);
  unless ($module_version_already_exists) {

    my @metric_columns = _metric_columns();
    my @metric_values = map { $metrics{$_} } @metric_columns;
    my $metric_column_names = join(',', @metric_columns);
    my $metric_placeholders = join(',', map { '?' } @metric_columns);

    my $statement = "INSERT INTO module_versions (id,module_id,$metric_column_names) VALUES (?,?,$metric_placeholders)";
    $self->{st_add_module_version} ||= $self->{dbh}->prepare($statement);
    $self->{st_add_module_version}->execute($module_version_id, $module_id, @metric_values);
  }

  $self->{st_link_commit_and_module_version} ||= $self->{dbh}->prepare('INSERT INTO commits_module_versions (commit_id,module_version_id) VALUES (?,?)');
  $self->{st_link_commit_and_module_version}->execute($commit_id, $module_version_id);

  return $module_version_id;
}

sub _mark_as_added($$$) {
  my ($self, $commit_id, $module_version_id) = @_;
  $self->{st_mark_as_added} ||= $self->{dbh}->prepare('UPDATE commits_module_versions SET added = 1 WHERE commit_id = ? AND module_version_id = ?');
  $self->{st_mark_as_added}->execute($commit_id, $module_version_id);
}

sub _mark_as_modified($$$) {
  my ($self, $commit_id, $module_version_id) = @_;
  $self->{st_mark_as_modified} ||= $self->{dbh}->prepare('UPDATE commits_module_versions SET modified = 1 WHERE commit_id = ? AND module_version_id = ?');
  $self->{st_mark_as_modified}->execute($commit_id, $module_version_id);
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
      $statement =~ s/\@\@METRICS\@\@/_metric_columns_ddl()/egm;
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

use Analizo::Metrics;
use Analizo::Model;
my @__metric_columns = ();
sub _metric_columns() {
  if (!@__metric_columns) {
    my $metrics = new Analizo::Metrics(model => new Analizo::Model);
    my %metrics = $metrics->list_of_metrics();
    @__metric_columns = keys(%metrics);
  }
  return @__metric_columns;
}

sub _metric_columns_ddl {
  my @columns = _metric_columns();
  my $ddl = join(', ', map { "$_ REAL"} @columns);
  return $ddl;
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
  id CHAR(40) PRIMARY KEY,
  module_id INTEGER,
  @@METRICS@@
);

CREATE TABLE commits_module_versions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  commit_id CHAR(40),
  module_version_id CHAR(40),
  modified INTEGER default 0,
  added INTEGER default 0
);
CREATE INDEX commits_module_versions_commit_id ON commits_module_versions (commit_id);

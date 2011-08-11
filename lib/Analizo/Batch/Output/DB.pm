package Analizo::Batch::Output::DB;
use strict;
use warnings;
use base qw( Analizo::Batch::Output );
use DBI;

sub database($) {
  my ($self) = @_;
  my $db = $self->file || 'output.sqlite3';
  if ($db =~ /^dbi:/) {
    return $db;
  } else {
    return 'dbi:SQLite:' . $db;
  }
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
        push @DDL_STATEMENTS, $sql;
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
  id CHAR(40) PRIMARY KEY,
  name CHAR(250),
  email CHAR(250)
);

CREATE TABLE commits (
  id CHAR(40) PRIMARY KEY,
  parent_id CHAR(40),
  project_id INTEGER,
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

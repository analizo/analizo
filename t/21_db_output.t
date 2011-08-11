package Analizo::Batch::Output::DB::Tests;
use strict;
use warnings;
use base qw( Test::Class );
use Test::More;
use Test::Analizo;
my $TMPDIR = tmpdir();
my $OUTFILE = $TMPDIR . '/out.sqlite3';

use Analizo::Batch::Output::DB;
use DBI;

sub basics : Tests {
  isa_ok(new Analizo::Batch::Output::DB, 'Analizo::Batch::Output');
  isa_ok(new Analizo::Batch::Output::DB, 'Analizo::Batch::Output::DB');
}

sub destination_database : Tests {
  my $output = __create();
  is($output->database, 'dbi:SQLite:output.sqlite3', 'use SQLite output by default');

  # specify an specific output file
  $output->file('mydb.sqlite3');
  is($output->database, 'dbi:SQLite:mydb.sqlite3', 'use SQLite with a custom DB name');

  # use an explicit DBI data source instead
  $output->file('dbi:mysql:mydb');
  is($output->database, 'dbi:mysql:mydb');
}

sub setting_up_a_database : Tests {
  # new database
  my $output = __create();
  $output->file($OUTFILE);
  $output->initialize();

  table_created_ok($OUTFILE, 'projects');
  table_created_ok($OUTFILE, 'commits');
  table_created_ok($OUTFILE, 'developers');
  table_created_ok($OUTFILE, 'modules');
  table_created_ok($OUTFILE, 'module_versions');
  table_created_ok($OUTFILE, 'commits_module_versions'); # relationship table
  table_created_ok($OUTFILE, 'metrics');

  # try to re-initialize an existing database - should not crash
  my $output2 = __create();
  $output2->file($OUTFILE);
  $output2->initialize();
}

sub __create {
  my ($file) = @_;
  my $output = new Analizo::Batch::Output::DB();
  if ($file) {
    $output->file($file);
    $output->initialize();
  }
  return $output;
}

sub setup : Test(setup) {
  system("mkdir -p $TMPDIR");
}

sub teardown : Test(teardown) {
  system("rm -rf $TMPDIR");
}

sub table_created_ok($$) {
  my ($db, $table) = @_;
  my $dbh = DBI->connect("dbi:SQLite:$db");
  my $TABLE = uc($table);
  $table = lc($table);
  my @tables = $dbh->tables();
  my $projects_table = scalar(grep { lc($_) =~ /$table/ } @tables);
  ok($projects_table, "must create $TABLE table");
}

__PACKAGE__->runtests;

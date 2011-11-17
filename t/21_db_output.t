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
use Analizo::Batch::Job;
use Analizo::Batch::Job::Directories;

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

  # try to re-initialize an existing database - should not crash
  my $output2 = __create();
  $output2->file($OUTFILE);
  $output2->initialize();
}

sub add_project_data : Tests {
  my $output = __create($OUTFILE);
  my $job = new Analizo::Batch::Job;
  $job->directory('/path/to/niceproject');
  $output->push($job);
  select_one_ok($OUTFILE, "select * from projects where name = 'niceproject'", 'must insert project the first time');

  $output->push($job);
  select_one_ok($OUTFILE, "select * from projects where name = 'niceproject'", 'must not insert same project twice');
}

sub add_commit_and_developer_data : Tests {
  my $output = __create($OUTFILE);
  my $job = mock(new Analizo::Batch::Job);
  $job->directory('/path/to/niceproject');
  $job->id('XPTO');
  $job->mock(
    'metadata_hashref',
    sub {
      {
        'author_name'   => 'Jonh Doe',
        'author_email'  => 'jdoe@example.com',
        'previous_commit_id'  => 'PREVIOUS',
        'author_date'   => '1313206352',
      }
    }
  );

  $output->push($job);
  select_one_ok($OUTFILE, "SELECT * FROM commits JOIN projects on (projects.id = commits.project_id) WHERE commits.id = 'XPTO'");
  select_one_ok($OUTFILE, "SELECT * FROM developers JOIN commits on (commits.developer_id = developers.id) WHERE developers.name = 'Jonh Doe' AND developers.email = 'jdoe\@example.com' AND commits.id = 'XPTO'");
  select_one_ok($OUTFILE, "SELECT * FROM commits WHERE id = 'XPTO' AND previous_commit_id = 'PREVIOUS' AND date = '1313206352'");

  # pushing the same data again should not crash
  $output->push($job);
}

my $SAMPLE = ('t/samples/animals/cpp');

sub add_module_data_for_modules_changed_by_commit : Tests {
  my $output = __create($OUTFILE);
  my $job = mock(new Analizo::Batch::Job::Directories($SAMPLE));
  $job->id('foo');
  $job->execute();
  $job->mock(
    'metadata_hashref',
    sub {
      {
        'changed_files' => {
          'mammal.h'  => 'M',
          'dog.cc'    => 'M',
        },
        'files' => {
          'mammal.h'  => '1111111111111111111111111111111111111111',
          'dog.cc'    => '2222222222222222222222222222222222222222',
          'dog.h'     => '3333333333333333333333333333333333333333',
          'cat.cc'    => '4444444444444444444444444444444444444444',
          'cat.h'     => '5555555555555555555555555555555555555555',
        }
      }
    }
  );
  $job->mock('project_name', sub { 'animals'; });

  $output->push($job);

  for my $module ('Mammal', 'Dog') {
    # module
    select_one_ok($OUTFILE, "SELECT * FROM modules JOIN projects ON (projects.id = modules.project_id) WHERE projects.name = 'animals' AND modules.name = '$module'");
    # module_versions and commits_module_versions
    select_one_ok($OUTFILE, "SELECT * FROM modules JOIN module_versions ON (module_versions.module_id = modules.id) JOIN commits_module_versions ON (commits_module_versions.module_version_id = module_versions.id) JOIN commits ON (commits_module_versions.commit_id = commits.id) WHERE commits.id = 'foo' AND modules.name = '$module' AND module_versions.lcom4 >= 0 AND module_versions.cbo >= 0");
  }

  select_ok($OUTFILE, "SELECT * FROM module_versions JOIN commits_module_versions ON (module_versions.id = commits_module_versions.module_version_id) JOIN commits ON (commits.id = commits_module_versions.commit_id) WHERE commit_id = 'foo'", 3);
  select_one_ok($OUTFILE, "SELECT * FROM modules JOIN module_versions ON (module_versions.module_id = modules.id) WHERE modules.name = 'Mammal' AND module_versions.id = '1111111111111111111111111111111111111111'");

  # one module with multiple files: concatenate SHA1 of files and calculate the SHA1 of that.
  select_one_ok($OUTFILE, "SELECT * FROM modules JOIN module_versions ON (module_versions.module_id = modules.id) WHERE modules.name = 'Dog' AND module_versions.id = '452219454519b29aae2e135c470d97d9e234976b'");

}

sub changed_added_module_versions : Tests {
  my $output = __create($OUTFILE);
  my $job = mock(new Analizo::Batch::Job::Directories($SAMPLE));
  $job->id('foo');
  $job->execute();
  $job->mock(
    'metadata_hashref',
    sub {
      {
        'changed_files' => {
          'mammal.h'  => 'M',
          'dog.cc'    => 'A',
          'dog.h'     => 'A',
          'cat.cc'    => 'A',
          'cat.h'     => 'M',
        },
        'files' => {
          'mammal.h'  => '1111111111111111111111111111111111111111',
          'dog.cc'    => '2222222222222222222222222222222222222222',
          'dog.h'     => '3333333333333333333333333333333333333333',
          'cat.cc'    => '4444444444444444444444444444444444444444',
          'cat.h'     => '5555555555555555555555555555555555555555',
        }
      }
    }
  );
  $job->mock('project_name', sub { 'animals'; });

  $output->push($job);

  select_one_ok($OUTFILE, "SELECT * FROM commits_module_versions WHERE commit_id = 'foo' AND module_version_id = '1111111111111111111111111111111111111111' AND modified AND NOT added");
  # 452219454519b29aae2e135c470d97d9e234976b = sha1(22222222222222222222222222222222222222223333333333333333333333333333333333333333)
  select_one_ok($OUTFILE, "SELECT * FROM commits_module_versions WHERE commit_id = 'foo' AND module_version_id = '452219454519b29aae2e135c470d97d9e234976b' AND added AND NOT modified");
  # f676c6d81e63377edc2f9ec60b1bc2359b94606f = sha1(44444444444444444444444444444444444444445555555555555555555555555555555555555555)
  select_one_ok($OUTFILE, "SELECT * FROM commits_module_versions WHERE commit_id = 'foo' AND module_version_id = 'f676c6d81e63377edc2f9ec60b1bc2359b94606f' AND modified AND NOT added");
}

sub module_versions_with_the_same_id : Tests {
  my $output = __create($OUTFILE);
  my $job = mock(new Analizo::Batch::Job::Directories($SAMPLE));
  $job->mock('project_name', sub { 'animals'; });
  $job->id('foo');
  $job->execute();
  $job->mock(
    'metadata_hashref',
    sub {
      {
        'changed_files' => {
          'animal.h'  => 'A',
          'mammal.h'  => 'M',
        },
        'files' => {
          'animal.h'  => '1111111111111111111111111111111111111111',
          'mammal.h'  => '1111111111111111111111111111111111111111',
        }
      }
    }
  );
  $output->push($job);
  select_ok($OUTFILE, "SELECT * FROM module_versions WHERE id = '1111111111111111111111111111111111111111'", 2);
}

sub global_metrics : Tests {
  my $output = __create($OUTFILE);
  my $job = mock(new Analizo::Batch::Job::Directories($SAMPLE));
  $job->mock('project_name', sub { 'animals'; });
  $job->id('foo');
  $job->execute();
  $output->push($job);
  select_one_ok($OUTFILE, "SELECT * FROM commits where total_abstract_classes > 0");
  select_one_ok($OUTFILE, "SELECT * FROM commits where total_eloc > 0");
}

sub files_with_multiple_modules : Tests {
  my $output = __create($OUTFILE);
  my $job = mock(new Analizo::Batch::Job::Directories('t/samples/file_with_two_modules/cpp'));
  $job->mock('project_name', sub { 'multiple' });
  $job->id("foo");
  $job->execute;
  $job->mock(
    'metadata_hashref',
    sub {
      {
        'changed_files' => {
          'classes.cc'  => 'A',
          'classes.h'   => 'A',
          'main.cc'     => 'A',
        },
        'files' => {
          'classes.cc'  => '1111111111111111111111111111111111111111',
          'classes.h'   => '2222222222222222222222222222222222222222',
          'main.cc'     => '3333333333333333333333333333333333333333',
        }
      }
    }
  );
  $output->push($job);
  select_ok($OUTFILE, 'SELECT * FROM modules', 3);
}

sub numeric_autoincrement_pk : Tests {
  ok(Analizo::Batch::Output::DB::_numeric_autoinc_pk('dbi:SQLite:file.sqlite3') =~ /AUTOINCREMENT/);
  ok(Analizo::Batch::Output::DB::_numeric_autoinc_pk('dbi:Pg:dbname=analizo') =~ /SERIAL/);
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

sub select_ok($$$) {
  my ($db, $query, $count) = @_;
  my $dbh = DBI->connect("dbi:SQLite:$db");
  my $rows = $dbh->selectall_arrayref($query);
  my $row_count = scalar(@$rows);
  is($row_count, $count, "[$query] returned $row_count rows instead of exactly $count");
}

sub select_one_ok($$) {
  my ($db, $query) = @_;
  select_ok($db, $query, 1);
}

use Cwd 'abs_path';
use File::Copy;
sub __debug_db($) {
  my ($origdb) = @_;
  my $db = '/tmp/debug.sqlite3';
  system("rm -rf $db");
  copy($origdb, $db);
  system("x-terminal-emulator -e sqlite3 $db");
}

__PACKAGE__->runtests;

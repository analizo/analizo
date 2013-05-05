package t::Analizo::Batch::Job::Directories;
use strict;
use warnings;
use base qw(Test::Class);
use Test::More 'no_plan';

use t::Analizo::Test;

use Analizo::Batch::Job::Directories;
use Cwd;

sub constructor : Tests {
  my $job = __create_job('c');
  isa_ok($job, 'Analizo::Batch::Job::Directories');
  is($job->directory, 'c');
  is($job->id, 'c');
}

sub prepare_and_cleanup : Tests {
  my $job = __create_job('c');
  on_dir(
    't/samples/hello_world/',
    sub {
      my $oldcwd = getcwd;
      $job->prepare();
      my $newcwd = getcwd();
      $job->cleanup();

      ok($newcwd ne $oldcwd, 'must change dir in prepare()');
      ok($oldcwd eq getcwd, 'must change back dir in cleanup()');
    }
  )
}

sub __create_job {
  my @args = @_;
  on_dir('t/samples/hello_world', sub { new Analizo::Batch::Job::Directories(@args) });
}

__PACKAGE__->runtests;


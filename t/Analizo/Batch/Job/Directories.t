package t::Analizo::Batch::Job::Directories;
use strict;
use warnings;
use parent qw(Test::Analizo::Class);
use Test::More;
use Test::Analizo;

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
  on_dir('t/samples/hello_world', sub { Analizo::Batch::Job::Directories->new(@args) });
}

__PACKAGE__->runtests;


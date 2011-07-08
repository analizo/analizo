package Analizo::Batch::Job::Git::Test;
use strict;
use warnings;

use base 'Test::Class';
use Test::More;
use Test::Analizo;
use Cwd;

use Analizo::Batch::Job::Git;

my $TESTDIR = 'evolution';

my $MASTER = '8183eafad3a0f3eff6e8869f1bdbfd255e86825a'; # first commit id in sample
my $SOME_COMMIT = '0a06a6fcc2e7b4fe56d134e89d74ad028bb122ed'; # some commit in the middle of the history

sub constructor : Tests {
  isa_ok(__create(), 'Analizo::Batch::Job::Git');
}

sub constructor_with_arguments : Tests {
  my $id = $MASTER;
  my $job = __create($TESTDIR, $id);
  is($job->{directory}, $TESTDIR);
  is($job->id, $id);
}

sub prepare_and_cleanup : Tests {
  my $job = mock(__create($TESTDIR, $SOME_COMMIT));

  my @checkouts = ();
  $job->mock('git_checkout', sub { push @checkouts, $_[1]; } );
  my $oldcwd = getcwd();
  $job->prepare();
  my $newcwd = getcwd();
  $job->cleanup();

  ok($newcwd ne $oldcwd, 'prepare must change dir');
  ok(getcwd eq $oldcwd, 'cleanup must change cwd back');
  is_deeply(\@checkouts, [$SOME_COMMIT, $MASTER], 'cleanup must checkout given commit and go back to previous one');
}

sub git_checkout_should_actually_checkout : Tests {
  my $job = __create($TESTDIR, $SOME_COMMIT);
  my $getHEAD = sub {
    $job->git_HEAD();
  };
  my $master1 = on_dir($TESTDIR, $getHEAD);
  $job->prepare();
  my $commit = $job->git_HEAD;
  $job->cleanup();
  my $master2 = on_dir($TESTDIR, $getHEAD);

  is($commit, $SOME_COMMIT);
  is($master1, $master2);
  is($master2, $MASTER);
}

sub __create {
  my @args = @_;
  new Analizo::Batch::Job::Git(@args);
}

unpack_sample_git_repository(
  sub {
    my $cwd = getcwd;
    chdir tmpdir();
    __PACKAGE__->runtests;
    chdir $cwd;
  }
);

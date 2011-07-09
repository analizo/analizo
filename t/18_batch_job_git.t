package Analizo::Batch::Job::Git::Test;
use strict;
use warnings;

use base 'Test::Class';
use Test::More;
use Test::Analizo;
use Cwd;
use Test::MockObject;

use Analizo::Batch::Job::Git;
use Test::Analizo::Git;

my $TESTDIR = 'evolution';


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

sub points_to_batch : Tests {
  my $job = __create();
  $job->batch(42);
  is($job->batch, 42);
}

sub relevance : Tests {
  my $batch = new Test::MockObject();
  $batch->set_series('matches_filters', 1, 0, 1);
  my $job = __create();
  $job->batch($batch);

  is($job->relevant, 1);
  is($job->relevant, 0);
  is($job->relevant, 1);
}

sub changed_files : Tests {
  my $master = __create($TESTDIR, $MASTER);
  is_deeply($master->changed_files, ['input.cc']);

  my $some_commit = __create($TESTDIR, $SOME_COMMIT);
  is_deeply($some_commit->changed_files, ['prog.cc']);
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

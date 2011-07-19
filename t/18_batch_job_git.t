package Analizo::Batch::Job::Git::Test;
use strict;
use warnings;

use base 'Test::Class';
use Test::More;
use Test::Analizo;
use Cwd;
use Test::MockObject;
use Test::Analizo::Git;

use Analizo::Batch::Job::Git;
use Analizo::Batch::Git;

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
  is_deeply(\@checkouts, [$SOME_COMMIT, 'master'], 'cleanup must checkout given commit and go back to previous one');
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
  my $branch = on_dir($TESTDIR, sub { $job->git_current_branch() });

  is($commit, $SOME_COMMIT);
  is($master1, $master2);
  is($master2, $MASTER);
  is($branch, 'master');
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

sub previous_relevant : Tests {
  my $batch = __create_repo($TESTDIR);

  my $first = $batch->find($FIRST_COMMIT);
  is($first->previous_relevant, undef);

  my $master = $batch->find($MASTER);
  isa_ok($master->previous_relevant, 'Analizo::Batch::Job::Git');
  is($master->previous_relevant->id, '0a06a6fcc2e7b4fe56d134e89d74ad028bb122ed');

  my $commit = $batch->find('0a06a6fcc2e7b4fe56d134e89d74ad028bb122ed');
  isa_ok($commit->previous_relevant, 'Analizo::Batch::Job::Git');
  is($commit->previous_relevant->id, 'eb67c27055293e835049b58d7d73ce3664d3f90e');
}

sub previous_wanted : Tests {
  my $batch = __create_repo($TESTDIR);

  my $master = $batch->find($MASTER);
  is($master->previous_wanted, $master->previous_relevant);

  my $merge = $batch->find($MERGE_COMMIT);
  is($merge->previous_wanted, undef);
}

sub metadata : Tests {
  my $repo = __create_repo($TESTDIR);
  my $master = $repo->find($MASTER);

  my $metadata = $master->metadata();
  metadata_ok($metadata, 'author_name', 'Antonio Terceiro', 'author name');
  metadata_ok($metadata, 'author_email', 'terceiro@softwarelivre.org', 'author email');
  metadata_ok($metadata, 'author_date', 1297788040, 'author date'); # UNIX timestamp for [Tue Feb 15 13:40:40 2011 -0300]
  metadata_ok($metadata, 'previous_commit_id', '0a06a6fcc2e7b4fe56d134e89d74ad028bb122ed', 'previous commit');

  my $first = $repo->find($FIRST_COMMIT);
  metadata_ok($first->metadata, 'previous_commit_id', undef, 'unexisting commit id');
}

sub merge_and_first_commit_detection : Tests {
  my $master = __create($TESTDIR, $MASTER);
  ok(!$master->is_merge);
  ok(!$master->is_first_commit);

  my $first = __create($TESTDIR, $FIRST_COMMIT);
  ok($first->is_first_commit);

  my $merge = __create($TESTDIR, $MERGE_COMMIT);
  ok($merge->is_merge);
}

sub metadata_ok {
  my ($metadata,$field,$value,$testname) = @_;
  if (is(ref($metadata), 'ARRAY', $testname))  {
    my @entries = grep { $_->[0] eq $field } @$metadata;
    my $entry = $entries[0];
    if (is(ref($entry), 'ARRAY', $testname)) {
      is($entry->[1], $value, $testname);
    }
  }
}

sub __create {
  my @args = @_;
  new Analizo::Batch::Job::Git(@args);
}

sub __create_repo {
  my @args = @_;
  my $repo = new Analizo::Batch::Git(@args);
  $repo->initialize();
  return $repo;
}

unpack_sample_git_repository(
  sub {
    my $cwd = getcwd;
    chdir tmpdir();
    __PACKAGE__->runtests;
    chdir $cwd;
  }
);

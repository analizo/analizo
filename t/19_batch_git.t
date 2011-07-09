package Analizo::Batch::Git::Test;
use strict;
use warnings;
use base qw( Test::Class );
use Test::More;
use Test::Analizo;
use Test::Analizo::Git;
use Cwd 'abs_path';
use Test::MockObject;

use Analizo::Batch::Git;

my $TESTDIR = tmpdir() . '/evolution';

sub constructor : Tests {
  isa_ok(new Analizo::Batch::Git, 'Analizo::Batch::Git');
}

sub create_with_and_without_args : Tests {
  # without arg: git repo is the current directory
  my $batch1 = on_dir($TESTDIR, sub { __create(); });
  # with arg: git repo is in the directory named by the argument
  my $batch2 = __create($TESTDIR);

  is($batch1->directory, $batch2->directory);
  is($batch1->directory, abs_path($TESTDIR));

  my $job1 = $batch1->next();
  my $job2 = $batch2->next();
  is($job1->id, $job2->id);
  is($job1->id, $MASTER);
  is($job1->batch, $batch1);
  is($job2->batch, $batch2);
}

sub traverse_repository : Tests {
  my $batch = __create($TESTDIR);
  $batch->filters(new Analizo::LanguageFilter('cpp'));
  my %jobs = ();
  while (my $job = $batch->next()) {
    $jobs{$job->id} = 1;
  }
  ok($jobs{$MASTER}, 'master commit must be listed');
  ok($jobs{$SOME_COMMIT}, 'intermediate relevant commit must be listed');
  ok(!$jobs{$IRRELEVANT_COMMIT}, 'intermediate IRRELEVANT commit must not be listed');
}

use Analizo::LanguageFilter;
sub filters : Tests {
  my $job = new Test::MockObject();
  my $batch = __create();
  $batch->filters(new Analizo::LanguageFilter('c'));

  $job->mock('changed_files', sub { ['test.c'] });
  ok($batch->matches_filters($job), 'test.c');

  $job->mock('changed_files', sub { ['test.h', 'README'] });
  ok($batch->matches_filters($job), 'test.h');

  $job->mock('changed_files', sub { ['README'] });
  ok(!$batch->matches_filters($job), 'only README');
}

sub __create {
  my @args = @_;
  new Analizo::Batch::Git(@args);
}

unpack_sample_git_repository(
  sub {
    __PACKAGE__->runtests;
  }
)

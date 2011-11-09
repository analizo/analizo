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

sub count : Tests {
  my $batch = __create($TESTDIR);
  $batch->initialize();
  is($batch->count, 11);
}

sub default_filter : Tests {
  my $batch = __create($TESTDIR);
  while (my $job = $batch->next()) {
    my @files = grep { /\.(cc|h)$/ } keys(%{$job->changed_files});
    ok(scalar(@files) > 0, sprintf("must not analyze commit containing only (%s)", join(',', keys(%{$job->changed_files}))));
  }
}

sub find_commit : Tests {
  my $batch = __create($TESTDIR);
  $batch->initialize();

  is($batch->find('abczyx1234'), undef);

  my $master = $batch->find($MASTER);
  isa_ok($master, 'Analizo::Batch::Job::Git');
  is($master->id, $MASTER);
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

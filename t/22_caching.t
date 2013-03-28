package Analizo::Batch::Output::Caching::Tests;

use strict;
use warnings;
use base qw( Test::Class );
use Test::More;
use Test::Analizo;
use Test::MockModule;

use Analizo::Batch::Job::Directories;

local $ENV{'ANALIZO_CACHE'} = tmpdir();

sub teardown : Test(teardown) {
  system('rm', '-rf', $ENV{ANALIZO_CACHE});
}

sub cache_of_model_and_metrics : Tests {
  # first time
  my $job1 = new_job();
  $job1->execute();

  my $model_result = 'cache used';
  my $AnalizoExtractor = new Test::MockModule('Analizo::Extractor');
  $AnalizoExtractor->mock('process', sub { $model_result = 'cache not used!' });
  my $metrics_result = 'cache used';
  my $AnalizoMetrics = new Test::MockModule('Analizo::Metrics');
  $AnalizoMetrics->mock('data', sub { $metrics_result = 'cache not used!'});

  $job1->execute();

  is($model_result, 'cache used');
  is($metrics_result, 'cache used');
}

sub tree_id : Tests {
  my $job = new_job();
  my $id;
  on_dir(
    't/samples/tree_id',
    sub {
      $id = $job->tree_id('.');
    }
  );
  is($id, '82df8dce26abfcf4e489a6d0201d2ef481591831'); # calculated by hand
}

sub new_job {
  my $job = new Analizo::Batch::Job::Directories('t/samples/animals/cpp');
  return $job;
}

__PACKAGE__->runtests();

package Analizo::Batch::Output::Caching::Tests;

use strict;
use warnings;
use base qw( Test::Class );
use Test::More;
use Test::Analizo;
use Test::MockModule;
use File::Temp qw/ tempdir /;

use Analizo::Batch::Job::Directories;

$ENV{ANALIZO_CACHE} = tempdir(CLEANUP => 1);

sub cache_of_model_and_metrics : Tests {
  # first time
  my $job1 = new_job();
  $job1->execute();
  my $model1 = $job1->model;
  my $metrics1 = $job1->metrics;

  my $job2 = new_job();
  $job2->execute();
  my $model2 = $job2->model;
  my $metrics2 = $job2->metrics;

  # FIXME these are needed because empty hashes are not coming back from the
  # cache. Maybe this is a bug in the CHI cache driver
  $model2->{calls}->{'Animal::name()'} = {};
  $model2->{modules}->{'Mammal'} = {};

  is_deeply($model2, $model1, 'cached model is the same');
  is_deeply($metrics2, $metrics1, 'cached metrics is the same ');
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

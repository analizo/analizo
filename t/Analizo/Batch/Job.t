package t::Analizo::Batch::Job;
use strict;
use warnings;
use base qw(t::Analizo::Test::Class);
use Test::More 'no_plan';
use Test::MockObject::Extends;
use Test::MockModule;

use t::Analizo::Test;

use Analizo::Batch::Job;

sub constructor : Tests {
  isa_ok(new Analizo::Batch::Job, 'Analizo::Batch::Job');
}

my @EXPOSED_INTERFACE = qw(
  prepare
  execute
  cleanup
  parallel_prepare
  parallel_cleanup

  model
  metrics

  id
  directory
  metadata
  metadata_hashref
);

sub exposed_interface : Tests {
  can_ok('Analizo::Batch::Job', @EXPOSED_INTERFACE);
}

sub before_execute : Tests {
  my $job = new Analizo::Batch::Job;
  is($job->model, undef);
  is($job->metrics, undef);
}

sub execute : Tests {
  # model and metrics must be set
  my $job = new Test::MockObject::Extends(new Analizo::Batch::Job);

  my $prepared = 0; $job->mock('prepare', sub { $prepared = 1; });
  my $cleaned  = 0; $job->mock('cleanup', sub { die('cleanup() must be called after prepare()') unless $prepared; $cleaned  = 1; });

  my $metrics_data_called = undef;
  my $MetricsMock = new Test::MockModule('Analizo::Metrics');
  $MetricsMock->mock('data', sub { $metrics_data_called = 1; });

  my $sloccount_extractor_called = undef;
  my $SloccountExtractorMock = new Test::MockModule('Analizo::Extractor::Sloccount');
  $SloccountExtractorMock->mock('process', sub { $sloccount_extractor_called = 1 });

  on_dir(
    't/samples/hello_world/c',
    sub {
      $job->execute();
    }
  );
  ok($prepared && $cleaned, 'must call prepare() and cleanup() on execute');
  isa_ok($job->model, 'Analizo::Model');
  isa_ok($job->metrics, 'Analizo::Metrics');
  isa_ok($job->metrics->model, 'Analizo::Model');
  ok($metrics_data_called, 'must force metrics calculation during execute() bu calling $metrics->data()');
  ok($sloccount_extractor_called, 'must call SloccountExtractor to extract ELOC data');
}

sub empty_metadata_by_default : Tests {
  my $job = new Analizo::Batch::Job;
  is_deeply($job->metadata(), []);
}

sub metadata_as_hash : Tests {
  my $job = mock(new Analizo::Batch::Job);
  $job->mock('metadata', sub { [['field1', 'value1'],['field2', 'value2']]});
  my $hash = $job->metadata_hashref();
  is($hash->{field1}, 'value1');
  is($hash->{field2}, 'value2');
  is(scalar(keys(%$hash)), 2);
}

sub project_name : Tests {
  my $job = new Analizo::Batch::Job;

  $job->directory('myproject');
  is($job->project_name, 'myproject');

  $job->directory('/path/to/my/project');
  is($job->project_name, 'project');
}

sub pass_filters_to_extractor : Tests {
  my @filters = ();
  my $extractor = mock(bless {}, 'Analizo::Extractor');
  $extractor->mock(
    'process',
    sub { my ($self) = @_; push @filters, @{$self->filters}; }
  );

  my $module = new Test::MockModule('Analizo::Extractor');
  $module->mock(
    'load',
    sub { $extractor; }
  );

  my $job = new Analizo::Batch::Job;
  my $cpp_filter = new Analizo::LanguageFilter('cpp');
  $job->filters($cpp_filter);

  on_dir(
    't/samples/hello_world/cpp/',
    sub {
      $job->execute();
    }
  );
  is_deeply(\@filters, [$cpp_filter], 'must pass filters to extractor object');
}

use File::Temp qw/ tempdir /;

$ENV{ANALIZO_CACHE} = tempdir(CLEANUP => 1);

sub cache_of_model_and_metrics : Tests {
  # first time
  my $job1 = new Analizo::Batch::Job;
  on_dir(
    't/samples/animals/cpp',
    sub {
      $job1->execute();
    });
  my $model1 = $job1->model;
  my $metrics1 = $job1->metrics;

  my $model_result = 'cache used';
  my $AnalizoExtractor = new Test::MockModule('Analizo::Extractor');
  $AnalizoExtractor->mock('process', sub { $model_result = 'cache not used!' });
  my $metrics_result = 'cache used';
  my $AnalizoMetrics = new Test::MockModule('Analizo::Metrics');
  $AnalizoMetrics->mock('data', sub { $metrics_result = 'cache not used!'});

  my $job2 = new Analizo::Batch::Job;
  on_dir(
    't/samples/animals/cpp',
    sub {
      $job2->execute();
    });
  my $model2 = $job2->model;
  my $metrics2 = $job2->metrics;

  # FIXME these are needed because empty hashes are not coming back from the
  # cache. Maybe this is a bug in the CHI cache driver
  $model2->{calls}->{'Animal::name()'} = {};
  $model2->{modules}->{'Mammal'} = {};
  $model2->{security_metrics}->{'Memory leak'} = {};
  $model2->{security_metrics}->{'Dead assignment'} = {};
  $model2->{security_metrics}->{'Division by zero'} = {};
  $model2->{security_metrics}->{'Dereference of null pointer'} = {};
  $model2->{security_metrics}->{'Assigned value is garbage or undefined'} = {};
  $model2->{security_metrics}->{'Return of address to stack-allocated memory'} = {};

  is($model_result, 'cache used', 'use cache for model');
  is($metrics_result, 'cache used', 'use cache for metrics');

  is_deeply($model2, $model1, 'cached model is the same');
  is_deeply($metrics2, $metrics1, 'cached metrics is the same ');
}

sub tree_id : Tests {
  my $job = new Analizo::Batch::Job;
  my $id;
  on_dir(
    't/samples/tree_id',
    sub {
      $id = $job->tree_id('.');
    }
  );
  is($id, '82df8dce26abfcf4e489a6d0201d2ef481591831'); # calculated by hand
}

__PACKAGE__->runtests;

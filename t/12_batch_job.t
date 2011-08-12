package BatchJobTests;
use strict;
use warnings;
use base qw(Test::Class);
use Test::More 'no_plan';
use Test::MockObject::Extends;
use Test::MockModule;

use Test::Analizo;

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

BatchJobTests->runtests;

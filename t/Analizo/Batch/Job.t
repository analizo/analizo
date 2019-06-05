package t::Analizo::Batch::Job;
use strict;
use warnings;
use parent qw(Test::Analizo::Class);
use Test::More;
use Test::MockObject::Extends;
use Test::MockModule;
use File::Path qw(remove_tree);

use Test::Analizo;

use Analizo::Batch::Job;

sub constructor : Tests {
  isa_ok(Analizo::Batch::Job->new, 'Analizo::Batch::Job');
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
  my $job = Analizo::Batch::Job->new;
  is($job->model, undef);
  is($job->metrics, undef);
}

sub execute : Tests {
  # model and metrics must be set
  my $job = Test::MockObject::Extends->new(Analizo::Batch::Job->new);

  my $prepared = 0; $job->mock('prepare', sub { $prepared = 1; });
  my $cleaned  = 0; $job->mock('cleanup', sub { die('cleanup() must be called after prepare()') unless $prepared; $cleaned  = 1; });

  my $metrics_data_called = undef;
  my $MetricsMock = Test::MockModule->new('Analizo::Metrics');
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
  my $job = Analizo::Batch::Job->new;
  is_deeply($job->metadata(), []);
}

sub metadata_as_hash : Tests {
  my $job = mock(Analizo::Batch::Job->new);
  $job->mock('metadata', sub { [['field1', 'value1'],['field2', 'value2']]});
  my $hash = $job->metadata_hashref();
  is($hash->{field1}, 'value1');
  is($hash->{field2}, 'value2');
  is(scalar(keys(%$hash)), 2);
}

sub project_name : Tests {
  my $job = Analizo::Batch::Job->new;

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

  my $module = Test::MockModule->new('Analizo::Extractor');
  $module->mock(
    'load',
    sub { $extractor; }
  );

  my $job = Analizo::Batch::Job->new;
  my $cpp_filter = Analizo::LanguageFilter->new('cpp');
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
  my $job1 = Analizo::Batch::Job->new;
  on_dir(
    't/samples/animals/cpp',
    sub {
      $job1->execute();
    });
  my $model1 = $job1->model;
  my $metrics1 = $job1->metrics;

  my $model_result = 'cache used';
  my $AnalizoExtractor = Test::MockModule->new('Analizo::Extractor');
  $AnalizoExtractor->mock('process', sub { $model_result = 'cache not used!' });
  my $metrics_result = 'cache used';
  my $AnalizoMetrics = Test::MockModule->new('Analizo::Metrics');
  $AnalizoMetrics->mock('data', sub { $metrics_result = 'cache not used!' });

  # second time
  my $job2 = Analizo::Batch::Job->new;
  on_dir(
    't/samples/animals/cpp',
    sub {
      $job2->execute();
    });
  my $model2 = $job2->model;
  my $metrics2 = $job2->metrics;

  $model2->{calls}->{'Animal::name()'} = {};
  $model2->{calls}->{'Mammal::~Mammal()'} = {};

  is($model_result, 'cache used', 'use cache for model');
  is($metrics_result, 'cache used', 'use cache for metrics');

  # FIXME commenting failing test only in order to release a new version
  # but we need to fix it ASAP (issue #77)
  is_deeply($model2, $model1, 'cached model is the same');

  is_deeply($metrics2, $metrics1, 'cached metrics is the same ');
}

sub stores_cache_on_distinct_dirs_for_each_version : Tests {
  my $FileSpec = Test::MockModule->new('File::Spec');
  $FileSpec->mock('splitdir', sub { '/bypass_the_tempdir_creation_on_development_environment' });
  local $ENV{ANALIZO_CACHE} = undef;

  my $job = Analizo::Batch::Job->new;

  local $Analizo::VERSION = "1.1.1";
  like ($job->_get_cache_dir, qr/1\.1\.1$/);

  local $Analizo::VERSION = "2.2.2";
  like ($job->_get_cache_dir, qr/2\.2\.2$/);
}

sub invalidates_cache_after_upgrade_version : Tests {
  my $FileSpec = Test::MockModule->new('File::Spec');
  $FileSpec->mock('splitdir', sub { '/bypass_the_tempdir_creation_on_development_environment' });
  local $ENV{ANALIZO_CACHE} = undef;

  local $Analizo::VERSION = "1.1.1";
  my $job_a = Analizo::Batch::Job->new;
  $job_a->cache->set('metrics', 'metrics values');
  ok ($job_a->cache->get('metrics'), 'metrics values sucessfully retrievied from the cache');

  my $job_b = Analizo::Batch::Job->new;
  ok ($job_b->cache->get('metrics'), 'values for metrics found on cache for same analizo version');

  local $Analizo::VERSION = "2.2.2";
  my $job_c = Analizo::Batch::Job->new;
  ok (!$job_c->cache->get('metrics'), 'values for metrics should not found for other analizo version');

  # remove all cache directories created in this testcase
  foreach ($job_a->_get_cache_dir, $job_b->_get_cache_dir, $job_c->_get_cache_dir) {
    remove_tree $_ if -e $_;
  }
}

sub tree_id : Tests {
  my $job = Analizo::Batch::Job->new;
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

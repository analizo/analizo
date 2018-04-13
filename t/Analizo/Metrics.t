package t::Analizo::Metrics;
use strict;
use warnings;
use base qw(Test::Analizo::Class);
use Test::More;
use Analizo::Metrics;
use Analizo::Model;

use vars qw($model $metrics);

sub setup : Test(setup) {
  $model = Analizo::Model->new;
  $metrics = Analizo::Metrics->new(model => $model);
}

sub constructor : Tests {
  isa_ok($metrics, 'Analizo::Metrics');
}

sub model : Tests {
  can_ok($metrics, 'model');
  is($metrics->model, $model);
}

sub sample_modules_for_report {
  # first module
  $model->declare_module('mod1');
  $model->declare_function('mod1' , 'f1a');
  $model->declare_function('mod1' , 'f1b');
  $model->declare_variable('mod1' , 'v1');
  $model->add_variable_use($_, 'v1') for qw(f1a f1b);

  # second module
  $model->declare_module('mod2');
  $model->declare_function('mod2', 'f2');
  $model->add_call('f2', 'f1a');
  $model->add_call('f2', 'f1b');
}

sub report : Tests {
  sample_modules_for_report();
  $model->declare_total_eloc(38);

  my $output = $metrics->report;

  $output =~ m/total_modules: ([0-9]+)/;
  my $modules = $1;
  is($modules, 2, 'reporting number of classes in YAML stream');
  ok($output =~ /_module: mod1/, 'reporting module 1');
  ok($output =~ /_module: mod2/, 'reporting module 2');
  ok($output =~ /total_eloc: 38/, 'reporting total eloc');
}

sub report_global_only : Tests {
  sample_modules_for_report();

  my $output = $metrics->report_global_metrics_only;

  ok($output =~ /total_modules: 2/, 'reporting number of classes (it is global)');
  ok($output !~ /_module: mod1/, 'not reporting module 1 details');
  ok($output !~ /_module: mod2/, 'not reporting module 2 details');
}

sub report_without_modules_at_all : Tests {
  # if this call does not crash we are fine
  $metrics->report;
}

sub list_of_metrics : Tests {
  my %metrics = $metrics->list_of_metrics();
  cmp_ok(scalar(keys(%metrics)), '>', 0, 'must list metrics');
}

sub metrics_for : Tests {
  sample_modules_for_report();
  my $data = $metrics->metrics_for('mod1');
  is(ref($data), 'HASH');
  is($data->{_module}, 'mod1');
}

__PACKAGE__->runtests;


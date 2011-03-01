package MetricsTests;
use strict;
use base qw(Test::Class);
use Test::More;
use Analizo::Metrics;
use Analizo::Model;

use vars qw($model $metrics);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $metrics = new Analizo::Metrics(model => $model);
}

sub constructor : Tests {
  isa_ok($metrics, 'Analizo::Metrics');
}

sub model : Tests {
  can_ok($metrics, 'model');
  is($metrics->model, $model);
}


#Average Method LOC
sub average_method_lines_of_code_with_no_functions_at_all : Tests {
  is($metrics->average_method_lines_of_code(0, 0), 0);
}

#Methods Per Abstract Class
sub methods_per_abstract_class : Tests {
  is($metrics->methods_per_abstract_class, 0, 'no abstract classes');

  $model->declare_module('A');
  $model->add_abstract_class('A');
  is($metrics->methods_per_abstract_class, 0, 'no methods on abstract classes');

  $model->declare_function('A', 'functionA');
  is($metrics->methods_per_abstract_class, 1, 'one methods on one abstract classes');

  $model->declare_module('B');
  $model->add_abstract_class('B');
  $model->declare_function('B', 'functionB');
  is($metrics->methods_per_abstract_class, 1, 'one methods on one abstract classes');
}

sub total_eloc : Tests {
  $model->declare_total_eloc(28);
  is($metrics->total_eloc, 28, 'calculating total eloc');
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

  ok($output =~ /total_modules: 2/, 'reporting number of classes in YAML stream');
  ok($output =~ /_module: mod1/, 'reporting module 1');
  ok($output =~ /_module: mod2/, 'reporting module 2');
  ok($output =~ /total_eloc: 38/, 'reporting total eloc');
}

sub report_global_only : Tests {
  sample_modules_for_report();

  $metrics->report_global_metrics_only(1);
  my $output = $metrics->report;

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

sub metrics_of_module : Tests {
  $model->declare_function('mod1', 'f1');
  $model->add_protection('f1', 'public');
  $model->add_loc('f1', 10);

  $model->declare_function('mod1', 'f2');
  $model->add_loc('f2', 10);
  my %result = $metrics->metrics_of_module('mod1');

  is($result{'_module'}, 'mod1');
  is($result{'nom'}, 2);
  is($result{'noa'}, 0);
  is($result{'npm'}, 1);
  is($result{'amloc'}, 10);
}

MetricsTests->runtests;


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

sub coupling : Tests {
  $model->declare_function('mod1', 'f1');
  $model->declare_function('mod2', 'f2');

  is($metrics->coupling('mod1'), 0, 'no coupling');
  $model->add_call('f1', 'f1');
  is($metrics->coupling('mod1'), 0, 'calling itself does not count as coupling');

  $model->add_call('f1', 'f2');
  is($metrics->coupling('mod1'), 1, 'calling a single other module');

  $model->declare_function('mod3', 'f3');
  $model->add_call('f1', 'f3');
  is($metrics->coupling('mod1'), 2, 'calling two function in distinct modules');

  $model->declare_function('mod3', 'f3a');
  $model->add_call('f1', 'f3a');
  is($metrics->coupling('mod1'), 2, 'calling two different functions in the same module');
}

sub lcom4 : Tests {
  $model->declare_function('mod1', $_) for qw(f1 f2);
  is($metrics->lcom4('mod1'), 2, 'two unrelated functions');

  $model->declare_variable('mod1', 'v1');
  $model->add_variable_use($_, 'v1') for qw(f1 f2);
  is($metrics->lcom4('mod1'), 1, 'two cohesive functions');

  $model->declare_function('mod1', 'f3');
  $model->declare_variable('mod1', 'v2');
  $model->add_variable_use('f3', 'v2');
  is($metrics->lcom4('mod1'), 2, 'two different usage components');

  $model->declare_function('mod1', 'f4');
  $model->declare_variable('mod1', 'v3');
  $model->add_variable_use('f4', 'v3');
  is($metrics->lcom4('mod1'), 3, 'three different usage components');
}

sub lcom4_2 : Tests {
  $model->declare_function('mod1', 'f1');
  $model->declare_function('mod1', 'f2');
  $model->declare_function('mod1', 'f3');
  $model->declare_variable('mod1', 'v1');
  $model->add_call('f1', 'f2');
  $model->add_call('f1', 'f3', 'indirect');
  $model->add_variable_use('f2', 'v1');
  is($metrics->lcom4('mod1'), '1', 'different types of connections');
}

sub lcom4_3 : Tests {
  $model->declare_function('mod1', 'f1');
  $model->declare_function('mod1', 'f2');
  $model->declare_function('mod1', 'f3');
  $model->add_call('f1', 'f2');

  # f1 and f3 calls the same function in another module
  $model->add_call('f1', 'ff');
  $model->add_call('f3', 'ff');

  is($metrics->lcom4('mod1'), 2, 'functions outside the module don\'t count for LCOM4');
}

sub number_of_functions : Tests {
  is($metrics->number_of_functions('mod1'), 0, 'empty modules have no functions');

  $model->declare_function("mod1", 'f1');
  is($metrics->number_of_functions('mod1'), 1, 'module with just one function has number of functions = 1');

  $model->declare_function('mod1', 'f2');
  is($metrics->number_of_functions('mod1'), 2, 'module with just two functions has number of functions = 2');
}

sub public_functions : Tests {
  is($metrics->public_functions('mod1'), 0, 'empty modules have 0 public functions');

  $model->declare_function('mod1', 'mod1::f1');
  $model->add_protection('mod1::f1', 'public');
  is($metrics->public_functions('mod1'), 1, 'one public function added');

  $model->declare_function('mod1', 'mod1::f2');
  $model->add_protection('mod1::f2', 'public');
  is($metrics->public_functions('mod1'), 2, 'another public function added');
}

sub public_variables : Tests {
  is($metrics->public_variables('mod1'), 0, 'empty modules have 0 public variables');

  $model->declare_variable('mod1', 'mod1::f1');
  $model->add_protection('mod1::f1', 'public');
  is($metrics->public_variables('mod1'), 1, 'one public variable added');

  $model->declare_variable('mod1', 'mod1::f2');
  $model->add_protection('mod1::f2', 'public');
  is($metrics->public_variables('mod1'), 2, 'another public variable added');
}

sub loc : Tests {
  my @result = $metrics->loc('mod1');
  is($result[0], 0, 'empty module has 0 LOC');
  is($result[1], 0, 'empty module has max LOC 0');

  $model->declare_function('mod1', 'mod1::f1');
  $model->add_loc('mod1::f1', 10);
  @result = $metrics->loc('mod1');
  is($result[0], 10, 'one module, with 10 LOC');
  is($result[1], 10, 'one module, with 10 LOC, makes max LOC = 10');

  $model->declare_function('mod1', 'mod1::f2');
  $model->add_loc('mod1::f2', 20);
  @result = $metrics->loc('mod1');
  is($result[0], 30, 'adding another module with 20 LOC makes the total equal 30');
  is($result[1], 20, 'adding another module with 20 LOC makes the max LOC equal 20');
}

sub amz_size_with_no_functions_at_all : Tests {
  is($metrics->amz_size(0, 0), 0);
}

sub dit : Tests {
  $model->add_inheritance('Level1', 'Level2');
  $model->add_inheritance('Level2', 'Level3');
  is($metrics->dit('Level1'), 2, 'DIT = 2');
  is($metrics->dit('Level2'), 1, 'DIT = 1');
  is($metrics->dit('Level3'), 0, 'DIT = 0');
}

sub dit_with_multiple_inheritance : Tests {
  $model->add_inheritance('Level1', 'Level2A');
  $model->add_inheritance('Level1', 'Level2B');
  $model->add_inheritance('Level2B', 'Level3B');
  is($metrics->dit('Level1'), 2, 'with multiple inheritance take the larger DIT between the parents');
}

sub noc : Tests {
  $model->declare_module('A');
  $model->declare_module('B');
  $model->declare_module('C');
  $model->declare_module('D');

  is($metrics->noc('A'), 0, 'no children module A');
  is($metrics->noc('B'), 0, 'no children module B');
  is($metrics->noc('C'), 0, 'no children module C');

  $model->add_inheritance('B', 'A');
  is($metrics->noc('A'), 1, 'one child module A');
  is($metrics->noc('B'), 0, 'no children module B');

  $model->add_inheritance('C', 'A');

  is($metrics->noc('A'), 2, 'two children module A');
  is($metrics->noc('C'), 0, 'no children module C');

  $model->add_inheritance('D', 'C');
  is($metrics->noc('A'), 2, 'two children module A');
  is($metrics->noc('C'), 1, 'one child module C');
  is($metrics->noc('D'), 0, 'no children module D');
}

sub rfc : Tests {
  $model->declare_module('module');
  is($metrics->rfc('module'), 0, "no functions declared on the module");

  $model->declare_function('module', 'function');
  is($metrics->rfc('module'), 1, "one function declared on the module");

  $model->declare_function('module', 'another_function');
  is($metrics->rfc('module'), 2, "two functions declared on the module");

  $model->declare_function('module2', 'function2');
  $model->add_call('function', 'function2');
  is($metrics->rfc('module'), 3, "two functions and one call declared on the module");

  $model->declare_function('module2', 'function3');
  $model->add_call('another_function', 'function3');
  is($metrics->rfc('module'), 4, "two functions and two calls declared on the module");

}

sub report : Tests {
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

  my $output = $metrics->report;

  ok($output =~ /number_of_modules: 2/, 'reporting number of modules in YAML stream');
  ok($output =~ /_module: mod1/, 'reporting module 1');
  ok($output =~ /_module: mod2/, 'reporting module 2');
}

sub report_without_modules_at_all : Tests {
  # if this call does not crash we are fine
  $metrics->report;
}

sub discard_external_symbols_for_coupling : Tests {
  $model->declare_function('mod1', 'f1');
  $model->declare_function('mod2', 'f2');

  $model->add_call('f1', 'f2');
  $model->add_call('f1', 'external_function');
  is($metrics->coupling('mod1'), 1, 'calling a external function');
}

sub list_of_metrics : Tests {
  my %metrics = $metrics->list_of_metrics();
  cmp_ok(scalar(keys(%metrics)), '>', 0, 'must list metrics');
}

MetricsTests->runtests;

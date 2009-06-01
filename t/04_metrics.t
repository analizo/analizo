package MetricsTests;
use strict;
use base qw(Test::Class);
use Test::More;
use Egypt::Metrics;
use Egypt::Model;

use vars qw($model $metrics);

sub setup : Test(setup) {
  $model = new Egypt::Model;
  $metrics = new Egypt::Metrics(model => $model);
}

sub constructor : Tests {
  isa_ok($metrics, 'Egypt::Metrics');
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

sub lcom1 : Tests {
  $model->declare_function('mod1', 'f1');
  $model->declare_function('mod1', 'f2');

  is($metrics->lcom1('mod1'), 1, 'a pair of unrelated functions');

  $model->declare_variable('mod1', 'var1');
  $model->add_variable_use('f1', 'var1');
  $model->add_variable_use('f2', 'var1');
  is($metrics->lcom1('mod1'), 0, 'two cohesive functions');

  $model->declare_function('mod1', 'f3');
  $model->declare_variable('mod1', 'v2');
  $model->add_call('f3', 'v2');
  is($metrics->lcom1('mod1'), 1, 'a third function unrelated to the others');

  $model->declare_function('mod1', 'f4');
  $model->declare_variable('mod1', 'v3');
  $model->add_call('f4', 'v3');
  is($metrics->lcom1('mod1'), 4, 'yet another function unrelated to the previous ones');

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

sub interface_size : Tests {
  is($metrics->interface_size('mod1'), 0, 'empty modules have interface size 0');

  $model->declare_function("mod1", 'f1');
  is($metrics->interface_size('mod1'), 1, 'module with just one function has interface size = 1');

  $model->declare_function('mod1', 'f2');
  is($metrics->interface_size('mod1'), 2, 'module with just one function has interfaces size = 2');
}

sub report : Tests {
  # first module
  $model->declare_function('mod1' , 'f1a');
  $model->declare_function('mod1' , 'f1b');
  $model->declare_variable('mod1' , 'v1');
  $model->add_variable_use($_, 'v1') for qw(f1a f1b);

  # second module
  $model->declare_function('mod2', 'f2');
  $model->add_call('f2', 'f1a');
  $model->add_call('f2', 'f1b');

  is($metrics->report,
'---
average_coupling: 0.5
average_coupling_times_lcom1: 0
average_coupling_times_lcom4: 0.5
average_lcom1: 0
average_lcom4: 1
number_of_functions: 3
number_of_modules: 2
---
_module: mod1
coupling: 0
coupling_times_lcom1: 0
coupling_times_lcom4: 0
interface_size: 2
lcom1: 0
lcom4: 1
---
_module: mod2
coupling: 1
coupling_times_lcom1: 0
coupling_times_lcom4: 1
interface_size: 1
lcom1: 0
lcom4: 1
',
    'must report metrics as a YAML stream');
}

sub discard_external_symbols_for_coupling : Tests {
  $model->declare_function('mod1', 'f1');
  $model->declare_function('mod2', 'f2');

  $model->add_call('f1', 'f2');
  $model->add_call('f1', 'external_function');
  is($metrics->coupling('mod1'), 1, 'calling a external function');
}

MetricsTests->runtests;

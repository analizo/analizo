package MetricAccTests;
use base qw(Test::Class);
use Test::More 'no_plan'; # REMOVE THE 'no_plan'

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::AfferentConnections;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $acc);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $acc = new Analizo::Metric::AfferentConnections(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::AfferentConnections');
}

sub has_model : Tests {
  is($acc->model, $model);
}

sub calculate : Tests {
  $model->declare_module('A');
  $model->declare_function('A', 'fA');
  $model->declare_function('A', 'fA2');

  $model->declare_module('B');
  $model->declare_function('B', 'fB');
  $model->declare_variable('B', 'vB');

  $model->declare_module('C');
  $model->declare_function('C', 'fC');
  $model->declare_variable('C', 'vC');

  is($acc->calculate('A'), 0, 'no acc module A');
   is($acc->calculate('B'), 0, 'no acc module B');
  is($acc->calculate('C'), 0, 'no acc module C');

  $model->add_call('fA', 'fB');
  is($acc->calculate('A'), 0, 'no calls to a module');
  is($acc->calculate('B'), 1, 'calling function of another module');

  $model->add_variable_use('fA', 'vB');
  is($acc->calculate('A'), 0, 'no calls to a module');
  is($acc->calculate('B'), 1, 'calling variable of another module');

  $model->add_call('fA', 'fC');
  is($acc->calculate('A'), 0, 'no calls to a module');
  is($acc->calculate('C'), 1, 'calling variable of another module');

  $model->add_call('fA', 'fA2');
  is($acc->calculate('A'), 0, 'calling itself does not count as acc');

  $model->add_variable_use('fB', 'vC');
  is($acc->calculate('C'), 2, 'calling module twice');
}

sub calculate_with_inheritance : Tests {
  $model->declare_module('Mother');
  $model->declare_module('Child1');
  $model->declare_module('Child2');
  $model->declare_module('Grandchild1');
  $model->declare_module('Grandchild2');

  $model->add_inheritance('Child1', 'Mother');
  is($acc->calculate('Mother'), 1, 'inheritance counts as acc to superclass');
  is($acc->calculate('Child1'), 0, 'inheritance does not count as acc to child');

  $model->add_inheritance('Child2', 'Mother');
  is($acc->calculate('Mother'), 2, 'multiple inheritance counts as acc');
  is($acc->calculate('Child2'), 0, 'inheritance does not count as acc to another child');

  $model->add_inheritance('Grandchild1', 'Child1');
  is($acc->calculate('Grandchild1'), 0, 'grandchilds acc is not affected');
  is($acc->calculate('Child1'), 1, 'grandchild extending a child counts');
  is($acc->calculate('Mother'), 3, 'the deeper the tree, the biggest acc');

  $model->add_inheritance('Grandchild2', 'Child2');
  is($acc->calculate('Grandchild2'), 0, 'grandchilds acc is not affected');
  is($acc->calculate('Child2'), 1, 'grandchild extending a child counts');
  is($acc->calculate('Mother'), 4, 'the deeper the tree, the biggest acc');
}

MetricAccTests->runtests;


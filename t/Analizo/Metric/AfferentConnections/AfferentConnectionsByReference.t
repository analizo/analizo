package t::Analizo::Metric::AfferentConnections::AfferentConnectionsByReference;
use strict;
use warnings;
use parent qw(Test::Analizo::Class);
use Test::More;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::AfferentConnections;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $acc);

sub setup : Test(setup) {
  $model = Analizo::Model->new;
  $acc = Analizo::Metric::AfferentConnections->new(model => $model);

  $model->declare_module('A', 'A.c');
  $model->declare_function('A', 'fA');
  $model->declare_function('A', 'fA2');

  $model->declare_module('B', 'B.c');
  $model->declare_function('B', 'fB');
  $model->declare_variable('B', 'vB');

  $model->declare_module('C', 'C.c');
  $model->declare_function('C', 'fC');
  $model->declare_variable('C', 'vC');
}

sub use_package : Tests {
  use_ok('Analizo::Metric::AfferentConnections');
}

sub has_model : Tests {
  is($acc->model, $model);
}

sub description : Tests {
  is($acc->description, 'Afferent Connections per Class (used to calculate COF - Coupling Factor)');
}

sub calculate_calling_function_of_another_module : Tests {
  $model->add_call('fA', 'fB');
  is($acc->calculate('A'), 0, 'no calls to a module');
  is($acc->calculate('B'), 1, 'calling function of another module');
}

sub calculate_adding_variable_of_another_module : Tests {
  $model->add_call('fA', 'fB');
  $model->add_variable_use('fA', 'vB');
  is($acc->calculate('A'), 0, 'no calls to a module');
  is($acc->calculate('B'), 1, 'adding variable of another module');
}

sub calculate_calling_variable_of_another_module : Tests {
  $model->add_call('fA', 'fC');
  is($acc->calculate('A'), 0, 'no calls to a module');
  is($acc->calculate('C'), 1, 'calling variable of another module');
}

sub calculate_calling_itself_does_not_count : Tests {
  $model->add_call('fA', 'fA2');
  is($acc->calculate('A'), 0, 'calling itself does not count as acc');
}

sub calculate_calling_module_twice : Tests {
  $model->add_call('fA', 'fB');
  $model->add_variable_use('fA', 'vB');
  $model->add_call('fA', 'fC');
  $model->add_call('fA', 'fA2');
  $model->add_variable_use('fB', 'vC');
  is($acc->calculate('C'), 2, 'calling module twice');
}

sub calculate_empty_acc : Tests {
  is($acc->calculate('A'), 0, 'no acc module A');
  is($acc->calculate('B'), 0, 'no acc module B');
  is($acc->calculate('C'), 0, 'no acc module C');
}

__PACKAGE__->runtests;

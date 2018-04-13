package t::Analizo::Metric::LackOfCohesionOfMethods;
use strict;
use warnings;
use base qw(Test::Analizo::Class);
use Test::More;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::LackOfCohesionOfMethods;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $lcom4);

sub setup : Test(setup) {
  $model = Analizo::Model->new;
  $lcom4 = Analizo::Metric::LackOfCohesionOfMethods->new(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::LackOfCohesionOfMethods');
}

sub has_model : Tests {
  is($lcom4->model, $model);
}

sub description : Tests {
  is($lcom4->description, "Lack of Cohesion of Methods");
}

sub calculate : Tests {
  $model->declare_function('mod1', $_) for qw(f1 f2);
  is($lcom4->calculate('mod1'), 2, 'two unrelated functions');

  $model->declare_variable('mod1', 'v1');
  $model->add_variable_use($_, 'v1') for qw(f1 f2);
  is($lcom4->calculate('mod1'), 1, 'two cohesive functions');

  $model->declare_function('mod1', 'f3');
  $model->declare_variable('mod1', 'v2');
  $model->add_variable_use('f3', 'v2');
  is($lcom4->calculate('mod1'), 2, 'two different usage components');

  $model->declare_function('mod1', 'f4');
  $model->declare_variable('mod1', 'v3');
  $model->add_variable_use('f4', 'v3');
  is($lcom4->calculate('mod1'), 3, 'three different usage components');
}

sub calculate_2 : Tests {
  $model->declare_function('mod1', 'f1');
  $model->declare_function('mod1', 'f2');
  $model->declare_function('mod1', 'f3');
  $model->declare_variable('mod1', 'v1');
  $model->add_call('f1', 'f2');
  $model->add_call('f1', 'f3', 'indirect');
  $model->add_variable_use('f2', 'v1');
  is($lcom4->calculate('mod1'), '1', 'different types of connections');
}

sub calculate_3 : Tests {
  $model->declare_function('mod1', 'f1');
  $model->declare_function('mod1', 'f2');
  $model->declare_function('mod1', 'f3');
  $model->add_call('f1', 'f2');

  # f1 and f3 calls the same function in another module
  $model->add_call('f1', 'ff');
  $model->add_call('f3', 'ff');

  is($lcom4->calculate('mod1'), 2, 'functions outside the module don\'t count for LCOM4');
}


__PACKAGE__->runtests;


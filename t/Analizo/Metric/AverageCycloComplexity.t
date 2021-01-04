package t::Analizo::Metric::AverageCycloComplexity;
use strict;
use warnings;
use parent qw(Test::Analizo::Class);
use Test::More;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::AverageCycloComplexity;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $accm);

sub setup : Test(setup) {
  $model = Analizo::Model->new;
  $accm = Analizo::Metric::AverageCycloComplexity->new(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::AverageCycloComplexity');
}

sub has_model : Tests {
  is($accm->model, $model);
}

sub description : Tests {
  is($accm->description, "Average Cyclomatic Complexity per Method");
}

sub calculate : Tests {
  $model->declare_module('module');
  is($accm->calculate('module'), 0, 'no function');

  $model->declare_function('module', 'module::function');
  $model->add_conditional_paths('module::function', 2);
  is($accm->calculate('module'), 3, 'one function with two conditional paths');

  $model->declare_function('module', 'module::function1');
  $model->add_conditional_paths('module::function1', 1);
  $model->declare_function('module', 'module::function2');
  $model->add_conditional_paths('module::function2', 3);
  is($accm->calculate('module'), 3, 'two function with three average cyclomatic complexity per method');
}

__PACKAGE__->runtests;


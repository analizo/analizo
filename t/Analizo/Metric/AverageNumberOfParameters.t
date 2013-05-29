package t::Analizo::Metric::AverageNumberOfParameters;
use base qw(Test::Class);
use Test::More 'no_plan'; # REMOVE THE 'no_plan'

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::AverageNumberOfParameters;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $anpm);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $anpm = new Analizo::Metric::AverageNumberOfParameters(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::AverageNumberOfParameters');
}

sub has_model : Tests {
  is($anpm->model, $model);
}

sub description : Tests {
  is($anpm->description, "Average Number of Parameters per Method");
}

sub calculate : Tests {
  $model->declare_module('module');
  is($anpm->calculate('module'), 0, 'no parameters declared');

  $model->declare_function('module', 'module::function');
  $model->add_parameters('module::function', 1);
  is($anpm->calculate('module'), 1, 'one function with one parameter');
}


__PACKAGE__->runtests;


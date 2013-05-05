package MetricRfcTests;
use base qw(Test::Class);
use Test::More 'no_plan'; # REMOVE THE 'no_plan'

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::ResponseForClass;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $rfc);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $rfc = new Analizo::Metric::ResponseForClass(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::ResponseForClass');
}

sub has_model : Tests {
  is($rfc->model, $model);
}

sub description : Tests {
  is($rfc->description, "Response for a Class");
}

sub calculate : Tests {
  $model->declare_module('module');
  is($rfc->calculate('module'), 0, "no functions declared on the module");

  $model->declare_function('module', 'function');
  is($rfc->calculate('module'), 1, "one function declared on the module");

  $model->declare_function('module', 'another_function');
  is($rfc->calculate('module'), 2, "two functions declared on the module");

  $model->declare_function('module2', 'function2');
  $model->add_call('function', 'function2');
  is($rfc->calculate('module'), 3, "two functions and one call declared on the module");

  $model->declare_function('module2', 'function3');
  $model->add_call('another_function', 'function3');
  is($rfc->calculate('module'), 4, "two functions and two calls declared on the module");
}

__PACKAGE__->runtests;


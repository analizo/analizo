package MetricNpmTests;
use base qw(Test::Class);
use Test::More 'no_plan'; # REMOVE THE 'no_plan'

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::NumberOfPublicMethods;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $npm);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $npm = new Analizo::Metric::NumberOfPublicMethods(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::NumberOfPublicMethods');
}

sub has_model : Tests {
  is($npm->model, $model);
}

sub description : Tests {
  is($npm->description, "Number of Public Methods");
}

sub calculate : Tests {
  is($npm->calculate('mod1'), 0, 'empty modules have 0 public functions');

  $model->declare_function('mod1', 'mod1::f1');
  $model->add_protection('mod1::f1', 'public');
  is($npm->calculate('mod1'), 1, 'one public function added');

  $model->declare_function('mod1', 'mod1::f2');
  $model->add_protection('mod1::f2', 'public');
  is($npm->calculate('mod1'), 2, 'another public function added');

  $model->declare_function('mod1', 'mod1::f3');
  is($npm->calculate('mod1'), 2, 'not public function added');
}

MetricNpmTests->runtests;


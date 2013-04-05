package MetricMmlocTests;
use base qw(Test::Class);
use Test::More 'no_plan'; # REMOVE THE 'no_plan'

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::AverageMethodLinesOfCode;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $amloc);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $amloc = new Analizo::Metric::AverageMethodLinesOfCode(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::AverageMethodLinesOfCode');
}

sub has_model : Tests {
  is($amloc->model, $model);
}

sub description : Tests {
  is($amloc->description, "Average Method Lines of Code");
}

sub calculate : Tests {
  is($amloc->calculate('mod1'), 0, 'empty module has max loc 0');

  $model->declare_function('mod1', 'mod1::f1');
  $model->add_loc('mod1::f1', 10);
  is($amloc->calculate('mod1'), 10, 'one module, with 10 loc, makes avg loc = 10');

  $model->declare_function('mod1', 'mod1::f2');
  $model->add_loc('mod1::f2', 6);
  is($amloc->calculate('mod1'), 8, 'adding module with 5 loc makes the avg continue 10');
}

MetricMmlocTests->runtests;


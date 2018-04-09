package t::Analizo::Metric::CouplingBetweenObjects;
use base qw(Test::Class);
use Test::More;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::CouplingBetweenObjects;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $cbo);

sub setup : Test(setup) {
  $model = Analizo::Model->new;
  $cbo = Analizo::Metric::CouplingBetweenObjects->new(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::CouplingBetweenObjects');
}

sub has_model : Tests {
  is($cbo->model, $model);
}

sub description : Tests {
  is($cbo->description, "Coupling Between Objects");
}

sub calculate : Tests {
  $model->declare_function('mod1', 'f1');
  $model->declare_function('mod2', 'f2');

  is($cbo->calculate('mod1'), 0, 'no cbo');
  $model->add_call('f1', 'f1');
  is($cbo->calculate('mod1'), 0, 'calling itself does not count as cbo');

  $model->add_call('f1', 'f2');
  is($cbo->calculate('mod1'), 1, 'calling a single other module');

  $model->declare_function('mod3', 'f3');
  $model->add_call('f1', 'f3');
  is($cbo->calculate('mod1'), 2, 'calling two function in distinct modules');

  $model->declare_function('mod3', 'f3a');
  $model->add_call('f1', 'f3a');
  is($cbo->calculate('mod1'), 2, 'calling two different functions in the same module');
}

sub discard_external_symbols_for_calculate : Tests {
  $model->declare_function('mod1', 'f1');
  $model->declare_function('mod2', 'f2');

  $model->add_call('f1', 'f2');
  $model->add_call('f1', 'external_function');
  is($cbo->calculate('mod1'), 1, 'calling a external function');
}

__PACKAGE__->runtests;


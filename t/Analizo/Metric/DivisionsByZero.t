package t::Analizo::Metric::DivisionsByZero;
use base qw(Test::Class);
use Test::More;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::DivisionsByZero;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $dbz);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $dbz = new Analizo::Metric::DivisionsByZero(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::DivisionsByZero');
}

sub has_model : Tests {
  is($dbz->model, $model);
}

sub description : Tests {
  is($dbz->description, "Divisions by zero");
}

sub calculate : Tests {
  is($dbz->calculate('file'), 0, 'file without divisions by zero');

  $model->declare_security_metrics('Division by zero', 'file', 2);
  is($dbz->calculate('file'), 2, 'one module, with 2 divisions by zero');
}

__PACKAGE__->runtests;


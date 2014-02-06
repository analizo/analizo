package t::Analizo::Metric::AssignedUndefinedValue;
use base qw(Test::Class);
use Test::More tests => 5;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::AssignedUndefinedValue;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $auv);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $auv = new Analizo::Metric::AssignedUndefinedValue(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::AssignedUndefinedValue');
}

sub has_model : Tests {
  is($auv->model, $model);
}

sub description : Tests {
  is($auv->description, "Assigned value is garbage or undefined");
}

sub calculate : Tests {
  is($auv->calculate('file'), 0, 'file without assigned undefined value');

  $model->declare_security_metrics('Assigned value is garbage or undefined', 'file', 2);
  is($auv->calculate('file'), 2, 'one module, with 2 assigned undefined value');
}

__PACKAGE__->runtests;


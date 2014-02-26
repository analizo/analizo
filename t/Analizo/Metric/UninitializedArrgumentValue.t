package t::Analizo::Metric::UninitializedArgumentValue;
use base qw(Test::Class);
use Test::More tests => 5;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::UninitializedArgumentValue;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $uav);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $uav = new Analizo::Metric::UninitializedArgumentValue(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::UninitializedArgumentValue');
}

sub has_model : Tests {
  is($uav->model, $model);
}

sub description : Tests {
  is($uav->description, "Uninitialized argument value");
}

sub calculate : Tests {
  is($uav->calculate('file'), 0, 'file without uninitialized argument value');

  $model->declare_security_metrics('Uninitialized argument value', 'file', 2);
  is($uav->calculate('file'), 2, 'one module, with 2 uninitialized argument value');
}

__PACKAGE__->runtests;


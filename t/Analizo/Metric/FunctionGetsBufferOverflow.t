package t::Analizo::Metric::FunctionGetsBufferOverflow;
use base qw(Test::Class);
use Test::More tests => 5;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::FunctionGetsBufferOverflow;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $fgbo);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $fgbo = new Analizo::Metric::FunctionGetsBufferOverflow(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::FunctionGetsBufferOverflow');
}

sub has_model : Tests {
  is($fgbo->model, $model);
}

sub description : Tests {
  is($fgbo->description, "Potential buffer overflow in call to \'gets\'");
}

sub calculate : Tests {
  is($fgbo->calculate('file'), 0, 'file without offset free');

  $model->declare_security_metrics("Potential buffer overflow in call to \'gets\'", 'file', 2);
  is($fgbo->calculate('file'), 2, 'one module, with 2 offset free');
}

__PACKAGE__->runtests;


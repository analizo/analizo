package t::Analizo::Metric::ReturnOfStackVariableAddress;
use base qw(Test::Class);
use Test::More;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::ReturnOfStackVariableAddress;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $rsva);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $rsva = new Analizo::Metric::ReturnOfStackVariableAddress(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::ReturnOfStackVariableAddress');
}

sub has_model : Tests {
  is($rsva->model, $model);
}

sub description : Tests {
  is($rsva->description, "Return of stack variable address");
}

sub calculate : Tests {
  is($rsva->calculate('file'), 0, 'file without return of stack variable address');

  $model->declare_security_metrics('Return of address to stack-allocated memory', 'file', 2);
  is($rsva->calculate('file'), 2, 'one module, with 2 return of stack variable address');
}

__PACKAGE__->runtests;


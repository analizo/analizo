package t::Analizo::Metric::DereferenceOfUndefinedPointerValue;
use base qw(Test::Class);
use Test::More;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::DereferenceOfUndefinedPointerValue;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $dupv);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $dupv = new Analizo::Metric::DereferenceOfUndefinedPointerValue(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::DereferenceOfUndefinedPointerValue');
}

sub has_model : Tests {
  is($dupv->model, $model);
}

sub description : Tests {
  is($dupv->description, 'Dereference of undefined pointer value');
}

sub calculate : Tests {
  is($dupv->calculate('file'), 0, 'file without dereference of undefined pointer value');

  $model->declare_security_metrics('Dereference of undefined pointer value', 'file', 2);
  is($dupv->calculate('file'), 2, 'one module, with 2 dereference of undefined pointer value');
}

__PACKAGE__->runtests;


package t::Analizo::Metric::DereferenceOfNullPointer;
use base qw(Test::Class);
use Test::More;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::DereferenceOfNullPointer;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $dnp);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $dnp = new Analizo::Metric::DereferenceOfNullPointer(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::DereferenceOfNullPointer');
}

sub has_model : Tests {
  is($dnp->model, $model);
}

sub description : Tests {
  is($dnp->description, "Dereference of null pointer");
}

sub calculate : Tests {
  is($dnp->calculate('file'), 0, 'file without dereference of null pointer');

  $model->declare_security_metrics('Dereference of null pointer', 'file', 2);
  is($dnp->calculate('file'), 2, 'one module, with 2 dereference of null pointer');
}

__PACKAGE__->runtests;


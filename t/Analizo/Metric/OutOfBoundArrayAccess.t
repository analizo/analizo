package t::Analizo::Metric::OutOfBoundArrayAccess;
use base qw(Test::Class);
use Test::More;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::OutOfBoundArrayAccess;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $obaa);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $obaa = new Analizo::Metric::OutOfBoundArrayAccess(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::OutOfBoundArrayAccess');
}

sub has_model : Tests {
  is($obaa->model, $model);
}

sub description : Tests {
  is($obaa->description, "Out-of-bound array access");
}

sub calculate : Tests {
  is($obaa->calculate('file'), 0, 'file without out-of-bound array access');

  $model->declare_security_metrics('Out-of-bound array access', 'file', 2);
  is($obaa->calculate('file'), 2, 'one module, with 2 out-of-bound array access');
}

__PACKAGE__->runtests;


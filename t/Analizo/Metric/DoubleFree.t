package t::Analizo::Metric::DoubleFree;
use base qw(Test::Class);
use Test::More;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::DoubleFree;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $df);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $df = new Analizo::Metric::DoubleFree(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::DoubleFree');
}

sub has_model : Tests {
  is($df->model, $model);
}

sub description : Tests {
  is($df->description, "Double free");
}

sub calculate : Tests {
  is($df->calculate('file'), 0, 'file without double free');

  $model->declare_security_metrics('Double free', 'file', 2);
  is($df->calculate('file'), 2, 'one module, with 2 double free');
}

__PACKAGE__->runtests;


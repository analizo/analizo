package t::Analizo::Metric::BadFree;
use base qw(Test::Class);
use Test::More;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::BadFree;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $bf);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $bf = new Analizo::Metric::BadFree(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::BadFree');
}

sub has_model : Tests {
  is($bf->model, $model);
}

sub description : Tests {
  is($bf->description, "Bad free");
}

sub calculate : Tests {
  is($bf->calculate('file'), 0, 'file without bad free');

  $model->declare_security_metrics('Bad free', 'file', 2);
  is($bf->calculate('file'), 2, 'one module, with 2 bad free');
}

__PACKAGE__->runtests;


package t::Analizo::Metric::UseAfterFree;
use base qw(Test::Class);
use Test::More;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::UseAfterFree;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $uaf);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $uaf = new Analizo::Metric::UseAfterFree(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::UseAfterFree');
}

sub has_model : Tests {
  is($uaf->model, $model);
}

sub description : Tests {
  is($uaf->description, "Use-after-free");
}

sub calculate : Tests {
  is($uaf->calculate('file'), 0, 'file without use-after-free');

  $model->declare_security_metrics('Use-after-free', 'file', 2);
  is($uaf->calculate('file'), 2, 'one module, with 2 use-after-free');
}

__PACKAGE__->runtests;


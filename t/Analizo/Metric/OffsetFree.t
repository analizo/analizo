package t::Analizo::Metric::OffsetFree;
use base qw(Test::Class);
use Test::More;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::OffsetFree;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $osf);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $osf = new Analizo::Metric::OffsetFree(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::OffsetFree');
}

sub has_model : Tests {
  is($osf->model, $model);
}

sub description : Tests {
  is($osf->description, "Offset free");
}

sub calculate : Tests {
  is($osf->calculate('file'), 0, 'file without offset free');

  $model->declare_security_metrics('Offset free', 'file', 2);
  is($osf->calculate('file'), 2, 'one module, with 2 offset free');
}

__PACKAGE__->runtests;


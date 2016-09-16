package t::Analizo::Metric::ArgumentNull;
use base qw(Test::Class);
use Test::More;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::ArgumentNull;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $an);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $an = new Analizo::Metric::ArgumentNull(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::ArgumentNull');
}

sub has_model : Tests {
  is($an->model, $model);
}

sub description : Tests {
  is($an->description, "Argument with \'nonnull\' attribute passed null");
}

sub calculate : Tests {
  is($an->calculate('file'), 0, 'file without argument null');

  $model->declare_security_metrics("Argument with \'nonnull\' attribute passed null", 'file', 2);
  is($an->calculate('file'), 2, 'one module, with 2 argument null');
}

__PACKAGE__->runtests;


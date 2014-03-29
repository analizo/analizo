package t::Analizo::GlobalMetric::TotalAbstractClasses;
use base qw(Test::Class);
use Test::More;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::GlobalMetric::TotalAbstractClasses;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $tac);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $tac = new Analizo::GlobalMetric::TotalAbstractClasses(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::GlobalMetric::TotalAbstractClasses');
}

sub has_model : Tests {
  is($tac->model, $model);
}

sub description : Tests {
  is($tac->description, "Total Abstract Classes");
}

sub calculate : Tests {
  is($tac->calculate('mod'), 0, 'no abstract classes declared');

  $model->add_abstract_class('abstract1');
  is($tac->calculate('mod'), 1, 'one abstract classes declared');

  $model->add_abstract_class('abstract2');
  is($tac->calculate('mod'), 2, 'two abstract classes declared');
}

__PACKAGE__->runtests;


package t::Analizo::Metric::NumberOfAttributes;
use base qw(Test::Class);
use Test::More 'no_plan'; # REMOVE THE 'no_plan'

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::NumberOfAttributes;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $noa);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $noa = new Analizo::Metric::NumberOfAttributes(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::NumberOfAttributes');
}

sub has_model : Tests {
  is($noa->model, $model);
}

sub description : Tests {
  is($noa->description, "Number of Attributes");
}

sub calculate : Tests {
  is($noa->calculate('module1'), 0, 'empty modules have no attributes');

  $model->declare_variable('module1', 'attr1');
  is($noa->calculate('module1'), 1, 'module with one defined attribute');

  $model->declare_variable('module1', 'attr2');
  is($noa->calculate('module1'), 2, 'module with two defined attribute');
}


__PACKAGE__->runtests;


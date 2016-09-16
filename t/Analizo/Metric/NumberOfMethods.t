package t::Analizo::Metric::NumberOfMethods;
use base qw(Test::Class);
use Test::More;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::NumberOfMethods;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $nom);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $nom = new Analizo::Metric::NumberOfMethods(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::NumberOfMethods');
}

sub has_model : Tests {
  is($nom->model, $model);
}

sub description : Tests {
  is($nom->description, "Number of Methods");
}

sub calculate : Tests {
  is($nom->calculate('mod1'), 0, 'empty modules have no functions');

  $model->declare_function("mod1", 'f1');
  is($nom->calculate('mod1'), 1, 'module with just one function has number of functions = 1');

  $model->declare_function('mod1', 'f2');
  is($nom->calculate('mod1'), 2, 'module with just two functions has number of functions = 2');
}

__PACKAGE__->runtests;


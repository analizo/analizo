package t::Analizo::Metric::MaximumMethodLinesOfCode;
use base qw(Test::Class);
use Test::More;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::MaximumMethodLinesOfCode;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $mmloc);

sub setup : Test(setup) {
  $model = Analizo::Model->new;
  $mmloc = Analizo::Metric::MaximumMethodLinesOfCode->new(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::MaximumMethodLinesOfCode');
}

sub has_model : Tests {
  is($mmloc->model, $model);
}

sub description : Tests {
  is($mmloc->description, "Max Method LOC");
}

sub calculate : Tests {
  is($mmloc->calculate('mod1'), 0, 'empty module has max loc 0');

  $model->declare_function('mod1', 'mod1::f1');
  $model->add_loc('mod1::f1', 10);
  is($mmloc->calculate('mod1'), 10, 'one module, with 10 loc, makes max loc = 10');

  $model->declare_function('mod1', 'mod1::f2');
  $model->add_loc('mod1::f2', 5);
  is($mmloc->calculate('mod1'), 10, 'adding module with 5 loc makes the max continue 10');
}

__PACKAGE__->runtests;


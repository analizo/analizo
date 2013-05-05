package MetricLocTests;
use base qw(Test::Class);
use Test::More 'no_plan'; # REMOVE THE 'no_plan'

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::LinesOfCode;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $loc);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $loc = new Analizo::Metric::LinesOfCode(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::LinesOfCode');
}

sub has_model : Tests {
  is($loc->model, $model);
}

sub description : Tests {
  is($loc->description, "Lines of Code");
}

sub calculate : Tests {
  is($loc->calculate('mod1'), 0, 'empty module has 0 loc');

  $model->declare_function('mod1', 'mod1::f1');
  $model->add_loc('mod1::f1', 10);
  is($loc->calculate('mod1'), 10, 'one module, with 10 loc');

  $model->declare_function('mod1', 'mod1::f2');
  $model->add_loc('mod1::f2', 20);
  is($loc->calculate('mod1'), 30, 'adding another module with 20 loc makes the total equal 30');
}

__PACKAGE__->runtests;


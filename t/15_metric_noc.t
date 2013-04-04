package MetricNocTests;
use base qw(Test::Class);
use Test::More 'no_plan'; # REMOVE THE 'no_plan'

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::NumberOfChildren;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $noc);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $noc = new Analizo::Metric::NumberOfChildren(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::NumberOfChildren');
}

sub has_model : Tests {
  is($noc->model, $model);
}

sub description : Tests{
  is($noc->description, "Number of Children");
}

sub calculate : Tests {
  $model->declare_module('A');
  $model->declare_module('B');
  $model->declare_module('C');
  $model->declare_module('D');

  is($noc->calculate('A'), 0, 'no children module A');
  is($noc->calculate('B'), 0, 'no children module B');
  is($noc->calculate('C'), 0, 'no children module C');

  $model->add_inheritance('B', 'A');
  is($noc->calculate('A'), 1, 'one child module A');
  is($noc->calculate('B'), 0, 'no children module B');

  $model->add_inheritance('C', 'A');

  is($noc->calculate('A'), 2, 'two children module A');
  is($noc->calculate('C'), 0, 'no children module C');

  $model->add_inheritance('D', 'C');
  is($noc->calculate('A'), 2, 'two children module A');
  is($noc->calculate('C'), 1, 'one child module C');
  is($noc->calculate('D'), 0, 'no children module D');
}


MetricNocTests->runtests;


package t::Analizo::Metric::DeadAssignment;
use base qw(Test::Class);
use Test::More tests => 5;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::DeadAssignment;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $da);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $da = new Analizo::Metric::DeadAssignment(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::DeadAssignment');
}

sub has_model : Tests {
  is($da->model, $model);
}

sub description : Tests {
  is($da->description, "Dead assignment");
}

sub calculate : Tests {
  is($da->calculate('file'), 0, 'file without dead assignment');

  $model->declare_dead_assignment('file', 2);
  is($da->calculate('file'), 2, 'one module, with 2 dead assignment');
}

__PACKAGE__->runtests;


package t::Analizo::GlobalMetric::TotalEloc;
use base qw(Test::Class);
use Test::More 'no_plan'; # REMOVE THE 'no_plan'

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::GlobalMetric::TotalEloc;


use vars qw($model $eloc);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $eloc = new Analizo::GlobalMetric::TotalEloc(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::GlobalMetric::TotalEloc');
}

sub has_model : Tests {
  is($eloc->model, $model);
}

sub description : Tests {
  is($eloc->description, "Total Effective Lines of Code");
}

sub calculate : Tests {
  is($eloc->calculate, 0, 'no eloc declared');

  $model->declare_total_eloc(10);
  is($eloc->calculate, 10, 'eloc declared as 10');
}

__PACKAGE__->runtests;


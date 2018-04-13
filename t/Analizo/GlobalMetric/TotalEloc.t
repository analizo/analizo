package t::Analizo::GlobalMetric::TotalEloc;
use strict;
use warnings;
use base qw(Test::Analizo::Class);
use Test::More;
use File::Basename;

use Analizo::Model;
use Analizo::GlobalMetric::TotalEloc;

use vars qw($model $eloc);

sub setup : Test(setup) {
  $model = Analizo::Model->new;
  $eloc = Analizo::GlobalMetric::TotalEloc->new(model => $model);
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

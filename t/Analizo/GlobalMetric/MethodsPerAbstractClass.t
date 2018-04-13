package t::Analizo::GlobalMetric::MethodsPerAbstractClass;
use strict;
use warnings;
use base qw(Test::Analizo::Class);
use Test::More;
use File::Basename;

use Analizo::Model;
use Analizo::GlobalMetric::MethodsPerAbstractClass;

use vars qw($model $mac);

sub setup : Test(setup) {
  $model = Analizo::Model->new;
  $mac = Analizo::GlobalMetric::MethodsPerAbstractClass->new(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::GlobalMetric::MethodsPerAbstractClass');
}

sub has_model : Tests {
  is($mac->model, $model);
}

sub description : Tests {
  is($mac->description, "Methods per Abstract Class");
}

sub calculate : Tests {
  is($mac->calculate, 0, 'no abstract classes');

  $model->declare_module('A');
  $model->add_abstract_class('A');
  is($mac->calculate, 0, 'no methods on abstract classes');

  $model->declare_function('A', 'functionA');
  is($mac->calculate, 1, 'one methods on one abstract classes');

  $model->declare_module('B');
  $model->add_abstract_class('B');
  $model->declare_function('B', 'functionB');
  is($mac->calculate, 1, 'one methods on one abstract classes');
}

__PACKAGE__->runtests;


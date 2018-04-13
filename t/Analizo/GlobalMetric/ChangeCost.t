package t::Analizo::GlobalMetric::ChangeCost;
use strict;
use warnings;
use base qw(Test::Analizo::Class);
use Test::More;
use Analizo::Model;
use vars qw($model $metric);

BEGIN {
  use_ok 'Analizo::GlobalMetric::ChangeCost';
}

sub setup : Test(setup) {
  $model = Analizo::Model->new;
  $metric = Analizo::GlobalMetric::ChangeCost->new(model => $model);
}

sub has_model : Tests {
  is($metric->model, $model);
}

sub description : Tests {
  is($metric->description, "Change Cost");
}

sub calculate_for_an_empty_callgraph : Tests {
  is($metric->calculate, undef, 'no change cost');
}

sub calculate : Tests {
  $model->declare_module('a', 'src/a.c');
  $model->declare_module('b', 'src/b.c');
  $model->declare_module('c', 'src/c.c');
  $model->declare_module('d', 'src/d.c');
  $model->declare_module('e', 'src/e.c');
  $model->declare_module('f', 'src/f.c');
  $model->declare_function('a', 'a::name()');
  $model->declare_function('b', 'b::name()');
  $model->declare_function('c', 'c::name()');
  $model->declare_function('d', 'd::name()');
  $model->declare_function('e', 'e::name()');
  $model->declare_function('f', 'f::name()');
  $model->add_call('a::name()', 'b::name()');
  $model->add_call('a::name()', 'c::name()');
  $model->add_call('b::name()', 'd::name()');
  $model->add_call('c::name()', 'e::name()');
  $model->add_call('e::name()', 'f::name()');
  is($metric->calculate, 0.42);
}

__PACKAGE__->runtests;

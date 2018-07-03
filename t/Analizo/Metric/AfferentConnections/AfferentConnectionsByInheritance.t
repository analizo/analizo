package t::Analizo::Metric::AfferentConnections;
use strict;
use warnings;
use parent qw(Test::Analizo::Class);
use Test::More;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::AfferentConnections;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $acc);

sub setup : Test(setup) {
  $model = Analizo::Model->new;
  $acc = Analizo::Metric::AfferentConnections->new(model => $model);

  $model->declare_module('Mother', 'Mother.c');
  $model->declare_module('Child1', 'Child1.c');
  $model->declare_module('Child2', 'Child2.c');
  $model->declare_module('Grandchild1', 'Grandchild1.c');
  $model->declare_module('Grandchild2', 'Grandchild2.c');
}

sub use_package : Tests {
  use_ok('Analizo::Metric::AfferentConnections');
}

sub has_model : Tests {
  is($acc->model, $model);
}

sub description : Tests {
  is($acc->description, 'Afferent Connections per Class (used to calculate COF - Coupling Factor)');
}

sub calculate_first_degree_inheritance : Tests {
  $model->add_inheritance('Child1', 'Mother');
  is($acc->calculate('Mother'), 1, 'inheritance counts as acc to superclass');
  is($acc->calculate('Child1'), 0, 'inheritance does not count as acc to child');
}

sub calculate_multiple_childs : Tests {
  $model->add_inheritance('Child1', 'Mother');
  $model->add_inheritance('Child2', 'Mother');
  is($acc->calculate('Mother'), 2, 'multiple inheritance counts as acc');
  is($acc->calculate('Child2'), 0, 'inheritance does not count as acc to another child');
}

sub calculate_deeper_tree : Tests {
  $model->add_inheritance('Child1', 'Mother');
  $model->add_inheritance('Child2', 'Mother');
  $model->add_inheritance('Grandchild1', 'Child1');
  is($acc->calculate('Grandchild1'), 0, 'grandchilds acc is not affected');
  is($acc->calculate('Child1'), 1, 'grandchild extending a child counts');
  is($acc->calculate('Mother'), 3, 'the deeper the tree, the biggest acc');
}

sub calculate_deeper_tree_new_grandchild : Tests {
  $model->add_inheritance('Child1', 'Mother');
  $model->add_inheritance('Child2', 'Mother');
  $model->add_inheritance('Grandchild1', 'Child1');
  $model->add_inheritance('Grandchild2', 'Child2');

  is($acc->calculate('Grandchild2'), 0, 'grandchilds acc is not affected');
  is($acc->calculate('Child2'), 1, 'grandchild extending a child counts');
  is($acc->calculate('Mother'), 4, 'the deeper the tree, the biggest acc');
}

__PACKAGE__->runtests;

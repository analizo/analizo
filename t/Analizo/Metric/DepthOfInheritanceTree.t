package t::Analizo::Metric::DepthOfInheritanceTree;
use base qw(Test::Class);
use Test::More;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::DepthOfInheritanceTree;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $dit);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $dit = new Analizo::Metric::DepthOfInheritanceTree(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::DepthOfInheritanceTree');
}

sub has_model : Tests {
  is($dit->model, $model);
}

sub description : Tests {
  return "Depth of Inheritance Tree";
}

sub calculate : Tests {
  $model->add_inheritance('Level1', 'Level2');
  $model->add_inheritance('Level2', 'Level3');
  is($dit->calculate('Level1'), 2, 'DIT = 2');
  is($dit->calculate('Level2'), 1, 'DIT = 1');
  is($dit->calculate('Level3'), 0, 'DIT = 0');
}

sub calculate_with_multiple_inheritance : Tests {
  $model->add_inheritance('Level1', 'Level2A');
  $model->add_inheritance('Level1', 'Level2B');
  $model->add_inheritance('Level2B', 'Level3B');
  is($dit->calculate('Level1'), 2, 'with multiple inheritance take the larger DIT between the parents');
}


__PACKAGE__->runtests;


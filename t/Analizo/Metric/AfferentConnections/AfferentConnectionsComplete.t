package t::Analizo::Metric::AfferentConnections::AfferentConnectionsComplete;
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

  $model->declare_module('Friend', 'Friend.c');
  $model->declare_module('Child', 'Child.c');
  $model->declare_module('Mother', 'Mother.c');
  $model->declare_module('MotherSister', 'MotherSister.c');
  $model->declare_module('GrandMother', 'GrandMother.c');

  $model->declare_function('Friend', 'friendTalk');
  $model->declare_function('Child', 'childListen');
  $model->declare_function('GrandMother', 'grandMotherListen');

  $model->add_call('friendTalk', 'childListen');
  $model->add_call('friendTalk', 'grandMotherListen');

  $model->add_inheritance('Child', 'Mother');
  $model->add_inheritance('Mother', 'GrandMother');
  $model->add_inheritance('MotherSister', 'GrandMother');
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

sub calculate_inheritance_and_references : Tests {
  is($acc->calculate('GrandMother'), 4, 'deeper inheritance and reference counts as acc');
  is($acc->calculate('Child'), 1, 'calls counts as acc to child');
  is($acc->calculate('Mother'), 1, 'inheritance counts as acc to mother');
  is($acc->calculate('MotherSister'), 0, 'have no inheritance neither calls to mother sister');
  is($acc->calculate('Friend'), 0, 'have no inheritance neither calls to friend');
}

__PACKAGE__->runtests;

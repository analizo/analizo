package t::Analizo::Metric::StructuralComplexity;
use strict;
no strict 'subs';
use warnings;
use base qw(Test::Analizo::Class);
use Test::More;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::StructuralComplexity;
use Analizo::Metric::CouplingBetweenObjects;
use Analizo::Metric::LackOfCohesionOfMethods;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $sc $cbo $lcom4);

sub setup : Test(setup) {
  $model = Analizo::Model->new;
  $cbo = undef;
  $lcom4 = undef;
  $sc = Analizo::Metric::StructuralComplexity->new(model => $model, cbo => $cbo, lcom4 => $lcom4);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::StructuralComplexity');
}

sub has_model : Tests {
  is($sc->model, $model);
}

sub description : Tests {
  is($sc->description, "Structural Complexity");
}

sub sc_definition : Tests {
  no warnings;
  local *Analizo::Metric::LackOfCohesionOfMethods::calculate = sub { 2 };
  local *Analizo::Metric::CouplingBetweenObjects::calculate = sub { 3 };
  use warnings;
  $cbo = Analizo::Metric::CouplingBetweenObjects->new(model => $model);
  $lcom4 = Analizo::Metric::LackOfCohesionOfMethods->new(model => $model);
  $sc = Analizo::Metric::StructuralComplexity->new(model => $model, cbo => $cbo, lcom4 => $lcom4);
  is($sc->calculate('mod1'), 6);
}

sub sc_implementation : Tests {
  my $lcom4_called = undef;
  my $cbo_called = undef;
  no warnings;
  local *Analizo::Metric::LackOfCohesionOfMethods::calculate = sub { $lcom4_called = 1; return 2; };
  local *Analizo::Metric::CouplingBetweenObjects::calculate = sub { $cbo_called = 1; return 5; };
  use warnings;
  $cbo = Analizo::Metric::CouplingBetweenObjects->new(model => $model);
  $lcom4 = Analizo::Metric::LackOfCohesionOfMethods->new(model => $model);
  $sc = Analizo::Metric::StructuralComplexity->new(model => $model, cbo => $cbo, lcom4 => $lcom4);
  my $sc_value = $sc->calculate('mod1');
  ok($lcom4_called);
  ok($cbo_called);
  is($sc_value, 10);
}

__PACKAGE__->runtests;

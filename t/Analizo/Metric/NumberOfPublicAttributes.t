package MetricNpaTests;
use base qw(Test::Class);
use Test::More 'no_plan'; # REMOVE THE 'no_plan'

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::NumberOfPublicAttributes;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $npa);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $npa = new Analizo::Metric::NumberOfPublicAttributes(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::NumberOfPublicAttributes');
}

sub has_model : Tests {
  is($npa->model, $model);
}

sub description : Tests {
  is($npa->description, "Number of Public Attributes");
}

sub calculate : Tests {
  is($npa->calculate('mod1'), 0, 'empty modules have 0 public attributes');

  $model->declare_variable('mod1', 'mod1::a1');
  $model->add_protection('mod1::a1', 'public');
  is($npa->calculate('mod1'), 1, 'one public attribute added');

  $model->declare_variable('mod1', 'mod1::a2');
  $model->add_protection('mod1::a2', 'public');
  is($npa->calculate('mod1'), 2, 'another public attribute added');

  $model->declare_variable('mod1', 'mod1::a3');
  is($npa->calculate('mod1'), 2, 'not public attribute added');
}

MetricNpaTests->runtests;


package MetricsTests;
use strict;
use base qw(Test::Class);
use Test::More;
use Egypt::Metrics;
use Egypt::Model;

sub constructor : Tests {
  isa_ok(new Egypt::Metrics, 'Egypt::Metrics');
}

sub model : Tests {
  can_ok(new Egypt::Metrics, 'model');
  my $model = new Egypt::Model;
  is((new Egypt::Metrics(model => $model))->model, $model);
}

sub coupling : Tests {
  my $model = new Egypt::Model;
  $model->declare_function('mod1', 'f1');
  $model->declare_function('mod2', 'f2');
  my $metrics = new Egypt::Metrics(model => $model);

  is($metrics->coupling('mod1'), 0, 'no coupling');

  $model->add_call('f1', 'f2');
  is($metrics->coupling('mod1'), 1, 'calling a single other module');

  $model->declare_function('mod3', 'f3');
  $model->add_call('f1', 'f3');
  is($metrics->coupling('mod1'), 2, 'calling two function in distinct modules');

  $model->declare_function('mod3', 'f3a');
  $model->add_call('f1', 'f3a');
  is($metrics->coupling('mod1'), 2, 'calling two different functions in the same module');
}

sub lack_of_cohesion : Tests {
  my $model = new Egypt::Model;
  my $metrics = new Egypt::Metrics(model => $model);

  $model->declare_function('mod1', 'f1');
  $model->declare_function('mod1', 'f2');

  is($metrics->lack_of_cohesion('mod1'), 1, 'a pair of unrelated functions');

  $model->declare_variable('mod1', 'var1');
  $model->add_variable_use('f1', 'var1');
  $model->add_variable_use('f2', 'var1');
  is($metrics->lack_of_cohesion('mod1'), 0, 'two cohesive functions');

  $model->declare_function('mod1', 'f3');
  $model->declare_variable('mod1', 'v2');
  $model->add_call('f3', 'v2');
  is($metrics->lack_of_cohesion('mod1'), 2, 'a third function unrelated to the others');

  $model->declare_function('mod1', 'f4');
  $model->declare_variable('mod1', 'v3');
  $model->add_call('f4', 'v3');
  is($metrics->lack_of_cohesion('mod1'), 5, 'yet another function unrelated to the previous ones');

}


MetricsTests->runtests;

package t::Analizo::ModuleMetrics;
use strict;
use base qw(Test::Class);
use Test::More;

use Analizo::Model;
use Analizo::ModuleMetrics;

use vars qw($model $module_metrics );

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $module_metrics = new Analizo::ModuleMetrics(model => $model);
}

sub constructor : Tests {
  isa_ok($module_metrics, 'Analizo::ModuleMetrics');
}

sub list_of_metrics : Tests {
  my %metrics = $module_metrics->list();
  cmp_ok(scalar(keys(%metrics)), '>', 0, 'must list metrics');
}

sub metrics_of_module : Tests {
  $model->declare_function('mod1', 'f1');
  $model->add_protection('f1', 'public');
  $model->add_loc('f1', 10);

  $model->declare_function('mod1', 'f2');
  $model->add_loc('f2', 10);
  $model->declare_security_metrics('Division by zero', 'mod1', 2);
  $model->declare_security_metrics('Dead assignment', 'mod1', 2);
  $model->declare_security_metrics('Memory leak', 'mod1', 2);
  $model->declare_security_metrics('Dereference of null pointer', 'mod1', 2);
  $model->declare_security_metrics('Assigned value is garbage or undefined', 'mod1', 2);
  my $report = $module_metrics->report('mod1');

  is($report->{'_module'}, 'mod1');
  is($report->{'nom'}, 2);
  is($report->{'noa'}, 0);
  is($report->{'npm'}, 1);
  is($report->{'amloc'}, 10);
  is($report->{'dbz'}, 2);
  is($report->{'da'}, 2);
  is($report->{'mlk'}, 2);
  is($report->{'dnp'}, 2);
  is($report->{'auv'}, 2);
}

__PACKAGE__->runtests;


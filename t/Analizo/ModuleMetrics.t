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
  $model->declare_security_metrics('Return of address to stack-allocated memory', 'mod1', 5);
  $model->declare_security_metrics('Out-of-bound array access', 'mod1', 7);
  $model->declare_security_metrics('Uninitialized argument value', 'mod1', 8);
  $model->declare_security_metrics('Bad free', 'mod1', 9);
  $model->declare_security_metrics('Double free', 'mod1', 10);
  $model->declare_security_metrics('Bad deallocator', 'mod1', 5);
  $model->declare_security_metrics('Use-after-free', 'mod1', 6);
  $model->declare_security_metrics('Offset free', 'mod1', 7);
  $model->declare_security_metrics('Undefined allocation of 0 bytes (CERT MEM04-C; CWE-131)', 'mod1', 7);
  $model->declare_security_metrics("Potential buffer overflow in call to \'gets\'", 'mod1', 11);
  $model->declare_security_metrics('Dereference of undefined pointer value', 'mod1', 13);
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
  is($report->{'rsva'}, 5);
  is($report->{'obaa'}, 7);
  is($report->{'uav'}, 8);
  is($report->{'bf'}, 9);
  is($report->{'df'}, 10);
  is($report->{'bd'}, 5);
  is($report->{'uaf'}, 6);
  is($report->{'osf'}, 7);
  is($report->{'ua'}, 7);
  is($report->{'fgbo'}, 11);
  is($report->{'dupv'}, 13);
}

__PACKAGE__->runtests;


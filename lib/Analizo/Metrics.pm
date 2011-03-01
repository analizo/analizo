package Analizo::Metrics;
use strict;
use base qw(Class::Accessor::Fast);
use YAML;

use Analizo::ModuleMetrics;
use Analizo::GlobalMetrics;

__PACKAGE__->mk_accessors(qw(
    model
    modules_report
    module_metrics
    global_metrics
));

sub new {
  my ($package, %args) = @_;
  my @instance_variables = (
    model => $args{model},
    global_metrics => new Analizo::GlobalMetrics(model => $args{model}),
    module_metrics => new Analizo::ModuleMetrics(model => $args{model}),
    modules_report => ''
  );
  return bless { @instance_variables }, $package;
}

sub list_of_global_metrics {
  my $self = shift;
  return $self->global_metrics->list;
}

sub list_of_metrics {
  my $self = shift;
  return $self->module_metrics->list;
}

sub report {
  my $self = shift;
  $self->_collect_and_combine_module_metrics;
  return $self->global_report . $self->modules_report;
}

sub report_global_metrics_only {
  my $self = shift;
  $self->_collect_and_combine_module_metrics;
  return $self->global_report;
}

sub global_report {
  my $self = shift;
  return '' if $self->_there_are_no_modules;
  return Dump($self->global_metrics->report);
}

sub _there_are_no_modules {
  my $self = shift;
  return scalar $self->model->module_names == 0;
}

sub _collect_and_combine_module_metrics {
  my $self = shift;

  for my $module ($self->model->module_names) {
    my $values = $self->_collect($module);
    $self->_combine($values);
  }
}

sub _collect {
  my ($self, $module) = @_;
  return $self->module_metrics->report($module);
}

sub _combine {
  my ($self, $values) = @_;
  $self->global_metrics->add_module_values($values);
  $self->modules_report($self->modules_report . Dump($values));
}

1;


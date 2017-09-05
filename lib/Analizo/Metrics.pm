package Analizo::Metrics;
use strict;
use base qw(Class::Accessor::Fast);
use YAML;

use Analizo::ModuleMetrics;
use Analizo::GlobalMetrics;

__PACKAGE__->mk_accessors(qw(
    model
    module_metrics
    global_metrics
    module_data
    by_module
));

sub new {
  my ($package, %args) = @_;
  my @instance_variables = (
    model => $args{model},
    global_metrics => new Analizo::GlobalMetrics(model => $args{model}),
    module_metrics => new Analizo::ModuleMetrics(model => $args{model}),
    module_data => [],
    by_module => {},
  );
  return bless { @instance_variables }, $package;
}

sub list_of_global_metrics {
  my ($self) = @_;
  return $self->global_metrics->list;
}

sub list_of_metrics {
  my ($self) = @_;
  return $self->module_metrics->list;
}

sub report {
  my ($self) = @_;
  return $self->report_global_metrics_only() . $self->report_module_metrics();
}

sub report_global_metrics_only {
  my ($self) = @_;
  my ($global_metrics, $module_metrics) = $self->data();
  return Dump($global_metrics);
}

sub report_only_mean {
  my ($self) = @_;
  my ($global_metrics, $module_metrics) = $self->data_mean();
  return Dump($global_metrics); 
}

sub report_module_metrics {
  my ($self) = @_;
  return join('', map { Dump($_) } @{$self->module_data()});
}

sub data {
  my ($self) = @_;
  $self->_collect_and_combine_module_metrics;
  return ($self->global_metrics->report, $self->module_data());
}

sub data_mean {
  my ($self) = @_;
  $self->_collect_and_combine_module_metrics;
  return ($self->global_metrics->report_mean, $self->module_data());
}


sub _collect_and_combine_module_metrics {
  my ($self) = @_;
  if (defined $self->{_collect_and_combine_module_metrics}) {
    return;
  }

  for my $module ($self->model->module_names) {
    my $module_metrics = $self->_collect($module);
    $self->_combine($module_metrics);
  }

  $self->{_collect_and_combine_module_metrics} = 1;
}

sub _collect {
  my ($self, $module) = @_;
  return $self->module_metrics->report($module);
}

sub _combine {
  my ($self, $module_metrics) = @_;
  my $module = $module_metrics->{_module};

  $module_metrics->{_filename} = $self->model->files($module);
  push(@{$self->module_data()}, $module_metrics);
  $self->{by_module}->{$module} = $module_metrics;


  $self->global_metrics->add_module_values($module_metrics);
}

sub metrics_for {
  my ($self, $module) = @_;
  $self->data(); # FIXME shouldn't be needed
  return $self->{by_module}->{$module};
}

1;


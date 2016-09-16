package Analizo::Metric::ResultIsGarbage;
use strict;
use base qw(Class::Accessor::Fast Analizo::ModuleMetric);

__PACKAGE__->mk_accessors(qw( model ));

sub new {
  my ($package, %args) = @_;
   my @instance_variables = (
    model => $args{model}
  );
  return bless { @instance_variables }, $package;
}

sub description {
  return "Result of operation is garbage or undefined";
}

sub calculate {
  my ($self, $module) = @_;

  return 0 if (!defined $self->model->security_metrics('Result of operation is garbage or undefined', $module));

  return $self->model->security_metrics('Result of operation is garbage or undefined', $module);

}

1;
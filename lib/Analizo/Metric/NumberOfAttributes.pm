package Analizo::Metric::NumberOfAttributes;
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
  return "Number of Attributes";
}

sub calculate {
  my ($self, $module) = @_;
  my @variables = $self->model->variables($module);
  return scalar(@variables);
}

1;


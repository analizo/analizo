package Analizo::Metric::DivisionsByZero;
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
  return "Divisions by zero";
}

sub calculate {
  my ($self, $module) = @_;

  return 0 if (!defined $self->model->divisions_by_zero->{$module});

  return $self->model->divisions_by_zero->{$module};
}

1;


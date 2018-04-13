package Analizo::GlobalMetric::TotalAbstractClasses;
use strict;
use parent qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw( model ));

sub new {
  my ($package, %args) = @_;
   my @instance_variables = (
    model => $args{model},
  );
  return bless { @instance_variables }, $package;
}

sub description {
  return "Total Abstract Classes";
}

sub calculate {
  my ($self)= @_;
  my @total_of_abstract_classes = $self->model->abstract_classes;
  return scalar(@total_of_abstract_classes) || 0;
}

1;


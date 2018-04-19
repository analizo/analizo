package Analizo::GlobalMetric::TotalEloc;
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
  return "Total Effective Lines of Code";
}

sub calculate {
  my ($self) = @_;
  return $self->model->total_eloc;
}

1;


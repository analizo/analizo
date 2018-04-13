package Analizo::GlobalMetric::MethodsPerAbstractClass;
use strict;
use parent qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw( model));

sub new {
  my ($package, %args) = @_;
   my @instance_variables = (
    model => $args{model},
  );
  return bless { @instance_variables }, $package;
}

sub description {
  return "Methods per Abstract Class";
}

sub calculate {
  my ($self) = @_;
  my $total_number_of_methods = 0;
  my @abstract_classes = $self->model->abstract_classes;

  for my $abstract_class (@abstract_classes) {
    $total_number_of_methods += (scalar $self->model->functions($abstract_class)) || 0;
  }
  return _division($total_number_of_methods, scalar @abstract_classes);
}

sub _division {
  my ($dividend, $divisor) = @_;
  return ($divisor > 0) ? ($dividend / $divisor) : 0;
}

1;


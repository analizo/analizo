package Analizo::Metric::NumberOfMethods;
use strict;
use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw( model ));

sub new {
  my ($package, %args) = @_;
   my @instance_variables = (
    model => $args{model}
  );
  return bless { @instance_variables }, $package;
}

sub description {
  return "Number of Methods";
}

sub calculate {
  my ($self, $module) = @_;
  my @functions = $self->model->functions($module);
  return scalar(@functions);
}

1;


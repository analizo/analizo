package Analizo::Metric::NumberOfPublicMethods;
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
  return "Number of Public Methods";
}

sub calculate {
  my ($self, $module) = @_;

  my $count = 0;
  for my $function ($self->model->functions($module)) {
    $count += 1 if $self->_is_public($function);
  }
  return $count;
}

sub _is_public {
  my ($self, $function) = @_;
  return $self->model->{protection}->{$function} && $self->model->{protection}->{$function} eq "public";
}

1;


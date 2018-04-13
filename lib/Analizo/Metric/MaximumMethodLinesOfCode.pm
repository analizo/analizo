package Analizo::Metric::MaximumMethodLinesOfCode;
use strict;
use parent qw(Class::Accessor::Fast Analizo::ModuleMetric);
use Statistics::Descriptive;

__PACKAGE__->mk_accessors(qw( model ));

sub new {
  my ($package, %args) = @_;
   my @instance_variables = (
    model => $args{model}
  );
  return bless { @instance_variables }, $package;
}

sub description {
  return "Max Method LOC";
}

sub calculate {
  my ($self, $module) = @_;

  my $statisticalCalculator = Statistics::Descriptive::Full->new();

  for my $function ($self->model->functions($module)) {
    $statisticalCalculator->add_data($self->model->{lines}->{$function} || 0);
  }

  return $statisticalCalculator->max() || 0;
}

1;


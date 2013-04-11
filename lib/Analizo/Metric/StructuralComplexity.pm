package Analizo::Metric::StructuralComplexity;
use strict;
use base qw(Class::Accessor::Fast Analizo::ModuleMetric);

use Analizo::Metric::CouplingBetweenObjects;
use Analizo::Metric::LackOfCohesionOfMethods;

__PACKAGE__->mk_accessors(qw( model cbo lcom4 ));

sub new {
  my ($package, %args) = @_;
   my @instance_variables = (
    model => $args{model},
    cbo => $args{cbo},
    lcom4 => $args{lcom4},
  );

  return bless { @instance_variables }, $package;
}

sub description {
  return "Structural Complexity";
}

sub calculate {
  my ($self, $module) = @_;

  my $cbo   = $self->cbo->value($module);
  my $lcom4 = $self->lcom4->value($module);

  return ($cbo * $lcom4);
}

1;

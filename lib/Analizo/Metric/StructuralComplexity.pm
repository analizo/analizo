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
  
  #FIXME: we are re-calculating cbo and lcom4
  #How to call 'value' variable from the instances of cbo and lcom4?
  my $cbo   = $self->cbo->calculate($module);
  my $lcom4 = $self->lcom4->calculate($module);
  return ($cbo * $lcom4);
}

1;

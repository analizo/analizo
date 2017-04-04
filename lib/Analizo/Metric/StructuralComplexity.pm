package Analizo::Metric::StructuralComplexity;
use strict;
use base qw(Class::Accessor::Fast Analizo::ModuleMetric);

use Analizo::Metric::CouplingBetweenObjects;
use Analizo::Metric::LackOfCohesionOfMethods;

=head1 NAME

Analizo::Metric::StructuralComplexity - Structural Complexity metric

=head1 DESCRIPTION

The metric calculation is based on the following article and calculates the structural
complexity.

Article: Monitoring of source code metrics in open source projects by 
Paulo Roberto Miranda Meirelles.

See the adaptation of the paragraph about Structural Complexity in the article:

"When combined with a metric, the coupling and cohesion product is positively correlated 
to the maintenance effort. Therefore, we use in this PhD research the coupling product (CBO)
and cohesion (LCOM4) as our structural complexity metric (Darcy et al., 2005)."

=cut


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

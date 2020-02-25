package Analizo::Metric::AverageCycloComplexity;
use strict;
use parent qw(Class::Accessor::Fast Analizo::ModuleMetric);
use Statistics::Descriptive;

=head1 NAME

Analizo::Metric::AverageCycloComplexity - Average Cyclomatic Complexity per Method (ACCM) metric

=head1 DESCRIPTION

The metric calculation is based on the following article and calculates the
cyclomatic complexity of the program.

Article:
I<McCabe, Thomas J. "A complexity measure." IEEE Transactions on software Engineering 4 (1976): 308-320>.

The Average Cyclomatic Complexity per Method is calculated counting the
predicates (i.e., decision points, or conditional paths) on each method plus
one, then a mean of all methods is returned as the final value of ACCM.

The cyclomatic complexity of a program represented as a graph can be calculated
using a formula of graph theory:

  v(G) = e - n + 2

Where C<e> is the number of edges and C<n> is the number of nodes of the graph.

Another good reference is:
I<Woodward, Martin R., Michael A. Hennell, and David Hedley. "A measure of control flow complexity in program text." IEEE Transactions on Software Engineering 1 (1979): 45-50>.

=cut

__PACKAGE__->mk_accessors(qw( model ));

sub new {
  my ($package, %args) = @_;
   my @instance_variables = (
    model => $args{model}
  );
  return bless { @instance_variables }, $package;
}

sub description {
  return 'Average Cyclomatic Complexity per Method';
}

sub calculate {
  my ($self, $module) = @_;

  my @functions = $self->model->functions($module);
  if (scalar(@functions) == 0) {
    return 0;
  }

  my $statisticalCalculator = Statistics::Descriptive::Full->new();
  for my $function (@functions) {
    $statisticalCalculator->add_data($self->model->{conditional_paths}->{$function} + 1);
  }

  return $statisticalCalculator->mean();
}

1;

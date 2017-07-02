package Analizo::Metric::AverageCycloComplexity;
use strict;
use base qw(Class::Accessor::Fast Analizo::ModuleMetric);
use Statistics::Descriptive;

=head1 NAME

Analizo::Metric::AverageCycloComplexity - Average Cyclomatic Complexity per Method (ACCM) metric

=head1 DESCRIPTION

The metric calculation is based on the following article and calculates the
complexity of the program.

Article: I<Monitoring of source code metrics in open source projects> by Paulo
Roberto Miranda Meirelles.

See the adaptation of the paragraph about Average Cyclomatic Complexity per
Method in the article:

... The cyclomatic complexity of a graph can be calculated using a formula of
graph theory:

  v(G) = e - n + 2

where C<e> is the number of edges and C<n> is the number of nodes of the graph.

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
    $statisticalCalculator->add_data($self->model->{conditional_paths}->{$function} || 0);
  }

  return $statisticalCalculator->mean();
}

1;

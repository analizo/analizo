package Analizo::Metric::LackOfCohesionOfMethods;
use strict;
use parent qw(Class::Accessor::Fast Analizo::ModuleMetric);
use Graph;

=head1 NAME

Analizo::Metric::LackOfCohesionOfMethods - Lack of Cohesion of Methods (LCOM4) metric

=head1 DESCRIPTION

The metric calculation is based on the following article and calculates the
cohesion of the class.

Article: I<Comparison of Various Lacks of Cohesion Metrics> by Taranjeet Kaur
and Rupinder Kaur.

See the paragraphs about Lack of Cohesion of Methods LCOM4 in the article:

LCOM3 varies in range between C<[0, 1]>. LCOM3 indicates high cohesion and it
is also a well defined class, it show simplicity of class and high reusability
of class. A highly cohesive class provides high degree of encapsulation. LCOM3
formula is

  M: number of methods in a class
  A: number of variables in a class
  m.A: number of methods that access a variable
  Sum(m.A): number of methods over attributes
  a: variabes that shared may be or not

  LCOM3=(m - Sum(mA) / a) / m - 1

In other words also say that consider connected components of graph or also say
that if we consider undirected graph C<G> where vertices are methods of a class
and edge between vertices if corresponding methods at least share one instance
variable.

LCOM4 is like LCOM3 where graph C<G> additionally has an edge between vertices
representing methods C<Mi> and C<Mj> if C<Mi> invokes C<Mj>. In other words
also say that, it measure number of components in a class. A connected component
is a set of related methods.

=cut

__PACKAGE__->mk_accessors(qw( model graph ));

sub new {
  my ($package, %args) = @_;
   my @instance_variables = (
    model => $args{model},
    graph => Graph->new,
  );
  return bless { @instance_variables }, $package;
}

sub description {
  return "Lack of Cohesion of Methods";
}

sub calculate {
  my ($self, $module) = @_;
  my $graph = Graph->new;
  my @functions = $self->model->functions($module);
  my @variables = $self->model->variables($module);
  for my $function (@functions) {
    $graph->add_vertex($function);
    for my $used (keys(%{$self->model->calls->{$function}})) {
      # only include in the graph functions and variables that are inside the module.
      if ((grep { $_ eq $used } @functions) || (grep { $_ eq $used } @variables)) {
        $graph->add_edge($function, $used);
      }
    }
  }
  my @components = $graph->weakly_connected_components;
  return scalar @components;
}

1;


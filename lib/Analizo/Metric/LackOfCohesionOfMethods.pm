package Analizo::Metric::LackOfCohesionOfMethods;
use strict;
use parent qw(Class::Accessor::Fast Analizo::ModuleMetric);
use Graph;

=head1 NAME

Analizo::Metric::LackOfCohesionOfMethods - Lack of Cohesion of Methods (LCOM4) metric

=head1 DESCRIPTION

The metric calculation is based on the following article and calculates the
cohesion of the class.

Article:

   M. Hitz and B. Montazeri, "Measuring coupling and cohesion in
   object-oriented systems," in Proceedings of the International. Symposium on
   Applied Corporate Computing, 1995.
   http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.409.4862

The LCOM4 value for a module is the number of connected components of an
undirected graph, where the nodes are the module's subroutines (methods,
functions etc.), and the edges indicate that two subroutines use at least one
attribute/variable in common, or that one subroutines calls the other. These
connected components represent independent parts of a module, and modules
that have more than one of them have independent, distinct responsibilities.

You can see a study using the LCOM4 metric on the following paper:

   Terceiro, Antonio, et al. "Understanding structural complexity evolution: A
   quantitative analysis." Software Maintenance and Reengineering (CSMR), 2012
   16th European Conference on. IEEE, 2012. NBR 6023
   http://ieeexplore.ieee.org/abstract/document/6178856/

For a comparative study on the various LCOM1, LCOM2, LCOM3, LCOM4 and LCOM5
see:

   Kaur, Taranjeet, and Rupinder Kaur. "Comparison of various lacks of Cohesion
   Metrics." International Journal of Computer Trends and Technology (IJCTT)
   4.5 (2013). NBR 6023
   http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.686.2543

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


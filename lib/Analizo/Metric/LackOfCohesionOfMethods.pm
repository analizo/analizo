package Analizo::Metric::LackOfCohesionOfMethods;
use strict;
use base qw(Class::Accessor::Fast);
use Graph;

__PACKAGE__->mk_accessors(qw( model ));

sub new {
  my ($package, %args) = @_;
   my @instance_variables = (
    model => $args{model}
  );
  return bless { @instance_variables }, $package;
}

sub calculate {
  my ($self, $module) = @_;

  my $graph = $self->_cohesion_graph_of_module($module);
  my $number_of_components = scalar $graph->weakly_connected_components;

  return $number_of_components;
}

sub _cohesion_graph_of_module {
  my ($self, $module) = @_;

  my $graph = new Graph;
  my @functions = $self->model->functions($module);
  my @variables = $self->model->variables($module);

  for my $function (@functions) {
    $self->_add_function_as_vertix($graph, $function);
    $self->_add_edges_to_used_functions_and_variables($graph, $function, @functions, @variables);
  }

  return $graph;
}

sub _add_function_as_vertix {
  my ($self, $graph, $function) = @_;
  $graph->add_vertex($function);
}

sub _add_edges_to_used_functions_and_variables {
  my ($self, $graph, $function, @functions, @variables) = @_;

  for my $used (keys(%{$self->model->calls->{$function}})) {
    if (_used_inside_the_module($used, @functions, @variables)) {
      $graph->add_edge($function, $used);
    }
  }
}

sub _used_inside_the_module {
  my ($used, @functions, @variables) = @_;
  return (grep { $_ eq $used } @functions) || (grep { $_ eq $used } @variables);
}

1;


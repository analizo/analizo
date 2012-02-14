package Analizo::Metric::LackOfCohesionOfMethods;
use strict;
use base qw(Class::Accessor::Fast);
use Graph;

__PACKAGE__->mk_accessors(qw( model graph value ));

sub new {
  my ($package, %args) = @_;
   my @instance_variables = (
    model => $args{model},
    graph => new Graph(),
    value => undef
  );
  return bless { @instance_variables }, $package;
}

sub description {
  return "Lack of Cohesion of Methods";
}

sub calculate {
  my ($self, $module) = @_;

  $self->_build_cohesion_graph_of_module($module);

  my $number_of_components = scalar $self->graph->weakly_connected_components;
  my $value = $self->value($number_of_components);

  return $value;
}

sub _build_cohesion_graph_of_module {
  my ($self, $module) = @_;

  my @functions = $self->model->functions($module);
  my @variables = $self->model->variables($module);

  for my $function (@functions) {
    $self->_add_function_as_vertix($function);
    $self->_add_edges_to_used_functions_and_variables($function, @functions, @variables);
  }
}

sub _add_function_as_vertix {
  my ($self, $function) = @_;
  $self->graph->add_vertex($function);
}

sub _add_edges_to_used_functions_and_variables {
  my ($self, $function, @functions, @variables) = @_;

  for my $used (keys(%{$self->model->calls->{$function}})) {
    if (_used_inside_the_module($used, @functions, @variables)) {
      $self->graph->add_edge($function, $used);
    }
  }
}

sub _used_inside_the_module {
  my ($used, @functions, @variables) = @_;
  return (grep { $_ eq $used } @functions) || (grep { $_ eq $used } @variables);
}

1;


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
  my $graph = new Graph;
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


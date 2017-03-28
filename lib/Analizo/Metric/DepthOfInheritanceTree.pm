package Analizo::Metric::DepthOfInheritanceTree;
use strict;
use base qw(Class::Accessor::Fast Analizo::ModuleMetric);

=head1 NAME

Analizo::Metric::DepthOfInheritanceTree - Depth Of Inheritance Tree metric

=head1 DESCRIPTION

The metric calculation is based on the following article and calculates the longest.
path from a module to the class hierarchy root.

Article: An empirical study of aspect-oriented metrics by Eduardo Kessler Piveta, 
Ana Moreira, Marcelo Soares Pimenta, Joao Araujo, Pedro Guerreiro and R. Tom Price.

See the paragraph about Depth Of Inheritance Tree in the article:

"Considering a function s(x) : Module -> Module that computes the super-class or 
super-aspect of a giver module, the value of DIT is given by:

    DIT(m) = DIT(s(m)) + 1, ifc m != rootClass
    DIT(m) = 0, otherwise."

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
  return "Depth of Inheritance Tree";
}

sub calculate {
  my ($self, $module) = @_;

  my @parents = $self->model->inheritance($module);
  return 1 + $self->_depth_of_deepest_inheritance_tree(@parents) if (@parents);
  return 0;
}

sub _depth_of_deepest_inheritance_tree {
  my ($self, @parents) = @_;
  my @parent_dits = map { $self->calculate($_) } @parents;
  my @sorted = reverse(sort(@parent_dits));
  return $sorted[0];
}

1;


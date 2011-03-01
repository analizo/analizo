package Analizo::Metric::DepthOfInheritanceTree;
use strict;
use base qw(Class::Accessor::Fast);

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
  if (@parents) {
   return 1 + $self->_depth_of_deepest_inheritance_tree(@parents);
  }
  return 0;
}

sub _depth_of_deepest_inheritance_tree {
  my ($self, @parents) = @_;
  my @parent_dits = map { $self->calculate($_) } @parents;
  my @sorted = reverse(sort(@parent_dits));
  return $sorted[0];
}

1;


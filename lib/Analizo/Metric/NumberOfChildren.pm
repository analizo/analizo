package Analizo::Metric::NumberOfChildren;
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
  return "Number of Children";
}

sub calculate {
  my ($self, $module) = @_;

  my $number_of_children = 0;
  for my $other_module ($self->model->module_names) {
    $number_of_children++ if ($self->_module_parent_of_other($module, $other_module));
  }
  return $number_of_children;
}

sub _module_parent_of_other {
  my ($self, $module, $other_module) = @_;
  return grep {$_ eq $module} $self->model->inheritance($other_module);
}

1;


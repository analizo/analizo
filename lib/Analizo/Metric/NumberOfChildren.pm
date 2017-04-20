package Analizo::Metric::NumberOfChildren;
use strict;
use base qw(Class::Accessor::Fast Analizo::ModuleMetric);


=head1 NAME

Analizo::Metric::NumberOfChildren - Number of Children (NOC) metric

=head1 DESCRIPTION

The metric calculation is based on the following article and calculates the
number of immediate subclasses subordinate to a class in the hierarchy.

Article: I<Software Quality Metrics for Object-Oriented Environments> by Linda
H. Rosenberg and Lawrence E. Hyatt.

See the paragraph about Number of Children in the article:

The number of children is the number of immediate subclasses subordinate to a
class in the hierarchy. It is an indicator of the potential influence a class
can have on the design and on the system. The greater the number of children,
the greater the likelihood of improper abstraction of the parent and may be a
case of misuse of subclassing. But the greater the number of children, the
greater the reusability since inheritance is a form of reuse. If a class has a
large number of children, it may require more testing of the methods of that
class, thus increase the testing time.

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


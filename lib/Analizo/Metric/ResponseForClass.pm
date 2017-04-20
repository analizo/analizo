package Analizo::Metric::ResponseForClass;
use strict;
use base qw(Class::Accessor::Fast Analizo::ModuleMetric);

=head1 NAME

Analizo::Metric::ResponseForClass - Response for Class (RFC) metric

=head1 DESCRIPTION

The metric calculation is based on the following article and calculates the sum
between the number of methods in the module and the number of functions called
by each module function.

Article: I<A metrics suite for object oriented design> by Shyam R. Chidamber
and Chris F. Kemerer.

See the paragraph about Response for Class in the article:

... The response set of a class is a set of methods that can potentially be
executed in response to a message received by an object of that class.  The
cardinality of this set is a measure of the attributes of objects in the class.
Since it specifically includes methods called from outside the class, it is
also a measure of the potential communication between the class and other
classes.

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
  return "Response for a Class";
}

sub calculate {
  my ($self, $module) = @_;

  my @functions = $self->model->functions($module);
  my $number_of_functions = scalar @functions;
  my $number_of_functions_called_by_module_functions = $self->_number_of_functions_called_by(@functions);

  return $number_of_functions + $number_of_functions_called_by_module_functions;
}

sub _number_of_functions_called_by {
  my ($self, @functions) = @_;

  my $count = 0;
  for my $function (@functions){
    $count += scalar keys(%{$self->model->calls->{$function}});
  }
  return $count;
}

1;


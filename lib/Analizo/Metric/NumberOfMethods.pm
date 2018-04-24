package Analizo::Metric::NumberOfMethods;
use strict;
use parent qw(Class::Accessor::Fast Analizo::ModuleMetric);

=head1 NAME

Analizo::Metric::NumberOfMethods - Number of Methods (NOM) metric

=head1 DESCRIPTION

The metric calculation is based on the following article and calculates the
number of methods per class to measure the size of the classes in terms of its
implemented operations.

Article: I<Monitoring of source code metrics in open source projects> by Paulo
Roberto Miranda Meirelles.

See the adaptation of the paragraph about Number of Methods in the article:

... This metric is used to help to identify the potential reuse of a class. In
general, the classes with a large number of methods are harder to be reused,
because they are more likely to be less cohesive (Lorenz and Kidd, 1994). Thus,
it's recommended that a class don't have a excessive number of methods (Beck,
1997).

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
  return "Number of Methods";
}

sub calculate {
  my ($self, $module) = @_;
  my @functions = $self->model->functions($module);
  return scalar(@functions);
}

1;


package Analizo::Metric::AverageNumberOfParameters;
use strict;
use parent qw(Class::Accessor::Fast Analizo::ModuleMetric);
use Statistics::Descriptive;

=head1 NAME

Analizo::Metric::AverageNumberOfParamters - Average Number of Parameters (ANPM) metric

=head1 DESCRIPTION

The metric calculation is based on the following article and calculates the
average of the number of parameters of the class methods.

Article: I<Monitoring of source code metrics in open source projects> by Paulo
Roberto Miranda Meirelles.

See the adaptation of the paragraph about Average Number of Parameters per
Class in the article:

"Calculates the average of parameters of the class methods. Its minimum value is zero
and there is no upper limit to its result, but a high number of parameters may indicate
that a method may have one more responsibility, i. e., more than one function"

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
  return "Average Number of Parameters per Method";
}

sub calculate {
  my ($self, $module) = @_;

  my @functions = $self->model->functions($module);
  if (scalar(@functions) == 0) {
    return 0;
  }

  my $statisticalCalculator = Statistics::Descriptive::Full->new();
  for my $function (@functions) {
    $statisticalCalculator->add_data($self->model->{parameters}->{$function} || 0);
  }

  return $statisticalCalculator->mean();
}


1;


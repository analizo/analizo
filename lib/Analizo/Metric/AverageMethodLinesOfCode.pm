package Analizo::Metric::AverageMethodLinesOfCode;
use strict;
use parent qw(Class::Accessor::Fast Analizo::ModuleMetric);
use Statistics::Descriptive;

=head1 NAME

Analizo::Metric::AverageMethodLinesOfCode - Average Method Lines of Code (AMLOC) metric

=head1 DESCRIPTION

The metric calculation is based on the following article and calculates the
average number of lines of code per method.

Article: I<Monitoring of source code metrics in open source projects> by Paulo
Roberto Miranda Meirelles.

See the adaptation of the paragraph about Average Method Lines of Code metric:

This metric indicates if the code is well distributed between the methods. How
bigger, "heavier" are the methods. It's preferable to have a lot of small and
of easy understanding operations than few large and complex operations.

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
  return "Average Method Lines of Code";
}

sub calculate {
  my ($self, $module) = @_;

  my @functions = $self->model->functions($module);
  if (scalar(@functions) == 0) {
    return 0;
  }

  my $statisticalCalculator = Statistics::Descriptive::Full->new();
  for my $function (@functions) {
    $statisticalCalculator->add_data($self->model->{lines}->{$function} || 0);
  }
  return $statisticalCalculator->mean();
}

1;


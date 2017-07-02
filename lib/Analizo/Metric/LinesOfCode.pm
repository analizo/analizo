package Analizo::Metric::LinesOfCode;
use strict;
use base qw(Class::Accessor::Fast Analizo::ModuleMetric);
use Statistics::Descriptive;

=head1 NAME

Analizo::Metric::LinesOfCode - Lines of Code (LOC) metric

=head1 DESCRIPTION

The metric calculation is based on the following article and calculates the
program size in lines of code, excluding blank lines and comments.

Article: I<The Lines of Code Metric as a Predictor of Program Faults: A
Critical Analysis> by Taghi M. Khoshgoftaar and John C. Munson.

See the paragraph about Lines of Code in the article:

A description of the specific quantitative complexity data collected for
each program is as follows:

... program size in lines of code (non-comment, non-blank lines) in program
(LOC).

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
  return "Lines of Code";
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

  return $statisticalCalculator->sum();
}

1;


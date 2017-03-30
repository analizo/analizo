package Analizo::Metric::NumberOfPublicMethods;
use strict;
use base qw(Class::Accessor::Fast Analizo::ModuleMetric);

=head1 NAME

Analizo::Metric::NumerOfPublicMethods - Number of Public Methods metric

=head1 DESCRIPTION

The metric calculation is based on the following article and calculates the number 
of public methods of a class.

Article: Monitoring of source code metrics in open source projects by 
Paulo Roberto Miranda Meirelles.

See the adaptation of the paragraph about Number of Attributes in the article:

"Represents the size of the "interface" of the class. Methods are directly related 
to the operations provided in the respective class. High values for this metric indicate 
that a class has many methods and probably many responsibilities, which conflicts with 
good programming practices (Beck, 1997)."

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
  return "Number of Public Methods";
}

sub calculate {
  my ($self, $module) = @_;

  my $count = 0;
  for my $function ($self->model->functions($module)) {
    $count += 1 if $self->_is_public($function);
  }
  return $count;
}

sub _is_public {
  my ($self, $function) = @_;
  return $self->model->{protection}->{$function} && $self->model->{protection}->{$function} eq "public";
}

1;


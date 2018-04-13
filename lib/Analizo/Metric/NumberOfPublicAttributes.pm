package Analizo::Metric::NumberOfPublicAttributes;
use strict;
use parent qw(Class::Accessor::Fast Analizo::ModuleMetric);

=head1 NAME

Analizo::Metric::NumberOfPublicAttributes - Number of Public Attributes (NPA) metric

=head1 DESCRIPTION

The metric calculation is based on the following article and calculates the
number of public attributes of a class.

Article: I<Monitoring of source code metrics in open source projects> by Paulo
Roberto Miranda Meirelles.

See the adaptation of the paragraph about Number of Public Attributes in the
article:

It measures the encapsulation. The attributes of a class must only serve to the
functionalities of itself. Thus, good programming practices recommend that the
attributes of a class must be manipulated using the access methods (Beck,
1997), the attributes of a class must be private, indicating that the ideal
number for this metric is zero.

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
  return "Number of Public Attributes";
}

sub calculate {
  my ($self, $module) = @_;

  my $count = 0;
  for my $attribute ($self->model->variables($module)) {
    $count += 1 if $self->_is_public($attribute);
  }
  return $count;
}

sub _is_public {
  my ($self, $attribute) = @_;
  return $self->model->{protection}->{$attribute} && $self->model->{protection}->{$attribute} eq "public";
}

1;


package Analizo::Metric::NumberOfAttributes;
use strict;
use base qw(Class::Accessor::Fast Analizo::ModuleMetric);

=head1 NAME

Analizo::Metric::NumerOfAttributes - Number of Attributes (NOA) metric

=head1 DESCRIPTION

The metric calculation is based on the following article and calculates the
number of attributes of a class.

Article: I<Monitoring of source code metrics in open source projects> by Paulo
Roberto Miranda Meirelles.

See the adaptation of the paragraph about Number of Attributes in the article:

Calculates the number of attributes of a class. Its minimum value is zero and
there is no upper limit to its result. A class with many attributes may
indicate that it has many responsibilities and presents a low cohesion, i. e.,
is probably dealing with several different subjects.

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
  return "Number of Attributes";
}

sub calculate {
  my ($self, $module) = @_;
  my @variables = $self->model->variables($module);
  return scalar(@variables);
}

1;


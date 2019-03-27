package Analizo::Metric::AfferentConnections;
use strict;
use parent qw(Class::Accessor::Fast Analizo::ModuleMetric);

=head1 NAME

Analizo::Metric::AfferentConnections - Afferent Connections per Class (ACC) metric

=head1 DESCRIPTION

The metric calculation is based on the following article and calculates the
class conectivity.

Article: I<Monitoring of source code metrics in open source projects> by Paulo
Roberto Miranda Meirelles.

See the adaptation of the paragraph about Afferente Connections per Class in
the article:

Measures the connectivity of a class. If a class C<Ci> access a method or
attribute of a class C<Cj>, consider C<Ci> a client of the supplier class
C<Cj>, denoting C<< Ci => Cj >>.  Consider the follow function:

  client(Ci, Cj) = 1, if (Ci => Cj) and (Ci != Cj)
  client(Ci, Cj) = 0, otherwise.

So C<ACC(Cj) = (sum(client(Ci, Cj)), i = 1 to N)>, where C<N> is the total
number of system classes. If the value of this metric is large, a change in the
class has substantially more side effects, making maintenance more difficult.

=cut

__PACKAGE__->mk_accessors(qw( model analized_module));

sub new {
  my ($package, %args) = @_;
   my @instance_variables = (
    model => $args{model},
    analized_modules => undef
  );
  return bless { @instance_variables }, $package;
}

sub description {
  return 'Afferent Connections per Class (used to calculate COF - Coupling Factor)';
}

sub calculate {
  my ($self, $module) = @_;
  $self->analized_module($module);
  my $acc_result = $self->model->modules_graph->in_degree($module);
  return $acc_result ? $acc_result : 0;
}

1;

package Analizo::GlobalMetric::ChangeCost;
use strict;
use parent qw(Class::Accessor::Fast);
use List::Util qw( sum );

=head1 NAME

Analizo::GlobalMetric::ChangeCost - Change Cost global metric

=head1 DESCRIPTION

The metric calculation is based on the following article and calculates the
degree to which a change to any file causes a (potential) change to other files
in the system.

Article: Exploring the Structure of Complex Software Designs: An Empirical
Study of Open Source and Proprietary Code by Alan MacCormack, John Rusnak and
Carliss Baldwin.

See the paragraph about Change Cost in the article:

"... characterize the structure of a design is by measuring the degree of
'coupling' it exhibits, as captured by the degree to which a change to any
single element causes a (potential) change to other elements in the system,
either directly or indirectly (i.e., through a chain of dependencies that exist
across elements).

... measures the percentage of elements affected, on average, when a change is
made to one element in the system."

=cut

__PACKAGE__->mk_accessors(qw( model ));

sub new {
  my ($package, %args) = @_;
   my @instance_variables = (
    model => $args{model},
  );
  return bless { @instance_variables }, $package;
}

sub description {
  return "Change Cost";
}

sub calculate {
  my ($self) = @_;
  my $reachability_matrix = $self->model->get_files_graph->transitive_closure_matrix;
  my @vertices = sort $reachability_matrix->vertices;
  my $rows = scalar @vertices;
  return unless $rows;
  my @fan_out = (0) x $rows;
  my $n = 0;
  foreach my $i (@vertices) {
    foreach my $j (@vertices) {
      $fan_out[$n] += $reachability_matrix->[0]->get($i, $j);
    }
    $fan_out[$n] = $fan_out[$n] / $rows;
    $n++;
  }
  sprintf("%0.02f", sum(@fan_out) / $rows);
}

1;

package Analizo::Batch::Runner::Sequential;

use strict;
use warnings;

use base qw( Analizo::Batch::Runner );

sub run {
  my ($self, $batch, $output) = @_;
  my $before_each_job = $self->before_each_job || (sub {});
  while (my $job = $batch->next()) {
    &$before_each_job($job);
    $job->execute();
    $output->push($job);
  }
  $output->flush();
}

1;

package Analizo::Batch::Runner::Sequential;

use strict;
use warnings;

use base qw( Analizo::Batch::Runner );

sub actually_run {
  my ($self, $batch, $output, @binary_statistics) = @_;
  my $i = 0;
  while (my $job = $batch->next()) {
    $job->execute(@binary_statistics);
    $output->push($job);
    $i++;
    $self->report_progress($job, $i, $batch->count);
  }
}

1;

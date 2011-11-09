package Analizo::Batch::Runner::Sequential;

use strict;
use warnings;

use base qw( Analizo::Batch::Runner );

sub actually_run {
  my ($self, $batch, $output) = @_;
  my $i = 0;
  while (my $job = $batch->next()) {
    $job->execute();
    $output->push($job);
    $i++;
    $self->report_progress($job, $i, $batch->count);
  }
}

1;

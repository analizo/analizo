package Analizo::Batch::Runner::Sequential;

use strict;
use warnings;

use base qw( Analizo::Batch::Runner );

sub run {
  my ($self, $batch, $output) = @_;
  while (my $job = $batch->next()) {
    $job->execute();
    $output->push($job);
  }
  $output->flush();
}

1;

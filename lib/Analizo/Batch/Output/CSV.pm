package Analizo::Batch::Output::CSV;

use base qw( Analizo::Batch::Output );
use Analizo::Metrics;

sub push {
  my ($self, $job) = @_;
  $self->{jobs} ||= [];
  push @{$self->{jobs}}, $job;
}

sub write_data {
  my ($self, $fh) = @_;
  my @fields = ();

  for my $job (@{$self->{jobs}}) {

    my ($summary, $details) = $job->metrics->calculate_report();

    unless (@fields) {
      @fields = sort(keys(%$summary));

      my $header = join(',', @fields) . "\n";
      print $fh $header;
    }

    my @values = map { $summary->{$_} } @fields;
    my $line = join(',', @values) . "\n";
    print $fh $line;
  }
}

1;

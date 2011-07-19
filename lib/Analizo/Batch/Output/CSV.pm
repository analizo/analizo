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
  my @metadata_fields;

  for my $job (@{$self->{jobs}}) {

    my ($summary, $details) = $job->metrics->calculate_report();
    my $metadata = $job->metadata;

    unless (@fields) {
      @fields = sort(keys(%$summary));
      @metadata_fields = map { $_->[0] } @$metadata;

      my $header = join(',', 'id', @metadata_fields, @fields) . "\n";
      print $fh $header;
    }

    my @metadata = map { $_->[1] } @$metadata;
    my @values = map { $summary->{$_} } @fields;
    my $line = join(',', $job->id, @metadata, @values) . "\n";
    print $fh $line;
  }
}

1;

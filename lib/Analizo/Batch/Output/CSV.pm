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

    my ($summary, $details) = $job->metrics->data();
    my $metadata = $job->metadata;

    unless (@fields) {
      @fields = sort(keys(%$summary));
      @metadata_fields = map { $_->[0] } @$metadata;

      my $header = join(',', 'id', @metadata_fields, @fields) . "\n";
      print $fh $header;
    }

    my @metadata = map{ _encode_value($_->[1])} @$metadata;
    my @values = map { _encode_value($summary->{$_}) } @fields;
    my $line = join(',', $job->id, @metadata, @values) . "\n";
    print $fh $line;

    $self->_write_details($job->id, $details);
  }
}

my $__encoders = {
  _default => sub { $_[0] },
  ARRAY => sub { '"' . join(';', @{$_[0]}) . '"' },
  HASH => sub { '"' . join(';', map { join(':', $_, $_[0]->{$_}) } sort(keys(%{$_[0]}))) . '"' },
};

sub _encode_value($) {
  my ($value) = @_;
  my $encoder = $__encoders->{ref($value)} || $__encoders->{_default};
  return &$encoder($value);
}

sub _write_details {
  my ($self, $id, $details) = @_;
  my @array_of_values = ();
  my $files_name;

  my $csv_filename = $id. "-details.csv";
  open my $csv_handler, '>'.$csv_filename  || die "Cannot open ".$id."-details.csv\n".$!;

  print $csv_handler "filename,".
         "module,".
         "acc,".
         "accm,".
         "amloc,".
         "anpm,".
         "cbo,".
         "dit,".
         "lcom4,".
         "loc,".
         "mmloc,".
         "noa,".
         "noc,".
         "nom,".
         "npm,".
         "npa,".
         "rfc,".
         "sc\n";

  foreach (@$details)
  {
    if($_->{_filename}[1] eq "")
    {
      $file_name = $_->{_filename}[0];
    }
    else
    {
      $file_name = $_->{_filename}[0]."\/".$_->{_filename}[1];
    }

    push @array_of_values,  "".$file_name.",".
          "".$_->{_module}.",".
          $_->{acc}.",".
          $_->{accm}.",".
          $_->{amloc}.",".
          $_->{anpm}.",".
          $_->{cbo}.",".
          $_->{dit}.",".
          $_->{lcom4}.",".
          $_->{loc}.",".
          $_->{mmloc}.",".
          $_->{noa}.",".
          $_->{noc}.",".
          $_->{nom}.",".
          $_->{npm}.",".
          $_->{npa}.",".
          $_->{rfc}.",".
          $_->{sc}."\n";
  }

  print $csv_handler @array_of_values;
  close $csv_handler;
}

1;

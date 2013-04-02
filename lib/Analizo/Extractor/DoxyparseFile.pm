package Analizo::Extractor::DoxyparseFile;
use strict;
use warnings;

use base qw(Analizo::Extractor::Doxyparse);

sub use_filters {
  0;
}

sub actually_process {
  my $self = shift;
  my $doxyparse_filename = shift;
  open DOXYPARSE_FILE, '<', $doxyparse_filename or die $!;
  while (<DOXYPARSE_FILE>) {
    $self->feed($_);
  }
  close DOXYPARSE_FILE;
  if($@) {
    warn($@);
    exit -1;
  }
}

1;

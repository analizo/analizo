package Analizo::Extractor::Sloccount;

use strict;
use warnings;

use base qw(Analizo::Extractor);

sub new {
  my $package = shift;
  return bless { @_ }, $package;
}

sub feed {
  my ($self, $line) = @_;

  if ($line =~ m/Total Physical Source Lines of Code \(SLOC\)\s+= (\d+)/) {
    $self->model->declare_total_eloc($1);
  }
}

sub process {
  my $self = shift;
  my @files = ();
  eval {
    open SLOCCOUNT, sprintf("sloccount %s |", join(' ', @_) ) or die $!;
    while (<SLOCCOUNT>) {
      $self->feed($_);
    }
    close SLOCCOUNT;
  };

  if($@) {
    warn($@);
    exit -1;
  }
}

1;

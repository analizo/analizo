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

  if ($line =~ m/Total Physical Source Lines of Code \(SLOC\)\s+= ([\d,]*)/) {
    my $eloc = _strip_commas($1);
    $self->model->declare_total_eloc($eloc);
  }
}

sub _strip_commas {
  my $number = shift;
  $number =~ s/,//g;
  return $number;
}

sub actually_process {
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

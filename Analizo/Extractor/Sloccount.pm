package Analizo::Extractor::Sloccount;

use strict;
use warnings;

use Analizo::Extractor;

sub new {
 my ($package, %args) = @_;
  return bless { model => $args{model} }, $package;
}

sub model {
  my $self = shift;
  return $self->{model};
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

package Analizo::Extractor::Sloccount;

use strict;
use warnings;

use base qw(Analizo::Extractor);

use File::Path;
use File::Spec;

sub new {
  my ($package, @options) = @_;
  return bless { @options }, $package;
}

sub feed {
  my ($self, $line) = @_;

  if ($line =~ m/Total Physical Source Lines of Code \(SLOC\)\s+= ([\d,]*)/) {
    my $eloc = _strip_commas($1);
    $self->model->declare_total_eloc($eloc);
  }
}

sub _strip_commas {
  my ($number) = @_;
  $number =~ s/,//g;
  return $number;
}

sub actually_process {
  my ($self, @input_files) = @_;
  my @files = ();
  my $datadir = File::Spec->catfile(File::Spec->tmpdir(), 'analizo-sloccount-' . $$);
  mkdir($datadir);

  eval 'use Alien::SLOCCount';
  $ENV{PATH} = join(':', $ENV{PATH}, Alien::SLOCCount->bin_dir) unless $@;

  eval {
    open SLOCCOUNT, sprintf("sloccount --datadir $datadir %s |", join(' ', @input_files) ) or die $!;
    while (<SLOCCOUNT>) {
      $self->feed($_);
    }
    close SLOCCOUNT;
  };
  File::Path->remove_tree($datadir);

  if($@) {
    warn($@);
    exit -1;
  }
}

1;

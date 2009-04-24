package Egypt::Extractor::Doxyparse;

use strict;
use warnings;

use base qw(Egypt::Extractor);

use File::Basename;

sub new {
  my $package = shift;
  my @defaults = (
    model => Egypt::Model->new, # temporary (?)
  );
  return bless { @defaults, @_ }, $package;
}

sub feed {
  my ($self, $line) = @_;

  # function declarations
  if ($line =~ m/^\s{3}function (\S+) in line \d+$/) {
    $self->model->declare_function($self->current_module, $1);
    $self->{current_function} = $1;
  }

  # function calls/uses
  if ($line =~ m/^\s{6}uses function (\S+) defined in (\S+)$/) {
    # direct calls
    $self->model->add_call($self->current_function, $1, 'direct');
  #} elsif ($line =~ m/^.*\(symbol_ref.*"(.*)".*<function_decl\s.*$/) {
    # indirect calls (e.g. use of function pointers)
    #$self->model->add_call($self->current_function, $1, 'indirect');
  }

  # variable references
  if ($line =~ m/^\s{6}uses variable (\S+) defined in (\S+)$/) {
    $self->model->add_variable_use($self->current_function, $1);
  }

}

sub process {
  my $self = shift;
  my @files = ();
  foreach my $arg (@_) {
    $self->info("Parsing input $arg with Doxyparse ...");
    eval {
      open DOXYPARSE, sprintf("doxyparse %s |", $arg) or die $!;
      while (<DOXYPARSE>) {
         if (/^module (\S+)$/) {
           # discard input file suffix
           my $modulename = fileparse($1, qr/\.[^.]*/);
           $self->current_module($modulename);
         }
         else {
           $self->feed($_);
         }
      }
      close DOXYPARSE;
    };
    if($@) {
      exit -1;
    }
  }
}

1;

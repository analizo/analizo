package Egypt::Extractor::GCC;

use strict;
use warnings;

use base qw(Egypt::Extractor);

use File::Basename;
use File::Find;

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
  if ($line =~ m/^;; Function (\S+)\s*$/) {
    # pre-gcc4 style
    $self->model->declare_function($self->current_module, $1);
    $self->{current_function} = $1;
  } elsif ($line =~ m/^;; Function (.*)\s+\((\S+)\)$/) {
    # gcc4 style
    $self->model->declare_function($self->current_module, $2, $1);
    $self->{current_function} = $2;
  }

  # function calls/uses
  if ($line =~ m/^.*\(call.*"(.*)".*$/) {
    # direct calls
    $self->model->add_call($self->current_function, $1, 'direct');
  } elsif ($line =~ m/^.*\(symbol_ref.*"(.*)".*<function_decl\s.*$/) {
    # indirect calls (e.g. use of function pointers)
    $self->model->add_call($self->current_function, $1, 'indirect');
  }

  # variable references
  if ($line =~ m/^.*\(symbol_ref.*"(.*)".*<var_decl\s.*$/) {
    $self->model->add_variable_use($self->current_function, $1);
  }

}

sub process {
  my $self = shift;
  my @files = ();
  foreach my $arg (@_) {
    if (-d $arg) {
      # directories
      $self->info("Traversing directory $arg ...");
      find(sub { push(@files, $File::Find::name) if basename($File::Find::name) =~ /\.(rtl|expand)$/  }, ($arg));
    } else {
      # files
      if (-r $arg) {
        push(@files, $arg);
      } else {
        $self->warning("$arg is not readable (or doesn't exist at all).");
      }
    }
  }

  if (scalar(@files) == 0) {
    $self->error("No readable input files!");
    exit(1);
  }

  foreach my $file (@files) {
    my $modulename = $file;
    $modulename =~ s/\.\d+r\.expand$//;
    $self->current_module($modulename);

    open FILE, '<', $file or die("Cannot read $file");
    while (<FILE>) {
      $self->feed($_);
    }
    close FILE;
  }
}

1;

package Analizo::Extractor::Doxyparse;

use strict;
use warnings;

use base qw(Analizo::Extractor);

use File::Basename;

sub new {
  my $package = shift;
  return bless { @_ }, $package;
}

sub feed {
  my ($self, $line) = @_;

  # function declarations
  if ($line =~ m/^\s{3}function (.*) in line \d+$/) {
    my $function = _qualified_name($self->current_module, $1);
    $self->model->declare_function($self->current_module, $function);
    $self->{current_member} = $function;
  }
  # variable declarations
  elsif ($line =~ m/^\s{3}variable (\S+) in line \d+$/) {
    my $variable = _qualified_name($self->current_module, $1);
    $self->model->declare_variable($self->current_module, $variable);
    $self->{current_member} = $variable;
  }

  # inheritance
  if ($line =~ m/^\s{3}inherits from (.+)$/) {
    $self->model->add_inheritance($self->current_module, $1);
  }

  # function calls/uses
  if ($line =~ m/^\s{6}uses function (.*) defined in (\S+)$/) {
    my $function = _qualified_name($2, $1);
    $self->model->add_call($self->current_member, $function, 'direct');
  }

  # variable references
  elsif ($line =~ m/^\s{6}uses variable (\S+) defined in (\S+)$/) {
    my $variable = _qualified_name($2, $1);
    $self->model->add_variable_use($self->current_member, $variable);
  }

  # public members
  if ($line =~ m/^\s{6}protection public$/) {
    $self->model->add_protection($self->current_member, 'public');
  }

  # method LOC
  if($line =~ m/^\s{6}(\d+) lines of code$/){
    $self->model->add_loc($self->current_member, $1);
  }

  #method parameters
  if($line =~ m/^\s{6}(\d+) parameters$/) {
    $self->model->add_parameters($self->current_member, $1);
  }

  #method conditional paths
  if($line =~ m/^\s{6}(\d+) conditional paths$/){
    $self->model->add_conditional_paths($self->current_member, $1);
  }

  # abstract class
  if ($line =~ m/^\s{3}abstract class$/) {
    $self->model->add_abstract_class($self->current_module);
  }
}

# concat module with symbol (e.g. main::to_string)
sub _qualified_name {
  my ($file, $symbol) = @_;
  _file_to_module($file) . '::' . $symbol;
}

# discard file suffix (e.g. .c or .h)
sub _file_to_module {
  my $filename = shift;
  $filename ? fileparse($filename, qr/\.[^.]*/) : 'unknown';
}

sub process {
  my $self = shift;
  eval {
    open DOXYPARSE, sprintf("doxyparse %s |", join(' ', @_) ) or die $!;
    while (<DOXYPARSE>) {
       if (/^module (\S+)$/) {
         my $modulename = _file_to_module($1);
         $self->current_module($modulename);
       }
       else {
         $self->feed($_);
       }
    }
    close DOXYPARSE;
  };
  if($@) {
    warn($@);
    exit -1;
  }
}

1;


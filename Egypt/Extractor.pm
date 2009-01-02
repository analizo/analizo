package Egypt::Extractor;

use strict;
use warnings;

use base qw(Class::Accessor::Fast);

use Egypt::Output::DOT;

__PACKAGE__->mk_accessors(qw(output current_module));
__PACKAGE__->mk_ro_accessors(qw(current_function));

sub new {
  my $package = shift;
  my @defaults = (
    output => new Egypt::Output::DOT, # temporary (?)
  );
  return bless { @defaults, @_ }, __PACKAGE__;
}

sub feed {
  my ($self, $line) = @_;

  # function declarations
  if ($line =~ m/^;; Function (\S+)\s*$/) {
    # pre-gcc4 style
    $self->output->declare_function($self->current_module, $1);
    $self->{current_function} = $1;
  } elsif ($line =~ m/^;; Function (.*)\s+\((\S+)\)$/) {
    # gcc4 style
    $self->output->declare_function($self->current_module, $2, $1);
    $self->{current_function} = $2;
  }

  # function calls/uses
  if ($line =~ m/^.*\(call.*"(.*)".*$/) {
    # direct calls
    $self->output->add_call($self->current_function, $1, 'direct');
  } elsif ($line =~ m/^.*\(symbol_ref.*"(.*)".*<function_decl\s.*$/) {
    # indirect calls (e.g. use of function pointers)
    $self->output->add_call($self->current_function, $1, 'indirect');
  }

  # variable references
  if ($line =~ m/^.*\(symbol_ref.*"(.*)".*<var_decl\s.*$/) {
    $self->output->add_variable_use($self->current_function, $1);
  }

}


1;

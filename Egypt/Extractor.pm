package Egypt::Extractor;

use strict;
use warnings;

use base qw(Class::Accessor::Fast);

use Egypt::Output::DOT;

__PACKAGE__->mk_accessors(qw(output));
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

sub current_module {
  my $self = shift;

  # set the new value
  if (scalar @_) {
    $self->{current_module} = shift;
  }

  # read variable declarations
  $self->_read_variable_declarations();

  return $self->{current_module};
}

sub _read_variable_declarations {
  my $self = shift;
  return unless -r $self->{current_module};
  open TAGS, sprintf('ctags-exuberant -f - --fields=K %s |' ,$self->{current_module});
  while (<TAGS>) {
    chomp;
    my @fields = split(/\t/);
    if ($fields[3] eq 'variable') {
      $self->output->declare_variable($self->{current_module}, $fields[0]);
    }
  }
  close TAGS;
}

1;

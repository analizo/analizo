package Egypt::Model;
use strict;

sub new {
  my @defaults = (
    functions => {},
    modules => {},
    demangle => {},
    calls => {},
  );
  return bless { @defaults }, __PACKAGE__;
}

sub modules {
  my $self = shift;
  return $self->{modules};
}

sub functions {
  my $self = shift;
  return $self->{functions};
}

sub declare_function {
  my ($self, $module, $function, $demangled_name) = @_;

  # mapping function to module
  $self->{functions}->{$function} = $module;

  # mapping module to functions
  $self->modules->{$module} = [] if !exists($self->modules->{$module});
  push @{$self->modules->{$module}}, $function;

  # demangling name
  $self->{demangle}->{$function} = $demangled_name;
}

sub demangle {
  my $self = shift;
  my $function = shift;
  return $self->{demangle}->{$function} || $function;
}

sub declare_variable {
  declare_function(@_);
}

sub add_call {
  my ($self, $caller, $callee, $reftype) = @_;
  $reftype ||= 'direct';
  $self->{calls}->{$caller} = {} if !exists($self->{calls}->{$caller});
  $self->{calls}->{$caller}->{$callee} = $reftype;
}

sub calls {
  my $self = shift;
  return $self->{calls};
}

sub add_variable_use {
  add_call(@_, 'variable');
}

1;

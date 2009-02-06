package Egypt::Model;
use strict;

sub new {
  my @defaults = (
    members => {},
    types => {},
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

sub members {
  my $self = shift;
  return $self->{members};
}

sub declare_member {
  my ($self, $module, $member, $demangled_name, $type) = @_;

  # mapping member to module
  $self->{members}->{$member} = $module;

  # mapping module to member
  $self->modules->{$module} = [] if !exists($self->modules->{$module});
  push @{$self->modules->{$module}}, $member;

  # demangling name
  $self->{demangle}->{$member} = $demangled_name;

  # registering type of member
  $self->{types}->{$member} = $type;
}

sub type {
  my ($self, $member) = @_;
  return $self->{types}->{$member};
}

sub declare_function {
  my ($self, $module, $function, $demangled_name) = @_;
  $self->declare_member($module, $function, $demangled_name, 'function');
}

sub declare_variable {
  my ($self, $module, $variable, $demangled_name) = @_;
  $self->declare_member($module, $variable, $demangled_name, 'variable');
}

sub demangle {
  my $self = shift;
  my $function = shift;
  return $self->{demangle}->{$function} || $function;
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

sub _find_by_type {
  my ($self, $module, $type) = @_;
  return grep { $self->members->{$_} eq $module && $self->type($_) eq $type } keys(%{$self->members});
}

sub functions {
  _find_by_type(@_, 'function');
}

sub variables {
  _find_by_type(@_, 'variable');
}


1;

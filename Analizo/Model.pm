package Analizo::Model;
use strict;

sub new {
  my @defaults = (
    members => {},
    modules => {},
    demangle => {},
    calls => {},
    lines => {},
    protection => {},
    inheritance => {},
    parameters  => {},
    conditional_paths => {},
    module_names => [],
  );
  return bless { @defaults }, __PACKAGE__;
}

sub modules {
  my $self = shift;
  return $self->{modules};
}

sub module_names {
  my $self = shift;
  return @{$self->{module_names}};
}

sub declare_module {
  my ($self, $module) = @_;
  if (! grep { $_ eq $module} @{$self->{module_names}}) {
    push @{$self->{module_names}}, $module;
  }
}

sub inheritance {
  my ($self, $module) = @_;
  my $list = $self->{inheritance}->{$module};
  return $list ? @$list : ();
}

sub add_inheritance {
  my ($self, $child, $parent) = @_;
  $self->{inheritance}->{$child} = [] if !exists($self->{inheritance}->{$child});
  push @{$self->{inheritance}->{$child}}, $parent;
}

sub members {
  my $self = shift;
  return $self->{members};
}

sub declare_member {
  my ($self, $module, $member, $demangled_name, $type) = @_;

  # mapping member to module
  $self->{members}->{$member} = $module;

  # demangling name
  $self->{demangle}->{$member} = $demangled_name;
}

sub type {
  my ($self, $member) = @_;
  return $self->{types}->{$member};
}

sub declare_function {
  my ($self, $module, $function, $demangled_name) = @_;
  $self->declare_member($module, $function, $demangled_name, 'function');

  if (!exists($self->{modules}->{$module})){
    $self->{modules}->{$module} = {};
    $self->{modules}->{$module}->{functions} = [];
  }
  if(! grep { $_ eq $function } @{$self->{modules}->{$module}->{functions}}){
    push @{$self->{modules}->{$module}->{functions}}, $function;
  }
}

sub declare_variable {
  my ($self, $module, $variable, $demangled_name) = @_;
  $self->declare_member($module, $variable, $demangled_name, 'variable');

  if (!exists($self->{modules}->{$module})){
    $self->{modules}->{$module} = {};
    $self->{modules}->{$module}->{variables} = [];
  }
  if(! grep { $_ eq $variable } @{$self->{modules}->{$module}->{variables}}){
    push @{$self->{modules}->{$module}->{variables}}, $variable;
  }
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

sub add_loc {
    my ($self, $function, $lines) = @_;
    $self->{lines}->{$function} = $lines;
}

sub add_conditional_paths {
  my ($self, $function, $conditional_paths) = @_;
  $self->{conditional_paths}->{$function} = $conditional_paths;
}

sub add_protection {
    my ($self, $member, $protection) = @_;
     $self->{protection}->{$member} = $protection;
}

sub add_parameters {
  my ($self, $function, $parameters) = @_;
  $self->{parameters}->{$function} = $parameters;
}

sub functions {
  my ($self, $module) = @_;
  my $list = $self->{modules}->{$module}->{functions};
  return $list ? @$list : ();
}

sub variables {
  my ($self, $module) = @_;
  my $list = $self->{modules}->{$module}->{variables};
  return $list ? @$list : ();
}

sub all_members {
 my ($self, $module) = @_;
 my @functions = $self->functions($module);
 my @variables = $self->variables($module);
 return @functions, @variables;
}

1;


package Analizo::Model;
use strict;
use Graph;

sub new {
  my @defaults = (
    graph => undef,
    members => {},
    modules => {},
    files => {},
    module_by_file => {},
    demangle => {},
    calls => {},
    lines => {},
    protection => {},
    inheritance => {},
    parameters  => {},
    conditional_paths => {},
    abstract_classes => [],
    module_names => [],
    total_eloc => 0
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

sub declare_total_eloc {
  my ($self, $total_eloc) = @_;
  $self->{total_eloc} = $total_eloc;
}

sub total_eloc {
  my ($self) = shift;
  return $self->{total_eloc};
}

sub declare_module {
  my ($self, $module, $file) = @_;
  if (! grep { $_ eq $module} @{$self->{module_names}}) {
    push @{$self->{module_names}}, $module;
  }
  if (defined($file)) {
    $self->{files}->{$module} ||= [];
    push(@{$self->{files}->{$module}}, $file);

    $self->{module_by_file}->{$file} ||= [];
    push @{$self->{module_by_file}->{$file}}, $module;
  }
}

sub files {
  my ($self, $module) = @_;
  return $self->{files}->{$module};
}

sub module_by_file {
  my ($self, $file) = @_;
  return @{$self->{module_by_file}->{$file} || []};
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
  return unless $module;
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

sub abstract_classes {
  my $self = shift;
  my $list = $self->{abstract_classes};
  return $list ? @$list : ();
}

sub add_abstract_class {
  my ($self, $module) = @_;
  push @{$self->{abstract_classes}},$module;
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

sub graph {
  my $self = shift;
  $self->{graph};
}

sub _group_files {
  my @files = @_;
  (my $file = $files[0]) =~ s/\.[^.]+$//;
  $file;
}

sub build_graph {
  my $self = shift;
  $self->{graph} = Graph->new;
  $self->{graph}->set_graph_attribute('name', 'callgraph');
  foreach (keys %{ $self->{files}}) {
    my $file = _group_files(@{ $self->files($_) });
    $self->{graph}->add_vertices($file);
  }
  foreach my $caller (keys %{$self->calls}) {
    my $calling_file = $self->_function_to_file($caller);
    next unless $calling_file;
    $calling_file = _group_files(@{$calling_file});
    $self->{graph}->add_vertex($calling_file);
    foreach my $callee (keys %{$self->calls->{$caller}}) {
      my $called_file = $self->_function_to_file($callee);
      next unless ($calling_file && $called_file);
      next if ($calling_file eq $called_file);
      $called_file = _group_files(@{$called_file});
      $self->{graph}->add_edge($calling_file, $called_file);
    }
  }
  foreach my $subclass (keys(%{$self->{inheritance}})) {
    my $subclass_file = $self->files($subclass);
    next unless $subclass_file;
    $subclass_file = _group_files(@{$subclass_file});
    $self->{graph}->add_vertex($subclass_file);
    foreach my $superclass ($self->inheritance($subclass)) {
      my $superclass_file = $self->files($superclass);
      next unless $superclass_file;
      $superclass_file = _group_files(@{$superclass_file});
      $self->{graph}->add_edge($subclass_file, $superclass_file);
    }
  }
}

sub _function_to_file {
  my ($self, $function) = @_;
  return unless exists $self->members->{$function};
  my $module = $self->members->{$function};
  $self->{files}->{$module};
}

1;

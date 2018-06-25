package Analizo::Model;
use strict;
use Graph;
use File::Basename;

sub new {
  my @defaults = (
    members => {},
    modules => {},
    files => {},
    module_by_file => {},
    calls => {},
    lines => {},
    protection => {},
    inheritance => {},
    parameters  => {},
    conditional_paths => {},
    abstract_classes => [],
    module_names => [],
    graph => undef,
  );
  return bless { @defaults }, __PACKAGE__;
}

sub modules {
  my ($self) = @_;
  return $self->{modules};
}

sub module_names {
  my ($self) = @_;
  return @{$self->{module_names}};
}

sub declare_module {
  my ($self, $module, $file) = @_;
  if (! grep { $_ eq $module} @{$self->{module_names}}) {
    push @{$self->{module_names}}, $module;
  }
  if (defined($file)) {
    #undup filename
    foreach (@{$self->{files}->{$module}}) {
      return if($_ eq $file);
    }

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
  my ($self) = @_;
  return $self->{members};
}

sub declare_member {
  my ($self, $module, $member, $type) = @_;

  # mapping member to module
  $self->{members}->{$member} = $module;
}

sub type {
  my ($self, $member) = @_;
  return $self->{types}->{$member};
}

sub declare_function {
  my ($self, $module, $function) = @_;
  return unless $module;
  $self->declare_member($module, $function, 'function');

  if (!exists($self->{modules}->{$module})){
    $self->{modules}->{$module} = {};
    $self->{modules}->{$module}->{functions} = [];
  }
  if(! grep { $_ eq $function } @{$self->{modules}->{$module}->{functions}}){
    push @{$self->{modules}->{$module}->{functions}}, $function;
  }
}

sub declare_variable {
  my ($self, $module, $variable) = @_;
  $self->declare_member($module, $variable, 'variable');

  if (!exists($self->{modules}->{$module})){
    $self->{modules}->{$module} = {};
    $self->{modules}->{$module}->{variables} = [];
  }
  if(! grep { $_ eq $variable } @{$self->{modules}->{$module}->{variables}}){
    push @{$self->{modules}->{$module}->{variables}}, $variable;
  }
}

sub add_call {
  my ($self, $caller, $callee, $reftype) = @_;
  $reftype ||= 'direct';
  $self->{calls}->{$caller} = {} if !exists($self->{calls}->{$caller});
  $self->{calls}->{$caller}->{$callee} = $reftype;
}

sub calls {
  my ($self) = @_;
  return $self->{calls};
}

sub abstract_classes {
  my ($self) = @_;
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
  $self->{protection}->{$member} = $protection if $member;
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

sub _group_files {
  my @files = @_;
  (my $file = $files[0]) =~ s/\.[^.]+$//;
  $file;
}

sub graph {
  my ($self) = @_;
  return $self->{graph} if $self->{graph};
  my $graph = Graph->new;
  $graph->set_graph_attribute('name', 'graph');
  foreach my $module (keys %{$self->{files}}) {
    $graph->add_vertex($module);
  }
  foreach my $caller (keys %{$self->calls}) {
    next unless exists $self->members->{$caller};
    my $calling_module = $self->members->{$caller};
    $graph->add_vertex($calling_module);
    foreach my $callee (keys %{$self->calls->{$caller}}) {
      next unless exists $self->members->{$callee};
      my $called_module = $self->members->{$callee};
      $graph->add_vertex($called_module);
      next if ($calling_module eq $called_module);
      $graph->add_edge($calling_module, $called_module);
    }
  }
  foreach my $subclass (keys(%{$self->{inheritance}})) {
    $graph->add_vertex($subclass);
    foreach my $superclass ($self->inheritance($subclass)) {
      $self->_recursive_children($subclass, $superclass, $graph);
    }
  }
  $self->{graph} = $graph;
  $graph;
}

sub _recursive_children {
  my ($self, $subclass, $superclass, $graph) = @_;
  $graph->add_edge($subclass, $superclass);

  foreach my $super_uper_class ($self->inheritance($superclass)) {
    $self->_recursive_children($subclass, $super_uper_class, $graph);
  }
}

sub _function_to_file {
  my ($self, $function) = @_;
  return unless exists $self->members->{$function};
  my $module = $self->members->{$function};
  $self->{files}->{$module};
}

sub _add_dependency {
  my ($dependencies, $from, $to) = @_;
  $dependencies->{$from} = { } if !exists($dependencies->{$from});
  if (exists $dependencies->{$from}->{$to}) {
    $dependencies->{$from}->{$to} += 1;
  } else {
    $dependencies->{$from}->{$to} = 1;
  }
}

sub _reftype_to_style {
  my ($reftype) = @_;
  $reftype = $reftype || 'direct';
  my %styles = (
    'direct' => 'solid',
    'indirect' => 'dotted',
    'variable' => 'dashed',
  );
  return $styles{$reftype} || 'solid';
}

sub callgraph {
  my ($self, %args) = @_;
  my $graph = Graph->new;
  $graph->set_graph_attribute('name', 'callgraph');

  if ($args{group_by_module}) {
    # listing dependencies grouped by module
    my $modules_dependencies = { };
    foreach my $caller (sort(keys %{$self->calls})) {
      foreach my $callee (sort(keys %{$self->calls->{$caller}})) {
        my $calling_module = $self->_function_to_module($caller);
        my $called_module = $self->_function_to_module($callee);
        next unless (defined($calling_module) && defined($called_module) && ($calling_module ne $called_module));
        _add_dependency($modules_dependencies, $calling_module, $called_module);
      }
    }
    foreach my $subclass (sort(keys(%{$self->{inheritance}}))) {
      foreach my $superclass ($self->inheritance($subclass)) {
        _add_dependency($modules_dependencies, $subclass, $superclass);
      }
    }

    foreach my $calling_module (sort(keys %{$modules_dependencies})) {
      foreach my $called_module (sort(keys %{$modules_dependencies->{$calling_module}})) {
        my $strength = $modules_dependencies->{$calling_module}->{$called_module};
        $graph->add_edge($calling_module, $called_module);
        $graph->set_edge_attribute($calling_module, $called_module, 'style', 'solid');
        $graph->set_edge_attribute($calling_module, $called_module, 'label', $strength);
      }
    }

  } else {
    # listing raw dependency info
    foreach my $caller (grep { $self->_include_caller($_, @{$args{omit}}) } sort(keys(%{$self->calls}))) {
      foreach my $callee (grep { $self->_include_callee($_, $args{include_externals}, @{$args{omit}}) } sort(keys(%{$self->calls->{$caller}}))) {
        my $style = _reftype_to_style($self->calls->{$caller}->{$callee});
        $graph->add_edge($caller, $callee);
        $graph->set_edge_attribute($caller, $callee, 'style', $style);
        $graph->set_vertex_attribute($caller, 'group', $self->_function_to_module($caller));
        $graph->set_vertex_attribute($callee, 'group', $self->_function_to_module($callee));
      }
    }
  }
  return $graph;
}

sub _file_to_module {
  my ($filename) = @_;
  $filename =~ s/\.r\d+\.expand$//;
  return basename($filename);
}

sub _function_to_module {
  my ($self, $function) = @_;
  return undef if !exists($self->members->{$function});
  return _file_to_module($self->members->{$function});
}

sub _include_caller {
  my ($self, $function, @omitted) = @_;
  return !grep { $function eq $_ } @omitted;
}

sub _include_callee {
  my ($self, $member, $include_externals, @omitted) = @_;
  return $self->_include_caller($member, @omitted) && ( exists($self->members->{$member}) || $include_externals );
}

1;

package Egypt::Output::DOT;

use strict;
use warnings;
use base qw(Class::Accessor::Fast);
use File::Basename;

Egypt::Output::DOT->mk_accessors(qw(filename cluster group_by_module include_externals));

sub new {
  my $package = shift;
  my @defaults = (
    filename => 'output.dot',
    calls => {},
    modules => {},
    functions => {},
    omitted => {},
    demangled => {},
  );
  return bless { @defaults, @_ }, __PACKAGE__;
}

sub string {
  my $self = shift;
  my $result = "digraph callgraph {\n";

  if ($self->cluster) {
    $result .= $self->_calculate_clusters();
  }

  if ($self->group_by_module) {
    # listing dependencies grouped by module
    my $modules_dependencies = { };
    foreach my $caller (keys %{$self->{calls}}) {
      foreach my $callee (keys %{$self->{calls}->{$caller}}) {
        my $calling_module = $self->_function_to_module($caller);
        my $called_module = $self->_function_to_module($callee);
        next unless (defined($calling_module) && defined($called_module) && ($calling_module ne $called_module));
        $modules_dependencies->{$calling_module} = { } if !exists($modules_dependencies->{$calling_module});
        if (exists $modules_dependencies->{$calling_module}->{$called_module}) {
          $modules_dependencies->{$calling_module}->{$called_module} += 1;
        } else {
          $modules_dependencies->{$calling_module}->{$called_module} = 1;
        }
      }
    }
    foreach my $calling_module (sort(keys %{$modules_dependencies})) {
      foreach my $called_module (sort(keys %{$modules_dependencies->{$calling_module}})) {
        my $strength = $modules_dependencies->{$calling_module}->{$called_module};
        $result .= sprintf("\"%s\" -> \"%s\" [style=solid,label=%d];\n", $calling_module, $called_module, $strength);
      }
    }

  } else {
    # listing raw dependency info
    foreach my $caller (grep { $self->_include_caller($_) } keys(%{$self->{calls}})) {
      foreach my $callee (grep { $self->_include_callee($_) } keys(%{$self->{calls}->{$caller}})) {
        my $style = _reftype_to_style($self->{calls}->{$caller}->{$callee});
        $result .= sprintf("\"%s\" -> \"%s\" [style=%s];\n", $self->_demangle($caller), $self->_demangle($callee), $style);
      }
    }
  }
  $result .= "}\n";

  return $result;
}

sub add_call {
  my $self = shift;
  my ($caller, $callee, $reftype) = @_;
  $self->{calls}->{$caller} = {} unless exists($self->{calls}->{$caller});
  $self->{calls}->{$caller}->{$callee} = $reftype;
}

sub add_variable_use {
  my $self = shift;
  my ($using_module, $used_var) = @_;
  $self->add_call($using_module, $used_var, 'variable');
}

sub declare_function {
  my ($self, $module, $function, $demangled) = @_;

  # map module to functions
  $self->{modules}->{$module} = [] if !exists($self->{modules}->{$module});
  push @{$self->{modules}->{$module}}, $function;

  # map function to module
  $self->{functions}->{$function} = $module;

  # record mangled/demangled name mapping
  $self->{demangled}->{$function} = $demangled;
}

sub declare_variable {
  my $self = shift;
  $self->declare_function(@_);
}

sub omit {
  my ($self, $omitted) = @_;
  $self->{omitted}->{$omitted} = 1;
}

sub _include_caller {
  my ($self, $function) = @_;
  return !exists($self->{omitted}->{$function});
}

sub _include_callee {
  my ($self, $function) = @_;
  return $self->_include_caller($function) && (exists($self->{functions}->{$function}) || $self->include_externals)
}

sub _calculate_clusters {
  my $self = shift;
  my $result = "";
  foreach my $module (sort(keys(%{$self->{modules}}))) {
    $result .= "subgraph \"cluster_$module\" {\n";
    $result .= sprintf("  label = \"%s\";\n", _file_to_module($module));
    foreach my $function (@{$self->{modules}->{$module}}) {
      my $demangled = $self->_demangle($function);
      $result .= sprintf("  node [label=\"%s\"] \"%s\";\n", $demangled, $demangled);
    }
    $result .= "}\n";
  }
  return $result;
}

sub _function_to_module {
  my ($self, $function) = @_;
  return undef if !exists($self->{functions}->{$function});
  return _file_to_module($self->{functions}->{$function});
}

sub _file_to_module {
  my $filename = shift;
  $filename =~ s/\.r\d+\.expand$//;
  return basename($filename);
}

sub _reftype_to_style {
  my $reftype = shift || 'direct';
  my %styles = (
    'direct' => 'solid',
    'indirect' => 'dotted',
    'variable' => 'dashed',
  );
  return $styles{$reftype} || 'solid';
}

sub _demangle {
  my ($self, $mangled) = @_;
  return $self->{demangled}->{$mangled} || $mangled;
}

1;


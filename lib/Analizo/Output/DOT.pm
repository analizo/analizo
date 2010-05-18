package Analizo::Output::DOT;

use strict;
use warnings;
use base qw(Class::Accessor::Fast);
use File::Basename;
use Analizo::Model;

__PACKAGE__->mk_accessors(qw(filename cluster group_by_module include_externals));
__PACKAGE__->mk_ro_accessors(qw(model));

sub new {
  my $package = shift;
  my @defaults = (
    filename => 'output.dot',
    omitted => {},
  );
  my $self = { @defaults, @_ };
  if (!$self->{model}) {
    $self->{model} = new Analizo::Model;
  }
  return bless $self, $package;
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

sub string {
  my $self = shift;
  my $result = "digraph callgraph {\n";

  if ($self->cluster) {
    $result .= $self->_calculate_clusters();
  }

  if ($self->group_by_module) {
    # listing dependencies grouped by module
    my $modules_dependencies = { };
    foreach my $caller (keys %{$self->model->calls}) {
      foreach my $callee (keys %{$self->model->calls->{$caller}}) {
        my $calling_module = $self->_function_to_module($caller);
        my $called_module = $self->_function_to_module($callee);
        next unless (defined($calling_module) && defined($called_module) && ($calling_module ne $called_module));
        _add_dependency($modules_dependencies, $calling_module, $called_module);
      }
    }
    foreach my $subclass (keys(%{$self->model->{inheritance}})) {
      foreach my $superclass ($self->model->inheritance($subclass)) {
        _add_dependency($modules_dependencies, $subclass, $superclass);
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
    foreach my $caller (grep { $self->_include_caller($_) } keys(%{$self->model->calls})) {
      foreach my $callee (grep { $self->_include_callee($_) } keys(%{$self->model->calls->{$caller}})) {
        my $style = _reftype_to_style($self->model->calls->{$caller}->{$callee});
        $result .= sprintf("\"%s\" -> \"%s\" [style=%s];\n", $self->_demangle($caller), $self->_demangle($callee), $style);
      }
    }
  }
  $result .= "}\n";

  return $result;
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
  my ($self, $member) = @_;
  return $self->_include_caller($member) && ( exists($self->model->members->{$member}) || $self->include_externals );
}

sub _calculate_clusters {
  my $self = shift;
  my $result = "";
  foreach my $module (sort(keys(%{$self->model->modules}))) {
    $result .= "subgraph \"cluster_$module\" {\n";
    $result .= sprintf("  label = \"%s\";\n", _file_to_module($module));
    foreach my $member ($self->model->all_members($module)) {
      my $demangled = $self->_demangle($member);
      $result .= sprintf("  node [label=\"%s\"] \"%s\";\n", $demangled, $demangled);
    }
    $result .= "}\n";
  }
  return $result;
}

sub _function_to_module {
  my ($self, $function) = @_;
  return undef if !exists($self->model->members->{$function});
  return _file_to_module($self->model->members->{$function});
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
  return $self->model->demangle($mangled);
}

1;


package Egypt::Output::DOT;

use strict;
use warnings;
use base qw(Class::Accessor::Fast);

Egypt::Output::DOT->mk_accessors(qw(filename cluster group_by_module));

sub new {
  my $package = shift;
  my @defaults = (
    filename => 'output.dot',
    calls => {},
    modules => {},
    functions => {},
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
    foreach my $caller (keys(%{$self->{calls}})) {
      foreach my $callee (keys(%{$self->{calls}->{$caller}})) {
        my $style = _reftype_to_style($self->{calls}->{$caller}->{$callee});
        $result .= "\"$caller\" -> \"$callee\" [style=$style];\n";
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

sub add_in_module {
  my ($self, $module, $function) = @_;

  # map module to functions
  $self->{modules}->{$module} = [] if !exists($self->{modules}->{$module});
  push @{$self->{modules}->{$module}}, $function;

  # map function to module
  $self->{functions}->{$function} = $module;
}

sub _calculate_clusters {
  my $self = shift;
  my $result = "";
  foreach my $module (sort(keys(%{$self->{modules}}))) {
    $result .= "subgraph \"cluster_$module\" {\n";
    $result .= sprintf("  label \"%s\";\n", _file_to_module($module));
    foreach my $function (@{$self->{modules}->{$module}}) {
      $result .= "  node [label=\"$function\"] \"$function\";\n";
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
  return $filename;
}

sub _reftype_to_style {
  my $reftype = shift;
  my %styles = (
    'direct' => 'solid',
    'indirect' => 'dotted',
  );
  return $styles{$reftype} || 'solid';
}

1;


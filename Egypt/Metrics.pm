package Egypt::Metrics;
use strict;
use base qw(Class::Accessor::Fast);
use List::Compare;
use Graph;
use YAML;

__PACKAGE__->mk_accessors(qw(model));

sub new {
  my ($package, %args) = @_;
  return bless { model => $args{model} }, $package;
}

sub coupling {
  my ($self, $module) = @_;
  my %seen = ();
  for my $caller_function (@{$self->model->modules->{$module}}) {
    for my $called_function (keys(%{$self->model->calls->{$caller_function}})) {
      my $called_module = $self->model->members->{$called_function};
      next if $called_module eq $module;
      $seen{$called_module}++;
    }
  }
  return (scalar keys(%seen));
}

sub lcom1 {
  my ($self, $module) = @_;
  my @functions = $self->model->functions($module);
  my $n = scalar @functions;
  my $result = 0;
  # test each pair of functions in module for relation
  for (my $i = 0; $i < $n; $i++) {
    for (my $j = $i + 1; $j < $n; $j++) {
      if (!$self->_related($module, $functions[$i], $functions[$j])) {
        $result += 1
      }
    }
  }
  return $result;
}

sub _related {
  my ($self, $module, $f1, $f2) = @_;
  my @calls_f1 = keys(%{$self->model->calls->{$f1}});
  my @calls_f2 = keys(%{$self->model->calls->{$f2}});

  # f1 and f2 use variables in common
  my @variables = $self->model->variables($module);
  my $lc = new List::Compare(\@calls_f1, \@calls_f2);
  my @intersection = $lc->get_intersection;
  return 0 if (scalar @intersection == 0);

  $lc = new List::Compare(\@intersection, \@variables);
  my @local_intersection = $lc->get_intersection;
  return 1 if (scalar @local_intersection > 0);

  return 0;
}

sub lcom4 {
  my ($self, $module) = @_;
  my $graph = new Graph;
  for my $function ($self->model->functions($module)) {
    $graph->add_vertex($function);
    for my $used (keys(%{$self->model->calls->{$function}})) {
      $graph->add_edge($function, $used);
    }
  }
  my @components = $graph->weakly_connected_components;
  return scalar @components;
}

sub interface_size {
  my ($self, $module) = @_;
  return (scalar $self->model->functions($module));
}

sub report {
  my $self = shift;
  my $result = '';
  for my $module (keys(%{$self->model->modules})) {
    my %data = (
      _module => $module,
      coupling => $self->coupling($module),
      interface_size => $self->interface_size($module),
      lcom1 => $self->lcom1($module),
      lcom4 => $self->lcom4($module),
    );
    $result .= Dump(\%data);
  }
  return $result;
}

1;

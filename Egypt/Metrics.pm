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
      next if $called_module && ($called_module eq $module);
      $seen{$called_module}++ if $called_module;
    }
  }
  return (scalar keys(%seen));
}

sub loc {
  my ($self, $module) = @_;

  my @functions = $self->model->functions($module);
  my $lines = 0;
  my $max = 0;
  for my $function (@functions) {
    my $loc = $self->model->{lines}->{$function} || 0;
    $lines += $loc;
    $max = $loc if $loc > $max;
  }
  return ($lines, $max);
}

sub _is_public {
  my ($self, $member) = @_;
  return $self->model->{protection}->{$member} && $self->model->{protection}->{$member} eq "public";
}


sub public_functions {
  my ($self, $module) = @_;

  my @functions = $self->model->functions($module);
  my $public_functions = 0;
  for my $function (@functions) {
    $public_functions += 1 if $self->_is_public($function);
  }
  return $public_functions;
}

sub public_variables {
  my ($self, $module) = @_;

  my @variables = $self->model->variables($module);
  my $public_variables = 0;
  for my $variable (@variables) {
    $public_variables += 1 if $self->_is_public($variable);
  }
  return $public_variables;
}

sub lcom1 {
  my ($self, $module) = @_;
  my @functions = $self->model->functions($module);
  my $n = scalar @functions;
  my $result = 0;
  # test each pair of functions in module for relation
  for (my $i = 0; $i < $n; $i++) {
    for (my $j = $i + 1; $j < $n; $j++) {
      if ($self->_related($module, $functions[$i], $functions[$j])) {
        $result -= 1;
      } else {
        $result += 1
      }
    }
  }
  return $result > 0 ? $result : 0;
}

sub _related {
  my ($self, $module, $f1, $f2) = @_;

  # the variables and functions in the module
  my @variables = $self->model->variables($module);

  my @calls_f1 = keys(%{$self->model->calls->{$f1}});
  my @calls_f2 = keys(%{$self->model->calls->{$f2}});

  # f1 and f2 use variables in common
  my $lc = new List::Compare(\@calls_f1, \@calls_f2, \@variables);
  my @intersection = $lc->get_intersection;
  return (scalar @intersection == 0) ? 0 : 1;

  return 0;
}

sub lcom4 {
  my ($self, $module) = @_;
  my $graph = new Graph;
  my @functions = $self->model->functions($module);
  my @variables = $self->model->variables($module);
  for my $function (@functions) {
    $graph->add_vertex($function);
    for my $used (keys(%{$self->model->calls->{$function}})) {
      # only include in the graph functions and variables that are inside the module.
      if ((grep { $_ eq $used } @functions) || (grep { $_ eq $used } @variables)) {
        $graph->add_edge($function, $used);
      }
    }
  }
  my @components = $graph->weakly_connected_components;
  return scalar @components;
}

sub number_of_functions {
  my ($self, $module) = @_;
  return (scalar $self->model->functions($module));
}

sub amz_size {
  my ($lines, $count)= @_;
  return ($count > 0) ? ($lines / $count) : 0;
}

sub report {
  my $self = shift;
  my $result = '';
  my %totals = (
    coupling => 0,
    lcom1 => 0,
    lcom4 => 0,
    number_of_functions => 0,
    number_of_modules => 0,
    public_functions => 0,
    number_of_public_functions => 0,
    loc => 0
  );

  for my $module (keys(%{$self->model->modules})) {
    my $coupling = $self->coupling($module);
    my $number_of_functions = $self->number_of_functions($module);
    my $lcom1 = $self->lcom1($module);
    my $lcom4 = $self->lcom4($module);
    my ($lines, $max_mloc) = $self->loc($module);
    my $public_functions = $self->public_functions($module);
    my $amz_size = amz_size($lines, $number_of_functions);
    my $public_variables = $self->public_variables($module);

    my %data = (
      _module => $module,
      amz_size => $amz_size,
      coupling => $coupling,
      coupling_times_lcom1 => $coupling * $lcom1,
      coupling_times_lcom4 => $coupling * $lcom4,
      number_of_functions => $number_of_functions,
      lcom1 => $lcom1,
      lcom4 => $lcom4,
      loc => $lines,
      max_mloc => $max_mloc,
      public_functions => $public_functions,
      public_variables => $public_variables
    );
    $result .= Dump(\%data);

    $totals{'coupling'} += $coupling;
    $totals{'coupling_times_lcom1'} += ($coupling * $lcom1);
    $totals{'coupling_times_lcom4'} += ($coupling * $lcom4);
    $totals{'lcom1'} += $lcom1;
    $totals{'lcom4'} += $lcom4;
    $totals{'number_of_modules'} += 1;
    $totals{'number_of_functions'} += $number_of_functions;
    $totals{'number_of_public_functions'} += $public_functions;
    $totals{'loc'} += $lines;

  }
  my %summary = (
    average_coupling => ($totals{'coupling'}) / $totals{'number_of_modules'},
    average_coupling_times_lcom1 => ($totals{'coupling_times_lcom1'}) / $totals{'number_of_modules'},
    average_coupling_times_lcom4 => ($totals{'coupling_times_lcom4'}) / $totals{'number_of_modules'},
    average_lcom1 => ($totals{'lcom1'}) / $totals{'number_of_modules'},
    average_lcom4 => ($totals{'lcom4'}) / $totals{'number_of_modules'},
    number_of_functions => $totals{'number_of_functions'},
    number_of_modules => $totals{'number_of_modules'},
    number_of_public_functions => $totals{'number_of_public_functions'}
  );

  return Dump(\%summary) . $result;
}

1;


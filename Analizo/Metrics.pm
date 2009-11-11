package Analizo::Metrics;
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
  for my $caller_function ($self->model->functions($module)) {
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
  my @list = $self->model->functions($module);
  return scalar(@list);
}

sub amz_size {
  my ($lines, $count)= @_;
  return ($count > 0) ? ($lines / $count) : 0;
}

sub dit {
  my ($self, $module) = @_;
  my @parents = $self->model->inheritance($module);
  if (@parents) {
    my @parent_dits = map { $self->dit($_) } @parents;
    my @sorted = reverse(sort(@parent_dits));
    return 1 + $sorted[0];
  } else {
    return 0;
  }
}

sub noc {
  my ($self, $module) = @_;

  my $number_of_children = 0;

  for my $module_name ($self->model->module_names) {
    if (grep {$_ eq $module} $self->model->inheritance($module_name)) {
      $number_of_children++;
    }
  }
  return $number_of_children;
}

sub rfc {
  my ($self, $module) = @_;

  my @functions = $self->model->functions($module);

  my $rfc = scalar @functions;
  for my $function (@functions){
    $rfc += scalar keys(%{$self->model->calls->{$function}});
  }

  return $rfc;
}

sub afferent_connections {
  my ($self, $module) = @_;

  my @seen_modules = ();
  for my $caller_member (keys(%{$self->model->calls})){
    my $caller_module = $self->model->members->{$caller_member};
    for my $called_member (keys(%{$self->model->calls->{$caller_member}})) {
      my $called_module = $self->model->members->{$called_member};
      if($caller_module ne $called_module && $called_module eq $module){
        if(! grep { $_ eq $caller_module } @seen_modules){
          push @seen_modules, $caller_module;
        }
      }
    }
  }
  return scalar @seen_modules + $self->_recursive_noc($module);
}

sub _recursive_noc {
  my ($self, $module) = @_;

  my $number_of_children = 0;

  for my $module_name ($self->model->module_names){
    if (grep {$_ eq $module} $self->model->inheritance($module_name)) {
      $number_of_children += $self->_recursive_noc($module_name) + 1;
    }
  }

  return $number_of_children;
}

sub _report_module {
  my ($self, $module) = @_;

  my $coupling			= $self->coupling($module);
  my $number_of_functions	= $self->number_of_functions($module);
  my $lcom4			= $self->lcom4($module);
  my ($lines, $max_mloc)	= $self->loc($module);
  my $public_functions		= $self->public_functions($module);
  my $amz_size			= amz_size($lines, $number_of_functions);
  my $public_variables		= $self->public_variables($module);
  my $dit			= $self->dit($module);
  my $noc			= $self->noc($module);
  my $rfc			= $self->rfc($module);
  my $afferent_connections	= $self->afferent_connections($module);

  my %data = (
    _module 			=> $module,
    amz_size 			=> $amz_size,
    coupling 			=> $coupling,
    number_of_functions 	=> $number_of_functions,
    lcom4 			=> $lcom4,
    loc 			=> $lines,
    max_mloc 			=> $max_mloc,
    public_functions 		=> $public_functions,
    public_variables 		=> $public_variables,
    dit 			=> $dit,
    noc				=> $noc,
    rfc				=> $rfc,
    afferent_connections	=> $afferent_connections
  );

  return %data;
}

my %DESCRIPTIONS = (
  coupling 			=> "CBO coupling",
  lcom4 			=> "Lack of Cohesion (LCOM4)",
  loc 				=> "Lines of Code",
  number_of_functions 		=> "Number of functions/methods",
  public_functions 		=> "Number of public functions",
  amz_size 			=> "Average number of lines per method",
  max_mloc 			=> "Max number of method lines",
  public_variables 		=> "Number of public variables",
  dit 				=> "Depth of Inheritance Tree",
  noc				=> "Number of Children",
  rfc				=> "Response for a Class",
  afferent_connections		=> "Number of Afferent Conections per Class"
);

sub report {
  my $self = shift;
  my $result = '';
  my %totals = (
    coupling => 0,
    lcom4 => 0,
    number_of_functions => 0,
    number_of_modules => 0,
    public_functions => 0,
    number_of_public_functions => 0,
    loc => 0,
    cof => 0
  );

  my @module_names = $self->model->module_names;
  if (scalar(@module_names) == 0) {
    return '';
  }

  for my $module (@module_names) {
    my %data = $self->_report_module($module);

    $result .= Dump(\%data);

    $totals{'coupling'} += $data{coupling};
    $totals{'lcom4'} += $data{lcom4};
    $totals{'number_of_modules'} += 1;
    $totals{'number_of_functions'} += $data{number_of_functions};
    $totals{'number_of_public_functions'} += $data{public_functions};
    $totals{'loc'} += $data{loc};
    $totals{'cof'} += $data{afferent_connections};

  }
  my %summary = (
    average_coupling => ($totals{'coupling'}) / $totals{'number_of_modules'},
    average_lcom4 => ($totals{'lcom4'}) / $totals{'number_of_modules'},
    number_of_functions => $totals{'number_of_functions'},
    number_of_modules => $totals{'number_of_modules'},
    number_of_public_functions => $totals{'number_of_public_functions'},
    total_loc => $totals{'loc'},
    cof => ($totals{'cof'}) / ($totals{'number_of_modules'} * ($totals{'number_of_modules'} - 1))
  );

  return Dump(\%summary) . $result;
}

sub list_of_metrics {
  my $self = shift;
  my %report = $self->_report_module('dummy-module');
  my @names = grep { $_ !~ /^_/ } keys(%report);
  my %list = ();
  for my $name (@names) {
    $list{$name} = $DESCRIPTIONS{$name};
  }
  return %list;
}

1;

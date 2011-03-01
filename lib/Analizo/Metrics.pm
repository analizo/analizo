package Analizo::Metrics;
use strict;
use base qw(Class::Accessor::Fast);
use List::Compare;
use Graph;
use YAML;
use Statistics::Descriptive;
use Statistics::OnLine;

__PACKAGE__->mk_accessors(qw(model report_global_metrics_only));

my %DESCRIPTIONS = (
  acc       => "Afferent Connections per Class (used to calculate COF - Coupling Factor)",
  accm      => "Average Cyclomatic Complexity per Method",
  amloc     => "Average Method LOC",
  anpm      => "Average Number of Parameters per Method",
  cbo       => "Coupling Between Objects",
  dit       => "Depth of Inheritance Tree",
  lcom4     => "Lack of Cohesion of Methods ",
  mmloc     => "Max Method LOC",
  noa       => "Number of Attributes",
  noc       => "Number of Children",
  nom       => "Number of Methods",
  npm       => "Number of Public Methods",
  npa       => "Number of Public Attributes",
  rfc       => "Response For a Class",
  loc       => "Lines of Code"
);

sub new {
  my ($package, %args) = @_;
  return bless { model => $args{model} }, $package;
}

sub list_of_global_metrics {
  my %list = (
    total_abstract_classes => "Total Abstract Classes",
    total_cof => "Total Coupling Factor",
    total_modules => "Total Number of Modules/Classes",
    total_nom => "Total Number of Methods",
    total_loc => "Total Lines of Code",
    total_modules_with_defined_methods => "Total number of modules/classes with at least one defined method",
    total_modules_with_defined_attributes => "Total number of modules/classes with at least one defined attributes",
    total_methods_per_abstract_class => "Total number of methods per abstract class"
  );
  return %list;
}

sub afferent_connections_per_class {
  my ($self, $module) = @_;

  my $number_of_caller_modules = $self->_number_of_modules_that_call_module($module);
  my $number_of_modules_on_inheritance_tree = $self->_recursive_number_of_children($module);

  return $number_of_caller_modules + $number_of_modules_on_inheritance_tree;
}

sub _number_of_modules_that_call_module {
  my ($self, $module) = @_;

  my @seen_modules = ();
  for my $caller_member (keys(%{$self->model->calls})){
    $self->_push_member_module_if_it_calls_searched_module($caller_member, $module, \@seen_modules);
  }

  return scalar @seen_modules;
}

sub _push_member_module_if_it_calls_searched_module {
  my ($self, $caller_member, $searched_module, $seen_modules) = @_;

  my $caller_module = $self->model->members->{$caller_member};
  if($self->_member_calls_searched_module($caller_member, $caller_module, $searched_module)){
    push @{$seen_modules}, $caller_module;
  }
}

sub _member_calls_searched_module {
  my ($self, $caller_member, $caller_module, $searched_module) = @_;

  for my $called_member (keys(%{$self->model->calls->{$caller_member}})) {
    my $called_module = $self->model->members->{$called_member};
    if(_called_module_is_the_searched($called_module, $searched_module, $caller_module)) {
        return 1;
    }
  }
  return 0;
}

sub _called_module_is_the_searched {
  my ($called_module, $searched_module, $caller_module) = @_;
  return $caller_module ne $called_module && $called_module eq $searched_module;
}

sub _recursive_number_of_children {
  my ($self, $module) = @_;

  my $number_of_children = 0;

  for my $other_module ($self->model->module_names){
    if ($self->_module_parent_of_other($module, $other_module)) {
      $number_of_children += $self->_recursive_number_of_children($other_module) + 1;
    }
  }

  return $number_of_children;
}

sub average_method_lines_of_code {
  my ($self, $lines_of_code, $count) = @_;
  return ($count > 0) ? ($lines_of_code / $count) : 0;
}

sub average_cyclo_complexity_per_method {
  my ($self, $module) = @_;

  my $statisticalCalculator = Statistics::Descriptive::Full->new();
  for my $function ($self->model->functions($module)) {
    $statisticalCalculator->add_data($self->model->{conditional_paths}->{$function} || 0);
  }

  return $statisticalCalculator->mean();
}

sub average_number_of_parameters_per_method {
  my ($self, $module) = @_;

  my $statisticalCalculator = Statistics::Descriptive::Full->new();
  for my $function ($self->model->functions($module)) {
    $statisticalCalculator->add_data($self->model->{parameters}->{$function} || 0);
  }

  return $statisticalCalculator->mean();
}

sub coupling_between_objects {
  my ($self, $module) = @_;
  return $self->_number_of_calls_to_other_modules($module);
}

sub _number_of_calls_to_other_modules {
  my ($self, $module) = @_;

  my %calls_to = ();
  for my $caller_function ($self->model->functions($module)) {
    $self->_add_number_of_calls_to_other_modules($caller_function, $module, \%calls_to);
  }

  return (scalar keys(%calls_to));
}

sub _add_number_of_calls_to_other_modules {
  my ($self, $caller_function, $module, $calls_to) = @_;

  for my $called_function (keys(%{$self->model->calls->{$caller_function}})) {
    $self->_add_function_module_other_then_searched_module($called_function, $module, $calls_to);
  }
}

sub _add_function_module_other_then_searched_module {
  my ($self, $called_function, $searched_module, $calls_to) = @_;

  my $called_module = $self->model->members->{$called_function};
  $calls_to->{$called_module}++ if ($called_module && $called_module ne $searched_module);
}

sub depth_of_inheritance_tree {
  my ($self, $module) = @_;

  my @parents = $self->model->inheritance($module);
  if (@parents) {
   return 1 + $self->_depth_of_deepest_inheritance_tree(@parents);
  }
  return 0;
}

sub _depth_of_deepest_inheritance_tree {
  my ($self, @parents) = @_;
  my @parent_dits = map { $self->depth_of_inheritance_tree($_) } @parents;
  my @sorted = reverse(sort(@parent_dits));
  return $sorted[0];
}

#lcom4
sub lack_of_cohesion_of_methods {
  my ($self, $module) = @_;

  my $graph = $self->_cohesion_graph_of_module($module);
  my $number_of_components = scalar $graph->weakly_connected_components;

  return $number_of_components;
}

sub _cohesion_graph_of_module {
  my ($self, $module) = @_;

  my $graph = new Graph;
  my @functions = $self->model->functions($module);
  my @variables = $self->model->variables($module);

  for my $function (@functions) {
    $self->_add_function_as_vertix($graph, $function);
    $self->_add_edges_to_used_functions_and_variables($graph, $function, @functions, @variables);
  }

  return $graph;
}

sub _add_function_as_vertix {
  my ($self, $graph, $function) = @_;
  $graph->add_vertex($function);
}

sub _add_edges_to_used_functions_and_variables {
  my ($self, $graph, $function, @functions, @variables) = @_;

  for my $used (keys(%{$self->model->calls->{$function}})) {
    if (_used_inside_the_module($used, @functions, @variables)) {
      $graph->add_edge($function, $used);
    }
  }
}

sub _used_inside_the_module {
  my ($used, @functions, @variables) = @_;
  return (grep { $_ eq $used } @functions) || (grep { $_ eq $used } @variables);
}

sub number_of_attributes {
  my ($self, $module) = @_;
  my @variables = $self->model->variables($module);
  return scalar(@variables);
}

sub number_of_children {
  my ($self, $module) = @_;

  my $number_of_children = 0;
  for my $other_module ($self->model->module_names) {
    $number_of_children++ if ($self->_module_parent_of_other($module, $other_module));
  }
  return $number_of_children;
}

sub _module_parent_of_other {
  my ($self, $module, $other_module) = @_;
  return grep {$_ eq $module} $self->model->inheritance($other_module);
}

sub number_of_methods {
  my ($self, $module) = @_;
  my @functions = $self->model->functions($module);
  return scalar(@functions);
}

sub number_of_public_methods {
  my ($self, $module) = @_;

  my @functions = $self->model->functions($module);
  return $self->_number_of_public(@functions);
}

sub number_of_public_attributes {
  my ($self, $module) = @_;

  my @variables = $self->model->variables($module);
  return $self->_number_of_public(@variables);
}

sub _number_of_public {
  my ($self, @members) = @_;

  my $count = 0;
  for my $member (@members) {
    $count += 1 if $self->_is_public($member);
  }
  return $count;
}

sub _is_public {
  my ($self, $member) = @_;
  return $self->model->{protection}->{$member} && $self->model->{protection}->{$member} eq "public";
}

sub response_for_class {
  my ($self, $module) = @_;

  my @functions = $self->model->functions($module);
  my $number_of_functions = scalar @functions;
  my $number_of_functions_called_by_module_functions = $self->_number_of_functions_called_by(@functions);

  return $number_of_functions + $number_of_functions_called_by_module_functions;
}

sub _number_of_functions_called_by {
  my ($self, @functions) = @_;

  my $count = ();
  for my $function (@functions){
    $count += scalar keys(%{$self->model->calls->{$function}});
 }
 return $count;
}

sub lines_of_code {
  my ($self, $module) = @_;

  my $statisticalCalculator = Statistics::Descriptive::Full->new();

  for my $function ($self->model->functions($module)) {
    $statisticalCalculator->add_data($self->model->{lines}->{$function} || 0);
  }

  return ($statisticalCalculator->sum(), $statisticalCalculator->max() || 0);
}

sub total_abstract_classes{
  my ($self)= @_;
  my @total_of_abstract_classes = $self->model->abstract_classes;
  return scalar(@total_of_abstract_classes) || 0;
}

sub methods_per_abstract_class {
  my $self = shift;
  my $total_number_of_methods = 0;
  my @abstract_classes = $self->model->abstract_classes;

  for my $abstract_class (@abstract_classes) {
    $total_number_of_methods += (scalar $self->model->functions($abstract_class)) || 0;
  }

  return _division($total_number_of_methods, scalar @abstract_classes,);
}

sub _division {
  my ($dividend, $divisor) = @_;
  return ($divisor > 0) ? ($dividend / $divisor) : 0;
}

sub total_eloc {
  my $self = shift;
  return $self->model->total_eloc;
}

sub _report_module {
  my ($self, $module) = @_;

  my $acc                  = $self->afferent_connections_per_class($module);
  my $accm                 = $self->average_cyclo_complexity_per_method($module);
  my $anpm                 = $self->average_number_of_parameters_per_method($module);
  my $cbo                  = $self->coupling_between_objects($module);
  my $dit                  = $self->depth_of_inheritance_tree($module);
  my $lcom4                = $self->lack_of_cohesion_of_methods($module);
  my $noa                  = $self->number_of_attributes($module);
  my $noc                  = $self->number_of_children($module);
  my $nom                  = $self->number_of_methods($module);
  my $npm                  = $self->number_of_public_methods($module);
  my $npa                  = $self->number_of_public_attributes($module);
  my $rfc                  = $self->response_for_class($module);
  my ($loc, $mmloc)        = $self->lines_of_code($module);
  my $amloc                = $self->average_method_lines_of_code($loc, $nom);

  my %data = (
    _module              => $module,
    acc                  => $acc,
    accm                 => $accm,
    amloc                => $amloc,
    anpm                 => $anpm,
    cbo                  => $cbo,
    dit                  => $dit,
    lcom4                => $lcom4,
    mmloc                => $mmloc,
    noa                  => $noa,
    noc                  => $noc,
    nom                  => $nom,
    npm                  => $npm,
    npa                  => $npa,
    rfc                  => $rfc,
    loc                  => $loc
  );
  return %data;
}

sub report {
  my $self = shift;

  my $module_metrics_totals = $self->_initialize_module_metrics_totals();
  my $module_counts = $self->_initialize_module_counts();
  my $values_lists = $self->_initialize_values_lists();

  return '' if $self->_there_are_no_modules();

  my $modules_report = $self->_collect_all_modules_report($module_metrics_totals, $module_counts, $values_lists);
  my $global_report = $self->_collect_global_metrics_report($module_metrics_totals, $module_counts, $values_lists);

  return Dump($global_report) if $self->report_global_metrics_only();
  return Dump($global_report) . $modules_report;
}

sub _there_are_no_modules {
  my $self = shift;
  return scalar $self->model->module_names == 0;
}

sub _initialize_module_metrics_totals {
  my $self = shift;
  my %module_metrics_totals = (
    acc       => 0,
    accm      => 0,
    amloc     => 0,
    anpm      => 0,
    cbo       => 0,
    dit       => 0,
    lcom4     => 0,
    mmloc     => 0,
    noa       => 0,
    noc       => 0,
    nom       => 0,
    npm       => 0,
    npa       => 0,
    rfc       => 0,
    loc       => 0
  );
  return \%module_metrics_totals;
}

sub _initialize_module_counts {
  my $self = shift;
  my %module_counts = (
    total_modules => 0,
    total_modules_with_defined_methods => 0,
    total_modules_with_defined_attributes => 0
  );
  return \%module_counts;
}

sub _initialize_values_lists {
  my ($self, %module_metrics_totals) = @_;
  my %values_lists = ();

  for my $metric (keys %module_metrics_totals) {
    $values_lists{$metric} = [];
  }

  return \%values_lists;
}

sub _collect_all_modules_report {
  my ($self, $module_metrics_totals, $module_counts, $values_lists) = @_;

  my $modules_report = '';
  for my $module ($self->model->module_names) {
    my %data = $self->_report_module($module);
    $self->_update_module_metrics_totals_and_values_lists(\%data, $module_metrics_totals, $values_lists);
    $self->_update_module_counts(\%data, $module_counts);
    $modules_report .= Dump(\%data);
  }
  return $modules_report;
}

sub _update_module_metrics_totals_and_values_lists {
  my ($self, $data, $module_metrics_totals, $values_lists) = @_;
  for my $metric (keys %{$module_metrics_totals}){
    push @{$values_lists->{$metric}}, $data->{$metric};
    $module_metrics_totals->{$metric} += $data->{$metric};
  }
}

sub _update_module_counts {
  my ($self, $data, $module_counts) = @_;
  $module_counts->{'total_modules'} += 1;
  $module_counts->{'total_modules_with_defined_methods'} += 1 if $data->{'nom'} > 0;
  $module_counts->{'total_modules_with_defined_attributes'} += 1 if $data->{'noa'} > 0;
}

sub _collect_global_metrics_report {
  my ($self, $module_metrics_totals, $module_counts, $values_lists) = @_;
  my $summary = $self->_initialize_summary();
  $self->_add_module_metrics_totals($summary, $module_metrics_totals);
  $self->_add_module_counts($summary, $module_counts);
  $self->_add_statistical_values($summary, $values_lists);
  $self->_add_total_cof($summary, $module_counts->{'total_modules'}, $module_metrics_totals->{'acc'});
  return $summary;
}

sub _initialize_summary {
  my ($self) = @_;
  my %summary = ();
  return \%summary;
}

sub _add_module_counts {
  my ($self, $summary, $module_counts) = @_;
  for my $count (keys  %{$module_counts}) {
      $summary->{$count} = $module_counts->{$count};
  }
}

sub _add_module_metrics_totals {
  my ($self, $summary, $module_metrics_totals) = @_;
  $summary->{'total_nom'} = $module_metrics_totals->{'nom'};
  $summary->{'total_loc'} = $module_metrics_totals->{'loc'};
  $summary->{'total_abstract_classes'} = $self->total_abstract_classes;
  $summary->{'total_methods_per_abstract_class'} = $self->methods_per_abstract_class;
  $summary->{'total_eloc'} = $self->total_eloc;
}

sub _add_statistical_values {
  my ($self, $summary, $values_lists) = @_;
  for my $metric (keys %{$values_lists}){
    my $statistics = Statistics::Descriptive::Full->new();
    my $distributions = Statistics::OnLine->new();

    $statistics->add_data(@{$values_lists->{$metric}});
    $distributions->add_data(@{$values_lists->{$metric}});

    my $variance = $statistics->variance();
    $self->_add_descriptive_statistics($summary, $statistics, $metric);
    $self->_add_distributions_statistics($summary, $distributions, $metric, $variance);
  }
}

sub _add_descriptive_statistics {
  my ($self, $summary, $statistics, $metric) = @_;
  $summary->{$metric . "_average"} = $statistics->mean();
  $summary->{$metric . "_maximum"} = $statistics->max();
  $summary->{$metric . "_mininum"} = $statistics->min();
  $summary->{$metric . "_mode"} = $statistics->mode();
  $summary->{$metric . "_median"}= $statistics->median();
  $summary->{$metric . "_standard_deviation"}= $statistics->standard_deviation();
  $summary->{$metric . "_sum"} = $statistics->sum();
  $summary->{$metric . "_variance"}= $statistics->variance;
}

sub _add_distributions_statistics {
  my ($self, $summary, $distributions, $metric, $variance) = @_;
  if (($variance > 0) && ($distributions->count >= 4)) {
    $summary->{$metric . "_kurtosis"} = $distributions->kurtosis;
    $summary->{$metric . "_skewness"} = $distributions->skewness;
  }
  else {
    $summary->{$metric . "_kurtosis"} = 0;
    $summary->{$metric . "_skewness"} = 0;
  }
}

sub _add_total_cof {
  my ($self, $summary, $total_modules, $acc) = @_;
  if ($total_modules > 1) {
    $summary->{"total_cof"} = ($acc) / ($total_modules * ($total_modules - 1));
  }
  else {
    $summary->{"total_cof"} = 1;
  }
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


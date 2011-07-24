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
  sc        => "Structural Complexity (CBO X LCOM4)",
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

#Afferent Connections per Class
sub acc {
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

#Average Method LOC
sub amloc {
  my ($self, $loc, $count) = @_;
  return ($count > 0) ? ($loc / $count) : 0;
}

#Average Cyclomatic Complexity per Method
sub accm {
  my ($self, $module) = @_;

  my @functions = $self->model->functions($module);
  my $total_of_conditional_paths = 0;
  my $number_of_functions = 0;

  for my $function(@functions) {
    $total_of_conditional_paths += ($self->model->{conditional_paths}->{$function} || 0);
    $number_of_functions++;
  }

  return ($number_of_functions > 0) ? ($total_of_conditional_paths / $number_of_functions) : 0;
}

#Average Number of Parameters per Method
sub anpm {
  my ($self, $module) = @_;

  my @functions = $self->model->functions($module);
  my $total_of_parameters = 0;
  my $number_of_functions = 0;

  for my $function (@functions) {
    $total_of_parameters += ($self->model->{parameters}->{$function} || 0);
    $number_of_functions++;
  }

  return ($number_of_functions > 0) ? ($total_of_parameters / $number_of_functions) : 0;
}

#Coupling Between Objects
sub cbo {
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

#Depth of Inheritance Tree
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

#Lack of Cohesion of Methods
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

sub sc {
  my ($self, $module) = @_;
  return $self->lcom4($module) * $self->cbo($module);
}

#Number of Attributes
sub noa {
  my ($self, $module) = @_;
  my @variables = $self->model->variables($module);
  return scalar(@variables);
}

#Number of Children
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

#Number of Methods
sub nom {
  my ($self, $module) = @_;
  my @list = $self->model->functions($module);
  return scalar(@list);
}

#Number of Public Methods
sub npm {
  my ($self, $module) = @_;

  my @functions = $self->model->functions($module);
  my $npm = 0;
  for my $function (@functions) {
    $npm += 1 if $self->_is_public($function);
  }
  return $npm;
}

#Number of Public Attributes
sub npa {
  my ($self, $module) = @_;

  my @attributes = $self->model->variables($module);
  my $npa = 0;
  for my $attributes (@attributes) {
    $npa += 1 if $self->_is_public($attributes);
  }
  return $npa;
}

#Response For a Class
sub rfc {
  my ($self, $module) = @_;

  my @functions = $self->model->functions($module);

  my $rfc = scalar @functions;
  for my $function (@functions){
    $rfc += scalar keys(%{$self->model->calls->{$function}});
  }

  return $rfc;
}

#Lines Of Code
sub loc {
  my ($self, $module) = @_;

  my @functions = $self->model->functions($module);
  my $loc = 0;
  my $max = 0;

  for my $function (@functions) {
    my $lines = $self->model->{lines}->{$function} || 0;
    $loc += $lines;
    $max = $lines if $lines > $max;
  }

  return ($loc, $max);
}

sub total_abstract_classes{
  my ($self)= @_;
  my @total_of_abstract_classes = $self->model->abstract_classes;
  return @total_of_abstract_classes ? scalar(@total_of_abstract_classes) : 0;
}

sub methods_per_abstract_class {
  my $self = shift;
  my $total_number_of_methods = 0;
  my @abstract_classes = $self->model->abstract_classes;

  for my $abstract_class (@abstract_classes) {
    $total_number_of_methods += (scalar $self->model->functions($abstract_class)) || 0;
  }

  return (scalar @abstract_classes > 0  ) ? ($total_number_of_methods / scalar @abstract_classes) : 0;
}

sub total_eloc {
  my $self = shift;
  return $self->model->total_eloc;
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

sub _is_public {
  my ($self, $member) = @_;
  return $self->model->{protection}->{$member} && $self->model->{protection}->{$member} eq "public";
}

sub _report_module {
  my ($self, $module) = @_;

  my $acc                  = $self->acc($module);
  my $accm                 = $self->accm($module);
  my $anpm                 = $self->anpm($module);
  my $cbo                  = $self->cbo($module);
  my $dit                  = $self->dit($module);
  my $lcom4                = $self->lcom4($module);
  my $sc                   = $self->sc($module);
  my $noa                  = $self->noa($module);
  my $noc                  = $self->noc($module);
  my $nom                  = $self->nom($module);
  my $npm                  = $self->npm($module);
  my $npa                  = $self->npa($module);
  my $rfc                  = $self->rfc($module);
  my ($loc, $mmloc)        = $self->loc($module);
  my $amloc                = $self->amloc($loc, $nom);

  my %data = (
    _module              => $module,
    _filename            => $self->model->file($module),
    acc                  => $acc,
    accm                 => $accm,
    amloc                => $amloc,
    anpm                 => $anpm,
    cbo                  => $cbo,
    dit                  => $dit,
    lcom4                => $lcom4,
    sc                   => $sc,
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
  my ($self) = @_;
  my ($summary, $details) = $self->data();
  return Dump($summary) . join('', map { Dump($_)} @$details);
}

sub data {
  my ($self) = @_;
  if (!exists($self->{metrics_summary}) && !exists($self->{metrics_details})) {
    my ($summary, $details) = $self->_actually_calculate_data();
    $self->{metrics_summary} = $summary;
    $self->{metrics_details} = $details;
  }
  return ($self->{metrics_summary}, $self->{metrics_details});
}

sub _actually_calculate_data {
  my $self = shift;
  my @details = ();
  my $total_modules = 0;
  my $total_modules_with_defined_methods = 0;
  my $total_modules_with_defined_attributes = 0;
  my %totals = (
    acc       => 0,
    accm      => 0,
    amloc     => 0,
    anpm      => 0,
    cbo       => 0,
    dit       => 0,
    lcom4     => 0,
    sc        => 0,
    mmloc     => 0,
    noa       => 0,
    noc       => 0,
    nom       => 0,
    npm       => 0,
    npa       => 0,
    rfc       => 0,
    loc       => 0
  );
  my %list_values = ();

  for my $metric (keys %totals) {
    $list_values{$metric} = [];
  }

  my @module_names = $self->model->module_names;
  if (scalar(@module_names) == 0) {
    return '';
  }

  for my $module (@module_names) {
    my %data = $self->_report_module($module);

    unless ($self->report_global_metrics_only()) {
      push @details, \%data;
    }

    $total_modules += 1;
    for my $metric (keys %totals){
      push @{$list_values{$metric}}, $data{$metric};
      $totals{$metric} += $data{$metric};
    }
    $total_modules_with_defined_methods += 1 if $data{'nom'} > 0;
    $total_modules_with_defined_attributes += 1 if $data{'noa'} > 0;
  }

  my %summary = (
    total_modules                          => $total_modules,
    total_nom                              => $totals{'nom'},
    total_loc                              => $totals{'loc'},
    total_abstract_classes                 => $self->total_abstract_classes,
    total_modules_with_defined_methods     => $total_modules_with_defined_methods,
    total_modules_with_defined_attributes  => $total_modules_with_defined_attributes,
    total_methods_per_abstract_class       => $self->methods_per_abstract_class,
    total_eloc                             => $self->total_eloc
  );

  for my $metric (keys %totals){
    my $statistics = Statistics::Descriptive::Full->new();
    my $distributions = Statistics::OnLine->new();

    $statistics->add_data(@{$list_values{$metric}});
    $distributions->add_data(@{$list_values{$metric}});
    my $variance = $statistics->variance();

    $summary{$metric . "_average"} = $statistics->mean();
    $summary{$metric . "_maximum"} = $statistics->max();
    $summary{$metric . "_mininum"} = $statistics->min();
    $summary{$metric . "_mode"} = $statistics->mode();
    $summary{$metric . "_median"}= $statistics->median();
    $summary{$metric . "_standard_deviation"}= $statistics->standard_deviation();
    $summary{$metric . "_sum"} = $statistics->sum();
    $summary{$metric . "_variance"}= $variance;


    if (($variance > 0) && ($distributions->count >= 4)) {
      $summary{$metric . "_kurtosis"} = $distributions->kurtosis;
      $summary{$metric . "_skewness"} = $distributions->skewness;
    }
    else {
      $summary{$metric . "_kurtosis"} = 0;
      $summary{$metric . "_skewness"} = 0;
    }
  }

  if ($total_modules > 1) {
    $summary{"total_cof"} = ($totals{'acc'}) / ($total_modules * ($total_modules - 1));
  }
  else {
    $summary{"total_cof"} = 1;
  }

  return (\%summary, \@details);
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


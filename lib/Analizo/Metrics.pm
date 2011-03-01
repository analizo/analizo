package Analizo::Metrics;
use strict;
use base qw(Class::Accessor::Fast);
use List::Compare;
use YAML;
use Statistics::Descriptive;
use Statistics::OnLine;

use Analizo::Metric::AfferentConnections;
use Analizo::Metric::AverageCycloComplexity;
use Analizo::Metric::AverageNumberOfParameters;
use Analizo::Metric::CouplingBetweenObjects;
use Analizo::Metric::DepthOfInheritanceTree;
use Analizo::Metric::LackOfCohesionOfMethods;
use Analizo::Metric::LinesOfCode;
use Analizo::Metric::MaximumMethodLinesOfCode;
use Analizo::Metric::NumberOfAttributes;
use Analizo::Metric::NumberOfChildren;
use Analizo::Metric::NumberOfMethods;
use Analizo::Metric::NumberOfPublicAttributes;
use Analizo::Metric::NumberOfPublicMethods;
use Analizo::Metric::ResponseForClass;

__PACKAGE__->mk_accessors(qw(
    model
    module_metrics_totals
    module_counts
    values_lists
    global_report
    report_global_metrics_only
    metric_calculators)
);

sub new {
  my ($package, %args) = @_;
  my @instance_variables = (
    model => $args{model},
    module_metrics_totals => _initialize_module_metrics_totals(),
    module_counts => _initialize_module_counts(),
    values_lists => _initialize_values_lists(),
    global_report => _initialize_global_report(),
    metric_calculators => _initialize_metric_calculators($args{model})
  );
  return bless { @instance_variables }, $package;
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

sub average_method_lines_of_code {
  my ($self, $lines_of_code, $count) = @_;
  return ($count > 0) ? ($lines_of_code / $count) : 0;
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

sub _initialize_metric_calculators {
  my $model = shift;
  my  %calculators = (
    acc                  => new Analizo::Metric::AfferentConnections(model => $model),
    accm                 => new Analizo::Metric::AverageCycloComplexity(model => $model),
    anpm                 => new Analizo::Metric::AverageNumberOfParameters(model => $model),
    cbo                  => new Analizo::Metric::CouplingBetweenObjects(model => $model),
    dit                  => new Analizo::Metric::DepthOfInheritanceTree(model => $model),
    lcom4                => new Analizo::Metric::LackOfCohesionOfMethods(model => $model),
    loc                  => new Analizo::Metric::LinesOfCode(model => $model),
    mmloc                => new Analizo::Metric::MaximumMethodLinesOfCode(model => $model),
    noa                  => new Analizo::Metric::NumberOfAttributes(model => $model),
    noc                  => new Analizo::Metric::NumberOfChildren(model => $model),
    nom                  => new Analizo::Metric::NumberOfMethods(model => $model),
    npm                  => new Analizo::Metric::NumberOfPublicMethods(model => $model),
    npa                  => new Analizo::Metric::NumberOfPublicAttributes(model => $model),
    rfc                  => new Analizo::Metric::ResponseForClass(model => $model)
  );
  return \%calculators;
}

sub metrics_of_module {
  my ($self, $module) = @_;

  my %values = ();
  $values{'_module'} = $module;

  for my $metric (keys %{$self->metric_calculators}) {
      $values{$metric} = $self->metric_calculators->{$metric}->calculate($module);
  }

  $values{'amloc'} = $self->average_method_lines_of_code($values{'loc'}, $values{'nom'});
  return %values;
}

sub report {
  my $self = shift;

  return '' if $self->_there_are_no_modules();

  my $modules_report = $self->_collect_and_dump_all_modules_report();
  $self->_collect_global_metrics_report();

  return Dump($self->global_report) if $self->report_global_metrics_only();
  return Dump($self->global_report) . $modules_report;
}

sub _there_are_no_modules {
  my $self = shift;
  return scalar $self->model->module_names == 0;
}

sub _initialize_module_metrics_totals {
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
  my %module_counts = (
    total_modules => 0,
    total_modules_with_defined_methods => 0,
    total_modules_with_defined_attributes => 0
  );
  return \%module_counts;
}

sub _initialize_values_lists {
  my ( %module_metrics_totals) = @_;
  my %values_lists = ();

  for my $metric (keys %module_metrics_totals) {
    $values_lists{$metric} = [];
  }

  return \%values_lists;
}

sub _collect_and_dump_all_modules_report {
  my $self = shift;

  my $modules_report = '';
  for my $module ($self->model->module_names) {
    my %data = $self->metrics_of_module($module);
    $self->_update_module_metrics_totals_and_values_lists(\%data);
    $self->_update_module_counts(\%data);
    $modules_report .= Dump(\%data);
  }
  return $modules_report;
}

sub _update_module_metrics_totals_and_values_lists {
  my ($self, $data) = @_;
  for my $metric (keys %{$self->module_metrics_totals}){
    push @{$self->values_lists->{$metric}}, $data->{$metric};
    $self->module_metrics_totals->{$metric} += $data->{$metric};
  }
}

sub _update_module_counts {
  my ($self, $data) = @_;
  $self->module_counts->{'total_modules'} += 1;
  $self->module_counts->{'total_modules_with_defined_methods'} += 1 if $data->{'nom'} > 0;
  $self->module_counts->{'total_modules_with_defined_attributes'} += 1 if $data->{'noa'} > 0;
}

sub _collect_global_metrics_report {
  my $self = shift;
  $self->_add_module_metrics_totals();
  $self->_add_module_counts();
  $self->_add_statistical_values();
  $self->_add_total_coupling_factor();
}

sub _initialize_global_report {
  my %global_report = ();
  return \%global_report;
}

sub _add_module_metrics_totals {
  my $self = shift;
  $self->global_report->{'total_nom'} = $self->module_metrics_totals->{'nom'};
  $self->global_report->{'total_loc'} = $self->module_metrics_totals->{'loc'};
  $self->global_report->{'total_abstract_classes'} = $self->total_abstract_classes;
  $self->global_report->{'total_methods_per_abstract_class'} = $self->methods_per_abstract_class;
  $self->global_report->{'total_eloc'} = $self->total_eloc;
}

sub _add_module_counts {
  my $self = shift;
  for my $count (keys  %{$self->module_counts}) {
      $self->global_report->{$count} = $self->module_counts->{$count};
  }
}
sub _add_statistical_values {
  my $self = shift;
  for my $metric (keys %{$self->values_lists}){
    my $statistics = Statistics::Descriptive::Full->new();
    my $distributions = Statistics::OnLine->new();

    $statistics->add_data(@{$self->values_lists->{$metric}});
    $distributions->add_data(@{$self->values_lists->{$metric}});

    my $variance = $statistics->variance();
    $self->_add_descriptive_statistics($statistics, $metric);
    $self->_add_distributions_statistics($distributions, $metric, $variance);
  }
}

sub _add_descriptive_statistics {
  my ($self, $statistics, $metric) = @_;
  $self->global_report->{$metric . "_average"} = $statistics->mean;
  $self->global_report->{$metric . "_maximum"} = $statistics->max;
  $self->global_report->{$metric . "_mininum"} = $statistics->min;
  $self->global_report->{$metric . "_mode"} = $statistics->mode;
  $self->global_report->{$metric . "_median"} = $statistics->median;
  $self->global_report->{$metric . "_standard_deviation"} = $statistics->standard_deviation;
  $self->global_report->{$metric . "_sum"} = $statistics->sum;
  $self->global_report->{$metric . "_variance"} = $statistics->variance;
}

sub _add_distributions_statistics {
  my ($self, $distributions, $metric) = @_;
  if (($distributions->variance > 0) && ($distributions->count >= 4)) {
    $self->global_report->{$metric . "_kurtosis"} = $distributions->kurtosis;
    $self->global_report->{$metric . "_skewness"} = $distributions->skewness;
  }
  else {
    $self->global_report->{$metric . "_kurtosis"} = 0;
    $self->global_report->{$metric . "_skewness"} = 0;
  }
}

sub _add_total_coupling_factor {
  my $self = shift;
  my $total_modules = $self->module_counts->{'total_modules'};
  my $total_acc = $self->module_metrics_totals->{'acc'};

  if ($total_modules > 1) {
    $self->global_report->{"total_cof"} = $total_acc / _number_of_combinations($total_modules);
  }
  else {
    $self->global_report->{"total_cof"} = 1;
  }
}

sub _number_of_combinations {
  my $total_modules = shift;
  return $total_modules * ($total_modules - 1);
}

sub list_of_metrics {
  my $self = shift;
  my %list = ();
  for my $metric (keys %{$self->metric_calculators}) {
    $list{$metric} = $self->metric_calculators->{$metric}->description;
  }
  $list{'amloc'} = "Average Method LOC";
  return %list;
}

1;


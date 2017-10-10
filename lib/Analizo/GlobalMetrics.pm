package Analizo::GlobalMetrics;
use strict;
use base qw(Class::Accessor::Fast);

use Analizo::GlobalMetric::TotalAbstractClasses;
use Analizo::GlobalMetric::MethodsPerAbstractClass;
use Analizo::GlobalMetric::TotalEloc;
use Analizo::GlobalMetric::ChangeCost;

use Statistics::Descriptive;


__PACKAGE__->mk_accessors(qw(
    model
    calculators
    metric_report
    values_lists
    module_metrics_list
));

sub new {
  my ($package, %args) = @_;
  my @instance_variables = (
    model => $args{model},
    calculators => _initialize_calculators($args{model}),
    metric_report => _initialize_metric_report(),
    values_lists => {},
  );
  return bless { @instance_variables }, $package;
}

sub _initialize_calculators {
  my ($model) = @_;
  my %calculators = (
    total_abstract_classes            => new Analizo::GlobalMetric::TotalAbstractClasses(model => $model),
    total_methods_per_abstract_class  => new Analizo::GlobalMetric::MethodsPerAbstractClass(model => $model),
    total_eloc                        => new Analizo::GlobalMetric::TotalEloc(model => $model),
    change_cost                       => Analizo::GlobalMetric::ChangeCost->new(model => $model),
  );
  return \%calculators;
}

sub _initialize_metric_report {
  my %metric_report = (
    total_modules => 0,
    total_modules_with_defined_methods => 0,
    total_modules_with_defined_attributes => 0,
    total_nom => 0,
    total_loc => 0,
    total_cof => 0
  );
  return \%metric_report;
}

sub list {
  my ($self) = @_;
  my %list = (
    total_cof => "Total Coupling Factor",
    total_modules => "Total Number of Modules",
    total_nom => "Total Number of Methods",
    total_loc => "Total Lines of Code",
    total_modules_with_defined_methods => "Total number of modules with at least one defined method",
    total_modules_with_defined_attributes => "Total number of modules with at least one defined attributes"
  );
  for my $metric (keys %{$self->calculators}) {
    $list{$metric} = $self->calculators->{$metric}->description;
  }
  return %list;
}

sub add_module_values {
  my ($self, $values) = @_;

  $self->_update_metric_report($values);
  $self->_add_values_to_values_lists($values);
}

sub _update_metric_report {
  my ($self, $values) = @_;
  $self->metric_report->{'total_modules'} += 1;
  $self->metric_report->{'total_modules_with_defined_methods'} += 1 if $values->{'nom'} > 0;
  $self->metric_report->{'total_modules_with_defined_attributes'} += 1 if $values->{'noa'} > 0;
  $self->metric_report->{'total_nom'} += $values->{'nom'};
  $self->metric_report->{'total_loc'} += $values->{'loc'};
}

sub _add_values_to_values_lists {
  my ($self, $values) = @_;
  for my $metric (keys %{$values}) {
    $self->_add_metric_value_to_values_list($metric, $values->{$metric});
  }
}

sub _add_metric_value_to_values_list {
  my ($self, $metric, $metric_value) = @_;
  if( $metric ne '_module' && $metric ne '_filename' ) {
    $self->values_lists->{$metric} = [] unless ($self->values_lists->{$metric});
    push @{$self->values_lists->{$metric}}, $metric_value;
  }
}

sub report {

  my ($self, @binary_statistics) = @_;

  $self->_include_metrics_from_calculators;
  $self->_add_statistics(@binary_statistics);
  $self->_add_total_coupling_factor;

  return \%{$self->metric_report};
}


sub _include_metrics_from_calculators {
  my ($self) = @_;
  for my $metric (keys %{$self->calculators}) {
    $self->metric_report->{$metric} = $self->calculators->{$metric}->calculate();
  }
}

sub _add_statistics {
  my ($self, @binary_statistics) = @_;

  for my $metric (keys %{$self->values_lists}) {
    my $statistics = Statistics::Descriptive::Full->new();
    $statistics->add_data(@{$self->values_lists->{$metric}});
    $self->_add_descriptive_statistics($metric, $statistics, @binary_statistics);
    $self->_add_distributions_statistics($metric, $statistics, @binary_statistics);
  }
}

sub _add_descriptive_statistics {
  my ($self, $metric, $statistics, @binary_statistics) = @_;

  if($binary_statistics[0]) {
    $self->metric_report->{$metric . "_mean"} = $statistics->mean();
  }
  if($binary_statistics[1]) {
    $self->metric_report->{$metric . "_mode"} = $statistics->mode();
  }
  if($binary_statistics[2]) {
    $self->metric_report->{$metric . "_standard_deviation"} = $statistics->standard_deviation();
  }
  if($binary_statistics[3]) {
    $self->metric_report->{$metric . "_sum"} = $statistics->sum();
  }
  if($binary_statistics[4]) {
    $self->metric_report->{$metric . "_variance"} = $statistics->variance();
  }
  if($binary_statistics[5]) {
    $self->metric_report->{$metric . "_quantile_min"}   = $statistics->min(); #minimum
  }
  if($binary_statistics[6]) {
    $self->metric_report->{$metric . "_quantile_lower"}   = $statistics->quantile(1); #lower quartile
  }
  if($binary_statistics[7]) {
    $self->metric_report->{$metric . "_quantile_median"}   = $statistics->median(); #median
  }
  if($binary_statistics[8]) {
    $self->metric_report->{$metric . "_quantile_upper"}   = $statistics->quantile(3); #upper quartile
  }
  if($binary_statistics[9]) {
    $self->metric_report->{$metric . "_quantile_ninety"}  = $statistics->percentile(90); #90th percentile
  }
  if($binary_statistics[10]) {
    $self->metric_report->{$metric . "_quantile_ninety_five"}  = $statistics->percentile(95); #95th percentile
  }
  if($binary_statistics[11]) {
    $self->metric_report->{$metric . "_quantile_max"} = $statistics->max(); #maximum
  }
 }

sub _add_distributions_statistics {
  my ($self, $metric, $statistics, @binary_statistics) = @_;

  if (($statistics->count >= 4) && ($statistics->variance() > 0)) {
    if($binary_statistics[12]) {
      $self->metric_report->{$metric . "_kurtosis"} = $statistics->kurtosis();
    }
    if($binary_statistics[13]) {
      $self->metric_report->{$metric . "_skewness"} = $statistics->skewness();
    }
  }
  else {
    if($binary_statistics[12]) {
      $self->metric_report->{$metric . "_kurtosis"} = 0;
    }
    if($binary_statistics[13]) {
      $self->metric_report->{$metric . "_skewness"} = 0;
    }
  }
}

sub _add_total_coupling_factor {
  my ($self) = @_;
  my $total_modules = $self->metric_report->{'total_modules'};
  my $total_acc = $self->metric_report->{'acc_sum'};

  $self->metric_report->{"total_cof"} = $self->coupling_factor($total_acc, $total_modules);
}

sub coupling_factor {
  my ($self, $total_acc, $total_modules) = @_;
  $total_acc ||= 0;
  return ($total_modules > 1) ? $total_acc / _number_of_combinations($total_modules) : 1;
}

sub _number_of_combinations {
  my ($total_modules) = @_;
  return $total_modules * ($total_modules - 1);
}



1;

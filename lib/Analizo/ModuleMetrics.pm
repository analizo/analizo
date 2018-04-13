package Analizo::ModuleMetrics;
use strict;
use parent qw(Class::Accessor::Fast);

use Analizo::Metric::AfferentConnections;
use Analizo::Metric::AverageCycloComplexity;
use Analizo::Metric::AverageMethodLinesOfCode;
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
use Analizo::Metric::StructuralComplexity;

__PACKAGE__->mk_accessors(qw(model metric_calculators));

sub new {
  my ($package, %args) = @_;
  my @instance_variables = (
    model => $args{model},
    metric_calculators => _initialize_metric_calculators($args{model})
  );
  return bless { @instance_variables }, $package;
}

sub _initialize_metric_calculators {
  my ($model) = @_;
  my $cbo                = Analizo::Metric::CouplingBetweenObjects->new(model => $model);
  my $lcom4              = Analizo::Metric::LackOfCohesionOfMethods->new(model => $model);

  my  %calculators = (
    acc                  => Analizo::Metric::AfferentConnections->new(model => $model),
    accm                 => Analizo::Metric::AverageCycloComplexity->new(model => $model),
    amloc                => Analizo::Metric::AverageMethodLinesOfCode->new(model => $model),
    anpm                 => Analizo::Metric::AverageNumberOfParameters->new(model => $model),
    cbo                  => $cbo,
    dit                  => Analizo::Metric::DepthOfInheritanceTree->new(model => $model),
    lcom4                => $lcom4,
    loc                  => Analizo::Metric::LinesOfCode->new(model => $model),
    mmloc                => Analizo::Metric::MaximumMethodLinesOfCode->new(model => $model),
    noa                  => Analizo::Metric::NumberOfAttributes->new(model => $model),
    noc                  => Analizo::Metric::NumberOfChildren->new(model => $model),
    nom                  => Analizo::Metric::NumberOfMethods->new(model => $model),
    npm                  => Analizo::Metric::NumberOfPublicMethods->new(model => $model),
    npa                  => Analizo::Metric::NumberOfPublicAttributes->new(model => $model),
    rfc                  => Analizo::Metric::ResponseForClass->new(model => $model),
    sc                   => Analizo::Metric::StructuralComplexity->new(model => $model, cbo => $cbo, lcom4 => $lcom4),

  );
  return \%calculators;
}

sub list {
  my ($self) = @_;
  my %list = ();
  for my $metric (keys %{$self->metric_calculators}) {
    $list{$metric} = $self->metric_calculators->{$metric}->description;
  }
  return %list;
}

sub report {
  my ($self, $module) = @_;

  my %values = ();
  $values{'_module'} = $module;
  for my $metric (keys %{$self->metric_calculators}) {
    my $value = $self->metric_calculators->{$metric}->value($module);
    $values{$metric} = $value;
  }

  #FIXME: move to another function
  $self->model->files($module);

  return \%values;
}

1;


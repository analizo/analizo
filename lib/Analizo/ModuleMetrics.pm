package Analizo::ModuleMetrics;
use strict;
use base qw(Class::Accessor::Fast);

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
use Analizo::Metric::DivisionsByZero;
use Analizo::Metric::DeadAssignment;
use Analizo::Metric::MemoryLeak;
use Analizo::Metric::DereferenceOfNullPointer;
use Analizo::Metric::AssignedUndefinedValue;
use Analizo::Metric::ReturnOfStackVariableAddress;

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
  my $cbo                = new Analizo::Metric::CouplingBetweenObjects(model => $model);
  my $lcom4              = new Analizo::Metric::LackOfCohesionOfMethods(model => $model);

  my  %calculators = (
    acc                  => new Analizo::Metric::AfferentConnections(model => $model),
    accm                 => new Analizo::Metric::AverageCycloComplexity(model => $model),
    amloc                => new Analizo::Metric::AverageMethodLinesOfCode(model => $model),
    anpm                 => new Analizo::Metric::AverageNumberOfParameters(model => $model),
    cbo                  => $cbo,
    dit                  => new Analizo::Metric::DepthOfInheritanceTree(model => $model),
    lcom4                => $lcom4,
    loc                  => new Analizo::Metric::LinesOfCode(model => $model),
    mmloc                => new Analizo::Metric::MaximumMethodLinesOfCode(model => $model),
    noa                  => new Analizo::Metric::NumberOfAttributes(model => $model),
    noc                  => new Analizo::Metric::NumberOfChildren(model => $model),
    nom                  => new Analizo::Metric::NumberOfMethods(model => $model),
    npm                  => new Analizo::Metric::NumberOfPublicMethods(model => $model),
    npa                  => new Analizo::Metric::NumberOfPublicAttributes(model => $model),
    rfc                  => new Analizo::Metric::ResponseForClass(model => $model),
    sc                   => new Analizo::Metric::StructuralComplexity(model => $model, cbo => $cbo, lcom4 => $lcom4),
    dbz                  => new Analizo::Metric::DivisionsByZero(model => $model),
    da                   => new Analizo::Metric::DeadAssignment(model => $model),
    mlk                  => new Analizo::Metric::MemoryLeak(model => $model),
    dnp                  => new Analizo::Metric::DereferenceOfNullPointer(model => $model),
    auv                  => new Analizo::Metric::AssignedUndefinedValue(model => $model),
    rsva                 => new Analizo::Metric::ReturnOfStackVariableAddress(model => $model),
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


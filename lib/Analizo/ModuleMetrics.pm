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
  my $model = shift;
  my  %calculators = (
    acc                  => new Analizo::Metric::AfferentConnections(model => $model),
    accm                 => new Analizo::Metric::AverageCycloComplexity(model => $model),
    amloc                => new Analizo::Metric::AverageMethodLinesOfCode(model => $model),
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

sub list {
  my $self = shift;
  my %list = ();
  for my $metric (keys %{$self->metric_calculators}) {
    $list{$metric} = $self->metric_calculators->{$metric}->description;
  }
  return %list;
}

sub short_metric_names {
  my $self = shift;

  my @list = ();
  for my $metric (keys %{$self->metric_calculators}) {
    push @list, $metric;
  }
  return @list;
}

sub report {
  my ($self, $module) = @_;

  my %values = ();
  $values{'_module'} = $module;
  for my $metric (keys %{$self->metric_calculators}) {
      $values{$metric} = $self->metric_calculators->{$metric}->calculate($module);
  }
  return \%values;
}

1;


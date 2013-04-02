package Analizo::Metric::LinesOfCode;
use strict;
use base qw(Class::Accessor::Fast);
use Statistics::Descriptive;

__PACKAGE__->mk_accessors(qw( model ));

sub new {
  my ($package, %args) = @_;
   my @instance_variables = (
    model => $args{model}
  );
  return bless { @instance_variables }, $package;
}

sub description {
  return "Lines of Code";
}

sub calculate {
  my ($self, $module) = @_;

  my @functions = $self->model->functions($module);
  if (scalar(@functions) == 0) {
    return 0;
  }

  my $statisticalCalculator = Statistics::Descriptive::Full->new();

  for my $function (@functions) {
    $statisticalCalculator->add_data($self->model->{lines}->{$function} || 0);
  }

  return $statisticalCalculator->sum();
}

1;


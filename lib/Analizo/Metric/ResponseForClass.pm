package Analizo::Metric::ResponseForClass;
use strict;
use base qw(Class::Accessor::Fast Analizo::ModuleMetric);

__PACKAGE__->mk_accessors(qw( model ));

sub new {
  my ($package, %args) = @_;
   my @instance_variables = (
    model => $args{model}
  );
  return bless { @instance_variables }, $package;
}

sub description {
  return "Response for a Class";
}

sub calculate {
  my ($self, $module) = @_;

  my @functions = $self->model->functions($module);
  my $number_of_functions = scalar @functions;
  my $number_of_functions_called_by_module_functions = $self->_number_of_functions_called_by(@functions);

  return $number_of_functions + $number_of_functions_called_by_module_functions;
}

sub _number_of_functions_called_by {
  my ($self, @functions) = @_;

  my $count = 0;
  for my $function (@functions){
    $count += scalar keys(%{$self->model->calls->{$function}});
  }
  return $count;
}

1;


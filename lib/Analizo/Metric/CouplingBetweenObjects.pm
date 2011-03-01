package Analizo::Metric::CouplingBetweenObjects;
use strict;
use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw( model ));

sub new {
  my ($package, %args) = @_;
   my @instance_variables = (
    model => $args{model}
  );
  return bless { @instance_variables }, $package;
}

sub calculate {
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



1;


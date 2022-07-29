package Analizo::Metric::CouplingBetweenObjects;
use strict;
use parent qw(Class::Accessor::Fast Analizo::ModuleMetric);

=head1 NAME

Analizo::Metric::CouplingBetweenObjects - Coupling Between Objects (CBO) metric

=head1 DESCRIPTION

The metric calculation is based on the following article and calculates the
number of calls to other modules.

Article: I<A metrics suite for object oriented design> by Shyam R. Chidamber
and Chris F. Kemerer.

See the paragraph about Coupling Between Objects in the article:

Theoretical Basis: CBO relates to the notion that an object is coupled to
another object if one of them acts on the other, i.e., methods of one use
method or instance variables of another. As stated earlier, since objects of
the same class have the same properties, two classes are coupled when methods
declared in on class use methods or instance variables defined by the other
class.

=cut

__PACKAGE__->mk_accessors(qw( model analized_module calls_to ));

sub new {
  my ($package, %args) = @_;
   my @instance_variables = (
    model => $args{model},
    analized_module => undef,
    calls_to => {},
  );
  return bless { @instance_variables }, $package;
}

sub description {
  return "Coupling Between Objects";
}

sub calculate {
  my ($self, $module) = @_;
  $self->analized_module($module);
  $self->calls_to({});

  my $number_of_calls_to_other_modules = $self->_number_of_calls_to_other_modules();
  return $number_of_calls_to_other_modules;
}

sub _number_of_calls_to_other_modules {
  my ($self) = @_;

  for my $caller_function ($self->model->functions($self->analized_module)) {
    $self->_add_number_of_calls_to_other_modules($caller_function);
  }
  return (scalar keys(%{$self->calls_to}));
}

sub _add_number_of_calls_to_other_modules {
  my ($self, $caller_function) = @_;

  for my $called_function (keys(%{$self->model->calls->{$caller_function}})) {
    $self->_add_function_module_other_then_analized_module($called_function);
  }
}

sub _add_function_module_other_then_analized_module {
  my ($self, $called_function) = @_;

  my $called_module = $self->model->members->{$called_function};
  $self->calls_to->{$called_module}++ if ($called_module && $called_module ne $self->analized_module);
}

1;


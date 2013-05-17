package Analizo::Metric::AfferentConnections;
use strict;
use base qw(Class::Accessor::Fast Analizo::ModuleMetric);

__PACKAGE__->mk_accessors(qw( model analized_module));

sub new {
  my ($package, %args) = @_;
   my @instance_variables = (
    model => $args{model},
    analized_modules => undef
  );
  return bless { @instance_variables }, $package;
}

sub description {
  return 'Afferent Connections per Class (used to calculate COF - Coupling Factor)';
}

sub calculate {
  my ($self, $module) = @_;
  $self->analized_module($module);

  my $number_of_caller_modules = $self->_number_of_modules_that_call_module();
  my $number_of_modules_on_inheritance_tree = $self->_recursive_number_of_children($self->analized_module);

  return $number_of_caller_modules + $number_of_modules_on_inheritance_tree;
}

sub _number_of_modules_that_call_module {
  my ($self) = @_;

  my @seen_modules = ();
  for my $caller_member (keys(%{$self->model->calls})){
    $self->_push_member_module_if_it_calls_analized_module($caller_member, \@seen_modules);
  }

  return scalar @seen_modules;
}

sub _push_member_module_if_it_calls_analized_module {
  my ($self, $caller_member, $seen_modules) = @_;

  my $caller_module = $self->model->members->{$caller_member};
  if($self->_member_calls_analized_module($caller_member, $caller_module)){
    push @{$seen_modules}, $caller_module;
  }
}

sub _member_calls_analized_module {
  my ($self, $caller_member, $caller_module) = @_;

  for my $called_member (keys(%{$self->model->calls->{$caller_member}})) {
    my $called_module = $self->model->members->{$called_member};
    if($self->_called_module_is_the_analized($called_module, $caller_module)) {
        return 1;
    }
  }
  return 0;
}

sub _called_module_is_the_analized {
  my ($self, $called_module, $caller_module) = @_;
  return $caller_module ne $called_module && $called_module eq $self->analized_module;
}

sub _recursive_number_of_children {
  my ($self, $module) = @_;

  my $number_of_children = 0;

  for my $other_module ($self->model->module_names){
    if ($self->_module_parent_of_other($module, $other_module)) {
      $number_of_children += $self->_recursive_number_of_children($other_module) + 1;
    }
  }

  return $number_of_children;
}

sub _module_parent_of_other {
  my ($self, $module, $other_module) = @_;
  return grep {$_ eq $module} $self->model->inheritance($other_module);
}

1;


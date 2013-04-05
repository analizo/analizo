package Analizo::Metric::NumberOfPublicAttributes;
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

sub description {
  return "Number of Public Attributes";
}

sub calculate {
  my ($self, $module) = @_;

  my $count = 0;
  for my $attribute ($self->model->variables($module)) {
    $count += 1 if $self->_is_public($attribute);
  }
  return $count;
}

sub _is_public {
  my ($self, $attribute) = @_;
  return $self->model->{protection}->{$attribute} && $self->model->{protection}->{$attribute} eq "public";
}

1;


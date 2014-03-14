package Analizo::Metric::AllocatorSizeofOperandMismatch;
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
  return "Allocator sizeof operand mismatch";
}

sub calculate {
  my ($self, $module) = @_;

  return 0 if (!defined $self->model->security_metrics('Allocator sizeof operand mismatch', $module));

  return $self->model->security_metrics('Allocator sizeof operand mismatch', $module);

}

1;


package Analizo::Metric::UndefinedAllocation;
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
  return "Undefined allocation of 0 bytes (CERT MEM04-C; CWE-131)";
}

sub calculate {
  my ($self, $module) = @_;

  return 0 if (!defined $self->model->security_metrics('Undefined allocation of 0 bytes (CERT MEM04-C; CWE-131)', $module));

  return $self->model->security_metrics('Undefined allocation of 0 bytes (CERT MEM04-C; CWE-131)', $module);

}

1;


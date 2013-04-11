package Analizo::ModuleMetric;

sub new {
  return bless { cache => {} }, __PACKAGE__;
}

sub value {
  my ($self, $module) = @_;
  if (!defined $self->{cache}->{$module}) {
    $self->{cache}->{$module} = $self->calculate($module);
  }
  my $value = $self->{cache}->{$module};
  return $value;
}

sub calculate {
  die("Not implemented. Override in subclasses");
}

1;

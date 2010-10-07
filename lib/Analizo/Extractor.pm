package Analizo::Extractor;

use strict;
use warnings;

use base qw(Class::Accessor::Fast);

use Analizo::Model;

our $QUIET = undef;

__PACKAGE__->mk_ro_accessors(qw(current_member));

sub alias {
  my $alias = shift;
  my %aliases = (
    doxy => 'Doxyparse',
  );
  exists $aliases{$alias} ? $aliases{$alias} : $alias;
}

sub sanitize {
  my ($extractor_name) = @_;
  if ($extractor_name =~ /^\w+$/) {
    return $extractor_name;
  } else {
    return 'Doxyparse';
  }
}

sub load {
  my ($self, $extractor_method) = @_;
  $extractor_method = alias(sanitize($extractor_method));
  my $extractor = "Analizo::Extractor::$extractor_method";

  eval "use $extractor";
  die "error loading $extractor_method extractor: $@" if $@;

  eval { $extractor = $extractor->new(@_) };
  die "error instancing extractor: $@" if $@;

  return $extractor;
}

sub model {
  my $self = shift;
  if (!exists($self->{model})) {
    $self->{model} = new Analizo::Model;
  }
  return $self->{model};
}

sub current_module {
  my $self = shift;

  # set the new value
  if (scalar @_) {
    $self->{current_module} = shift;

    #declare
    $self->model->declare_module($self->{current_module});
  }

  return $self->{current_module};
}

sub process {
   die "you must override 'process' method in a subclass";
}

sub info {
  shift; #discard self ref
  return if $QUIET;
  my $msg = shift;
  print STDERR "I: $msg\n";
}

sub warning {
  shift; #discard self ref
  return if $QUIET;
  my $msg = shift;
  print STDERR "W: $msg\n";
}

sub error {
  shift; #discard self ref
  return if $QUIET;
  my $msg = shift;
  print STDERR "E: $msg\n";
}

1;

package Analizo::Extractor;

use strict;
use warnings;

use parent qw(Class::Accessor::Fast Analizo::Filter::Client);

use Analizo::Model;
use Analizo::FilenameFilter;
use Analizo::LanguageFilter;

our $QUIET = undef;

__PACKAGE__->mk_ro_accessors(qw(current_member));
__PACKAGE__->mk_accessors(qw(current_file));
__PACKAGE__->mk_accessors('includedir');

sub new {
  die(sprintf("%s cannot be instantied. Try %s->load() instead", __PACKAGE__, __PACKAGE__));
}

sub alias {
  my ($alias) = @_;
  my %aliases = (
    doxy => 'Doxyparse',
    excluding_dirs => 0,
  );
  exists $aliases{$alias} ? $aliases{$alias} : $alias;
}

sub sanitize {
  my ($extractor_name) = @_;
  if ($extractor_name && $extractor_name =~ /^\w+$/) {
    return $extractor_name;
  } else {
    return 'Doxyparse';
  }
}

sub load {
  my ($self, $extractor_method, @options) = @_;
  $extractor_method = alias(sanitize($extractor_method));
  my $extractor = "Analizo::Extractor::$extractor_method";

  eval "use $extractor";
  die "error loading $extractor_method extractor: $@" if $@;

  eval { $extractor = $extractor->new(@options) };
  die "error instancing extractor: $@" if $@;

  return $extractor;
}

sub model {
  my ($self) = @_;
  if (!exists($self->{model})) {
    $self->{model} = Analizo::Model->new;
  }
  return $self->{model};
}

sub current_module {
  my ($self, $current_module) = @_;

  # set the new value
  if (scalar $current_module) {
    ($self->{current_module}) = $current_module;

    #declare
    $self->model->declare_module($self->{current_module}, $self->current_file);
  }

  return $self->{current_module};
}

sub actually_process {
  # This method must be overriden by subclasses
}

# To disable filtering override this method returning false
sub use_filters {
  1;
}

sub process {
  my ($self, @input) = @_;

  if ($self->use_filters) {
    @input = $self->apply_filters(@input);
  }
  $self->actually_process(@input);
}

sub info {
  return if $QUIET;
  my ($self, $msg) = @_;
  print STDERR "I: $msg\n";
}

sub warning {
  return if $QUIET;
  my ($self, $msg) = @_;
  print STDERR "W: $msg\n";
}

sub error {
  return if $QUIET;
  my ($self, $msg) = @_;
  print STDERR "E: $msg\n";
}

1;

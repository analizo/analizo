package Egypt::Extractor;

use strict;
use warnings;

use base qw(Class::Accessor::Fast);

use Egypt::Model;

our $QUIET = undef;

__PACKAGE__->mk_ro_accessors(qw(current_member));

sub alias {
  my $alias = shift;
  my %aliases = (
    doxy => 'Doxyparse',
    gcc  => 'GCC',
  );
  exists $aliases{$alias} ? $aliases{$alias} : $alias;
}

sub load {
  shift; # discard self ref
  my $extractor_method = alias shift;
  my $extractor = "Egypt::Extractor::$extractor_method";

  eval "use $extractor";
  die "error loading $extractor_method extractor: $@" if $@;

  eval { $extractor = $extractor->new(@_) };
  die "error instancing extractor: $@" if $@;

  return $extractor;
}

sub model {
  my $self = shift;
  if (!exists($self->{model})) {
    $self->{model} = new Egypt::Model;
  }
  return $self->{model};
}

sub current_module {
  my $self = shift;

  # set the new value
  if (scalar @_) {
    $self->{current_module} = shift;

    # read variable declarations
    $self->_read_variable_declarations();

    #declare
    $self->model->declare_module($self->{current_module});
  }

  return $self->{current_module};
}

sub _read_variable_declarations {
  my $self = shift;
  return unless -r $self->current_module;
  open TAGS, sprintf('ctags-exuberant -f - --fields=K %s |', $self->current_module);
  while (<TAGS>) {
    chomp;
    my @fields = split(/\t/);
    if ($fields[3] eq 'variable') {
      $self->model->declare_variable($self->current_module, $fields[0]);
    }
  }
  close TAGS;
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

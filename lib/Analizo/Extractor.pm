package Analizo::Extractor;

use strict;
use warnings;

use base qw(Class::Accessor::Fast Analizo::Filter::Client);
use File::Find;

use Analizo::Model;
use Analizo::FilenameFilter;
use Analizo::LanguageFilter;

our $QUIET = undef;

__PACKAGE__->mk_ro_accessors(qw(current_member));
__PACKAGE__->mk_accessors(qw(current_file));

sub new {
  die(sprintf("%s cannot be instantied. Try %s->load() instead", __PACKAGE__, __PACKAGE__));
}

sub alias {
  my $alias = shift;
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
    @input = $self->_filter_input(@input);
  }
  $self->actually_process(@input);
}

sub _filter_input {
  my ($self, @input) = @_;
  unless ($self->has_filters) {
    # By default, only look at supported languages
    $self->filters(new Analizo::LanguageFilter('all'));
  }
  return $self->_apply_filters(@input);
}

sub _apply_filters {
  my ($self, @input) = @_;
  my @result = ();
  for my $input (@input) {
    find(
      { wanted => sub { push @result, $_ if !-d $_ && $self->filename_matches_filters($_); }, no_chdir => 1 },
      $input
    );
  }
  return @result;
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

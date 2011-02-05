package Analizo::Extractor;

use strict;
use warnings;

use base qw(Class::Accessor::Fast);
use File::Find;

use Analizo::Model;

our $QUIET = undef;

__PACKAGE__->mk_ro_accessors(qw(current_member));
__PACKAGE__->mk_accessors(qw(language));

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

sub actually_process {
  # This method must be overriden by subclasses
}

sub process {
  my ($self, @input) = @_;
  @input = $self->filter(@input);
  $self->actually_process(@input);
}

sub filter {
  my ($self, @input) = @_;
  if ($self->exclude) {
    @input = $self->filter_by_excluded_directories(@input);
  }
  if ($self->language) {
    @input = $self->filter_by_language(@input);
  }
  return @input;
}

sub filter_by_excluded_directories {
  my ($self, @input) = @_;
  my @result = ();
  for my $filename (@input) {
    if (-d $filename) {
      find(
        sub {
          if ($File::Find::name ne $filename && -d $_ && !$self->_excluded($File::Find::name)) {
            push @result, $File::Find::name;
          }
        },
        $filename
      );
    } else {
      push @result, $filename if !$self->_excluded($filename);
    }
  }
  return @result;
}

sub exclude {
  my ($self, @dirs) = @_;
  if (@dirs) {
    $self->{exclude} ||= [];
    push @{$self->{exclude}}, @dirs;
  }
  return $self->{exclude};
}

sub _excluded {
  my ($self, $filename) = @_;
  my $list = $self->exclude;
  if (@$list && grep { $filename =~ /^$_/ || $filename =~ /^.\/$_/ } @$list) {
    return 1;
  } else {
    return 0;
  }
}

sub filter_by_language {
  my ($self, @input) = @_;
  my @result = ();
  for my $filename (@input) {
    if (-d $filename) {
      find(
        sub {
          push @result, $File::Find::name if $self->language->matches($_);
        },
        $filename
      );
    } else {
      push @result, $filename if $self->language->matches($filename);
    }
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

package Analizo::LanguageFilter;

use strict;
use warnings;
use Carp;

our $FILTERS = {
  null      => '.',
  c         => '\.(c|h)$',
  cpp       => '\.(cpp|cxx|cc|h|hpp)$',
  java      => '\.java$',
};

sub new {
  my ($package, $filter_type) = @_;
  $filter_type ||= 'null';
  my $regex = $FILTERS->{$filter_type};
  if (!defined($regex)) {
    croak "E: Unknown language filter $filter_type";
  }
  my $self = {
    regex => $regex,
  };
  return bless $self, $package;
}

sub matches {
  my ($self, $filename) = @_;
  if ($filename =~ /$self->{regex}/) {
    return 1;
  }
  return 0;
}

1;

package Analizo::LanguageFilter;

use strict;
use warnings;
use Carp;

use base qw(Analizo::FilenameFilter);

our $FILTERS = {
  c         => 'c|h',
  cpp       => 'cpp|cxx|cc|h|hpp',
  java      => 'java',
};
$FILTERS->{all} = join('|', values(%$FILTERS));

sub new {
  my ($package, $filter_type) = @_;
  $filter_type ||= 'all';
  my $regex = $FILTERS->{$filter_type};
  if (!defined($regex)) {
    croak "E: Unknown language filter $filter_type";
  }
  my $self = {
    regex => '\.(' . $regex . '|' . uc($regex) . ')$',
  };
  return bless $self, $package;
}

sub list {
  my ($self) = @_;
  sort keys %$FILTERS;
}

1;

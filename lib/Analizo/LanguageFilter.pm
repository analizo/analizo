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
$FILTERS->{null} = join('|', values(%$FILTERS));

sub new {
  my ($package, $filter_type) = @_;
  $filter_type ||= 'null';
  my $regex = $FILTERS->{$filter_type};
  if (!defined($regex)) {
    croak "E: Unknown language filter $filter_type";
  }
  my $self = {
    regex => '\.(' . $regex . ')$',
  };
  return bless $self, $package;
}

1;

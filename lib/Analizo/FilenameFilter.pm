package Analizo::FilenameFilter;
use strict;
use warnings;

sub new {
  my ($package, @options) = @_;
  my $self = {
    regex => '.',
    reverse =>  0,
    @options
  };
  return bless $self, __PACKAGE__;
}

sub exclude {
  my ($package, @paths) = @_;
  my $regex = sprintf("^(./)?(%s)", join('|', @paths));
  return $package->new(regex => $regex, reverse => 1);
}

sub matches {
  my ($self, $filename) = @_;
  my $match = ($filename =~ /$self->{regex}/);
  return $self->{reverse} ? !$match : $match;
}

1;

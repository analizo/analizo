package Analizo::VCS::Driver;
use strict;
use warnings;
use Class::Accessor::Fast qw(antlers);
use List::MoreUtils qw(uniq);
use File::Find;

has url => (is => 'rw');
has url_sha1 => (is => 'ro', lazy => 1, builder => '_calculate_url_hash');

sub _calculate_url_hash {
  my ($self) = @_;
  sha1_hex($self->url);
}

sub repository_exists {
  my ($self) = @_;
  -e $self->url_sha1 && -d $self->url_sha1;
}

sub available_drivers {
  qw[ Git Subversion ];
}

1;

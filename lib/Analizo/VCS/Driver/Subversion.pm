package Analizo::VCS::Driver::Subversion;
use strict;
use warnings;
use base 'Analizo::VCS::Driver';
use SVN::Client;

sub download {
  my ($self) = @_;
  my $svn = SVN::Client->new();
  my $recursive = 1;
  $svn->checkout($self->url, $self->url_sha1, 'HEAD', $recursive);
  return 1;
}

1;

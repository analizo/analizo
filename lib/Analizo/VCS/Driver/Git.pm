package Analizo::VCS::Driver::Git;
use strict;
use warnings;
use base 'Analizo::VCS::Driver';
use Git::Wrapper;

sub fetch {
  my ($self) = @_;
  my $git = Git::Wrapper->new('it_will_be_ignored');
  $git->RUN('clone', $self->url, $self->output);
  return 1;
}

1;

package Analizo::Batch::Directories;
use strict;
use warnings;

use base qw(Analizo::Batch Class::Accessor::Fast);
use Analizo::Batch::Job::Directories;

__PACKAGE__->mk_accessors(qw(directories));

sub new {
  my ($class, @directories) = @_;
  my $self = $class->SUPER::new;
  if ($#directories < 1) {
    @directories = glob('*');
  }
  @directories = grep { -d $_ } @directories;
  $self->directories(\@directories);
  $self->{index} = 0;
  return $self;
}

sub fetch_next {
  my ($self) = @_;
  my $next_directory = $self->{directories}->[$self->{index}];
  if ($next_directory) {
    my $next_job = new Analizo::Batch::Job::Directories($next_directory);
    $self->{index} += 1;
    return $next_job;
  }
  return undef;
}

sub count {
  my ($self) = @_;
  return scalar(@{$self->{directories}});
}

1;

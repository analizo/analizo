package Analizo::Batch::Git;
use strict;
use warnings;

use base qw(
  Analizo::Batch
  Class::Accessor::Fast
);

use Analizo::Batch::Job::Git;
use Cwd 'abs_path';

__PACKAGE__->mk_ro_accessors(qw( directory ));

sub new {
  my ($class, $directory) = @_;
  $directory ||= '.';
  $directory = abs_path($directory);
  $class->SUPER::new(directory => $directory);
}

sub fetch_next {
  my ($self) = @_;
  $self->initialize();
  my $nextcommit = $self->{relevant}->[$self->{index}];
  if ($nextcommit) {
    $self->{index}++;
    return $nextcommit;
  } else {
    return undef;
  }
}

sub initialize {
  my ($self) = @_;
  unless(defined($self->{index})) {
    # read in list of commits
    open COMMITIDS, "(cd $self->{directory} && git log --format=%H)|";
    my @ids = <COMMITIDS>;
    close COMMITIDS;
    chomp @ids;
    # initialize filter: by default look only for files in known languages
    unless ($self->has_filters) {
      $self->filters(new Analizo::LanguageFilter('all'));
    }
    # construct job objects
    my @jobs = map { my $job = new Analizo::Batch::Job::Git($self->directory, $_); $job->batch($self); $job } @ids;
    my %jobs = map { $_->id => $_ } @jobs;
    my @relevant = grep { $_->relevant } @jobs;
    $self->{jobs} = \%jobs;
    $self->{relevant} = \@relevant;
    $self->{index} = 0;
    for my $job (@relevant) {
      # force calculating previous relevant right now
      $job->previous_relevant();
    }
  }
}

sub find {
  my ($self, $id) = @_;
  return $self->{jobs}->{$id};
}

1;

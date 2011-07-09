package Analizo::Batch::Git;
use strict;
use warnings;

use base qw(
  Analizo::Batch
  Class::Accessor::Fast
  Analizo::Filter::Client
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

sub next {
  my ($self) = @_;
  $self->initialize_if_needed;
  my $nextcommit = $self->{jobs}->[$self->{index}];
  if ($nextcommit) {
    $self->{index}++;
    return $nextcommit;
  } else {
    return undef;
  }
}

sub initialize_if_needed {
  my ($self) = @_;
  unless(defined($self->{index})) {
    open COMMITIDS, "(cd $self->{directory} && git log --format=%H)|";
    my @ids = <COMMITIDS>;
    close COMMITIDS;
    chomp @ids;
    my @jobs = map { my $job = new Analizo::Batch::Job::Git($self->directory, $_); $job->batch($self); $job } @ids;
    @jobs = grep { $_->relevant } @jobs;
    $self->{jobs} = \@jobs;
    $self->{index} = 0;
  }
}

sub matches_filters {
  my ($self, $job) = @_;
  return 1 unless ($self->filters);
  for my $file (@{$job->changed_files}) {
    if ($self->filename_matches_filters($file)) {
      return 1;
    }
  }
  return 0;
}

1;

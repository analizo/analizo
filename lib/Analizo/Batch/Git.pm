package Analizo::Batch::Git;
use strict;
use warnings;

use parent qw(
  Analizo::Batch
  Class::Accessor::Fast
);

use Analizo::Batch::Job::Git;
use Cwd 'abs_path';
use YAML::XS;

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
    # initialize filter: by default look only for files in known languages
    unless ($self->has_filters) {
      $self->filters(Analizo::LanguageFilter->new('all'));
    }

    # read in list of commits
    my $data = `(cd $self->{directory} && git log --name-status --format='---%nid: %H%nparents: %P%nauthor_date: %at%nauthor_name: %aN%nauthor_email: %aE%n--- |')`;
    $data =~ s/^([[:upper:]])+\t/  $1  /sgm;
    my @data = Load($data);
    my @jobs = ();
    while($#data > 0) {

      my $commit_data = shift(@data);

      my @parents = ();
      @parents = split(/\s+/, $commit_data->{parents}) if defined($commit_data->{parents});
      $commit_data->{parents} = \@parents;

      my $changed_files = shift(@data);
      if(scalar(@parents) > 1) {
        # merge commits do not have their changed files listed in `git log`, no
        # matter what. This way we *need* to do a `git show` here.
        $changed_files = `(cd $self->{directory} && git show --name-status --format='%n' $commit_data->{id})`;
      }
      chomp($changed_files);
      $changed_files =~ s/^\s*//; # remove leading whitespace
      my %changed_files = map { my ($status, $file) = split(/\s+/, $_); $file => $status } (split("\n", $changed_files));
      for my $file (keys(%changed_files)) {
        if (!$self->filename_matches_filters($file)) {
          delete $changed_files{$file};
        }
      }
      $commit_data->{changed_files} = \%changed_files;

      my $job = Analizo::Batch::Job::Git->new($self->{directory}, $commit_data->{id}, $commit_data);
      $job->batch($self);
      push @jobs, $job;

    }

    my %jobs = map { $_->id => $_ } @jobs;
    my @relevant = grep { $_->relevant } @jobs;
    $self->{jobs} = \%jobs;
    $self->{relevant} = \@relevant;
    $self->{count} = scalar(@relevant);
    $self->{index} = 0;
    for my $job (@relevant) {
      # force calculating previous relevant right now
      $job->previous_relevant();
    }
  }
}

sub count {
  my ($self) = @_;
  return $self->{count};
}

sub find {
  my ($self, $id) = @_;
  return $self->{jobs}->{$id};
}

1;

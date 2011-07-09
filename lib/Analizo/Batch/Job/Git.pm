package Analizo::Batch::Job::Git;

use base 'Analizo::Batch::Job';
use Cwd;

__PACKAGE__->mk_accessors('batch');

sub new {
  my ($class, $directory, $id) = @_;
  $class->SUPER::new(directory => $directory, id => $id);
}

sub prepare {
  my ($self) = @_;
  # change directory
  $self->{oldcwd} = getcwd();
  chdir($self->{directory});
  # checkout
  $self->{oldHEAD} = git_HEAD();
  $self->git_checkout($self->id);
}

sub cleanup {
  my ($self) = @_;
  # undo checkout
  $self->git_checkout($self->{oldHEAD});
  delete($self->{oldHEAD});
  # undo directory change
  chdir($self->{oldcwd});
  delete($self->{oldcwd});
}

sub relevant {
  my ($self) = @_;
  return $self->batch->matches_filters($self);
}

use Data::Dumper;
sub changed_files {
  my ($self) = @_;
  return $self->data->{changed_files};
}

sub data {
  my ($self) = @_;
  unless (defined($self->{data})) {
    my @output = `cd $self->{directory} && git show --name-only --format=%P/%aD/%aN/%aE $self->{id}`;
    chomp @output;
    @output = grep { length($_) > 0 } @output;
    my @header = split('/', shift @output);
    $self->{data} = {
      changed_files => \@output,
    };
  }
  return $self->{data};
}

sub git_HEAD {
  my $commit = `git log --format=%H | head -n 1`; chomp($commit);
  return $commit;
}

sub git_checkout {
  my ($self, $commit) = @_;
  system("git checkout --quiet $commit");
}

1;

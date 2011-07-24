package Analizo::Batch::Job::Git;

use base 'Analizo::Batch::Job';
use Cwd;
use Cwd 'abs_path';
use File::Spec;
use Digest::SHA1 qw/ sha1_hex /;
use File::Copy::Recursive qw(dircopy);
use File::Path qw(remove_tree);

__PACKAGE__->mk_accessors('batch');

sub new {
  my ($class, $directory, $id) = @_;
  $class->SUPER::new(directory => $directory, id => $id);
}

sub parallel_prepare {
  my ($self) = @_;
  $self->{original_directory} = $self->{directory};
  $self->{directory} = _create_work_directory($self->{directory});
}

sub parallel_cleanup {
  my ($self) = @_;
  my $workdir = _create_work_directory($self->{original_directory});
  remove_tree($workdir);
}

sub _create_work_directory {
  my ($original_dir) = @_;
  my $basename = 'analizo.' . $$ . '.' . sha1_hex(abs_path($original_dir));
  my $newdir = File::Spec->catfile(File::Spec->tmpdir(), $basename);
  if (! -d $newdir) {
    # Assume that the same directory may have been created before by the same
    # process.
    dircopy($original_dir, $newdir);
  }
  return $newdir;
}

sub prepare {
  my ($self) = @_;
  # change directory
  $self->{oldcwd} = getcwd();
  chdir($self->{directory});
  # checkout
  $self->{old_branch} = git_current_branch();
  $self->git_checkout($self->id);
}

sub cleanup {
  my ($self) = @_;
  # undo checkout
  $self->git_checkout($self->{old_branch});
  delete($self->{old_branch});
  # undo directory change
  chdir($self->{oldcwd});
  delete($self->{oldcwd});
}

sub relevant {
  my ($self) = @_;
  return $self->batch->matches_filters($self);
}

sub previous_wanted {
  my ($self) = @_;
  if ($self->is_merge) {
    return undef;
  } else {
    return $self->previous_relevant;
  }
}

sub previous_relevant {
  my ($self, $repository) = @_;
  if (exists($self->{previous_relevant})) {
    return $self->{previous_relevant};
  }
  $self->{previous_relevant} = $self->_calculate_previous_relevant();
  return $self->{previous_relevant};
}

sub _calculate_previous_relevant {
  my ($self) = @_;
  if ($self->is_first_commit) {
    return undef;
  } elsif ($self->is_merge) {
    my @possibilities = map { $self->batch->find($_)->previous_relevant } @{$self->data->{parents}};
    my %ids = map { $_->id => 1 } @possibilities;
    if (scalar(keys(%ids)) == 1) {
      return $possibilities[0];
    } else {
      return undef;
    }
  } else {
    my $parent = $self->batch->find($self->data->{parents}->[0]);
    if ($parent->relevant) {
      return $parent;
    } else {
      return $parent->previous_relevant();
    }
  }
}

sub is_first_commit {
  my ($self) = @_;
  return scalar(@{$self->data->{parents}}) == 0;
}

sub is_merge {
  my ($self) = @_;
  my $ret = scalar(@{$self->data->{parents}}) > 1;
  return $ret;
}

sub changed_files {
  my ($self) = @_;
  return $self->data->{changed_files};
}

sub data {
  my ($self) = @_;
  unless (defined($self->{data})) {
    my @output = `cd $self->{directory} && git show --name-only --format=%P/%at/%aN/%aE $self->{id}`;
    chomp @output;
    @output = grep { length($_) > 0 } @output;
    my @header = split('/', shift @output);
    my @parents = split(/\s+/, $header[0]);
    $self->{data} = {
      changed_files => \@output,
      parents       => \@parents,
      author_date   => $header[1],
      author_name   => $header[2],
      author_email  => $header[3],
    };
  }
  return $self->{data};
}

sub metadata {
  my ($self) = @_;
  my $data = $self->data;
  my $previous_commit = $self->previous_wanted();
  return [
    ['previous_commit_id', $previous_commit ? $previous_commit->id() : undef],
    ['author_date', $data->{author_date}],
    ['author_name', $data->{author_name}],
    ['author_email', $data->{author_email}],
  ];
}

sub git_HEAD {
  my $commit = `git log --format=%H | head -n 1`; chomp($commit);
  return $commit;
}

sub git_checkout {
  my ($self, $commit) = @_;
  system("git checkout --quiet $commit");
}

sub git_current_branch {
  my @branches = `git branch`;
  chomp(@branches);
  my @current = grep { /^\*/ } @branches;
  my $current = $current[0];
  $current =~ s/^\*\s*//;
  return $current;
}

1;

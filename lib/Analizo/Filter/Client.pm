package Analizo::Filter::Client;

use File::Find;

sub filters {
  my ($self, @new_filters) = @_;
  $self->{filters} ||= [];
  if (@new_filters) {
    push @{$self->{filters}}, @new_filters;
  }
  return $self->{filters};
}

sub has_filters {
  my ($self) = @_;
  return exists($self->{filters}) && exists($self->{filters}->[0]);
}

sub share_filters_with($$) {
  my ($self, $other) = @_;
  $other->{filters} = $self->{filters};
}

sub exclude {
  my ($self, @dirs) = @_;
  if (!$self->{excluding_dirs}) {
    $self->{excluding_dirs} = 1;
    $self->filters(Analizo::LanguageFilter->new);
  }
  $self->filters(Analizo::FilenameFilter->exclude(@dirs));
}

sub filename_matches_filters {
  my ($self, $filename) = @_;
  for my $filter (@{$self->filters}) {
    unless ($filter->matches($filename)) {
      return 0;
    }
  }
  return 1;
}

sub apply_filters {
  my ($self, @input) = @_;

  unless ($self->has_filters) {
    # By default, only look at supported languages
    $self->filters(new Analizo::LanguageFilter('all'));
  }

  my @result = ();
  for my $input (@input) {
    find(
      { wanted => sub { push @result, $_ if !-d $_ && $self->filename_matches_filters($_); }, no_chdir => 1 },
      $input
    );
  }
  return @result;
}

1;

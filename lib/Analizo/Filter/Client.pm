package Analizo::Filter::Client;

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

1;

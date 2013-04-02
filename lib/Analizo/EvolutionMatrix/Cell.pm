package Analizo::EvolutionMatrix::Cell;
use strict;
use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw(matrix data));

sub width {
  my $self = shift;
  $self->data->{$self->matrix->cell_width};
}

sub height {
  my $self = shift;
  $self->data->{$self->matrix->cell_height};
}

sub normalized_width {
  my $self = shift;
  $self->width / $self->matrix->max_width;
}

sub normalized_height {
  my $self = shift;
  $self->height / $self->matrix->max_height;
}

1;

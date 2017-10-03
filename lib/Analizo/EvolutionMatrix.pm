package Analizo::EvolutionMatrix;
use strict;
use List::MoreUtils qw( uniq );
use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw(cells cell_width cell_height max_width max_height name));

sub versions {
  my ($self) = @_;
  [sort { compare_versions($a, $b) } uniq(map { keys %$_ } values %{$self->cells})];
}

sub compare_versions {
  my ($a, $b) = @_;
  if ($a == $b) {
    0
  } else {
    my @a_array = map { int $_ } split(/[^0-9]+/, $a);
    my @b_array = map { int $_ } split(/[^0-9]+/, $b);
    while ($a_array[0] == $b_array[0]) {
      shift @a_array;
      shift @b_array;
    }
    $a_array[0] <=> $b_array[0];
  }
}

sub modules {
  [keys %{shift->cells}];
}

sub put {
  my ($self, $mod, $version, $data) = @_;
  die "Cannot use empty version (mod = $mod, version = $version, data = $data)" unless $version;
  my $cell = Analizo::EvolutionMatrix::Cell->new({matrix => $self, data => $data});
  if ($cell->width > $self->max_width) {
    $self->{max_width} = $cell->width;
  }
  if ($cell->height > $self->max_height) {
    $self->{max_height} = $cell->height;
  }
  $self->{cells} ||= {};
  $self->cells->{$mod} ||= {};
  $self->cells->{$mod}->{$version} = $cell;
}

sub get {
  my ($self, $mod, $version) = @_;
  $self->cells->{$mod} && $self->cells->{$mod}->{$version};
}

sub is_empty {
  my ($self) = @_;
  $self->cells && keys %{$self->cells} == 0;
}

sub cell_width {
  shift->{cell_width};
}

sub cell_height {
  shift->{cell_height};
}

sub max_width {
  shift->{max_width} || 0;
}

sub max_height {
  shift->{max_height} || 0;
}

sub name {
  shift->{name};
}

1;

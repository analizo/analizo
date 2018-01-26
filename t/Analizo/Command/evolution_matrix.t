package t::Analizo::Command::evolution_matrix;
use strict;
use warnings;
use parent qw(Test::Analizo::Class);
use Test::More;
use Test::Analizo;
use Analizo;

BEGIN {
  use_ok 'Analizo::Command::evolution_matrix'
};

sub constructor : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('evolution-matrix');
  isa_ok($cmd, 'Analizo::Command::evolution_matrix');
}

sub is_a_subclass_of_Analizo_Command : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('evolution-matrix');
  isa_ok($cmd, 'Analizo::Command');
}

__PACKAGE__->runtests;

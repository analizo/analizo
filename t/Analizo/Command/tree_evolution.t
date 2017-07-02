package t::Analizo::Command::tree_evolution;
use strict;
use warnings;
use parent qw(t::Analizo::Test::Class);
use Test::More;
use t::Analizo::Test;
use Analizo;

BEGIN {
  use_ok 'Analizo::Command::tree_evolution'
};

sub constructor : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('tree-evolution');
  isa_ok($cmd, 'Analizo::Command::tree_evolution');
}

sub is_a_subclass_of_Analizo_Command : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('tree-evolution');
  isa_ok($cmd, 'Analizo::Command');
}

__PACKAGE__->runtests;

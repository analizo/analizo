package t::Analizo::Command::treeevolution;
use strict;
use warnings;
use base qw(t::Analizo::Test::Class);
use Test::More 'no_plan';
use t::Analizo::Test;
use Analizo;

BEGIN {
  use_ok 'Analizo::Command::treeevolution'
};

sub constructor : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('treeevolution');
  isa_ok($cmd, 'Analizo::Command::treeevolution');
}

sub construct_through_alias : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('tree-evolution');
  isa_ok($cmd, 'Analizo::Command::treeevolution');
}

sub is_a_subclass_of_Analizo_Command : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('treeevolution');
  isa_ok($cmd, 'Analizo::Command');
}

__PACKAGE__->runtests;

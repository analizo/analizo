package t::Analizo::Command::evolutionmatrix;
use strict;
use warnings;
use base qw(t::Analizo::Test::Class);
use Test::More 'no_plan';
use t::Analizo::Test;
use Analizo;

BEGIN {
  use_ok 'Analizo::Command::evolutionmatrix'
};

sub constructor : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('evolutionmatrix');
  isa_ok($cmd, 'Analizo::Command::evolutionmatrix');
}

sub construct_through_alias : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('evolution-matrix');
  isa_ok($cmd, 'Analizo::Command::evolutionmatrix');
}

sub is_a_subclass_of_Analizo_Command : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('evolutionmatrix');
  isa_ok($cmd, 'Analizo::Command');
}

__PACKAGE__->runtests;

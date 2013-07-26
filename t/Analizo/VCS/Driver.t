package t::Analizo::VCS::Driver;
use strict;
use warnings;
use base qw(t::Analizo::Test::Class);
use Test::More 'no_plan'; # REMOVE THE 'no_plan'
use Test::Exception;

BEGIN {
  use_ok 'Analizo::VCS::Driver';
}

sub find_at_least_two_drivers : Tests {
  my @drivers = Analizo::VCS::Driver->available_drivers;
  cmp_ok(@drivers, '>=', 2);
}

sub find_Git_driver : Tests {
  my @drivers = Analizo::VCS::Driver->available_drivers;
  ok(grep { $_ eq 'Git' } @drivers, 'Git driver found!');
}

sub find_Subversion_driver : Tests {
  my @drivers = Analizo::VCS::Driver->available_drivers;
  ok(grep { $_ eq 'Subversion' } @drivers, 'Subversion driver found!');
}

__PACKAGE__->runtests;

package t::Analizo::VCS;
use strict;
use warnings;
use base qw(t::Analizo::Test::Class);
use Test::More 'no_plan'; # REMOVE THE 'no_plan'
use Test::Exception;

BEGIN {
  use_ok 'Analizo::VCS';
}

sub fail_when_pass_no_driver : Tests {
  dies_ok { Analizo::VCS->new };
}

sub fail_when_pass_unavailable_driver : Tests {
  dies_ok { Analizo::VCS->new('NotValid') };
}

sub load_Git_driver : Tests {
  lives_ok { Analizo::VCS->new('Git') };
}

sub load_Subversion_driver : Tests {
  lives_ok { Analizo::VCS->new('Subversion') };
}

sub access_the_loaded_driver : Tests {
  isa_ok(Analizo::VCS->new('Git')->driver, 'Analizo::VCS::Driver::Git');
  isa_ok(Analizo::VCS->new('Subversion')->driver, 'Analizo::VCS::Driver::Subversion');
}

__PACKAGE__->runtests;

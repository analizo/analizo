package t::Analizo::VCS::Driver::Git;
use strict;
use warnings;
use base qw(t::Analizo::Test::Class);
use t::Analizo::Test;
use Test::More 'no_plan'; # REMOVE THE 'no_plan'
use Test::File;

BEGIN {
  use_ok 'Analizo::VCS::Driver::Git';
}

sub constructor : Tests {
  isa_ok(Analizo::VCS::Driver::Git->new, 'Analizo::VCS::Driver::Git');
}

sub fetch : Tests {
  my $driver = Analizo::VCS::Driver::Git->new;
  my $output = tmpdir . "/repository-fetched";
  unpack_sample_git_repository(sub {
    $driver->url('.');
    $driver->output($output);
    file_not_exists_ok($output);
    $driver->fetch;
    dir_exists_ok($output);
    dir_contains_ok($output, 'README');
    dir_contains_ok($output, '.git');
  }, 'tree-evolution');
}

__PACKAGE__->runtests;

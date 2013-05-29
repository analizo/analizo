package t::Analizo::Test::Class;
use strict;
use warnings;

use base qw( Test::Class );
use File::Path qw(remove_tree);

sub create_tmpdir : Test(setup) {
  mkdir 't/tmp';
}

sub cleanup_tmpdir : Test(teardown) {
  remove_tree 't/tmp';
}

1;

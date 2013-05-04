package Test::Analizo::Class;
use strict;
use warnings;

use base qw( Test::Class );
use File::Path qw(remove_tree);

sub create_tmpdir : Test(setup) {
  mkdir 't/tmp';
  chdir 't/tmp';
}

sub cleanup_tmpdir : Test(teardown) {
  chdir '../../';
  remove_tree 't/tmp';
}

1;

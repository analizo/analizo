package Test::Analizo::Class;
use strict;
use warnings;

use parent qw( Test::Class );
use File::Path qw(remove_tree);
use File::Temp qw( tempdir );

sub create_tmpdir : Test(setup) {
  mkdir 't/tmp';
}

sub cleanup_tmpdir : Test(teardown) {
  remove_tree 't/tmp';
}

sub create_analizo_cache_tmpdir : Test(setup) {
  $ENV{ANALIZO_CACHE} = tempdir(CLEANUP => 1);
}

sub cleanup_analizo_cache_tmpdir : Test(teardown) {
  remove_tree $ENV{ANALIZO_CACHE};
}

1;

#!/usr/bin/perl -w
use Devel::NYTProf;
use FindBin::libs;
use Analizo;
use strict;
use warnings;

my $analizo = Analizo->new;
$analizo->execute_command(
  $analizo->prepare_command(
    $ENV{COMMAND} // 'metrics',
    $ENV{SOURCE} // $ARGV[0] // 't/samples/hello_world/cpp/'
  )
);

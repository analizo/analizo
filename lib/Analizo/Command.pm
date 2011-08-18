package Analizo::Command;

use YAML;
use File::Basename;

my @caller = caller();
my $command = basename($caller[1]);
$command =~ s/^analizo-//;

if (-e '.analizo') {
  my $config = YAML::LoadFile('.analizo');
  if ($config->{$command}) {
    my @options = split(/\s+/, $config->{$command});
    unshift @ARGV, @options;
  }
}

1;

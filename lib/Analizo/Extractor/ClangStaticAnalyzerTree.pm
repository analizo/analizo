package Analizo::Extractor::ClangStaticAnalyzerTree;

use strict;
use warnings;

my $tree;

sub new {
  $tree = undef;
  my $package = shift;
  return bless {@_}, $package;
}

sub building_tree {
  my ($self, $line) = @_;
  my $file_name;
  my $bug_name;
  my @raw_path;

  if($line =~ m/<\/td><td class="DESC">([^<]+)<\/td><td>([^&]+)<\/td><td class="Q">([\d]+)<\/td><td class="Q">/) {
    @raw_path = split("<span class=\"W\"> </span>", $2);
    $file_name = join('', @raw_path);
    $bug_name = $1;

    if(!defined $tree->{$file_name}->{$bug_name}) {
      $tree->{$file_name}->{$bug_name} = 1;
    }
    else {
      $tree->{$file_name}->{$bug_name}++;
    }
  }

  return $tree;
}

1;

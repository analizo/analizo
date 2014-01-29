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
  my ($self, $line, $file_name) = @_;
  my $bug_name;

  if($line =~ m/<\/td><td class="DESC">([^<]+)<\/td><td>([^&]+)<\/td><td class="Q">([\d]+)<\/td><td class="Q">/) {
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

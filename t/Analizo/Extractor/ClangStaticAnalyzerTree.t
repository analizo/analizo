package t::Analizo::Extractor::ClangStaticAnalyzerTree;
use base qw(Test::Class);
use Test::More;

use strict;
use warnings;
use File::Basename;

use Analizo::Extractor;
use Analizo::Extractor::ClangStaticAnalyzerTree;

eval('$Analizo::Extractor::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

my $tree;

sub before : Test(setup) {
  $tree = new Analizo::Extractor::ClangStaticAnalyzerTree;
}

sub after : Test(teardown){
  $tree = undef;
}

sub constructor : Tests {
  use_ok('Analizo::Extractor::ClangStaticAnalyzerTree');
  my $tree = new Analizo::Extractor::ClangStaticAnalyzerTree;
  isa_ok($tree, 'Analizo::Extractor::ClangStaticAnalyzerTree');
}

sub building_tree_with_reports_from_radom_file  : Tests {
  my $report_path = "t/clang_analyzer_reports/analizo_org.html";
  my $report_tree;
  my $metrics_size = 0;

  open (my $file_report, '<', $report_path) or die $!;
  while(<$file_report>){
    $report_tree = $tree->building_tree($_, "file.c");
  }
  close ($file_report);

  $metrics_size = keys %$report_tree if defined $report_tree;
  is($metrics_size , 0, "No metrics expected");
}

sub building_tree_with_reports_empty_file  : Tests {
  my $report_tree;
  my $metrics_size = 0;

  $report_tree = $tree->building_tree("", "file.c");

  $metrics_size = keys %$report_tree if defined $report_tree;
  is($metrics_size , 0, "No metrics expected");
}

sub building_tree_with_reports_from_multiple_files : Tests {
  my $report_path = "t/clang_analyzer_reports/libreoffice.html";
  my $report_tree;

  open (my $file_report, '<', $report_path) or die $!;
  while(<$file_report>){
    $report_tree = $tree->building_tree($_, "file.c");
  }
  close ($file_report);

  my $total_bugs = 0;
  foreach my $file_name (keys %$report_tree) {
    my $bugs_hash = $report_tree->{$file_name};

    foreach my $bugs (values %$bugs_hash) {
      $total_bugs += $bugs;
    }
  }

  is($total_bugs, 726, "726 bugs expected");
}

__PACKAGE__->runtests;


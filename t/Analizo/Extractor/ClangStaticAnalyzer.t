package t::Analizo::Extractor::ClangStaticAnalyzer;
use base qw(Test::Class);
use Test::More tests => 4;

use strict;
use warnings;
use File::Basename;

use Analizo::Extractor;
use Analizo::Extractor::ClangStaticAnalyzer;

eval('$Analizo::Extractor::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

sub constructor : Tests {
  use_ok('Analizo::Extractor::ClangStaticAnalyzer');
  my $extractor = Analizo::Extractor->load('ClangStaticAnalyzer');
  isa_ok($extractor, 'Analizo::Extractor::ClangStaticAnalyzer');
  isa_ok($extractor, 'Analizo::Extractor');
}

sub has_a_model : Tests {
  isa_ok((Analizo::Extractor->load('ClangStaticAnalyzer'))->model, 'Analizo::Model');
}

#sub filter_html_report_empty_file : Tests {
#  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
#  my $report_path = "t/clang_analyzer_reports/blank.html";
#  my %metrics = $extractor->filter_html_report($report_path);
#  my $metrics_size = keys %metrics;
#  is($metrics_size, 0, "0 expected for empty files");
#}
#
#sub filter_html_report_no_file : Tests {
#  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
#  my $report_path = "t/clang_analyzer_reports/no_file.html";
#  my %metrics = $extractor->filter_html_report($report_path);
#  my $metrics_size = keys %metrics;
#  is($metrics_size, 0, "0 expected when no files are opened");
#}
#
#sub filter_html_report_random_file : Tests {
#  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
#  my $report_path = "t/clang_analyzer_reports/analizo_org.html";
#  my %metrics = $extractor->filter_html_report($report_path);
#  my $metrics_size = keys %metrics;
#  is($metrics_size, 0, "no metrics from non report files");
#}
#
#sub filter_html_report_with_reports : Tests {
#  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
#  my $report_path = "t/clang_analyzer_reports/libreoffice.html";
#  my %metrics = $extractor->filter_html_report($report_path);
#  my $metrics_size = keys %metrics;
#  is($metrics_size , 20, "metrics expected");
#  my $sum = 0;
#  foreach my $value(values %metrics) {
#    $sum += $value;
#  }
#  is($sum, 726, "Sum of metrics from libreoffice.html is 726.");
#  is($metrics{"Argument with 'nonnull' attribute passed null"}, 22);
#  is($metrics{"Undefined allocation of 0 bytes (CERT MEM04-C; CWE-131)"}, 2);
#}
#
#sub filter_html_report_with_reports_from_multiple_files : Tests {
#  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
#  my $report_path = "t/clang_analyzer_reports/multiple_files.html";
#  my %metrics = $extractor->filter_html_report($report_path);
#  my $metrics_size = keys %metrics;
#  is($metrics_size , 2, "metrics expected");
#}
#
#sub test_actually_process : Tests {
#  no warnings 'redefine';
#  our %global_metrics;
#
#  sub overriden_feed {
#    my ($self, %metrics) = @_;
#    %global_metrics = %metrics;
#  }
#
#  *Analizo::Extractor::ClangStaticAnalyzer::feed = \&overriden_feed;
#
#  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
#  $extractor->actually_process("t/samples/clang_analyzer/division_by_zero.c", "t/samples/clang_analyzer/dead_assignment.c");
#  my $metrics_size = keys %global_metrics;
#  is($metrics_size , 2, "2 bugs expected");
#}

__PACKAGE__->runtests;


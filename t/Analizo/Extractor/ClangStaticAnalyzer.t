package t::Analizo::Extractor::ClangStaticAnalyzer;
use base qw(Test::Class);
use Test::More tests => 5;

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

sub test_actually_process : Tests {
  no warnings 'redefine';
  our $report_tree;

  local *Analizo::Extractor::ClangStaticAnalyzer::feed = sub {
    my ($self, $tree) = @_;
    $report_tree = $tree;
  };

  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
  $extractor->actually_process("t/samples/clang_analyzer/division_by_zero.c", "t/samples/clang_analyzer/dead_assignment.c");

  my $total_bugs = 0;
  foreach my $file_name (keys %$report_tree) {
    my $bugs_hash = $report_tree->{$file_name};

    foreach my $bugs (values %$bugs_hash) {
      $total_bugs += $bugs;
    }
  }

  is($total_bugs , 2, "2 bugs expected");
}

__PACKAGE__->runtests;


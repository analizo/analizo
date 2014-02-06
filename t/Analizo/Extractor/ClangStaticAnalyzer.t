package t::Analizo::Extractor::ClangStaticAnalyzer;
use base qw(Test::Class);
use Test::More tests => 15;

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
  our $report_tree;

  no warnings;
  local *Analizo::Extractor::ClangStaticAnalyzer::feed = sub {
    my ($self, $tree) = @_;
    $report_tree = $tree;
  };
  use warnings;

  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
  $extractor->actually_process("t/samples/clang_analyzer/dead_assignment.c", "t/samples/clang_analyzer/division_by_zero.c", "t/samples/clang_analyzer/memory_leak.c", "t/samples/clang_analyzer/no_compilable.c");

  my $total_bugs = 0;
  foreach my $file_name (keys %$report_tree) {
    my $bugs_hash = $report_tree->{$file_name};

    foreach my $bugs (values %$bugs_hash) {
      $total_bugs += $bugs;
    }

  }

  is($total_bugs , 3, "3 bugs expected");
}

sub feed_declares_divisions_by_zero : Tests {

  our $received_module;
  our $received_value;

  no warnings;
  local *Analizo::Model::declare_security_metrics = sub {
    my ($self, $bug, $module, $value) = @_;
    $received_module = $module;
    $received_value = $value;
  };
  use warnings;
  my $tree;
  $tree->{'a/b/c.d/dir/file.c'}->{'Division by zero'} = 2;

  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
  $extractor->feed($tree);

  is($received_module,'a/b/c.d/dir/file','Module name must be the file name.');
  is($received_value, 2, '2 bugs expected.');

}

sub feed_declares_dead_assignment : Tests {

  our $received_module;
  our $received_value;

  no warnings;
  local *Analizo::Model::declare_security_metrics = sub {
    my ($self, $bug_name, $module, $value) = @_;
    $received_module = $module;
    $received_value = $value;
  };
  use warnings;
  my $tree;
  $tree->{'a/b/c.d/dir/file.c'}->{'Dead assignment'} = 2;

  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
  $extractor->feed($tree);

  is($received_module,'a/b/c.d/dir/file','Module name must be the file name.');
  is($received_value, 2, '2 bugs expected.');

}

sub feed_declares_memory_leak : Tests {

  our $received_module;
  our $received_value;

  no warnings;
  local *Analizo::Model::declare_security_metrics = sub {
    my ($self, $bug_name, $module, $value) = @_;
    $received_module = $module;
    $received_value = $value;
  };
  use warnings;
  my $tree;
  $tree->{'a/b/c.d/dir/file.c'}->{'Memory leak'} = 2;

  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
  $extractor->feed($tree);

  is($received_module,'a/b/c.d/dir/file','Module name must be the file name.');
  is($received_value, 2, '2 bugs expected.');

}

sub feed_declares_dereference_of_null_pointer : Tests {

  our $received_module;
  our $received_value;

  no warnings;
  local *Analizo::Model::declare_security_metrics = sub {
    my ($self, $bug_name, $module, $value) = @_;
    $received_module = $module;
    $received_value = $value;
  };
  use warnings;
  my $tree;
  $tree->{'a/b/c.d/dir/file.c'}->{'Dereference of null pointer'} = 2;

  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
  $extractor->feed($tree);

  is($received_module,'a/b/c.d/dir/file','Module name must be the file name.');
  is($received_value, 2, '2 bugs expected.');

}

sub feed_declares_assigned_undefined_value : Tests {

  our $received_module;
  our $received_value;

  no warnings;
  local *Analizo::Model::declare_security_metrics = sub {
    my ($self, $bug_name, $module, $value) = @_;
    $received_module = $module;
    $received_value = $value;
  };
  use warnings;
  my $tree;
  $tree->{'a/b/c.d/dir/file.c'}->{'Assigned value is garbage or undefined'} = 2;

  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
  $extractor->feed($tree);

  is($received_module,'a/b/c.d/dir/file','Module name must be the file name.');
  is($received_value, 2, '2 bugs expected.');

}

__PACKAGE__->runtests;


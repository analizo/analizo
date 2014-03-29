package t::Analizo::Extractor::ClangStaticAnalyzer;
use base qw(Test::Class);
use Test::More;

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
  is($report_tree->{'t/samples/clang_analyzer/no_compilable.c'}->{'Memory leak'}, undef, 'Metric must be undef');
  is($total_bugs , 3, "3 bugs expected");
}

sub feed_declares_divisions_by_zero : Tests {

  our $received_bug;
  our $received_module;
  our $received_value;

  no warnings;
  local *Analizo::Model::declare_security_metrics = sub {
    my ($self, $bug, $module, $value) = @_;
    $received_bug = $bug;
    $received_module = $module;
    $received_value = $value;
  };
  use warnings;
  my $tree;
  $tree->{'a/b/c.d/dir/file.c'}->{'Division by zero'} = 2;

  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
  $extractor->feed($tree);

  is($received_bug,'Division by zero','Bug name must be Division by zero');
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

sub feed_declares_return_of_stack_variable_address : Tests {

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
  $tree->{'a/b/c.d/dir/file.c'}->{'Return of stack variable address'} = 2;

  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
  $extractor->feed($tree);

  is($received_module,'a/b/c.d/dir/file','Module name must be the file name.');
  is($received_value, 2, '2 bugs expected.');

}

sub feed_declares_uninitialized_argument_value : Tests {

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
  $tree->{'a/b/c.d/dir/file.c'}->{'Uninitialized argument value'} = 4;

  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
  $extractor->feed($tree);

  is($received_module,'a/b/c.d/dir/file','Module name must be the file name.');
  is($received_value, 4, '4 bugs expected.');

}

sub feed_declares_bad_free : Tests {

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
  $tree->{'a/b/c.d/dir/file.c'}->{'Bad free'} = 5;

  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
  $extractor->feed($tree);

  is($received_module,'a/b/c.d/dir/file','Module name must be the file name.');
  is($received_value, 5, '5 bugs expected.');

}

sub feed_declares_double_free : Tests {

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
  $tree->{'a/b/c.d/dir/file.c'}->{'Double free'} = 5;

  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
  $extractor->feed($tree);

  is($received_module,'a/b/c.d/dir/file','Module name must be the file name.');
  is($received_value, 5, '5 bugs expected.');

}

sub feed_declares_bad_deallocator : Tests {

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
  $tree->{'a/b/c.d/dir/file.c'}->{'Bad deallocator'} = 6;

  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
  $extractor->feed($tree);

  is($received_module,'a/b/c.d/dir/file','Module name must be the file name.');
  is($received_value, 6, '6 bugs expected.');

}

sub feed_declares_use_after_free : Tests {

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
  $tree->{'a/b/c.d/dir/file.c'}->{'Use-after-free'} = 7;

  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
  $extractor->feed($tree);

  is($received_module,'a/b/c.d/dir/file','Module name must be the file name.');
  is($received_value, 7, '7 bugs expected.');

}

sub feed_declares_offset_free : Tests {
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
  $tree->{'a/b/c.d/dir/file.c'}->{'Offset free'} = 8;

  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
  $extractor->feed($tree);

  is($received_module,'a/b/c.d/dir/file','Module name must be the file name.');
  is($received_value, 8, '8 bugs expected.');

}

sub feed_declares_undefined_allocation : Tests {
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
  $tree->{'a/b/c.d/dir/file.c'}->{'Undefined allocation of 0 bytes (CERT MEM04-C; CWE-131)'} = 9;

  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
  $extractor->feed($tree);

  is($received_module,'a/b/c.d/dir/file','Module name must be the file name.');
  is($received_value, 9, '9 bugs expected.');

}

sub feed_declares_function_gets_buffer_overflow : Tests {
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
  $tree->{'a/b/c.d/dir/file.c'}->{"Potential buffer overflow in call to \'gets\'"} = 11;

  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
  $extractor->feed($tree);

  is($received_module,'a/b/c.d/dir/file','Module name must be the file name.');
  is($received_value, 11, '11 bugs expected.');

}

sub feed_declares_dereference_of_undefined_pointer_value : Tests {
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
  $tree->{'a/b/c.d/dir/file.c'}->{'Dereference of undefined pointer value'} = 13;

  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
  $extractor->feed($tree);

  is($received_module,'a/b/c.d/dir/file','Module name must be the file name.');
  is($received_value, 13, '13 bugs expected.');

}

sub feed_declares_allocator_sizeof_operand_mismatch : Tests {
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
  $tree->{'a/b/c.d/dir/file.c'}->{'Allocator sizeof operand mismatch'} = 17;

  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
  $extractor->feed($tree);

  is($received_module,'a/b/c.d/dir/file','Allocator sizeof operand mismatch');
  is($received_value, 17, '17 bugs expected.');

}

sub feed_declares_argument_null : Tests {
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
  $tree->{'a/b/c.d/dir/file.c'}->{'Argument with \'nonnull\' attribute passed null'} = 18;

  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
  $extractor->feed($tree);

  is($received_module,'a/b/c.d/dir/file','Argument with \'nonnull\' attribute passed null');
  is($received_value, 18, '18 bugs expected.');

}

sub feed_declares_stack_address_into_global_variable : Tests {
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
  $tree->{'a/b/c.d/dir/file.c'}->{'Stack address stored into global variable'} = 19;

  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
  $extractor->feed($tree);

  is($received_module,'a/b/c.d/dir/file','Stack address stored into global variable');
  is($received_value, 19, '19 bugs expected.');

}

__PACKAGE__->runtests;


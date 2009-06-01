package ExtractorDoxyparseTests;
use base qw(Test::Class);
use Test::More 'no_plan'; # REMOVE THE 'no_plan'

use strict;
use warnings;
use File::Basename;

use Egypt::Extractor;

eval('$Egypt::Extractor::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

sub constructor : Tests {
  use_ok('Egypt::Extractor::Doxyparse');
  my $extractor = Egypt::Extractor->load('Doxyparse');
  isa_ok($extractor, 'Egypt::Extractor::Doxyparse');
  isa_ok($extractor, 'Egypt::Extractor');
}

sub has_a_model : Tests {
  isa_ok((Egypt::Extractor->load('Doxyparse'))->model, 'Egypt::Model');
}

sub current_module : Tests {
  my $extractor = Egypt::Extractor->load('Doxyparse');
  $extractor->current_module('module1.c');
  is($extractor->current_module, 'module1.c', 'must be able to set the current module');
  $extractor->current_module('module2.c');
  is($extractor->current_module, 'module2.c', 'must be able to change the current module');
}

sub detect_function_declaration : Tests {
  my $extractor = Egypt::Extractor->load('Doxyparse', current_module => 'module1.c');
  $extractor->feed('   function myfunction in line 5');
  ok(grep { $_ eq 'module1::myfunction' } @{$extractor->model->{modules}->{'module1.c'}});
  is($extractor->current_function, 'module1::myfunction', 'must set the current function');
}

sub detect_variable_declaration : Tests {
  my $extractor = Egypt::Extractor->load('Doxyparse', current_module => 'module1.c');
  $extractor->feed('   variable myvariable in line 10');
  ok(grep { $_ eq 'module1::myvariable' } @{$extractor->model->{modules}->{'module1.c'}});
  $extractor->current_module; # only read the current module
  is(scalar(grep { $_ eq 'module1::myvariable' } @{$extractor->model->{modules}->{'module1.c'}}), 1, 'must not read variable declarations when reading the name of the current module');
}

sub detect_direct_function_calls : Tests {
  my $extractor = Egypt::Extractor->load('Doxyparse', current_module => 'module1.c');
  $extractor->feed('   function callerfunction in line 5');
  $extractor->feed('      uses function say_hello defined in module2.c');
  is($extractor->model->{calls}->{'module1::callerfunction'}->{'module2::say_hello'}, 'direct');
}

sub detect_indirect_function_calls : Tests {
  local $TODO = 'indirect calls currently unimplemented'; # TODO
  my $extractor = Egypt::Extractor->load('Doxyparse', current_module => 'module1.c');
  $extractor->feed('(symbol_ref:SI ("callback") [flags 0x41] <function_decl 0x40404580 callback>)) -1 (nil))');
  is($extractor->model->{calls}->{'callerfunction'}->{'callback'}, 'indirect');
}

sub detect_variable_uses : Tests {
  my $extractor = Egypt::Extractor->load('Doxyparse', current_module => 'module1.c');
  $extractor->feed('   function callerfunction in line 5');
  $extractor->feed('      uses variable myvariable defined in module2.c');
  is($extractor->model->{calls}->{'module1::callerfunction'}->{'module2::myvariable'}, 'variable');
}

sub reading_from_one_input_file : Tests {
  # set up
  my $sample_dir = dirname(__FILE__) . '/sample';
  my $extractor = Egypt::Extractor->load('Doxyparse');

  # one file
  $extractor->process($sample_dir . '/module1.c');
  is(scalar(keys(%{$extractor->model->members})), 1, 'module1 has once member');
  ok(grep { $_ eq 'module1::main' } keys(%{$extractor->model->members}), 'main is member of module1');
  is(scalar(keys(%{$extractor->model->{modules}})), 1, 'we have once module');
  ok(grep { $_ eq 'module1' } keys(%{$extractor->model->{modules}}));
}

sub reading_from_some_input_files : Tests {
  # set up
  my $sample_dir = dirname(__FILE__) . '/sample';
  my $extractor = Egypt::Extractor->load('Doxyparse');

  # some files
  $extractor->process($sample_dir . '/module1.c', $sample_dir . '/module2.c');
  is(scalar(keys(%{$extractor->model->members})), 3, 'module1 and module2 has 3 members');
  is(scalar(keys(%{$extractor->model->{modules}})), 2, 'we have 2 modules');
  is($extractor->model->{calls}->{'module1::main'}->{'module2::say_hello'}, 'direct');
  is($extractor->model->{calls}->{'module1::main'}->{'module2::say_bye'}, 'direct');
}

sub reading_from_directories : Tests {
  # set up
  my $sample_dir = dirname(__FILE__) . '/sample';
  my $extractor = Egypt::Extractor->load('Doxyparse');

  # directory
  $extractor->process($sample_dir);
  is(scalar(keys(%{$extractor->model->members})), 5);
  is(scalar(keys(%{$extractor->model->{modules}})), 3);
  is($extractor->model->{calls}->{'module1::main'}->{'module2::say_hello'}, 'direct');
  is($extractor->model->{calls}->{'module1::main'}->{'module2::say_bye'}, 'direct');

  local $TODO = "indirect calls currently unimplemented"; # TODO
  is($extractor->model->{calls}->{'main'}->{'callback'}, 'indirect');
}

ExtractorDoxyparseTests->runtests;

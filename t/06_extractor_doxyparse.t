package ExtractorTests;
use base qw(Test::Class);
use Test::More 'no_plan'; # REMOVE THE 'no_plan'

use strict;
use warnings;
use File::Basename;

use Egypt::Extractor;

eval('$Egypt::Extractor::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

sub constructor : Tests {
  isa_ok(new Egypt::Extractor, 'Egypt::Extractor');
}

sub has_a_model : Tests {
  isa_ok((Egypt::Extractor->load('GCC'))->model, 'Egypt::Model');
}

my $extractor; # REMOVE

##############################################################################
# BEGIN test of indicating current module
##############################################################################
sub current_module : Tests {
  my $extractor = Egypt::Extractor->load('GCC');
  $extractor->current_module('module1.c');
  is($extractor->current_module, 'module1.c', 'must be able to set the current module');
  $extractor->current_module('module2.c');
  is($extractor->current_module, 'module2.c', 'must be able to change the current module');
}

##############################################################################
# BEGIN test detecting the start of pre-GCC4 style functions
##############################################################################
sub pre_gcc4_style : Tests {
  $extractor = Egypt::Extractor->load('GCC', current_module => 'module1.c');
  $extractor->feed(';; Function myfunction    ');
  ok((grep { $_ eq 'myfunction' } @{$extractor->model->{modules}->{'module1.c'}}), 'must be able to read a function with trailing whitespace in the line');
  is($extractor->current_function, 'myfunction', 'must set the current function');

  $extractor->feed(';; Function anotherfunction');
  ok((grep { $_ eq 'anotherfunction' } @{$extractor->model->{modules}->{'module1.c'}}), 'must be able to read function without trailing whitespace in the line');
  is($extractor->current_function, 'anotherfunction');
}

##############################################################################
# BEGIN test detecting the start of GCC4 style functions
##############################################################################
sub gcc4_style : Tests {
  $extractor = Egypt::Extractor->load('GCC', current_module => 'hello.c');
  $extractor->feed(';; Function say_hello (say_hello)');
  ok(grep { $_ eq 'say_hello' } @{$extractor->model->{modules}->{'hello.c'}});
  is($extractor->current_function, 'say_hello');

  # mangled/demangled name
  $extractor->feed(';; Function Class::method(int) (MangledName)');
  ok(grep { $_ eq 'MangledName' } @{$extractor->model->{modules}->{'hello.c'}});
  is($extractor->model->demangle('MangledName'), 'Class::method(int)');
  is($extractor->current_function, 'MangledName');
}

##############################################################################
# BEGIN test detecting variable declarations
##############################################################################
sub detect_variable_declarations : Tests {
  $extractor = Egypt::Extractor->load('GCC');
  my $testfile = dirname(__FILE__) . "/tmp.c";
  open FILE, ">", $testfile;
  print FILE <<EOF
#include <stdio.h>
int myvariable = 0;
EOF
  ;
  close FILE;
  $extractor->current_module($testfile);
  ok(grep { $_ eq 'myvariable' } @{$extractor->model->{modules}->{$testfile}});

  $extractor->current_module; # only read the current module
  is(scalar(grep { $_ eq 'myvariable' } @{$extractor->model->{modules}->{$testfile}}), 1, 'must not read variable declarations when reading the name of the current module');

  unlink $testfile;
}


sub detecting_calls_and_variable_uses : Tests {
  ##############################################################################
  # BEGIN test detecing a direct call
  ##############################################################################
  $extractor = Egypt::Extractor->load('GCC', current_module => 'module1.c');
  $extractor->feed(';; Function callerfunction (callerfunction)');
  $extractor->feed('(call_insn 7 6 8 3 module1.c:7 (call (mem:QI (symbol_ref:SI ("say_hello") [flags 0x41] <function_decl 0x40404480 say_hello>) [0 S1 A8])');
  is($extractor->model->{calls}->{'callerfunction'}->{'say_hello'}, 'direct');

  ##############################################################################
  # BEGIN test detecting a indirect call
  ##############################################################################
  $extractor->feed('(symbol_ref:SI ("callback") [flags 0x41] <function_decl 0x40404580 callback>)) -1 (nil))');
  is($extractor->model->{calls}->{'callerfunction'}->{'callback'}, 'indirect');

  ##############################################################################
  # BEGIN test detecting a variable use
  ##############################################################################
  $extractor->feed('(insn 13 12 14 3 module1.c:10 (set (mem/c/i:SI (symbol_ref:SI ("myvariable") [flags 0x40] <var_decl 0x403ec2e0 variable>) [0 variable+0 S4A32])');
  is($extractor->model->{calls}->{'callerfunction'}->{'myvariable'}, 'variable');
}

##############################################################################
# test reading from files and directories
##############################################################################
sub reading_from_files_and_directories : Tests {
  # set up
  my $sample_dir = dirname(__FILE__) . '/sample';
  system(sprintf('make -s -C %s', $sample_dir));

  # one file
  $extractor = Egypt::Extractor->load('GCC');
  $extractor->process($sample_dir . '/module1.c.131r.expand');
  is(scalar(keys(%{$extractor->model->members})), 1);
  ok(grep { $_ eq 'main' } keys(%{$extractor->model->members}));
  is(scalar(keys(%{$extractor->model->{modules}})), 1);
  ok(grep { $_ eq 't/sample/module1.c' } keys(%{$extractor->model->{modules}}));

  # some files
  $extractor = Egypt::Extractor->load('GCC');
  $extractor->process($sample_dir . '/module1.c.131r.expand', $sample_dir . '/module2.c.131r.expand');
  is(scalar(keys(%{$extractor->model->members})), 3);
  is(scalar(keys(%{$extractor->model->{modules}})), 2);
  is($extractor->model->{calls}->{'main'}->{'say_hello'}, 'direct');
  is($extractor->model->{calls}->{'main'}->{'say_bye'}, 'direct');

  # directory
  $extractor = Egypt::Extractor->load('GCC');
  $extractor->process($sample_dir);
  is(scalar(keys(%{$extractor->model->members})), 5);
  is(scalar(keys(%{$extractor->model->{modules}})), 3);
  is($extractor->model->{calls}->{'main'}->{'say_hello'}, 'direct');
  is($extractor->model->{calls}->{'main'}->{'say_bye'}, 'direct');
  is($extractor->model->{calls}->{'main'}->{'callback'}, 'indirect');

  # tear down
  system(sprintf('make -s -C %s clean', $sample_dir));
}

ExtractorTests->runtests;

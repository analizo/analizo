package t::Analizo::Extractor::DoxyparseFile;
use base qw(Test::Class);
use Test::More;

use strict;
use warnings;
use File::Basename;

use Analizo::Extractor;

eval('$Analizo::Extractor::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

sub constructor : Tests {
  use_ok('Analizo::Extractor::DoxyparseFile');
  my $extractor = Analizo::Extractor->load('DoxyparseFile');
  isa_ok($extractor, 'Analizo::Extractor::DoxyparseFile');
  isa_ok($extractor, 'Analizo::Extractor');
}

sub has_a_model : Tests {
  isa_ok((Analizo::Extractor->load('DoxyparseFile'))->model, 'Analizo::Model');
}

sub current_module : Tests {
  my $extractor = Analizo::Extractor->load('DoxyparseFile');
  $extractor->current_module('module1.c');
  is($extractor->current_module, 'module1.c', 'must be able to set the current module');
  $extractor->current_module('module2.c');
  is($extractor->current_module, 'module2.c', 'must be able to change the current module');
}

sub inheritance : Tests {
  my $extractor = Analizo::Extractor->load('DoxyparseFile');
  $extractor->current_module('Child');
  $extractor->feed('   inherits from Parent');
  my @result = $extractor->model->inheritance('Child');
  is($result[0], 'Parent', 'extractor detects inheritance');
}

sub detect_function_declaration : Tests {
  my $extractor = Analizo::Extractor->load('DoxyparseFile', current_module => 'module1.c');
  $extractor->feed('   function myfunction() in line 5');
  ok(grep { $_ eq 'module1::myfunction()' } @{$extractor->model->{modules}->{'module1.c'}->{functions}});
  is($extractor->current_member, 'module1::myfunction()', 'must set the current function');

  $extractor->feed('   function parametered_function(String) in line 5');
  ok(grep { $_ eq 'module1::parametered_function(String)' } @{$extractor->model->{modules}->{'module1.c'}->{functions}});
  is($extractor->current_member, 'module1::parametered_function(String)', 'must set the current function again');

  $extractor->feed('   function weird_function(hello_world *) in line 5');
  ok(grep { $_ eq 'module1::weird_function(hello_world *)' } @{$extractor->model->{modules}->{'module1.c'}->{functions}});
  is($extractor->current_member, 'module1::weird_function(hello_world *)', 'must set the current function one more time');
}

sub detect_variable_declaration : Tests {
  my $extractor = Analizo::Extractor->load('DoxyparseFile', current_module => 'module1.c');
  $extractor->feed('   variable myvariable in line 10');
  ok(grep { $_ eq 'module1::myvariable' } @{$extractor->model->{modules}->{'module1.c'}->{variables}});
  $extractor->current_module; # only read the current module
  is(scalar(grep { $_ eq 'module1::myvariable' } @{$extractor->model->{modules}->{'module1.c'}->{variables}}), 1, 'must not read variable declarations when reading the name of the current module');
  ok($extractor->model->{members}->{'module1::myvariable'});
}

sub detect_direct_function_calls : Tests {
  my $extractor = Analizo::Extractor->load('DoxyparseFile', current_module => 'module1.c');
  $extractor->feed('   function callerfunction() in line 5');
  $extractor->feed('      uses function say_hello() defined in module2.c');
  is($extractor->model->{calls}->{'module1::callerfunction()'}->{'module2::say_hello()'}, 'direct');

  $extractor->feed('      uses function say_hello_with_arg(string) defined in module2.c');
  is($extractor->model->{calls}->{'module1::callerfunction()'}->{'module2::say_hello_with_arg(string)'}, 'direct');

  $extractor->feed('      uses function weird_say_hello(hello_world *) defined in module2.c');
  is($extractor->model->{calls}->{'module1::callerfunction()'}->{'module2::weird_say_hello(hello_world *)'}, 'direct');
}

sub detect_variable_uses : Tests {
  my $extractor = Analizo::Extractor->load('DoxyparseFile', current_module => 'module1.c');
  $extractor->feed('   function callerfunction in line 5');
  $extractor->feed('      uses variable myvariable defined in module2.c');
  is($extractor->model->{calls}->{'module1::callerfunction'}->{'module2::myvariable'}, 'variable');

  $extractor->feed('   function hello_world_say(hello_world *) in line 10');
  $extractor->feed('      uses variable avariable defined in module2.c');
  is($extractor->model->{calls}->{'module1::hello_world_say(hello_world *)'}->{'module2::avariable'}, 'variable');
}

sub detect_function_protection : Tests {
  my $extractor = Analizo::Extractor->load('DoxyparseFile', current_module => 'module1.c');
  $extractor->feed('   function public_function in line 5');
  $extractor->feed('      protection public');
  $extractor->feed('   function non_public_function in line 15');
  is($extractor->model->{protection}->{'module1::public_function'}, 'public');
  is($extractor->model->{protection}->{'module1::non_public_function'}, undef);
}

sub detect_variable_protection : Tests {
  my $extractor = Analizo::Extractor->load('DoxyparseFile', current_module => 'module1.c');
  $extractor->feed('   variable private_variable in line 1');
  $extractor->feed('   variable public_variable in line 2');
  $extractor->feed('      protection public');
  is($extractor->model->{protection}->{'module1::private_variable'}, undef);
  is($extractor->model->{protection}->{'module1::public_variable'}, 'public');
}

sub detect_lines_of_code : Tests {
  my $extractor = Analizo::Extractor->load('DoxyparseFile', current_module => 'module1.c');
  $extractor->feed('   function one_function in line 5');
  $extractor->feed('      12 lines of code');
  $extractor->feed('   function another_function line 50');
  is($extractor->model->{lines}->{'module1::one_function'}, 12);
  is($extractor->model->{lines}->{'module1::another_function'}, undef);
}

sub detect_number_of_parameters : Tests {
  my $extractor = Analizo::Extractor->load('DoxyparseFile', current_module => 'module1.c');
  $extractor->feed('   function one_function in line 5');
  $extractor->feed('      1 parameters');
  is($extractor->model->{parameters}->{'module1::one_function'}, 1);
}

sub detect_conditional_paths : Tests {
  my $extractor = Analizo::Extractor->load('DoxyparseFile', current_module => 'module1.c');
  $extractor->feed('   function one_function in line 5');
  $extractor->feed('      3 conditional paths');
  is($extractor->model->{conditional_paths}->{'module1::one_function'}, 3);
}

sub detect_abstract_class : Tests {
  my $extractor = Analizo::Extractor->load('DoxyparseFile');
  $extractor->current_module('An_Abstract_Class');
  $extractor->feed('   abstract class');
  my @result = $extractor->model->abstract_classes;
  is($result[0], 'An_Abstract_Class', 'extractor detects an abstract class');
}

sub module_name_can_contain_spaces : Tests {
  my $extractor = Analizo::Extractor::DoxyparseFile->new;
  $extractor->feed('module TemplatedClass< true >');
  is($extractor->current_module, 'TemplatedClass< true >')
}

sub reading_from_the_input_file : Tests {
  # set up
  my $extractor = Analizo::Extractor->load('DoxyparseFile');

  # read file
  $extractor->process('t/samples/sample_basic.doxyparse');
  is($extractor->model->{calls}->{'module1::main()'}->{'module2::say_hello()'}, 'direct');
  is($extractor->model->{calls}->{'module1::main()'}->{'module2::say_bye()'}, 'direct');
}

__PACKAGE__->runtests;

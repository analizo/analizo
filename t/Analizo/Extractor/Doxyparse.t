package t::Analizo::Extractor::Doxyparse;
use base qw(Test::Class);
use Test::More;
use Test::Exception;

use strict;
use warnings;
use File::Basename;

use Analizo::Extractor;

eval('$Analizo::Extractor::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

sub constructor : Tests {
  use_ok('Analizo::Extractor::Doxyparse');
  my $extractor = Analizo::Extractor->load('Doxyparse');
  isa_ok($extractor, 'Analizo::Extractor::Doxyparse');
  isa_ok($extractor, 'Analizo::Extractor');
}

sub has_a_model : Tests {
  isa_ok((Analizo::Extractor->load('Doxyparse'))->model, 'Analizo::Model');
}

sub current_module : Tests {
  my $extractor = Analizo::Extractor->load('Doxyparse');
  $extractor->current_module('module1.c');
  is($extractor->current_module, 'module1.c', 'must be able to set the current module');
  $extractor->current_module('module2.c');
  is($extractor->current_module, 'module2.c', 'must be able to change the current module');
}

sub inheritance : Tests {
  my $extractor = Analizo::Extractor->load('Doxyparse');
  $extractor->feed("---
    src/child.cpp:
      Child:
        inherits: Parent
  ");
  my @result = $extractor->model->inheritance('Child');
  is($result[0], 'Parent', 'extractor detects inheritance');
}

sub detect_function_declaration : Tests {
  my $extractor = Analizo::Extractor->load('Doxyparse');
  $extractor->feed("---
    src/module1.c:
      module1.c:
        defines:
          - myfunction():
              type: function
              line: 5
  ");
  ok(grep { $_ eq 'module1::myfunction()' } @{$extractor->model->{modules}->{'module1'}->{functions}});
  is($extractor->current_member, 'module1::myfunction()', 'must set the current function');
  $extractor->feed("---
    src/module1.c:
      module1.c:
        defines:
          - myfunction():
              type: function
              line: 5
          - parametered_function(String):
              type: function
              line: 5
  ");
  ok(grep { $_ eq 'module1::parametered_function(String)' } @{$extractor->model->{modules}->{'module1'}->{functions}});
  is($extractor->current_member, 'module1::parametered_function(String)', 'must set the current function again');
  $extractor->feed("---
    src/module1.c:
      module1.c:
        defines:
          - myfunction():
              type: function
              line: 5
          - parametered_function(String):
              type: function
              line: 5
          - weird_function(hello_world *):
              type: function
              line: 5
  ");
  ok(grep { $_ eq 'module1::weird_function(hello_world *)' } @{$extractor->model->{modules}->{'module1'}->{functions}});
  is($extractor->current_member, 'module1::weird_function(hello_world *)', 'must set the current function one more time');
}

sub detect_variable_declaration : Tests {
  my $extractor = Analizo::Extractor->load('Doxyparse');
  $extractor->feed("---
    src/module1.c:
      module1.c:
        defines:
          - myvariable:
              type: variable
              line: 10
  ");
  ok(grep { $_ eq 'module1::myvariable' } @{$extractor->model->{modules}->{'module1'}->{variables}});
  $extractor->current_module; # only read the current module
  is(scalar(grep { $_ eq 'module1::myvariable' } @{$extractor->model->{modules}->{'module1'}->{variables}}), 1, 'must not read variable declarations when reading the name of the current module');
  ok($extractor->model->{members}->{'module1::myvariable'});
}

sub detect_direct_function_calls : Tests {
  my $extractor = Analizo::Extractor->load('Doxyparse');
  $extractor->feed("---
    src/module1.c:
      module1.c:
        defines:
          - callerfunction():
              type: function
              line: 5
              uses:
                - say_hello():
                    type: function
                    defined_in: module2.c
                - say_hello_with_arg(string):
                    type: function
                    defined_in: module2.c
                - weird_say_hello(hello_world *):
                    type: function
                    defined_in: module2.c
  ");
  is($extractor->model->{calls}->{'module1::callerfunction()'}->{'module2::say_hello()'}, 'direct');
  is($extractor->model->{calls}->{'module1::callerfunction()'}->{'module2::say_hello_with_arg(string)'}, 'direct');
  is($extractor->model->{calls}->{'module1::callerfunction()'}->{'module2::weird_say_hello(hello_world *)'}, 'direct');
}

sub detect_variable_uses : Tests {
  my $extractor = Analizo::Extractor->load('Doxyparse');
  $extractor->feed("---
    src/module1.c:
      module1.c:
        defines:
          - callerfunction:
              type: function
              line: 5
              uses:
                - myvariable:
                    type: variable
                    defined_in: module2
          - hello_world_say(hello_world *):
              type: function
              line: 10
              uses:
                - avariable:
                    type: variable
                    defined_in: module2
  ");
  is($extractor->model->{calls}->{'module1::callerfunction'}->{'module2::myvariable'}, 'variable');
  is($extractor->model->{calls}->{'module1::hello_world_say(hello_world *)'}->{'module2::avariable'}, 'variable');
}

sub detect_function_protection : Tests {
  my $extractor = Analizo::Extractor->load('Doxyparse');
  $extractor->feed("---
    src/module1.c:
      module1.c:
        defines:
          - public_function:
              type: function
              line: 5
              protection: public
          - non_public_function:
              type: function
              line: 15
  ");
  is($extractor->model->{protection}->{'module1::public_function'}, 'public');
  is($extractor->model->{protection}->{'module1::non_public_function'}, undef);
}

sub detect_variable_protection : Tests {
  my $extractor = Analizo::Extractor->load('Doxyparse');
  $extractor->feed("---
    src/module1.c:
      module1.c:
        defines:
          - private_variable:
              type: variable
              line: 1
          - public_variable:
              type: variable
              line: 1
              protection: public
  ");
  is($extractor->model->{protection}->{'module1::private_variable'}, undef);
  is($extractor->model->{protection}->{'module1::public_variable'}, 'public');
}

sub detect_lines_of_code : Tests {
  my $extractor = Analizo::Extractor->load('Doxyparse');
  $extractor->feed("---
    src/module1.c:
      module1.c:
        defines:
          - one_function:
              type: function
              line: 5
              lines_of_code: 12
          - another_function:
              type: function
              line: 50
  ");
  is($extractor->model->{lines}->{'module1::one_function'}, 12);
  is($extractor->model->{lines}->{'module1::another_function'}, undef);
}

sub detect_number_of_parameters : Tests {
  my $extractor = Analizo::Extractor->load('Doxyparse');
  $extractor->feed("---
    src/module1.c:
      module1.c:
        defines:
          - one_function:
              type: function
              line: 5
              parameters: 1
  ");
  is($extractor->model->{parameters}->{'module1::one_function'}, 1);
}

sub detect_conditional_paths : Tests {
  my $extractor = Analizo::Extractor->load('Doxyparse', current_module => 'module1.c');
  $extractor->feed("---
    src/module1.c:
      module1.c:
        defines:
          - one_function:
              type: function
              line: 5
              conditional_paths: 3
              protection: public
              lines_of_code: 18
  ");
  is($extractor->model->{conditional_paths}->{'module1::one_function'}, 3);
}

sub detect_abstract_class : Tests {
  my $extractor = Analizo::Extractor->load('Doxyparse');
  $extractor->feed("---
    src/test.cpp:
      An_Abstract_Class:
        information: abstract class
  ");
  my @result = $extractor->model->abstract_classes;
  is($result[0], 'An_Abstract_Class', 'extractor detects an abstract class');
}

sub reading_from_one_input_file : Tests {
  # set up
  my $extractor = Analizo::Extractor->load('Doxyparse');

  # one file
  $extractor->process('t/samples/sample_basic/c/module1.c');
  is(scalar(keys(%{$extractor->model->members})), 1, 'module1 has once member');
  ok(grep { $_ eq 'module1::main()' } keys(%{$extractor->model->members}), 'main is member of module1');
  is(scalar(keys(%{$extractor->model->{modules}})), 1, 'we have once module');
  ok(grep { $_ eq 'module1' } keys(%{$extractor->model->{modules}}));
}

sub reading_from_some_input_files : Tests {
  # set up
  my $sample_dir = 't/samples/sample_basic/c';
  my $extractor = Analizo::Extractor->load('Doxyparse');

  # some files
  $extractor->process($sample_dir . '/module1.c', $sample_dir . '/module2.c');
  is(scalar(keys(%{$extractor->model->members})), 3, 'module1 and module2 has 3 members');
  is(scalar(keys(%{$extractor->model->{modules}})), 2, 'we have 2 modules');
  is($extractor->model->{calls}->{'module1::main()'}->{'module2::say_hello()'}, 'direct');
  is($extractor->model->{calls}->{'module1::main()'}->{'module2::say_bye()'}, 'direct');
}

sub reading_from_directories : Tests {
  # set up
  my $extractor = Analizo::Extractor->load('Doxyparse');

  # directory
  $extractor->process('t/samples/sample_basic/c');
  is(scalar(keys(%{$extractor->model->members})), 5);
  is(scalar(keys(%{$extractor->model->{modules}})), 3);
  is($extractor->model->{calls}->{'module1::main()'}->{'module2::say_hello()'}, 'direct');
  is($extractor->model->{calls}->{'module1::main()'}->{'module2::say_bye()'}, 'direct');
}

sub invalid_doxyparse_input : Tests {
  # this test is to make sure that the extractor can handle malformed input,
  # e.g. receiving function/variable declarations before a current module is
  # declared. (it happends sometime)

  my $extractor = new Analizo::Extractor::Doxyparse;

  $extractor->feed("---
    wrong:
      type: function
      line: 10
    src/module1.c:
      module1.c:
        defines:
          - right:
              type: function
              line: 10
  ");

  #$extractor->feed("   function wrong in line 10"); # malformed input
  #$extractor->current_module('module1.c');
  #$extractor->feed("   function right in line 10"); # well-formed input

  is(scalar($extractor->model->functions('module1')), 1); # with 1 function
}

sub current_file : Tests {
  my $extractor = new Analizo::Extractor::Doxyparse;
  my $current_file_called_correctly = undef;
  no warnings;
  local *Analizo::Extractor::Doxyparse::current_file = sub {
    my ($self, $current_file) = @_;
    if (defined($current_file) && $current_file eq 'src/person.h') {
      $current_file_called_correctly = 1;
    }
  };
  use warnings;

  $extractor->feed("---
    src/person.h:
      person.h:
  ");
  ok($current_file_called_correctly);
}

sub current_file_strip_pwd : Tests {
  use Cwd;
  my $pwd = getcwd();
  my $extractor = new Analizo::Extractor::Doxyparse;
  $extractor->feed("---
    $pwd/src/test.c:
      test.c:
  ");
  is($extractor->current_file(), 'src/test.c')
}

sub use_full_filename_for_C_modules : Tests {
  my $extractor = new Analizo::Extractor::Doxyparse;
  $extractor->process('t/samples/multidir/c');
  my @modules = $extractor->model->module_names();
  ok(grep { /^lib\/main$/ } @modules);
  ok(grep { /^src\/main$/ } @modules);
}

sub module_name_can_contain_spaces : Tests {
  my $extractor = new Analizo::Extractor::Doxyparse;
  $extractor->feed("---
    src/template.cpp:
      TemplatedClass< true >:
  ");
  is($extractor->current_module, 'TemplatedClass< true >')
}

sub detects_multiple_inheritance_properly : Tests {
  # set up
  my $extractor = Analizo::Extractor->load('Doxyparse');

  lives_ok {
    # directory
    $extractor->process('t/samples/multiple_inheritance/java/');
    ok(grep({ $_ eq 'Animal' } @{ $extractor->model->{inheritance}->{'Bird'} }), 'Bird inherits Animal');
    ok(grep { $_ eq 'Flying' } @{ $extractor->model->{inheritance}->{'Bird'} }, 'Bird inherits Flying');
    ok(grep { $_ eq 'Animal' } @{ $extractor->model->{inheritance}->{'Horse'} }, 'Horse inherits Animal');
    ok(grep { $_ eq 'Horse' } @{ $extractor->model->{inheritance}->{'Pegasus'} }, 'Pegasus inherits Horse');
    ok(grep { $_ eq 'Flying' } @{ $extractor->model->{inheritance}->{'Pegasus'} }, 'Pegasus inherits Flying');
  } 'multiple inheritance detected';
}

__PACKAGE__->runtests;

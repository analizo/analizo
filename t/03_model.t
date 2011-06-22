package ModelTests;
use base qw(Test::Class);
use Test::More;
use strict;

use Analizo::Model;

sub constructor : Tests {
  isa_ok(new Analizo::Model, 'Analizo::Model');
}

sub empty_object : Tests {
  my $model = new Analizo::Model;
  isa_ok($model->modules, 'HASH', 'must have modules');
  isa_ok($model->members, 'HASH', 'must have members');
}

sub declaring_project_eloc : Tests {
  my $model = new Analizo::Model;
  is($model->{total_eloc}, 0, 'Project eLoc should be initialized');

  $model->declare_total_eloc(28);
  is($model->{total_eloc}, 28, 'Project eLoc should updated when declare_project_eloc is called');
  is($model->total_eloc, 28, 'using the getter');
}

sub declaring_modules : Tests {
  my $model = new Analizo::Model;
  $model->declare_module('Module1');
  $model->declare_module('Module2');
  my @modules = $model->module_names;
  is($modules[0], 'Module1');
  is($modules[1], 'Module2');
}

sub declaring_modules_with_files : Tests {
  my $model = new Analizo::Model;
  $model->declare_module('Module1', 'src/module1.c');
  is_deeply($model->file('Module1'), ['src/module1.c']);
}

sub declaring_inheritance : Tests {
  my $model = new Analizo::Model;
  $model->add_inheritance('Child', 'Parent');
  my @parents = $model->inheritance('Child');
  is($parents[0], 'Parent', 'class with one superclass');

  $model->add_inheritance('Child', 'AnotherParent');
  @parents = $model->inheritance("Child");
  is($parents[1], 'AnotherParent', 'class with two superclasses');
}

sub declaring_function : Tests {
  my $model = new Analizo::Model;
  $model->declare_function('mymodule', 'myfunction');
  $model->declare_function('mymodule', 'anotherfunction');

  ok((grep { $_ eq 'myfunction' } keys(%{$model->members})), "declared function must be stored");
  is('mymodule', $model->members->{'myfunction'}, 'must map function to module');
  ok((grep { $_ eq 'mymodule'} keys(%{$model->modules})), 'declaring a function must declare its module');
  ok((grep { $_ eq 'myfunction' } @{$model->{modules}->{'mymodule'}->{functions}}), 'must store members in a module');

  ok((grep { $_ eq 'anotherfunction' } keys(%{$model->members})), "another declared function must be stored");
  is('mymodule', $model->members->{'anotherfunction'}, 'must map another function to module');
  ok((grep { $_ eq 'mymodule'} keys(%{$model->modules})), 'declaring a another function must declare its module');
  ok((grep { $_ eq 'anotherfunction' } @{$model->{modules}->{'mymodule'}->{functions}}), 'must store members in a module');
}

sub declaring_function_with_demangled_name : Tests {
  my $model = new Analizo::Model;
  $model->declare_function('mymodule', 'myfunction', 'demangled_name');
  ok((grep { $_ eq 'demangled_name'} $model->demangle('myfunction')), 'must store mapping from mangled name to demangled name')
}

sub use_mangled_name_by_default_when_demanglig : Tests {
  my $model = new Analizo::Model;
  $model->declare_function("mod1", 'f1');
  is($model->demangle('f1'), 'f1', 'must demangle to the function name itself by default');
}

sub declaring_variables : Tests {
  my $model = new Analizo::Model;
  $model->declare_variable('mymodule', 'myvariable');
  ok((grep { $_ eq 'myvariable' } keys(%{$model->members})), "declared variable must be stored");
  is('mymodule', $model->members->{'myvariable'}, 'must map variable to module');
  ok((grep { $_ eq 'mymodule'} keys(%{$model->modules})), 'declaring a variable must declare its module');
  ok((grep { $_ eq 'myvariable' } @{$model->modules->{'mymodule'}->{variables}}), 'must store variable in a module');
}

sub adding_calls : Tests {
  my $model = new Analizo::Model;
  $model->add_call('function1', 'function2');
  is($model->calls->{'function1'}->{'function2'}, 'direct', 'must register function call');
}

sub indirect_calls : Tests {
  my $model = new Analizo::Model;
  $model->add_call('f1', 'f2', 'indirect');
  is($model->calls->{'f1'}->{'f2'}, 'indirect', 'must register indirect call');
}

sub addding_variable_uses : Tests {
  my $model = new Analizo::Model;
  $model->add_variable_use('function1', 'variable9');
  is($model->calls->{'function1'}->{'variable9'}, 'variable', 'must register variable use');
}

sub querying_variables : Tests {
  my $model = new Analizo::Model;
  $model->declare_variable('mod1', 'v1');
  $model->declare_variable('mod1', 'v2');

  ok((grep { $_ eq 'v1' } $model->variables('mod1')), 'must list v1 in variables');
  ok((grep { $_ eq 'v2' } $model->variables('mod1')), 'must list v2 in variables');
}

sub querying_functions : Tests {
  my $model = new Analizo::Model;
  $model->declare_function('mod1', 'f1');
  $model->declare_function('mod1', 'f2');

  ok((grep { $_ eq 'f1' } $model->functions('mod1')), 'must list f1 in functions');
  ok((grep { $_ eq 'f2' } $model->functions('mod1')), 'must list f2 in functions');
}

sub querying_members : Tests {
  my $model = new Analizo::Model;
  $model->declare_function('mod1', 'f1');
  $model->declare_variable('mod1', 'v1');

  $model->declare_function('mod1', 'f2');
  $model->declare_variable('mod1', 'v2');

  ok((grep { $_ eq 'f1' } $model->all_members('mod1')), 'must list f1 in functions');
  ok((grep { $_ eq 'f2' } $model->all_members('mod1')), 'must list f2 in functions');
  ok((grep { $_ eq 'v1' } $model->all_members('mod1')), 'must list v1 in variables');
  ok((grep { $_ eq 'v2' } $model->all_members('mod1')), 'must list v2 in variables');
}

sub declaring_protection : Tests {
  my $model = new Analizo::Model;
  $model->add_protection('main::f1', 'public');
  is($model->{protection}->{'main::f1'}, 'public');
}

sub declating_lines_of_code : Tests {
  my $model = new Analizo::Model;
  $model->add_loc('main::f1', 50);
  is($model->{lines}->{'main::f1'}, 50);
}

sub declaring_number_of_parameters {
  my $model = new Analizo::Model;
  $model->add_parameters('main::function', 2);
  is($model->{parameters}->{'main::function'}, 2);
}

sub declaring_number_of_conditional_paths : Tests {
  my $model = new Analizo::Model;
  $model->add_conditional_paths('main::function', 2);
  is($model->{conditional_paths}->{'main::function'}, 2);
}

sub adding_abstract_class : Tests {
  my $model = new Analizo::Model;
  $model->add_abstract_class('An_Abstract_Class');
  is($model->abstract_classes, 1, 'model detects an abstract class');
}

ModelTests->runtests;


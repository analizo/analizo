package t::Analizo::Model;
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
  is_deeply($model->files('Module1'), ['src/module1.c']);
}

sub retrieving_modules_by_file : Tests {
  my $model = new Analizo::Model;
  $model->declare_module('Module1', 'src/module1.c');
  my @module = $model->module_by_file('src/module1.c');
  is($module[0], 'Module1');

  $model->declare_module('Module2', 'src/module1.c');
  my @modules = $model->module_by_file('src/module1.c');
  is_deeply(['Module1', 'Module2'], \@modules);
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

sub build_graph_from_function_calls : Tests {
  my $model = Analizo::Model->new;
  $model->declare_module('a', 'src/a.c');
  $model->declare_module('b', 'src/b.c');
  $model->declare_module('c', 'src/c.c');
  $model->declare_function('a', 'a::name()');
  $model->declare_function('b', 'b::name()');
  $model->declare_function('c', 'c::name()');
  $model->add_call('a::name()', 'b::name()');
  $model->add_call('a::name()', 'c::name()');
  my $g = $model->graph;
  is("$g", 'src/a-src/b,src/a-src/c');
}

sub build_graph_from_inheritance : Tests {
  my $model = Analizo::Model->new;
  $model->declare_module('a', 'src/a.c');
  $model->declare_module('b', 'src/b.c');
  $model->declare_module('c', 'src/c.c');
  $model->add_inheritance('a', 'b');
  $model->add_inheritance('a', 'c');
  my $g = $model->graph;
  is("$g", 'src/a-src/b,src/a-src/c');
}

sub build_graph_from_funcion_calls_and_inheritance : Tests {
  my $model = Analizo::Model->new;
  $model->declare_module('a', 'src/a.c');
  $model->declare_module('b', 'src/b.c');
  $model->declare_module('c', 'src/c.c');
  $model->declare_module('d', 'src/d.c');
  $model->add_inheritance('b', 'd');
  $model->declare_function('a', 'a::name()');
  $model->declare_function('b', 'b::name()');
  $model->declare_function('c', 'c::name()');
  $model->add_call('a::name()', 'b::name()');
  $model->add_call('a::name()', 'c::name()');
  my $g = $model->graph;
  is("$g", 'src/a-src/b,src/a-src/c,src/b-src/d');
}

sub use_file_as_vertices_in_graph : Tests {
  my $model = Analizo::Model->new;
  $model->declare_module('a', 'src/a.c');
  $model->declare_module('b', 'src/b.c');
  $model->declare_module('c', 'src/c.c');
  my @vertices = sort $model->graph->vertices;
  is_deeply(\@vertices, ['src/a', 'src/b', 'src/c']);
}

sub group_files_when_build_graph : Tests {
  my $model = Analizo::Model->new;
  $model->declare_module('a', 'src/a.h');
  $model->declare_module('a', 'src/a.c');
  $model->declare_module('b', 'src/b.h');
  $model->declare_module('b', 'src/b.c');
  $model->declare_module('c', 'src/c.c');
  $model->declare_module('c', 'src/c.h');
  my @vertices = sort $model->graph->vertices;
  is_deeply(\@vertices, ['src/a', 'src/b', 'src/c']);
}

sub declaring_divisions_by_zero : Tests {
  my $model = new Analizo::Model;
  $model->declare_security_metrics('Division by zero', 'file', 2);
  is($model->{security_metrics}->{'Division by zero'}->{'file'}, 2);
}

sub declaring_dead_assignment : Tests {
  my $model = new Analizo::Model;
  $model->declare_security_metrics('Dead assignment', 'file', 2);
  is($model->{security_metrics}->{'Dead assignment'}->{'file'}, 2);
}

sub declaring_out_of_bound_array_access : Tests {
  my $model = new Analizo::Model;
  $model->declare_security_metrics('Out-of-bound array access', 'file', 2);
  is($model->{security_metrics}->{'Out-of-bound array access'}->{'file'}, 2);
}

sub declaring_assigned_undefined_value : Tests {
  my $model = new Analizo::Model;
  $model->declare_security_metrics('Assigned undefined value', 'file', 2);
  is($model->{security_metrics}->{'Assigned undefined value'}->{'file'}, 2);
}

sub declaring_memory_leak : Tests {
  my $model = new Analizo::Model;
  $model->declare_security_metrics('Memory leak', 'file', 2);
  is($model->{security_metrics}->{'Memory leak'}->{'file'}, 2);
}

sub declaring_return_of_stack_variable_address : Tests {
  my $model = new Analizo::Model;
  $model->declare_security_metrics('Return of stack variable address', 'file', 2);
  is($model->{security_metrics}->{'Return of stack variable address'}->{'file'}, 2);
}

sub declaring_dereference_of_null_pointer : Tests {
  my $model = new Analizo::Model;
  $model->declare_security_metrics('Dereference of null pointer', 'file', 2);
  is($model->{security_metrics}->{'Dereference of null pointer'}->{'file'}, 2);
}

sub declaring_bad_free : Tests {
  my $model = new Analizo::Model;
  $model->declare_security_metrics('Bad free', 'file', 2);
  is($model->{security_metrics}->{'Bad free'}->{'file'}, 2);
}

sub declaring_double_free : Tests {
  my $model = new Analizo::Model;
  $model->declare_security_metrics('Double free', 'file', 2);
  is($model->{security_metrics}->{'Double free'}->{'file'}, 2);
}

sub declaring_bad_deallocator : Tests {
  my $model = new Analizo::Model;
  $model->declare_security_metrics('Bad deallocator', 'file', 2);
  is($model->{security_metrics}->{'Bad deallocator'}->{'file'}, 2);
}

__PACKAGE__->runtests;


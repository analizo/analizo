package t::Analizo::Model;
use strict;
use warnings;
use parent qw(Test::Analizo::Class);
use Test::More;

use Analizo::Model;

sub constructor : Tests {
  isa_ok(Analizo::Model->new, 'Analizo::Model');
}

sub empty_object : Tests {
  my $model = Analizo::Model->new;
  isa_ok($model->modules, 'HASH', 'must have modules');
  isa_ok($model->members, 'HASH', 'must have members');
}

sub declaring_project_eloc : Tests {
  my $model = Analizo::Model->new;
  is($model->{total_eloc}, 0, 'Project eLoc should be initialized');

  $model->declare_total_eloc(28);
  is($model->{total_eloc}, 28, 'Project eLoc should updated when declare_project_eloc is called');
  is($model->total_eloc, 28, 'using the getter');
}

sub declaring_modules : Tests {
  my $model = Analizo::Model->new;
  $model->declare_module('Module1');
  $model->declare_module('Module2');
  my @modules = $model->module_names;
  is($modules[0], 'Module1');
  is($modules[1], 'Module2');
}

sub declaring_modules_with_files : Tests {
  my $model = Analizo::Model->new;
  $model->declare_module('Module1', 'src/module1.c');
  is_deeply($model->files('Module1'), ['src/module1.c']);
}

sub retrieving_modules_by_file : Tests {
  my $model = Analizo::Model->new;
  $model->declare_module('Module1', 'src/module1.c');
  my @module = $model->module_by_file('src/module1.c');
  is($module[0], 'Module1');

  $model->declare_module('Module2', 'src/module1.c');
  my @modules = $model->module_by_file('src/module1.c');
  is_deeply(['Module1', 'Module2'], \@modules);
}

sub declaring_inheritance : Tests {
  my $model = Analizo::Model->new;
  $model->add_inheritance('Child', 'Parent');
  my @parents = $model->inheritance('Child');
  is($parents[0], 'Parent', 'class with one superclass');

  $model->add_inheritance('Child', 'AnotherParent');
  @parents = $model->inheritance("Child");
  is($parents[1], 'AnotherParent', 'class with two superclasses');
}

sub declaring_function : Tests {
  my $model = Analizo::Model->new;
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

sub declaring_variables : Tests {
  my $model = Analizo::Model->new;
  $model->declare_variable('mymodule', 'myvariable');
  ok((grep { $_ eq 'myvariable' } keys(%{$model->members})), "declared variable must be stored");
  is('mymodule', $model->members->{'myvariable'}, 'must map variable to module');
  ok((grep { $_ eq 'mymodule'} keys(%{$model->modules})), 'declaring a variable must declare its module');
  ok((grep { $_ eq 'myvariable' } @{$model->modules->{'mymodule'}->{variables}}), 'must store variable in a module');
}

sub adding_calls : Tests {
  my $model = Analizo::Model->new;
  $model->add_call('function1', 'function2');
  is($model->calls->{'function1'}->{'function2'}, 'direct', 'must register function call');
}

sub indirect_calls : Tests {
  my $model = Analizo::Model->new;
  $model->add_call('f1', 'f2', 'indirect');
  is($model->calls->{'f1'}->{'f2'}, 'indirect', 'must register indirect call');
}

sub addding_variable_uses : Tests {
  my $model = Analizo::Model->new;
  $model->add_variable_use('function1', 'variable9');
  is($model->calls->{'function1'}->{'variable9'}, 'variable', 'must register variable use');
}

sub querying_variables : Tests {
  my $model = Analizo::Model->new;
  $model->declare_variable('mod1', 'v1');
  $model->declare_variable('mod1', 'v2');

  ok((grep { $_ eq 'v1' } $model->variables('mod1')), 'must list v1 in variables');
  ok((grep { $_ eq 'v2' } $model->variables('mod1')), 'must list v2 in variables');
}

sub querying_functions : Tests {
  my $model = Analizo::Model->new;
  $model->declare_function('mod1', 'f1');
  $model->declare_function('mod1', 'f2');

  ok((grep { $_ eq 'f1' } $model->functions('mod1')), 'must list f1 in functions');
  ok((grep { $_ eq 'f2' } $model->functions('mod1')), 'must list f2 in functions');
}

sub querying_members : Tests {
  my $model = Analizo::Model->new;
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
  my $model = Analizo::Model->new;
  $model->add_protection('main::f1', 'public');
  is($model->{protection}->{'main::f1'}, 'public');
}

sub declating_lines_of_code : Tests {
  my $model = Analizo::Model->new;
  $model->add_loc('main::f1', 50);
  is($model->{lines}->{'main::f1'}, 50);
}

sub declaring_number_of_parameters {
  my $model = Analizo::Model->new;
  $model->add_parameters('main::function', 2);
  is($model->{parameters}->{'main::function'}, 2);
}

sub declaring_number_of_conditional_paths : Tests {
  my $model = Analizo::Model->new;
  $model->add_conditional_paths('main::function', 2);
  is($model->{conditional_paths}->{'main::function'}, 2);
}

sub adding_abstract_class : Tests {
  my $model = Analizo::Model->new;
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

sub empty_call_graph : Tests {
  my $model = Analizo::Model->new;
  is($model->callgraph, '', 'empty output must give empty digraph');
}

sub listing_calls : Tests {
  my $model = Analizo::Model->new;
  $model->declare_function('module1', 'function1');
  $model->declare_function('module1', 'function2');
  $model->add_call('function1', 'function2', 'direct');
  is(
    $model->callgraph,
    'function1-function2',
    'must generate correctly a graph with one call'
  );
}

sub listing_two_calls : Tests {
  my $model = Analizo::Model->new;
  $model->declare_function('module1', 'function1(type)');
  $model->declare_function('module1', 'function2(type1, type2)');
  $model->declare_function('module1', 'function3()');
  $model->add_call('function1(type *)', 'function2(type1, type2)', 'direct');
  $model->add_call('function1(type *)', 'function3()', 'direct');
  is(
    $model->callgraph,
    'function1(type *)-function2(type1, type2),function1(type *)-function3()',
    'must generate correctly a graph with f1 -> f2, f1 -> f3'
  );
}

sub listing_only_defined_functions : Tests {
  my $model = Analizo::Model->new;
  $model->declare_function('module1', 'function1');
  $model->declare_function('module2', 'function2');
  $model->add_call('function1', 'function2');
  $model->add_call('function2', 'function3');
  is(
    $model->callgraph,
    'function1-function2',
    'must include by default only functions inside the project'
  );
}

sub ommiting_functions : Tests {
  my $model = Analizo::Model->new;
  $model->declare_function('module1', 'function1');
  $model->declare_function('module1', 'function2');
  $model->declare_function('module1', 'function3');
  $model->add_call('function1', 'function2');
  $model->add_call('function1', 'function3');
  is(
    $model->callgraph(omit => ['function3']),
    'function1-function2',
    'must be able to omit a called function'
  );
  is(
    $model->callgraph(omit => ['function1']),
    '',
    'must be able to omit a caller function'
  );
}

sub including_external_functions : Tests {
  my $model = Analizo::Model->new;
  $model->declare_function('module1', 'function1');
  $model->add_call('function1', 'function2');
  is(
    $model->callgraph(include_externals => 1),
    'function1-function2',
    'must be able to omit a called function'
  );
}

sub groupping_by_module : Tests {
  my $model = Analizo::Model->new;
  $model->declare_function('cluster1.c.r1874.expand', 'function1');
  $model->declare_function('cluster2.c.r9873.expand', 'function2');
  $model->declare_function('cluster2.c.r9873.expand', 'function3');
  $model->add_call('function1', 'function2');
  $model->add_call('function1', 'function3');
  is(
    $model->callgraph(group_by_module => 1),
    'cluster1.c-cluster2.c',
    'must list correctly a single dependency arrow between two modules'
  );
  $model->add_call('function1', 'function4');
  $model->declare_function('cluster3.c.r8773.expand', 'function4');
  is(
    $model->callgraph(group_by_module => 1),
    'cluster1.c-cluster2.c,cluster1.c-cluster3.c',
    'must list arrow targets in lexicographic order'
  );
  $model->add_call('function5', 'function1');
  $model->declare_function('cluster0.c.r7412.expand', 'function5');
  is(
    $model->callgraph(group_by_module => 1),
    'cluster0.c-cluster1.c,cluster1.c-cluster2.c,cluster1.c-cluster3.c',
    'must list arrow sources in in lexicographic order'
  );
}

sub use_of_variables : Tests {
  my $model = Analizo::Model->new;
  $model->declare_function('module1.c.r1234.expand', 'function1');
  $model->declare_variable('module2.c', 'myvariable');
  $model->add_variable_use('function1', 'myvariable');
  is(
    $model->callgraph,
    'function1-myvariable',
    'must output declared variables'
  );
  # test grouping by module
  is(
    $model->callgraph(group_by_module => 1),
    'module1.c-module2.c',
    'must use variable information for inter-module dependencies'
  );
}

__PACKAGE__->runtests;

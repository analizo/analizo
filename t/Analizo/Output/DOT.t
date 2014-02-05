package t::Analizo::Output::DOT;
use base qw(Test::Class);

use strict;
use warnings;

use Test::More;

use Analizo::Output::DOT;

# BEGIN test constructor
sub constructor : Tests {
  my $output = new Analizo::Output::DOT;
  isa_ok($output, 'Analizo::Output::DOT');
}

# BEGIN test output filename
sub filename : Tests  {
  my $output = new Analizo::Output::DOT;
  can_ok($output, 'filename');
}

sub filename_passed_to_constructor : Tests {
  is(
    (new Analizo::Output::DOT(filename => 'test.dot'))->filename,
    'test.dot',
    'must store filename passed to constructor'
  );
}

sub default_filename : Tests {
  is(
    (new Analizo::Output::DOT)->filename,
    'output.dot',
    'must use "output.dot" as output filename by default'
  );
}

sub setting_filename : Tests {
  my $output = new Analizo::Output::DOT();
  $output->filename('myfile.dot');
  is(
    $output->filename(),
    'myfile.dot',
    'must be able to set output filename'
  );
}

# BEGIN test empty call graph
sub empty_call_graph : Tests {
  my $output = new Analizo::Output::DOT;
  is(
    $output->string(),
    "digraph callgraph {\n}\n",
    'empty output must give empty digraph'
  );
}

sub must_have_a_model : Tests {
  my $output = new Analizo::Output::DOT;
  isa_ok($output->model, 'Analizo::Model', 'must have an associated instance of Analizo::Model');
}

sub must_be_able_to_set_a_model : Tests {
  my $model = new Analizo::Model;
  my $output = new Analizo::Output::DOT(model => $model);
  is($output->model, $model);
}

# BEGIN test listing calls
sub listing_calls : Tests {
  my $output = new Analizo::Output::DOT;
  $output->model->declare_function('module1', 'function1');
  $output->model->declare_function('module1', 'function2');
  $output->model->add_call('function1', 'function2', 'direct');
  is(
    $output->string,
    'digraph callgraph {
"function1" -> "function2" [style=solid];
}
',
    'must generate correctly a graph with one call'
  );
}

sub listing_two_calls : Tests {
  my $output = new Analizo::Output::DOT;
  $output->model->declare_function('module1', 'function1(type)');
  $output->model->declare_function('module1', 'function2(type1, type2)');
  $output->model->declare_function('module1', 'function3()');
  $output->model->add_call('function1(type *)', 'function2(type1, type2)', 'direct');
  $output->model->add_call('function1(type *)', 'function3()', 'direct');
  is(
    $output->string,
    'digraph callgraph {
"function1(type *)" -> "function2(type1, type2)" [style=solid];
"function1(type *)" -> "function3()" [style=solid];
}
',
    'must generate correctly a graph with f1 -> f2, f1 -> f3'
  );
}

# BEGIN test indirect calls
sub indirect_calls : Tests {
  my $output = new Analizo::Output::DOT;
  $output->model->declare_function('module1', 'function1');
  $output->model->declare_function('module1', 'function2');
  $output->model->declare_function('module1', 'function3');
  $output->model->add_call('function1', 'function2', 'direct');
  $output->model->add_call('function1', 'function3', 'indirect');
  is(
    $output->string,
    'digraph callgraph {
"function1" -> "function2" [style=solid];
"function1" -> "function3" [style=dotted];
}
',
    'should distinguish direct from indirect calls');
}

# BEGIN test calls are direct by default

sub direct_by_default : Tests {
  my $output = new Analizo::Output::DOT;
  $output->model->declare_function("module1", "function1");
  $output->model->declare_function("module1", "function2");
  $output->model->add_call('function1', 'function2');
  is(
    $output->string,
    'digraph callgraph {
"function1" -> "function2" [style=solid];
}
',
    'must consider calls as direct by default');
}

# BEGIN test listing only defined functions
sub listing_only_defined_functions : Tests {
  my $output = new Analizo::Output::DOT;
  $output->model->declare_function('module1', 'function1');
  $output->model->declare_function('module2', 'function2');
  $output->model->add_call('function1', 'function2');
  $output->model->add_call('function2', 'function3');
  is(
    $output->string,
    'digraph callgraph {
"function1" -> "function2" [style=solid];
}
',
    'must include by default only functions inside the project');
}

# BEGIN test omitting functions
sub ommiting_functions : Tests {
  my $output = new Analizo::Output::DOT;
  $output->model->declare_function('module1', 'function1');
  $output->model->declare_function('module1', 'function2');
  $output->model->declare_function('module1', 'function3');
  $output->model->add_call('function1', 'function2');
  $output->model->add_call('function1', 'function3');
  $output->omit('function3');
  is(
    $output->string,
    'digraph callgraph {
"function1" -> "function2" [style=solid];
}
',
    'must be able to omit a called function');

  $output->omit('function1');
  is(
    $output->string,
    'digraph callgraph {
}
',
  'must be able to omit a caller function');
}

# BEGIN test including external functions
sub including_external_functions : Tests {
  my $output = new Analizo::Output::DOT;
  can_ok($output, 'include_externals');
  $output->model->declare_function('module1', 'function1');
  $output->model->add_call('function1', 'function2');
  $output->include_externals(1);
  is(
    $output->string,
    'digraph callgraph {
"function1" -> "function2" [style=solid];
}
',
  'must be able to omit a called function'
);
}

# TODO test removing implicit C++ function generated by the compiler.

# BEGIN test clustering
sub clustering : Tests {
  my $output = new Analizo::Output::DOT;
  can_ok($output, 'cluster');

  $output->model->declare_function('cluster1.c.r1874.expand', 'function1');
  $output->model->declare_function('cluster1.c.r1874.expand', 'function2');
  $output->model->add_call('function1', 'function2', 'direct');
  $output->cluster(1);
  is(
    $output->string,
    'digraph callgraph {
subgraph "cluster_cluster1.c.r1874.expand" {
  label = "cluster1.c";
  node [label="function1"] "function1";
  node [label="function2"] "function2";
}
"function1" -> "function2" [style=solid];
}
',
    "must output a single cluster");
}

sub two_clusters_in_order : Tests {
  my $output = new Analizo::Output::DOT;
  $output->cluster(1);
  $output->model->declare_function('cluster1.c.r1874.expand', 'function1');
  $output->model->declare_function('cluster2.c.r9873.expand', 'function2');
  $output->model->declare_function('cluster2.c.r9873.expand', 'function3');
  $output->model->add_call('function1', 'function2');
  $output->model->add_call('function1', 'function3');
  is(
    $output->string,
    'digraph callgraph {
subgraph "cluster_cluster1.c.r1874.expand" {
  label = "cluster1.c";
  node [label="function1"] "function1";
}
subgraph "cluster_cluster2.c.r9873.expand" {
  label = "cluster2.c";
  node [label="function2"] "function2";
  node [label="function3"] "function3";
}
"function1" -> "function2" [style=solid];
"function1" -> "function3" [style=solid];
}
',
    "must add two clusters in lexicographic order");
}

# BEGIN test grouping calls by module
sub groupping_by_module : Tests {
  my $output = new Analizo::Output::DOT;
  can_ok($output, 'group_by_module');
  $output->model->declare_function('cluster1.c.r1874.expand', 'function1');
  $output->model->declare_function('cluster2.c.r9873.expand', 'function2');
  $output->model->declare_function('cluster2.c.r9873.expand', 'function3');
  $output->model->add_call('function1', 'function2');
  $output->model->add_call('function1', 'function3');
  $output->group_by_module(1);
  is(
    $output->string,
    'digraph callgraph {
"cluster1.c" -> "cluster2.c" [style=solid,label=2];
}
',
    'must list correctly a single dependency arrow between two modules');

  $output->model->add_call('function1', 'function4');
  $output->model->declare_function('cluster3.c.r8773.expand', 'function4');
  is(
    $output->string,
    'digraph callgraph {
"cluster1.c" -> "cluster2.c" [style=solid,label=2];
"cluster1.c" -> "cluster3.c" [style=solid,label=1];
}
',
    'must list arrow targets in lexicographic order');

  $output->model->add_call('function5', 'function1');
  $output->model->declare_function('cluster0.c.r7412.expand', 'function5');
  is(
    $output->string,
    'digraph callgraph {
"cluster0.c" -> "cluster1.c" [style=solid,label=1];
"cluster1.c" -> "cluster2.c" [style=solid,label=2];
"cluster1.c" -> "cluster3.c" [style=solid,label=1];
}
',
    'must list arrow sources in in lexicographic order');
}

# BEGIN test use of variables
sub use_of_variables : Tests {
  my $output = new Analizo::Output::DOT;
  $output->model->declare_function('module1.c.r1234.expand', 'function1');
  $output->model->declare_variable('module2.c', 'myvariable');
  $output->model->add_variable_use('function1', 'myvariable');
  is(
    $output->string,
    'digraph callgraph {
"function1" -> "myvariable" [style=dashed];
}
',
    'must output declared variables');

  # test grouping by module
  $output->group_by_module(1);
  is(
    $output->string,
    'digraph callgraph {
"module1.c" -> "module2.c" [style=solid,label=1];
}
',
    'must use variable information for inter-module dependencies');
}

__PACKAGE__->runtests;


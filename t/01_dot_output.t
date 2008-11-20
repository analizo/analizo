use strict;
use warnings;

my $output;

use Test::More 'no_plan';

# BEGIN test module declaration
use_ok('Egypt::Output::DOT');

# BEGIN test constructor
$output = new Egypt::Output::DOT;
isa_ok($output, 'Egypt::Output::DOT');

# BEGIN test output filename

can_ok($output, 'filename');

is(
  (new Egypt::Output::DOT(filename => 'test.dot'))->filename,
  'test.dot',
  'must store filename passed to constructor'
);

is(
  (new Egypt::Output::DOT)->filename,
  'output.dot',
  'must use "output.dot" as output filename by default'
);

$output = new Egypt::Output::DOT();
$output->filename('myfile.dot');
is(
  $output->filename(),
  'myfile.dot',
  'must be able to set output filename'
);

# BEGIN test empty call graph
$output = new Egypt::Output::DOT;
is(
  $output->string(),
  "digraph callgraph {\n}\n",
  'empty output must give empty digraph'
);

# BEGIN test listing calls
$output = new Egypt::Output::DOT;
$output->add_call('function1', 'function2', 'direct');
is(
  $output->string,
  'digraph callgraph {
"function1" -> "function2" [style=solid];
}
',
  'must generate correctly a graph with on call'
);

$output->add_call('function1', 'function3', 'direct');
is(
  $output->string,
  'digraph callgraph {
"function1" -> "function2" [style=solid];
"function1" -> "function3" [style=solid];
}
',
  'must generate correctly a graph with f1 -> f2, f1 -> f3'
);

# BEGIN test clustering
$output->cluster(1);
can_ok($output, 'cluster');
$output->add_in_module('cluster1.c.r1874.expand', 'function1');
is(
  $output->string,
  'digraph callgraph {
subgraph "cluster_cluster1.c.r1874.expand" {
  label "cluster1.c";
  node [label="function1"] "function1";
}
"function1" -> "function2" [style=solid];
"function1" -> "function3" [style=solid];
}
',
  "must output a single cluster"
);

$output->add_in_module('cluster2.c.r9873.expand', 'function2');
$output->add_in_module('cluster2.c.r9873.expand', 'function3');
is(
  $output->string,
  'digraph callgraph {
subgraph "cluster_cluster1.c.r1874.expand" {
  label "cluster1.c";
  node [label="function1"] "function1";
}
subgraph "cluster_cluster2.c.r9873.expand" {
  label "cluster2.c";
  node [label="function2"] "function2";
  node [label="function3"] "function3";
}
"function1" -> "function2" [style=solid];
"function1" -> "function3" [style=solid];
}
',
  "must add two clusters in lexicographic order"
);

# BEGIN test grouping calls by module

can_ok($output, 'group_by_module');
$output->cluster(0);
$output->group_by_module(1);
is(
  $output->string,
  'digraph callgraph {
"cluster1.c" -> "cluster2.c" [style=solid,label=2];
}
',
  'must list correctly a single dependency arrow between two modules'
);

$output->add_call('function1', 'function4');
$output->add_in_module('cluster3.c.r8773.expand', 'function4');
is(
  $output->string,
  'digraph callgraph {
"cluster1.c" -> "cluster2.c" [style=solid,label=2];
"cluster1.c" -> "cluster3.c" [style=solid,label=1];
}
',
  'must list arrow targets in lexicographic order'
);

$output->add_call('function5', 'function1');
$output->add_in_module('cluster0.c.r7412.expand', 'function5');
is(
  $output->string,
  'digraph callgraph {
"cluster0.c" -> "cluster1.c" [style=solid,label=1];
"cluster1.c" -> "cluster2.c" [style=solid,label=2];
"cluster1.c" -> "cluster3.c" [style=solid,label=1];
}
',
  'must list arrow sources in in lexicographic order'
);


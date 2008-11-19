use strict;
use warnings;

my $output;

use Test::More 'no_plan';

use_ok('Egypt::Output::DOT');

$output = new Egypt::Output::DOT;

isa_ok($output, 'Egypt::Output::DOT');

can_ok($output, 'filename');

ok((new Egypt::Output::DOT(filename => 'test.dot'))->filename eq 'test.dot', 'must store filename passed to constructor');

ok((new Egypt::Output::DOT)->filename eq 'output.dot', 'must use "output.dot" as output filename by default');

$output = new Egypt::Output::DOT();
$output->filename('myfile.dot');
is(
  $output->filename(),
  'myfile.dot',
  'must be able to set output filename'
);

$output = new Egypt::Output::DOT;
is(
  $output->string(),
 "digraph callgraph {\n}\n",
 'empty output must give empty digraph'
);

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

# TODO: test clustering

# TODO: test grouping calls by module

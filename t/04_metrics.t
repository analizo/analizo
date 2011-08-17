package MetricsTests;
use strict;
use base qw(Test::Class);
use Test::More;
use Analizo::Metrics;
use Analizo::Model;

use vars qw($model $metrics);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $metrics = new Analizo::Metrics(model => $model);
}

sub constructor : Tests {
  isa_ok($metrics, 'Analizo::Metrics');
}

sub model : Tests {
  can_ok($metrics, 'model');
  is($metrics->model, $model);
}

#Abstract Classes
sub abstract_classes : Tests {
  $model->declare_module('A');
  is($metrics->total_abstract_classes, 0, 'no abstract class');

  $model->declare_module('A');
  $model->add_abstract_class('A');
  is($metrics->total_abstract_classes, 1, 'one abstract class');

  $model->declare_module('B');
  $model->add_abstract_class('B');
  is($metrics->total_abstract_classes, 2, 'two abstract class');
}

#Afferent Connections per Class
sub acc : Tests {
  $model->declare_module('A');
  $model->declare_function('A', 'fA');
  $model->declare_function('A', 'fA2');

  $model->declare_module('B');
  $model->declare_function('B', 'fB');
  $model->declare_variable('B', 'vB');

  $model->declare_module('C');
  $model->declare_function('C', 'fC');
  $model->declare_variable('C', 'vC');

  is($metrics->acc('A'), 0, 'no acc module A');
  is($metrics->acc('B'), 0, 'no acc module B');
  is($metrics->acc('C'), 0, 'no acc module C');

  $model->add_call('fA', 'fB');
  is($metrics->acc('A'), 0, 'no calls to a module');
  is($metrics->acc('B'), 1, 'calling function of another module');

  $model->add_variable_use('fA', 'vB');
  is($metrics->acc('A'), 0, 'no calls to a module');
  is($metrics->acc('B'), 1, 'calling variable of another module');

  $model->add_call('fA', 'fC');
  is($metrics->acc('A'), 0, 'no calls to a module');
  is($metrics->acc('C'), 1, 'calling variable of another module');

  $model->add_call('fA', 'fA2');
  is($metrics->acc('A'), 0, 'calling itself does not count as acc');

  $model->add_variable_use('fB', 'vC');
  is($metrics->acc('C'), 2, 'calling module twice');
}

sub acc_with_inheritance : Tests {
  $model->declare_module('Mother');
  $model->declare_module('Child1');
  $model->declare_module('Child2');
  $model->declare_module('Grandchild1');
  $model->declare_module('Grandchild2');

  $model->add_inheritance('Child1', 'Mother');
  is($metrics->acc('Mother'), 1, 'inheritance counts as acc to superclass');
  is($metrics->acc('Child1'), 0, 'inheritance does not count as acc to child');

  $model->add_inheritance('Child2', 'Mother');
  is($metrics->acc('Mother'), 2, 'multiple inheritance counts as acc');
  is($metrics->acc('Child2'), 0, 'inheritance does not count as acc to another child');

  $model->add_inheritance('Grandchild1', 'Child1');
  is($metrics->acc('Grandchild1'), 0, 'grandchilds acc is not affected');
  is($metrics->acc('Child1'), 1, 'grandchild extending a child counts');
  is($metrics->acc('Mother'), 3, 'the deeper the tree, the biggest acc');

  $model->add_inheritance('Grandchild2', 'Child2');
  is($metrics->acc('Grandchild2'), 0, 'grandchilds acc is not affected');
  is($metrics->acc('Child2'), 1, 'grandchild extending a child counts');
  is($metrics->acc('Mother'), 4, 'the deeper the tree, the biggest acc');
}

# Average Cyclomatic Complexity per Method
sub accm : Tests {
  $model->declare_module('module');
  is($metrics->accm('module'), 0, 'no function');

  $model->declare_function('module', 'module::function');
  $model->add_conditional_paths('module::function', 3);
  is($metrics->accm('module'), 3, 'one function with three conditional paths');

  $model->declare_function('module', 'module::function1');
  $model->add_conditional_paths('module::function1', 2);
  $model->declare_function('module', 'module::function2');
  $model->add_conditional_paths('module::function2', 4);
  is($metrics->accm('module'), 3, 'two function with three average cyclomatic complexity per method');
}

#Average Method LOC
sub amloc_with_no_functions_at_all : Tests {
  is($metrics->amloc(0, 0), 0);
}

#Average Number of Parameters per Methods
sub anpm : Tests {
  $model->declare_module('module');
  is($metrics->anpm('module'), 0, 'no parameters declared');

  $model->declare_function('module', 'module::function');
  $model->add_parameters('module::function', 1);
  is($metrics->anpm('module'), 1, 'one function with one parameter');
}

#Coupling Between Objects
sub cbo : Tests {
  $model->declare_function('mod1', 'f1');
  $model->declare_function('mod2', 'f2');

  is($metrics->cbo('mod1'), 0, 'no cbo');
  $model->add_call('f1', 'f1');
  is($metrics->cbo('mod1'), 0, 'calling itself does not count as cbo');

  $model->add_call('f1', 'f2');
  is($metrics->cbo('mod1'), 1, 'calling a single other module');

  $model->declare_function('mod3', 'f3');
  $model->add_call('f1', 'f3');
  is($metrics->cbo('mod1'), 2, 'calling two function in distinct modules');

  $model->declare_function('mod3', 'f3a');
  $model->add_call('f1', 'f3a');
  is($metrics->cbo('mod1'), 2, 'calling two different functions in the same module');
}

#Depth of Inheritance Tree
sub dit : Tests {
  $model->add_inheritance('Level1', 'Level2');
  $model->add_inheritance('Level2', 'Level3');
  is($metrics->dit('Level1'), 2, 'DIT = 2');
  is($metrics->dit('Level2'), 1, 'DIT = 1');
  is($metrics->dit('Level3'), 0, 'DIT = 0');
}

sub dit_with_multiple_inheritance : Tests {
  $model->add_inheritance('Level1', 'Level2A');
  $model->add_inheritance('Level1', 'Level2B');
  $model->add_inheritance('Level2B', 'Level3B');
  is($metrics->dit('Level1'), 2, 'with multiple inheritance take the larger DIT between the parents');
}

#Lack of Cohesion of Methods
sub lcom4 : Tests {
  $model->declare_function('mod1', $_) for qw(f1 f2);
  is($metrics->lcom4('mod1'), 2, 'two unrelated functions');

  $model->declare_variable('mod1', 'v1');
  $model->add_variable_use($_, 'v1') for qw(f1 f2);
  is($metrics->lcom4('mod1'), 1, 'two cohesive functions');

  $model->declare_function('mod1', 'f3');
  $model->declare_variable('mod1', 'v2');
  $model->add_variable_use('f3', 'v2');
  is($metrics->lcom4('mod1'), 2, 'two different usage components');

  $model->declare_function('mod1', 'f4');
  $model->declare_variable('mod1', 'v3');
  $model->add_variable_use('f4', 'v3');
  is($metrics->lcom4('mod1'), 3, 'three different usage components');
}

sub lcom4_2 : Tests {
  $model->declare_function('mod1', 'f1');
  $model->declare_function('mod1', 'f2');
  $model->declare_function('mod1', 'f3');
  $model->declare_variable('mod1', 'v1');
  $model->add_call('f1', 'f2');
  $model->add_call('f1', 'f3', 'indirect');
  $model->add_variable_use('f2', 'v1');
  is($metrics->lcom4('mod1'), '1', 'different types of connections');
}

sub lcom4_3 : Tests {
  $model->declare_function('mod1', 'f1');
  $model->declare_function('mod1', 'f2');
  $model->declare_function('mod1', 'f3');
  $model->add_call('f1', 'f2');

  # f1 and f3 calls the same function in another module
  $model->add_call('f1', 'ff');
  $model->add_call('f3', 'ff');

  is($metrics->lcom4('mod1'), 2, 'functions outside the module don\'t count for LCOM4');
}

sub sc_definition : Tests {
  local *Analizo::Metrics::lcom4 = sub { 2 };
  local *Analizo::Metrics::cbo = sub { 3 };
  is($metrics->sc('mod1'), 6);
}

sub sc_implementation : Tests {
  my $lcom4_called = undef;
  my $cbo_called = undef;
  local *Analizo::Metrics::lcom4 = sub { $lcom4_called = ($_[0] == $metrics && $_[1] eq 'mod1'); return 2; };
  local *Analizo::Metrics::cbo = sub { $cbo_called = ($_[0] == $metrics && $_[1] eq 'mod1'); return 5; };
  my $sc = $metrics->sc('mod1');
  ok($lcom4_called);
  ok($cbo_called);
  is($sc, 10);
}

#Methods Per Abstract Class
sub methods_per_abstract_class : Tests {
  is($metrics->methods_per_abstract_class, 0, 'no abstract classes');

  $model->declare_module('A');
  $model->add_abstract_class('A');
  is($metrics->methods_per_abstract_class, 0, 'no methods on abstract classes');

  $model->declare_function('A', 'functionA');
  is($metrics->methods_per_abstract_class, 1, 'one methods on one abstract classes');

  $model->declare_module('B');
  $model->add_abstract_class('B');
  $model->declare_function('B', 'functionB');
  is($metrics->methods_per_abstract_class, 1, 'one methods on one abstract classes');
}

#Number of Attributes
sub noa : Tests {
  is($metrics->noa('module1'), 0, 'empty modules have no attributes');

  $model->declare_variable('module1', 'attr1');
  is($metrics->noa('module1'), 1, 'module with one defined attribute');

  $model->declare_variable('module1', 'attr2');
  is($metrics->noa('module1'), 2, 'module with two defined attribute');
}

#Number of Children
sub noc : Tests {
  $model->declare_module('A');
  $model->declare_module('B');
  $model->declare_module('C');
  $model->declare_module('D');

  is($metrics->noc('A'), 0, 'no children module A');
  is($metrics->noc('B'), 0, 'no children module B');
  is($metrics->noc('C'), 0, 'no children module C');

  $model->add_inheritance('B', 'A');
  is($metrics->noc('A'), 1, 'one child module A');
  is($metrics->noc('B'), 0, 'no children module B');

  $model->add_inheritance('C', 'A');

  is($metrics->noc('A'), 2, 'two children module A');
  is($metrics->noc('C'), 0, 'no children module C');

  $model->add_inheritance('D', 'C');
  is($metrics->noc('A'), 2, 'two children module A');
  is($metrics->noc('C'), 1, 'one child module C');
  is($metrics->noc('D'), 0, 'no children module D');
}

#Number of Methods
sub nom : Tests {
  is($metrics->nom('mod1'), 0, 'empty modules have no functions');

  $model->declare_function("mod1", 'f1');
  is($metrics->nom('mod1'), 1, 'module with just one function has number of functions = 1');

  $model->declare_function('mod1', 'f2');
  is($metrics->nom('mod1'), 2, 'module with just two functions has number of functions = 2');
}

#Number of Public Methods
sub npm : Tests {
  is($metrics->npm('mod1'), 0, 'empty modules have 0 public functions');

  $model->declare_function('mod1', 'mod1::f1');
  $model->add_protection('mod1::f1', 'public');
  is($metrics->npm('mod1'), 1, 'one public function added');

  $model->declare_function('mod1', 'mod1::f2');
  $model->add_protection('mod1::f2', 'public');
  is($metrics->npm('mod1'), 2, 'another public function added');
}

#Number of Public Attributes
sub npa : Tests {
  is($metrics->npa('mod1'), 0, 'empty modules have 0 public attributes');

  $model->declare_variable('mod1', 'mod1::f1');
  $model->add_protection('mod1::f1', 'public');
  is($metrics->npa('mod1'), 1, 'one public attribute added');

  $model->declare_variable('mod1', 'mod1::f2');
  $model->add_protection('mod1::f2', 'public');
  is($metrics->npa('mod1'), 2, 'another public attribute added');
}

#Response For a Class
sub rfc : Tests {
  $model->declare_module('module');
  is($metrics->rfc('module'), 0, "no functions declared on the module");

  $model->declare_function('module', 'function');
  is($metrics->rfc('module'), 1, "one function declared on the module");

  $model->declare_function('module', 'another_function');
  is($metrics->rfc('module'), 2, "two functions declared on the module");

  $model->declare_function('module2', 'function2');
  $model->add_call('function', 'function2');
  is($metrics->rfc('module'), 3, "two functions and one call declared on the module");

  $model->declare_function('module2', 'function3');
  $model->add_call('another_function', 'function3');
  is($metrics->rfc('module'), 4, "two functions and two calls declared on the module");
}

#Lines Of Code
sub loc : Tests {
  my @result = $metrics->loc('mod1');
  is($result[0], 0, 'empty module has 0 loc');
  is($result[1], 0, 'empty module has max loc 0');

  $model->declare_function('mod1', 'mod1::f1');
  $model->add_loc('mod1::f1', 10);
  @result = $metrics->loc('mod1');
  is($result[0], 10, 'one module, with 10 loc');
  is($result[1], 10, 'one module, with 10 loc, makes max loc = 10');

  $model->declare_function('mod1', 'mod1::f2');
  $model->add_loc('mod1::f2', 20);
  @result = $metrics->loc('mod1');
  is($result[0], 30, 'adding another module with 20 loc makes the total equal 30');
  is($result[1], 20, 'adding another module with 20 loc makes the max LOC equal 20');
}

sub total_eloc : Tests {
  $model->declare_total_eloc(28);
  is($metrics->total_eloc, 28, 'calculating total eloc');
}

sub sample_modules_for_report {
  # first module
  $model->declare_module('mod1');
  $model->declare_function('mod1' , 'f1a');
  $model->declare_function('mod1' , 'f1b');
  $model->declare_variable('mod1' , 'v1');
  $model->add_variable_use($_, 'v1') for qw(f1a f1b);

  # second module
  $model->declare_module('mod2');
  $model->declare_function('mod2', 'f2');
  $model->add_call('f2', 'f1a');
  $model->add_call('f2', 'f1b');
}

sub report : Tests {
  sample_modules_for_report();
  $model->declare_total_eloc(38);

  my $output = $metrics->report;

  ok($output =~ /total_modules: 2/, 'reporting number of classes in YAML stream');
  ok($output =~ /_module: mod1/, 'reporting module 1');
  ok($output =~ /_module: mod2/, 'reporting module 2');
  ok($output =~ /total_eloc: 38/, 'reporting total eloc');
}

sub report_global_only : Tests {
  sample_modules_for_report();

  $metrics->report_global_metrics_only(1);
  my $output = $metrics->report;

  ok($output =~ /total_modules: 2/, 'reporting number of classes (it is global)');
  ok($output !~ /_module: mod1/, 'not reporting module 1 details');
  ok($output !~ /_module: mod2/, 'not reporting module 2 details');
}

sub report_without_modules_at_all : Tests {
  # if this call does not crash we are fine
  $metrics->report;
}

sub discard_external_symbols_for_cbo : Tests {
  $model->declare_function('mod1', 'f1');
  $model->declare_function('mod2', 'f2');

  $model->add_call('f1', 'f2');
  $model->add_call('f1', 'external_function');
  is($metrics->cbo('mod1'), 1, 'calling a external function');
}

sub list_of_metrics : Tests {
  my %metrics = $metrics->list_of_metrics();
  cmp_ok(scalar(keys(%metrics)), '>', 0, 'must list metrics');
}

sub metrics_for : Tests {
  sample_modules_for_report();
  my $data = $metrics->metrics_for('mod1');
  is(ref($data), 'HASH');
  is($data->{_module}, 'mod1');
}

MetricsTests->runtests;


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
sub afferent_connections_per_class : Tests {
  $model->declare_module('A');
  $model->declare_function('A', 'fA');
  $model->declare_function('A', 'fA2');

  $model->declare_module('B');
  $model->declare_function('B', 'fB');
  $model->declare_variable('B', 'vB');

  $model->declare_module('C');
  $model->declare_function('C', 'fC');
  $model->declare_variable('C', 'vC');

  is($metrics->afferent_connections_per_class('A'), 0, 'no acc module A');
  is($metrics->afferent_connections_per_class('B'), 0, 'no acc module B');
  is($metrics->afferent_connections_per_class('C'), 0, 'no acc module C');

  $model->add_call('fA', 'fB');
  is($metrics->afferent_connections_per_class('A'), 0, 'no calls to a module');
  is($metrics->afferent_connections_per_class('B'), 1, 'calling function of another module');

  $model->add_variable_use('fA', 'vB');
  is($metrics->afferent_connections_per_class('A'), 0, 'no calls to a module');
  is($metrics->afferent_connections_per_class('B'), 1, 'calling variable of another module');

  $model->add_call('fA', 'fC');
  is($metrics->afferent_connections_per_class('A'), 0, 'no calls to a module');
  is($metrics->afferent_connections_per_class('C'), 1, 'calling variable of another module');

  $model->add_call('fA', 'fA2');
  is($metrics->afferent_connections_per_class('A'), 0, 'calling itself does not count as acc');

  $model->add_variable_use('fB', 'vC');
  is($metrics->afferent_connections_per_class('C'), 2, 'calling module twice');
}

sub afferent_connections_per_class_with_inheritance : Tests {
  $model->declare_module('Mother');
  $model->declare_module('Child1');
  $model->declare_module('Child2');
  $model->declare_module('Grandchild1');
  $model->declare_module('Grandchild2');

  $model->add_inheritance('Child1', 'Mother');
  is($metrics->afferent_connections_per_class('Mother'), 1, 'inheritance counts as acc to superclass');
  is($metrics->afferent_connections_per_class('Child1'), 0, 'inheritance does not count as acc to child');

  $model->add_inheritance('Child2', 'Mother');
  is($metrics->afferent_connections_per_class('Mother'), 2, 'multiple inheritance counts as acc');
  is($metrics->afferent_connections_per_class('Child2'), 0, 'inheritance does not count as acc to another child');

  $model->add_inheritance('Grandchild1', 'Child1');
  is($metrics->afferent_connections_per_class('Grandchild1'), 0, 'grandchilds acc is not affected');
  is($metrics->afferent_connections_per_class('Child1'), 1, 'grandchild extending a child counts');
  is($metrics->afferent_connections_per_class('Mother'), 3, 'the deeper the tree, the biggest acc');

  $model->add_inheritance('Grandchild2', 'Child2');
  is($metrics->afferent_connections_per_class('Grandchild2'), 0, 'grandchilds acc is not affected');
  is($metrics->afferent_connections_per_class('Child2'), 1, 'grandchild extending a child counts');
  is($metrics->afferent_connections_per_class('Mother'), 4, 'the deeper the tree, the biggest acc');
}

# Average Cyclomatic Complexity per Method
sub average_cyclo_complexity_per_method : Tests {
  $model->declare_module('module');
  is($metrics->average_cyclo_complexity_per_method('module'), 0, 'no function');

  $model->declare_function('module', 'module::function');
  $model->add_conditional_paths('module::function', 3);
  is($metrics->average_cyclo_complexity_per_method('module'), 3, 'one function with three conditional paths');

  $model->declare_function('module', 'module::function1');
  $model->add_conditional_paths('module::function1', 2);
  $model->declare_function('module', 'module::function2');
  $model->add_conditional_paths('module::function2', 4);
  is($metrics->average_cyclo_complexity_per_method('module'), 3, 'two function with three average cyclomatic complexity per method');
}

#Average Method LOC
sub average_method_lines_of_code_with_no_functions_at_all : Tests {
  is($metrics->average_method_lines_of_code(0, 0), 0);
}

#Average Number of Parameters per Methods
sub average_number_of_parameters_per_method : Tests {
  $model->declare_module('module');
  is($metrics->average_number_of_parameters_per_method('module'), 0, 'no parameters declared');

  $model->declare_function('module', 'module::function');
  $model->add_parameters('module::function', 1);
  is($metrics->average_number_of_parameters_per_method('module'), 1, 'one function with one parameter');
}

#Coupling Between Objects
sub coupling_between_objects : Tests {
  $model->declare_function('mod1', 'f1');
  $model->declare_function('mod2', 'f2');

  is($metrics->coupling_between_objects('mod1'), 0, 'no cbo');
  $model->add_call('f1', 'f1');
  is($metrics->coupling_between_objects('mod1'), 0, 'calling itself does not count as cbo');

  $model->add_call('f1', 'f2');
  is($metrics->coupling_between_objects('mod1'), 1, 'calling a single other module');

  $model->declare_function('mod3', 'f3');
  $model->add_call('f1', 'f3');
  is($metrics->coupling_between_objects('mod1'), 2, 'calling two function in distinct modules');

  $model->declare_function('mod3', 'f3a');
  $model->add_call('f1', 'f3a');
  is($metrics->coupling_between_objects('mod1'), 2, 'calling two different functions in the same module');
}

#Depth of Inheritance Tree
sub depth_of_inheritance_tree : Tests {
  $model->add_inheritance('Level1', 'Level2');
  $model->add_inheritance('Level2', 'Level3');
  is($metrics->depth_of_inheritance_tree('Level1'), 2, 'DIT = 2');
  is($metrics->depth_of_inheritance_tree('Level2'), 1, 'DIT = 1');
  is($metrics->depth_of_inheritance_tree('Level3'), 0, 'DIT = 0');
}

sub dit_with_multiple_inheritance : Tests {
  $model->add_inheritance('Level1', 'Level2A');
  $model->add_inheritance('Level1', 'Level2B');
  $model->add_inheritance('Level2B', 'Level3B');
  is($metrics->depth_of_inheritance_tree('Level1'), 2, 'with multiple inheritance take the larger DIT between the parents');
}

#Lack of Cohesion of Methods 4
sub lack_of_cohesion_of_methods : Tests {
  $model->declare_function('mod1', $_) for qw(f1 f2);
  is($metrics->lack_of_cohesion_of_methods('mod1'), 2, 'two unrelated functions');

  $model->declare_variable('mod1', 'v1');
  $model->add_variable_use($_, 'v1') for qw(f1 f2);
  is($metrics->lack_of_cohesion_of_methods('mod1'), 1, 'two cohesive functions');

  $model->declare_function('mod1', 'f3');
  $model->declare_variable('mod1', 'v2');
  $model->add_variable_use('f3', 'v2');
  is($metrics->lack_of_cohesion_of_methods('mod1'), 2, 'two different usage components');

  $model->declare_function('mod1', 'f4');
  $model->declare_variable('mod1', 'v3');
  $model->add_variable_use('f4', 'v3');
  is($metrics->lack_of_cohesion_of_methods('mod1'), 3, 'three different usage components');
}

sub lack_of_cohesion_of_methods_2 : Tests {
  $model->declare_function('mod1', 'f1');
  $model->declare_function('mod1', 'f2');
  $model->declare_function('mod1', 'f3');
  $model->declare_variable('mod1', 'v1');
  $model->add_call('f1', 'f2');
  $model->add_call('f1', 'f3', 'indirect');
  $model->add_variable_use('f2', 'v1');
  is($metrics->lack_of_cohesion_of_methods('mod1'), '1', 'different types of connections');
}

sub lack_of_cohesion_of_methods_3 : Tests {
  $model->declare_function('mod1', 'f1');
  $model->declare_function('mod1', 'f2');
  $model->declare_function('mod1', 'f3');
  $model->add_call('f1', 'f2');

  # f1 and f3 calls the same function in another module
  $model->add_call('f1', 'ff');
  $model->add_call('f3', 'ff');

  is($metrics->lack_of_cohesion_of_methods('mod1'), 2, 'functions outside the module don\'t count for LCOM4');
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
sub number_of_attributes : Tests {
  is($metrics->number_of_attributes('module1'), 0, 'empty modules have no attributes');

  $model->declare_variable('module1', 'attr1');
  is($metrics->number_of_attributes('module1'), 1, 'module with one defined attribute');

  $model->declare_variable('module1', 'attr2');
  is($metrics->number_of_attributes('module1'), 2, 'module with two defined attribute');
}

#Number of Children
sub number_of_children : Tests {
  $model->declare_module('A');
  $model->declare_module('B');
  $model->declare_module('C');
  $model->declare_module('D');

  is($metrics->number_of_children('A'), 0, 'no children module A');
  is($metrics->number_of_children('B'), 0, 'no children module B');
  is($metrics->number_of_children('C'), 0, 'no children module C');

  $model->add_inheritance('B', 'A');
  is($metrics->number_of_children('A'), 1, 'one child module A');
  is($metrics->number_of_children('B'), 0, 'no children module B');

  $model->add_inheritance('C', 'A');

  is($metrics->number_of_children('A'), 2, 'two children module A');
  is($metrics->number_of_children('C'), 0, 'no children module C');

  $model->add_inheritance('D', 'C');
  is($metrics->number_of_children('A'), 2, 'two children module A');
  is($metrics->number_of_children('C'), 1, 'one child module C');
  is($metrics->number_of_children('D'), 0, 'no children module D');
}

#Number of Methods
sub number_of_methods : Tests {
  is($metrics->number_of_methods('mod1'), 0, 'empty modules have no functions');

  $model->declare_function("mod1", 'f1');
  is($metrics->number_of_methods('mod1'), 1, 'module with just one function has number of functions = 1');

  $model->declare_function('mod1', 'f2');
  is($metrics->number_of_methods('mod1'), 2, 'module with just two functions has number of functions = 2');
}

#Number of Public Methods
sub number_of_public_methods : Tests {
  is($metrics->number_of_public_methods('mod1'), 0, 'empty modules have 0 public functions');

  $model->declare_function('mod1', 'mod1::f1');
  $model->add_protection('mod1::f1', 'public');
  is($metrics->number_of_public_methods('mod1'), 1, 'one public function added');

  $model->declare_function('mod1', 'mod1::f2');
  $model->add_protection('mod1::f2', 'public');
  is($metrics->number_of_public_methods('mod1'), 2, 'another public function added');
}

#Number of Public Attributes
sub number_of_public_attributes : Tests {
  is($metrics->number_of_public_attributes('mod1'), 0, 'empty modules have 0 public attributes');

  $model->declare_variable('mod1', 'mod1::f1');
  $model->add_protection('mod1::f1', 'public');
  is($metrics->number_of_public_attributes('mod1'), 1, 'one public attribute added');

  $model->declare_variable('mod1', 'mod1::f2');
  $model->add_protection('mod1::f2', 'public');
  is($metrics->number_of_public_attributes('mod1'), 2, 'another public attribute added');
}

#Response For a Class
sub response_for_class : Tests {
  $model->declare_module('module');
  is($metrics->response_for_class('module'), 0, "no functions declared on the module");

  $model->declare_function('module', 'function');
  is($metrics->response_for_class('module'), 1, "one function declared on the module");

  $model->declare_function('module', 'another_function');
  is($metrics->response_for_class('module'), 2, "two functions declared on the module");

  $model->declare_function('module2', 'function2');
  $model->add_call('function', 'function2');
  is($metrics->response_for_class('module'), 3, "two functions and one call declared on the module");

  $model->declare_function('module2', 'function3');
  $model->add_call('another_function', 'function3');
  is($metrics->response_for_class('module'), 4, "two functions and two calls declared on the module");
}

#Lines Of Code
sub lines_of_code : Tests {
  my @result = $metrics->lines_of_code('mod1');
  is($result[0], 0, 'empty module has 0 loc');
  is($result[1], 0, 'empty module has max loc 0');

  $model->declare_function('mod1', 'mod1::f1');
  $model->add_loc('mod1::f1', 10);
  @result = $metrics->lines_of_code('mod1');
  is($result[0], 10, 'one module, with 10 loc');
  is($result[1], 10, 'one module, with 10 loc, makes max loc = 10');

  $model->declare_function('mod1', 'mod1::f2');
  $model->add_loc('mod1::f2', 20);
  @result = $metrics->lines_of_code('mod1');
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

sub discard_external_symbols_for_coupling_between_objects : Tests {
  $model->declare_function('mod1', 'f1');
  $model->declare_function('mod2', 'f2');

  $model->add_call('f1', 'f2');
  $model->add_call('f1', 'external_function');
  is($metrics->coupling_between_objects('mod1'), 1, 'calling a external function');
}

sub list_of_metrics : Tests {
  my %metrics = $metrics->list_of_metrics();
  cmp_ok(scalar(keys(%metrics)), '>', 0, 'must list metrics');
}

MetricsTests->runtests;


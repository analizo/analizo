use Test::More 'no_plan';

use strict;
use warnings;
use File::Basename;

use_ok('Egypt::Extractor');

eval('$Egypt::Extractor::QUIET = 1;'); # don't complain about possible typo

isa_ok(new Egypt::Extractor, 'Egypt::Extractor');

isa_ok((new Egypt::Extractor)->output, 'Egypt::Output::DOT'); # temporary (?)

##############################################################################
# BEGIN test of indicating current module
##############################################################################
my $extractor = new Egypt::Extractor;
$extractor->current_module('module1.c');
is($extractor->current_module, 'module1.c');
$extractor->current_module('module2.c');
is($extractor->current_module, 'module2.c');

##############################################################################
# BEGIN test detecting the start of pre-GCC4 style functions
##############################################################################
$extractor = new Egypt::Extractor(current_module => 'module1.c');
$extractor->feed(';; Function myfunction    ');
ok(grep { $_ eq 'myfunction' } @{$extractor->output->{modules}->{'module1.c'}});
is($extractor->current_function, 'myfunction');

$extractor->feed(';; Function anotherfunction');
ok(grep { $_ eq 'anotherfunction' } @{$extractor->output->{modules}->{'module1.c'}});
is($extractor->current_function, 'anotherfunction');

##############################################################################
# BEGIN test detecting the start of GCC4 style functions
##############################################################################
$extractor = new Egypt::Extractor(current_module => 'hello.c');
$extractor->feed(';; Function say_hello (say_hello)');
ok(grep { $_ eq 'say_hello' } @{$extractor->output->{modules}->{'hello.c'}});
is($extractor->current_function, 'say_hello');

# mangled/demangled name
$extractor->feed(';; Function Class::method(int) (MangledName)');
ok(grep { $_ eq 'MangledName' } @{$extractor->output->{modules}->{'hello.c'}});
is($extractor->output->_demangle('MangledName'), 'Class::method(int)');
is($extractor->current_function, 'MangledName');

##############################################################################
# BEGIN test detecting variable declarations
##############################################################################
$extractor = new Egypt::Extractor;
my $testfile = dirname(__FILE__) . "/tmp.c";
open FILE, ">", $testfile;
print FILE <<EOF
#include <stdio.h>
int myvariable = 0;
EOF
;
close FILE;
$extractor->current_module($testfile);
ok(grep { $_ eq 'myvariable' } @{$extractor->output->{modules}->{$testfile}});
unlink $testfile;

##############################################################################
# BEGIN test detecing a direct call
##############################################################################
$extractor = new Egypt::Extractor(current_module => 'module1.c');
$extractor->feed(';; Function callerfunction (callerfunction)');
$extractor->feed('(call_insn 7 6 8 3 module1.c:7 (call (mem:QI (symbol_ref:SI ("say_hello") [flags 0x41] <function_decl 0x40404480 say_hello>) [0 S1 A8])');
is($extractor->output->{calls}->{'callerfunction'}->{'say_hello'}, 'direct');

##############################################################################
# BEGIN test detecting a indirect call
##############################################################################
$extractor->feed('(symbol_ref:SI ("callback") [flags 0x41] <function_decl 0x40404580 callback>)) -1 (nil))');
is($extractor->output->{calls}->{'callerfunction'}->{'callback'}, 'indirect');

##############################################################################
# BEGIN test detecting a variable use
##############################################################################
$extractor->feed('(insn 13 12 14 3 module1.c:10 (set (mem/c/i:SI (symbol_ref:SI ("myvariable") [flags 0x40] <var_decl 0x403ec2e0 variable>) [0 variable+0 S4A32])');
is($extractor->output->{calls}->{'callerfunction'}->{'myvariable'}, 'variable');

##############################################################################
# test reading from files and directories
##############################################################################

# set up
my $sample_dir = dirname(__FILE__) . '/sample';
system(sprintf('make -s -C %s', $sample_dir));

# one file
$extractor = new Egypt::Extractor;
$extractor->process($sample_dir . '/module1.c.131r.expand');
is(scalar(keys(%{$extractor->output->{functions}})), 1);
ok(grep { $_ eq 'main' } keys(%{$extractor->output->{functions}}));
is(scalar(keys(%{$extractor->output->{modules}})), 1);
ok(grep { $_ eq 't/sample/module1.c' } keys(%{$extractor->output->{modules}}));

# some files
$extractor = new Egypt::Extractor;
$extractor->process($sample_dir . '/module1.c.131r.expand', $sample_dir . '/module2.c.131r.expand');
is(scalar(keys(%{$extractor->output->{functions}})), 3);
is(scalar(keys(%{$extractor->output->{modules}})), 2);
is($extractor->output->{calls}->{'main'}->{'say_hello'}, 'direct');
is($extractor->output->{calls}->{'main'}->{'say_bye'}, 'direct');

# directory
$extractor = new Egypt::Extractor;
$extractor->process($sample_dir);
is(scalar(keys(%{$extractor->output->{functions}})), 5);
is(scalar(keys(%{$extractor->output->{modules}})), 3);
is($extractor->output->{calls}->{'main'}->{'say_hello'}, 'direct');
is($extractor->output->{calls}->{'main'}->{'say_bye'}, 'direct');
is($extractor->output->{calls}->{'main'}->{'callback'}, 'indirect');

# tear down
system(sprintf('make -s -C %s clean', $sample_dir));

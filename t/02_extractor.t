use Test::More 'no_plan';

use strict;
use warnings;

use_ok('Egypt::Extractor');

isa_ok(new Egypt::Extractor, 'Egypt::Extractor');

isa_ok((new Egypt::Extractor)->output, 'Egypt::Output::DOT'); # temporary (?)

##############################################################################
# BEGIN test of indicating current module
##############################################################################
my $extractor = new Egypt::Extractor;
$extractor->current_module('module1.c');
is('module1.c', $extractor->current_module);
$extractor->current_module('module2.c');
is('module2.c', $extractor->current_module);

##############################################################################
# BEGIN test detecting the start of pre-GCC4 style functions
##############################################################################
$extractor = new Egypt::Extractor(current_module => 'module1.c');
$extractor->feed(';; Function myfunction    ');
ok(grep { $_ eq 'myfunction' } @{$extractor->output->{modules}->{'module1.c'}});
is('myfunction', $extractor->current_function);

$extractor->feed(';; Function anotherfunction');
ok(grep { $_ eq 'anotherfunction' } @{$extractor->output->{modules}->{'module1.c'}});
is('anotherfunction', $extractor->current_function);

##############################################################################
# BEGIN test detecting the start of GCC4 style functions
##############################################################################
$extractor = new Egypt::Extractor(current_module => 'hello.c');
$extractor->feed(';; Function say_hello (say_hello)');
ok(grep { $_ eq 'say_hello' } @{$extractor->output->{modules}->{'hello.c'}});
is('say_hello', $extractor->current_function);

# mangled/demangled name
$extractor->feed(';; Function Class::method(int) (MangledName)');
ok(grep { $_ eq 'MangledName' } @{$extractor->output->{modules}->{'hello.c'}});
is('Class::method(int)', $extractor->output->_demangle('MangledName'));
is('MangledName', $extractor->current_function);

##############################################################################
# TODO test using ctags for detecting variable declarations
##############################################################################

##############################################################################
# BEGIN test detecing a direct call
##############################################################################
$extractor = new Egypt::Extractor(current_module => 'module1.c');
$extractor->feed(';; Function callerfunction (callerfunction)');
$extractor->feed('(call_insn 7 6 8 3 module1.c:7 (call (mem:QI (symbol_ref:SI ("say_hello") [flags 0x41] <function_decl 0x40404480 say_hello>) [0 S1 A8])');
is('direct', $extractor->output->{calls}->{'callerfunction'}->{'say_hello'});

##############################################################################
# BEGIN test detecting a indirect call
##############################################################################
$extractor->feed('(symbol_ref:SI ("callback") [flags 0x41] <function_decl 0x40404580 callback>)) -1 (nil))');
is('indirect', $extractor->output->{calls}->{'callerfunction'}->{'callback'});

##############################################################################
# BEGIN test detecting a variable use
##############################################################################
$extractor->feed('(insn 13 12 14 3 module1.c:10 (set (mem/c/i:SI (symbol_ref:SI ("myvariable") [flags 0x40] <var_decl 0x403ec2e0 variable>) [0 variable+0 S4A32])');
is('variable', $extractor->output->{calls}->{'callerfunction'}->{'myvariable'});

##############################################################################
# TODO test reading from files
##############################################################################

##############################################################################
# TODO test reading from directories
##############################################################################

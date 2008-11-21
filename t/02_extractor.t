use Test::More 'no_plan';

use strict;
use warnings;

use_ok('Egypt::Extractor');

isa_ok(new Egypt::Extractor, 'Egypt::Extractor');

can_ok(new Egypt::Extractor, 'output');

# TODO test detecting the start of pre-GCC4 style functions

# TODO test detecting the start of GCC4 style functions

# TODO test detecing a direct call

# TODO test detecting a indirect call

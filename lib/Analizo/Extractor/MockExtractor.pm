## This is a mock extractor used to test the ability to choose different extractors other than the default

package Analizo::Extractor::MockExtractor;

use strict;
use warnings;

use parent qw(Analizo::Extractor);

sub new {
    return __PACKAGE__;
}

sub feed {
}

sub actually_process {
}

1;
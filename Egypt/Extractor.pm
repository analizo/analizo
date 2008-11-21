package Egypt::Extractor;

use strict;
use warnings;

use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw(output));

sub new {
  return bless {}, __PACKAGE__;
}

1;

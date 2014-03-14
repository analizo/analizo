package t::Analizo::Metric::AllocatorSizeofOperandMismatch;
use base qw(Test::Class);
use Test::More tests => 5;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::AllocatorSizeofOperandMismatch;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $dbz);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $dbz = new Analizo::Metric::AllocatorSizeofOperandMismatch(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::AllocatorSizeofOperandMismatch');
}

sub has_model : Tests {
  is($dbz->model, $model);
}

sub description : Tests {
  is($dbz->description, "Allocator sizeof operand mismatch");
}

sub calculate : Tests {
  is($dbz->calculate('file'), 0, 'file without allocator sizeof operand mismatch');

  $model->declare_security_metrics('Allocator sizeof operand mismatch', 'file', 2);
  is($dbz->calculate('file'), 2, 'one module, with 2 allocator sizeof operand mismatch');
}

__PACKAGE__->runtests;


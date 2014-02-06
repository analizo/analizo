package t::Analizo::Metric::MemoryLeak;
use base qw(Test::Class);
use Test::More tests => 5;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::MemoryLeak;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $mlk);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $mlk = new Analizo::Metric::MemoryLeak(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::MemoryLeak');
}

sub has_model : Tests {
  is($mlk->model, $model);
}

sub description : Tests {
  is($mlk->description, "Memory leak");
}

sub calculate : Tests {
  is($mlk->calculate('file'), 0, 'file without memory leak');

  $model->declare_security_metrics('Memory leak', 'file', 2);
  is($mlk->calculate('file'), 2, 'one module, with 2 memory leak');
}

__PACKAGE__->runtests;


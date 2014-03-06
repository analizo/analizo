package t::Analizo::Metric::UndefinedAllocation;
use base qw(Test::Class);
use Test::More tests => 5;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::UndefinedAllocation;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $ua);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $ua = new Analizo::Metric::UndefinedAllocation(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::UndefinedAllocation');
}

sub has_model : Tests {
  is($ua->model, $model);
}

sub description : Tests {
  is($ua->description, "Undefined allocation of 0 bytes (CERT MEM04-C; CWE-131)");
}

sub calculate : Tests {
  is($ua->calculate('file'), 0, 'file without undefined allocation');

  $model->declare_security_metrics('Undefined allocation of 0 bytes (CERT MEM04-C; CWE-131)', 'file', 2);
  is($ua->calculate('file'), 2, 'one module, with 2 undefined allocation');
}

__PACKAGE__->runtests;


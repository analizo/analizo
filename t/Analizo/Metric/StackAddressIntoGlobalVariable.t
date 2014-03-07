package t::Analizo::Metric::StackAddressIntoGlobalVariable;
use base qw(Test::Class);
use Test::More tests => 5;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::StackAddressIntoGlobalVariable;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $saigv);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $saigv = new Analizo::Metric::StackAddressIntoGlobalVariable(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::StackAddressIntoGlobalVariable');
}

sub has_model : Tests {
  is($saigv->model, $model);
}

sub description : Tests {
  is($saigv->description, "Stack address stored into global variable");
}

sub calculate : Tests {
  is($saigv->calculate('file'), 0, 'file without stack address into global variable');

  $model->declare_security_metrics('Stack address stored into global variable', 'file', 2);
  is($saigv->calculate('file'), 2, 'one module, with 2 stack address into global variable');
}

__PACKAGE__->runtests;


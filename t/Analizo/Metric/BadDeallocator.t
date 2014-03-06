package t::Analizo::Metric::BadDeallocator;
use base qw(Test::Class);
use Test::More tests => 5;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::BadDeallocator;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $bd);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $bd = new Analizo::Metric::BadDeallocator(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::BadDeallocator');
}

sub has_model : Tests {
  is($bd->model, $model);
}

sub description : Tests {
  is($bd->description, "Bad deallocator");
}

sub calculate : Tests {
  is($bd->calculate('file'), 0, 'file without bad deallocator');

  $model->declare_security_metrics('Bad deallocator', 'file', 2);
  is($bd->calculate('file'), 2, 'one module, with 2 bad deallocator');
}

__PACKAGE__->runtests;


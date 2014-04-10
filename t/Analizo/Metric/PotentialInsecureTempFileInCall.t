package t::Analizo::Metric::PotentialInsecureTempFileInCall;
use base qw(Test::Class);
use Test::More;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::PotentialInsecureTempFileInCall;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $dnp);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $dnp = new Analizo::Metric::PotentialInsecureTempFileInCall(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::PotentialInsecureTempFileInCall');
}

sub has_model : Tests {
  is($dnp->model, $model);
}

sub description : Tests {
  is($dnp->description, "Potential insecure temporary file in call 'mktemp'");
}

sub calculate : Tests {
  is($dnp->calculate('file'), 0, 'file dont use temporary file in call');

  $model->declare_security_metrics('Potential insecure temporary file in call \'mktemp\'', 'file', 1);
  is($dnp->calculate('file'), 1, 'one module, with 1 Result of potential insecure temporary file in call');
}

__PACKAGE__->runtests;

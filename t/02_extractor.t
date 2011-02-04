package ExtractorTests;
use base qw(Test::Class);
use Test::More 'no_plan'; # REMOVE THE 'no_plan'
use Test::Exception;

use strict;
use warnings;

BEGIN {
   use_ok 'Analizo::Extractor';
}

eval('$Analizo::Extractor::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

sub constructor : Tests {
  isa_ok(new Analizo::Extractor, 'Analizo::Extractor');
}

sub has_a_current_member : Tests {
  can_ok('Analizo::Extractor', 'current_member');
}

##############################################################################
# BEGIN test of indicating current module
##############################################################################
sub current_module : Tests {
  my $extractor = new Analizo::Extractor;
  $extractor->current_module('module1.c');
  is($extractor->current_module, 'module1.c', 'must be able to set the current module');
  $extractor->current_module('module2.c');
  is($extractor->current_module, 'module2.c', 'must be able to change the current module');
}

sub process_must_delegate_to_actually_process : Tests {
  my $called = 0;
  no warnings;
  local *Analizo::Extractor::actually_process = sub { $called = 1; };
  use warnings;
  Analizo::Extractor->new->process;
  ok($called);
}

sub load_doxyparse_extractor : Tests {
  lives_ok { Analizo::Extractor->load('Doxyparse') };
}

sub fail_when_load_invalid_extractor : Tests {
  dies_ok { Analizo::Extractor->load('ThisNotExists') };
}

sub load_doxyparse_extractor_by_alias : Tests {
  lives_ok {
    isa_ok(Analizo::Extractor->load('doxy'), 'Analizo::Extractor::Doxyparse');
  }
}

sub dont_allow_code_injection: Tests {
  lives_ok {
    isa_ok(Analizo::Extractor->load('Doxyparse; die("BOOM!")'), 'Analizo::Extractor::Doxyparse');
  }
}

sub possibly_has_one_language_filter : Tests {
  my $extractor = new Analizo::Extractor;
  can_ok($extractor, 'language');
  ok(!defined($extractor->language));
  my $language = {};
  $extractor->language($language);
  ok($extractor->language == $language);
}

sub must_not_filter_input_with_a_language_filter : Tests {
  my $extractor = new Analizo::Extractor;
  my @processed = ();
  no warnings;
  local *Analizo::Extractor::actually_process = sub {
    my $self = shift;
    @processed = @_;
  };
  use warnings;
  my $path = 't/samples/mixed';
  $extractor->process($path);
  ok($processed[0] eq $path);
}

sub must_filter_input_with_language_filter : Tests {
  my @processed = ();
  no warnings;
  local *Analizo::Extractor::actually_process = sub {
    my $self = shift;
    @processed = @_;
  };
  local *LanguageFilterStub::matches = sub {
    my ($self, $filename) = @_;
    if ($filename =~ /\.java$/) {
      return 1;
    } else {
      return 0;
    }
  };
  use warnings;

  my $extractor = new Analizo::Extractor;
  $extractor->language(new LanguageFilterStub);
  $extractor->process('t/samples/mixed');

  my @expected = ('t/samples/mixed/Backend.java', 't/samples/mixed/UI.java');
  @processed = sort(@processed);
  is_deeply(\@processed, \@expected);
}

package LanguageFilterStub;
sub new {
  return bless {}, __PACKAGE__;
}

ExtractorTests->runtests;

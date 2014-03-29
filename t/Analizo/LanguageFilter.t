package t::Analizo::LanguageFilter;
use base qw(Test::Class);
use Test::More;

use strict;
use warnings;

use Analizo::LanguageFilter;

sub constructor : Tests {
  isa_ok(Analizo::LanguageFilter->new, 'Analizo::LanguageFilter');
}

sub null_object_matches_everything_that_is_supported : Tests {
  my $filter = Analizo::LanguageFilter->new();
  ok($filter->matches('test.c'));
  ok($filter->matches('Test.java'));
  ok(!$filter->matches('Makefile'))
}

sub c_filter_matches_dot_c_and_dot_h : Tests {
  my $filter = Analizo::LanguageFilter->new('c');
  ok($filter->matches('test.c'));
  ok($filter->matches('test.h'));
  ok(!$filter->matches('Test.java'));
}

sub cpp_filter_matches_cpp_cc_cxx_hpp_h : Tests {
  my $filter = Analizo::LanguageFilter->new("cpp");
  ok($filter->matches('test.cpp'));
  ok($filter->matches('test.cxx'));
  ok($filter->matches('test.cc'));
  ok($filter->matches('test.hpp'));
  ok($filter->matches('test.h'));

  ok(!$filter->matches('test.c'));
  ok(!$filter->matches('test.java'));
}

sub java_filter_matches_java_only : Tests {
  my $filter = Analizo::LanguageFilter->new('java');
  ok($filter->matches('Test.java'));
  ok(!$filter->matches('Test.c'));
  ok(!$filter->matches('Test.h'));
  ok(!$filter->matches('Test.cpp'));
}

sub must_be_case_insensitive : Tests {
  my $filter = Analizo::LanguageFilter->new('all');
  ok($filter->matches('test.C'));
  ok($filter->matches('test.CPP'));
  ok($filter->matches('Test.H'));
  ok($filter->matches('Test.JAVA'));
}

sub list_languages : Tests {
  my @language_list = Analizo::LanguageFilter->list;
  ok(grep { /^java$/ } @language_list);
  ok(grep { /^cpp$/ } @language_list);
}

__PACKAGE__->runtests;

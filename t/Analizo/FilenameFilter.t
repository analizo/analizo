package t::Analizo::FilenameFilter;
use strict;
use warnings;
use parent qw(Test::Analizo::Class);
use Test::More;
use Analizo::FilenameFilter;

sub constructor : Tests {
  isa_ok(Analizo::FilenameFilter->new, 'Analizo::FilenameFilter');
}

sub null_object : Tests {
  my $filter = Analizo::FilenameFilter->new;
  ok($filter->matches('test.c'));
}

sub excluder : Tests {
  my $excluder = Analizo::FilenameFilter->exclude('test', 'stats');
  isa_ok($excluder, 'Analizo::FilenameFilter');
  ok(!$excluder->matches('test'));
  ok(!$excluder->matches('test/test.c'));
  ok(!$excluder->matches('stats'));
  ok(!$excluder->matches('stats/stats.c'));
  ok($excluder->matches('main.c'));
}

sub must_match_filenames_with_or_without_leading_dot : Tests {
  my $filter = Analizo::FilenameFilter->exclude('test', 'src');
  ok(!$filter->matches('test'));
  ok(!$filter->matches('./test'));

  # now also exclude 'src'
  ok(!$filter->matches('src'));
  ok(!$filter->matches('./src'));
}


__PACKAGE__->runtests;

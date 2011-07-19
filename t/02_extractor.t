package ExtractorTests;
use base qw(Test::Class);
use Test::More 'no_plan'; # REMOVE THE 'no_plan'
use Test::Exception;

use strict;
use warnings;

use Analizo::Extractor;

# Redefine constructor so that this test class can instantiate
# Analizo::Extractor directly
use Test::MockModule;
my $AnalizoExtractor = new Test::MockModule('Analizo::Extractor');
$AnalizoExtractor->mock('new', sub { return bless {}, 'Analizo::Extractor'});

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

sub current_file : Tests {
  my $extractor = new Analizo::Extractor;
  is($extractor->current_file, undef);
  $extractor->current_file('file1.c');
  is($extractor->current_file, 'file1.c');
}

sub current_file_plus_current_module : Tests {
  my $extractor = new Analizo::Extractor;

  $extractor->{model} = new ModelStub;
  my $mapped_module_to_filename = undef;
  no warnings;
  *ModelStub::declare_module = sub {
    my ($self, $_module, $_filename) = @_;
    if ($_module eq 'Person' && defined($_filename) && $_filename eq 'person.cpp') {
      $mapped_module_to_filename = 1;
    }
  };
  use warnings;

  $extractor->current_file('person.cpp');
  $extractor->current_module('Person');
  ok($mapped_module_to_filename);
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

sub has_filters : Tests {
  my $extractor = new Analizo::Extractor;
  can_ok($extractor, 'filters');
  my @filters = $extractor->filters;
  is_deeply([], \@filters);
  my $language = {};
  $extractor->filters($language);
  @filters = $extractor->filters;
  is($language, $filters[0]);
}

sub must_consider_only__supported_languages : Tests {
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
  @processed = sort @processed;
  my @expected = qw(
    t/samples/mixed/Backend.java
    t/samples/mixed/UI.java
    t/samples/mixed/native_backend.c
  );
  is_deeply(\@processed, \@expected);
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
  $extractor->filters(new LanguageFilterStub);
  $extractor->process('t/samples/mixed');

  my @expected = ('t/samples/mixed/Backend.java', 't/samples/mixed/UI.java');
  @processed = sort(@processed);
  is_deeply(\@processed, \@expected);
}

sub must_create_filters_for_excluded_dirs : Tests {
  my $extractor = new Analizo::Extractor;
  my @filters = $extractor->filters;
  is(scalar @filters, 0);

  # addding the first excluded directory filter also adds a null language filter
  $extractor->exclude('test');
  @filters = $extractor->filters;
  is(scalar @filters, 2);

  $extractor->exclude('uitest');
  @filters = $extractor->filters;
  is(scalar(@filters), 3);
}

sub must_not_process_files_in_excluded_dirs : Tests {
  my @processed = ();
  no warnings;
  local *Analizo::Extractor::actually_process = sub {
    my $self = shift;
    @processed = sort(@_);
  };
  use warnings;

  my $extractor = new Analizo::Extractor;
  $extractor->exclude('t/samples/multidir/cpp/test');
  $extractor->process('t/samples/multidir/cpp');
  is_deeply(\@processed, ['t/samples/multidir/cpp/hello.cc', 't/samples/multidir/cpp/src/hello.cc', 't/samples/multidir/cpp/src/hello.h']);
}

sub must_not_exclude_everything_in_the_case_of_unexisting_excluded_dir : Tests {
  my @processed = ();
  no warnings;
  local *Analizo::Extractor::actually_process = sub {
    my $self = shift;
    @processed = sort(@_);
  };
  use warnings;

  my $extractor = new Analizo::Extractor;

  ok(! -e 't/samples/animals/cpp/test');
  $extractor->exclude('t/samples/animals/cpp/test');  # does not exist!
  $extractor->process('t/samples/animals/cpp');

  isnt(0, scalar @processed);
}

package LanguageFilterStub;
sub new {
  return bless {}, __PACKAGE__;
}

package ModelStub;
sub new {
  return bless {}, __PACKAGE__;
}

ExtractorTests->runtests;

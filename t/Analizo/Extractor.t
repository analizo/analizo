  package t::Analizo::Extractor;
use strict;
use warnings;
use parent qw(Test::Analizo::Class);
use Test::More;
use Test::Exception;

use Analizo::Extractor;
use Analizo::LanguageFilter;
use Analizo::Model;

# Redefine constructor so that this test class can instantiate
# Analizo::Extractor directly
use Test::MockModule;
my $AnalizoExtractor = Test::MockModule->new('Analizo::Extractor');
$AnalizoExtractor->mock('new', sub { return bless {}, 'Analizo::Extractor'});

eval('$Analizo::Extractor::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

sub constructor : Tests {
  isa_ok(Analizo::Extractor->new, 'Analizo::Extractor');
}

sub has_a_current_member : Tests {
  can_ok('Analizo::Extractor', 'current_member');
}

##############################################################################
# BEGIN test of indicating current module
##############################################################################
sub current_module : Tests {
  my $extractor = Analizo::Extractor->new;
  $extractor->current_module('module1.c');
  is($extractor->current_module, 'module1.c', 'must be able to set the current module');
  $extractor->current_module('module2.c');
  is($extractor->current_module, 'module2.c', 'must be able to change the current module');
}

sub current_file : Tests {
  my $extractor = Analizo::Extractor->new;
  is($extractor->current_file, undef);
  $extractor->current_file('file1.c');
  is($extractor->current_file, 'file1.c');
}

sub current_file_plus_current_module : Tests {
  my $extractor = Analizo::Extractor->new;

  my $model = Analizo::Model->new;
  $extractor->{model} = $model;

  $extractor->current_file('person.cpp');
  $extractor->current_module('Person');

  is_deeply($model->{module_by_file}->{'person.cpp'}, ['Person']);
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
  my $extractor = Analizo::Extractor->new;
  can_ok($extractor, 'filters');
  my $filters = $extractor->filters;
  is_deeply([], $filters);
  my $language = {};
  $extractor->filters($language);
  $filters = $extractor->filters;
  is($language, $filters->[0]);
}

sub must_consider_only__supported_languages : Tests {
  my $extractor = Analizo::Extractor->new;
  my @processed = ();
  no warnings;
  local *Analizo::Extractor::actually_process = sub {
    my ($self, @options) = @_;
    @processed = @options;
  };
  use warnings;

  my $path = 't/samples/mixed';
  $extractor->process($path);
  @processed = sort @processed;
  my @expected = qw(
    t/samples/mixed/Backend.java
    t/samples/mixed/CSharp_Backend.cs
    t/samples/mixed/UI.java
    t/samples/mixed/hello_world.py
    t/samples/mixed/native_backend.c
    t/samples/mixed/polygons.py
  );
  is_deeply(\@processed, \@expected);
}

sub must_filter_input_with_language_filter : Tests {
  my @processed = ();
  no warnings;
  local *Analizo::Extractor::actually_process = sub {
    my ($self, @options) = @_;
    @processed = @options;
  };

  my $extractor = Analizo::Extractor->new;
  $extractor->filters(Analizo::LanguageFilter->new('java'));
  $extractor->process('t/samples/mixed');

  my @expected = ('t/samples/mixed/Backend.java', 't/samples/mixed/UI.java');
  @processed = sort(@processed);
  is_deeply(\@processed, \@expected);
}

sub must_create_filters_for_excluded_dirs : Tests {
  my $extractor = Analizo::Extractor->new;
  my $filters = $extractor->filters;
  is(scalar @$filters, 0);

  # addding the first excluded directory filter also adds a null language filter
  $extractor->exclude('test');
  $filters = $extractor->filters;
  is(scalar @$filters, 2);

  $extractor->exclude('uitest');
  $filters = $extractor->filters;
  is(scalar(@$filters), 3);
}

sub must_not_process_files_in_excluded_dirs : Tests {
  my @processed = ();
  no warnings;
  local *Analizo::Extractor::actually_process = sub {
    my ($self, @options) = @_;
    @processed = sort(@options);
  };
  use warnings;

  my $extractor = Analizo::Extractor->new;
  $extractor->exclude('t/samples/multidir/cpp/test');
  $extractor->process('t/samples/multidir/cpp');
  is_deeply(\@processed, ['t/samples/multidir/cpp/hello.cc', 't/samples/multidir/cpp/src/hello.cc', 't/samples/multidir/cpp/src/hello.h']);
}

sub must_not_exclude_everything_in_the_case_of_unexisting_excluded_dir : Tests {
  my @processed = ();
  no warnings;
  local *Analizo::Extractor::actually_process = sub {
    my ($self, @options) = @_;
    @processed = sort(@options);
  };
  use warnings;

  my $extractor = Analizo::Extractor->new;

  ok(! -e 't/samples/animals/cpp/test');
  $extractor->exclude('t/samples/animals/cpp/test');  # does not exist!
  $extractor->process('t/samples/animals/cpp');

  isnt(0, scalar @processed);
}

sub must_not_ignore_filter_by_default : Tests {
  no warnings;
  local *Analizo::Extractor::apply_filters = sub {
    die "apply_filters() was called"
  };
  use warnings;

  my $extractor = Analizo::Extractor->new;
  dies_ok { $extractor->process('t/samples/mixed') };
}

sub force_ignore_filter : Tests {
  no warnings;
  local *Analizo::Extractor::use_filters = sub {
    0;
  };
  local *Analizo::Extractor::apply_filters = sub {
    die "apply_filters() was called"
  };
  use warnings;

  my $extractor = Analizo::Extractor->new;
  lives_ok { $extractor->process('t/samples/mixed') };
}

__PACKAGE__->runtests;

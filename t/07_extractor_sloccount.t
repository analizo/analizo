package ExtractorSloccountTests;
use base qw(Test::Class);
use Test::More 'no_plan'; # REMOVE THE 'no_plan'

use strict;
use warnings;
use File::Basename;

eval('$Analizo::Extractor::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

sub new_sloccount_extractor() {
  my $model = new Analizo::Model;
  return Analizo::Extractor::Sloccount->new(model => $model);
}

sub constructor : Tests {
  use_ok('Analizo::Extractor::Sloccount');

  my $extractor = new_sloccount_extractor();
  isa_ok($extractor, 'Analizo::Extractor::Sloccount');
  isa_ok($extractor->model, 'Analizo::Model');
}

sub feed : Tests {
  my $extractor = new_sloccount_extractor();
  $extractor->feed("Total Physical Source Lines of Code (SLOC)                = 28");
  is($extractor->model->total_eloc, 28, "project with 28 lines of code");

  $extractor->feed("Total Physical Source Lines of Code (SLOC)                = 1,291");
  is($extractor->model->total_eloc, 1291, "project with 1291 lines of code");

  $extractor->feed("Total Physical Source Lines of Code (SLOC)                = 1,291,549");
  is($extractor->model->total_eloc, 1291549, "project with 1291549 lines of code");
}

sub reading_from_one_output : Tests {
  my $sample_dir = dirname(__FILE__) . '/samples/sample_basic';
  my $extractor = new_sloccount_extractor();

  $extractor->process($sample_dir . '/module1.c');
  is($extractor->model->total_eloc, 16, 'reading from one input file');
}

sub reading_from_many_inputs_files : Tests {
  my $sample_dir = dirname(__FILE__) . '/samples/sample_basic';
  my $extractor = new_sloccount_extractor();

  $extractor->process($sample_dir . '/module1.c', $sample_dir . '/module2.c');
  is($extractor->model->total_eloc, 24, 'reading from many input files');
}

sub reading_from_directory : Tests {
  my $sample_dir = dirname(__FILE__) . '/samples/sample_basic';
  my $extractor = new_sloccount_extractor();

  $extractor->process($sample_dir);
  is($extractor->model->total_eloc, 46, 'reading from an input directory');    
}

ExtractorSloccountTests->runtests;

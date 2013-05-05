package GlobalMetricsTests;
use strict;
use base qw(Test::Class);
use Test::More;
use Statistics::Descriptive;
use Analizo::GlobalMetrics;
use Analizo::Model;


use vars qw($model $global_metrics);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $global_metrics = new Analizo::GlobalMetrics(model => $model);
}

sub constructor : Tests {
  isa_ok($global_metrics, 'Analizo::GlobalMetrics');
}

sub model : Tests {
  is($global_metrics->model, $model);
}

sub metric_from_global_metrics_package : Tests{
  $model->add_abstract_class('mod');
  $model->declare_function('mod', 'f1');

  $model->declare_total_eloc(10);

  my $report = $global_metrics->report();

  is($report->{'total_eloc'}, 10, '10 eloc declared and reported');
  is($report->{'total_abstract_classes'}, 1, '1 abstract class');
  is($report->{'total_methods_per_abstract_class'}, 1, '1 method per abstract class');
}

sub total_modules : Tests {
  my $report = $global_metrics->report;
  is($report->{'total_modules'}, 0);

  my %dummy_module_values = ();
  $global_metrics->add_module_values(\%dummy_module_values);
  $report = $global_metrics->report;
  is($report->{'total_modules'}, 1);
}


sub total_modules_with_defined_methods_when_no_modules_where_defined : Tests {
  my $report = $global_metrics->report;
  is($report->{'total_modules_with_defined_methods'}, 0);
}

sub total_modules_with_defined_methods_when_a_module_has_nom : Tests{
  my %module_values = (nom => 1);
  $global_metrics->add_module_values(\%module_values);
  my $report = $global_metrics->report;
  is($report->{'total_modules_with_defined_methods'}, 1);
}

sub total_modules_with_defined_methods_when_a_module_has_no_nom : Tests {
  my %module_values = (nom => 0);
  $global_metrics->add_module_values(\%module_values);
  my $report = $global_metrics->report;
  is($report->{'total_modules_with_defined_methods'}, 0);
}

sub total_modules_with_defined_attributes_when_no_modules_where_defined : Tests {
  my $report = $global_metrics->report;
  is($report->{'total_modules_with_defined_attributes'}, 0);
}

sub total_modules_with_defined_attributes_when_a_module_has_noa : Tests{
  my %module_values = (noa => 1);
  $global_metrics->add_module_values(\%module_values);
  my $report = $global_metrics->report;
  is($report->{'total_modules_with_defined_attributes'}, 1);
}

sub total_modules_with_defined_attributes_when_a_module_has_no_noa : Tests {
  my %module_values = (noa => 0);
  $global_metrics->add_module_values(\%module_values);
  my $report = $global_metrics->report;
  is($report->{'total_modules_with_defined_attributes'}, 0);
}

sub total_nom_with_no_nom_found : Tests {
  my $report = $global_metrics->report;
  is($report->{'total_nom'}, 0);

}

sub one_total_nom_found : Tests {
  my %module_values = (nom => 1);
  $global_metrics->add_module_values(\%module_values);
  my $report = $global_metrics->report;
  is($report->{'total_nom'}, 1);
}

sub sum_the_values_of_nom_found : Tests {
  my %module_values = (nom => 1);
  $global_metrics->add_module_values(\%module_values);
  my %other_values = (nom => 3);
  $global_metrics->add_module_values(\%other_values);
  my $report = $global_metrics->report;
  is($report->{'total_nom'}, 4);
}

sub total_loc_with_no_loc_found : Tests {
  my $report = $global_metrics->report;
  is($report->{'total_loc'}, 0);
}

sub one_total_loc_found : Tests {
  my %module_values = (loc => 1);
  $global_metrics->add_module_values(\%module_values);
  my $report = $global_metrics->report;
  is($report->{'total_loc'}, 1);
}

sub sum_the_values_of_loc_found : Tests {
  my %module_values = (loc => 1);
  $global_metrics->add_module_values(\%module_values);
  my %other_values = (loc => 3);
  $global_metrics->add_module_values(\%other_values);
  my $report = $global_metrics->report;
  is($report->{'total_loc'}, 4);
}


sub add_loc_mean_when_there_was_no_added_values : Tests {
  my $report = $global_metrics->report;
  is($report->{'loc_mean'}, undef);
}

sub add_loc_mean_when_there_was_one_added_values : Tests {
  my %module_values = (loc => 1);
  $global_metrics->add_module_values(\%module_values);
  my $report = $global_metrics->report;
  is($report->{'loc_mean'}, 1);
}

sub add_loc_mean_when_there_were_two_added_values : Tests {
  my %module_values = (loc => 1);
  $global_metrics->add_module_values(\%module_values);

  my %other_values = (loc => 3);
  $global_metrics->add_module_values(\%other_values);

  my $report = $global_metrics->report;
  is($report->{'loc_mean'}, 2);
}

sub add_lcom4_mean_when_there_were_two_added_values : Tests {
  my %module_values = (lcom4 => 1);
  $global_metrics->add_module_values(\%module_values);

  my %other_values = (lcom4 => 3);
  $global_metrics->add_module_values(\%other_values);

  my $report = $global_metrics->report;
  is($report->{'lcom4_mean'}, 2);
}


sub add_rfc_sum_when_there_were_two_added_values : Tests {
  my %module_values = (rfc => 1);
  $global_metrics->add_module_values(\%module_values);

  my %other_values = (rfc => 3);
  $global_metrics->add_module_values(\%other_values);

  my $report = $global_metrics->report;
  is($report->{'rfc_sum'}, 4);
}

sub should_have_other_descriptive_statistics : Tests {
  my %module_values = (rfc => 1);
  $global_metrics->add_module_values(\%module_values);

  my $report = $global_metrics->report;
  isnt($report->{'rfc_mean'}, undef);
  isnt($report->{'rfc_quantile_max'}, undef);
  isnt($report->{'rfc_standard_deviation'}, undef);
  isnt($report->{'rfc_sum'}, undef);
  isnt($report->{'rfc_variance'}, undef);
}

sub should_have_distributions_statistics : Tests {
  my %module_values = (rfc => 4);
  $global_metrics->add_module_values(\%module_values);
  $global_metrics->add_module_values(\%module_values);
  $global_metrics->add_module_values(\%module_values);
  $global_metrics->add_module_values(\%module_values);
  my $report = $global_metrics->report;
  isnt($report->{'rfc_kurtosis'}, undef);
  isnt($report->{'rfc_skewness'}, undef);
}


sub should_add_total_coupling_factor : Tests {
  my $report = $global_metrics->report;
  is($report->{'total_cof'}, 1);

  my %module_values = (acc => 1);
  $global_metrics->add_module_values(\%module_values);
  $global_metrics->add_module_values(\%module_values);
  $global_metrics->add_module_values(\%module_values);
  my $report = $global_metrics->report;
  is($report->{'total_cof'}, 0.5);
}

sub should_ignore_module_name : Tests {
  my %module_values = ('_module' => 'mod1');
  $global_metrics->add_module_values(\%module_values);
  my $report = $global_metrics->report;
  is($report->{'_module'}, undef);
}

sub list_of_metrics : Tests {
  my %metrics = $global_metrics->list();
  cmp_ok(scalar(keys(%metrics)), '>', 0, 'must list metrics');
}

sub should_ignore_filename : Tests {
  my %values = (_filename => 'main.c');
  $global_metrics->add_module_values(\%values);
  my $report = $global_metrics->report;
  ok(! grep(/^_filename/, keys %$report), "Should ignore _filename metrics");
}

__PACKAGE__->runtests;


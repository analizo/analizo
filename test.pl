use strict;
use warnings;
use Test::BDD::Cucumber;

print "I: Running acceptance tests with Test::BDD::Cucumber v$Test::BDD::Cucumber::VERSION ...\n\n";

# This will find step definitions and feature files in the directory you point
# it at below
use Test::BDD::Cucumber::Loader;

# This harness prints out nice TAP
use t::Analizo::Test::BDD::Cucumber::Harness;

# Load a directory with Cucumber files in it. It will recursively execute any
# file matching .*_steps.pl as a Step file, and .*\.feature as a feature file.
# The features are returned in @features, and the executor is created with the
# step definitions loaded.
# It's possible to execute just a feature by passing it as argument in
# command-line. Like: $ perl test.pl t/features/dsm.feature
my ($executor, @features) = @ARGV == 0
  ? Test::BDD::Cucumber::Loader->load('t/features/')
  : Test::BDD::Cucumber::Loader->load(@ARGV);

# Create a Harness to execute against. TestBuilder harness prints TAP
my $harness = t::Analizo::Test::BDD::Cucumber::Harness->new({});

# For each feature found, execute it, using the Harness to print results
$executor->execute($_, $harness) for @features;

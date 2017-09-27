Feature: evolution matrix
  As a software engineering reasearcher
  I want to visualize the evolution of metrics among project versions
  So that I can analyze how metrics changes over time

  Scenario: requires input file
    When I run "analizo evolution-matrix"
    Then the exit status must not be 0
    And analizo must emit a warning matching "No input files"

  Scenario: require yaml file as input
    When I run "analizo evolution-matrix fake-1.0.yml"
    Then the exit status must not be 0
    And analizo must emit a warning matching "No such file or directory"

  Scenario: sample basic
    When I run "analizo evolution-matrix t/samples/sample_basic-1.0.yml"
    Then the output must match "\<html\>"

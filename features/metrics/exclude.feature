Feature: exclude directories from the analysis
  As a software developer in a large project
  I want to exclude some directories from the source code analysis
  In order to not analyse non-production code such as tests

  Scenario: excluding test directory
    Given I am in t/samples/multidir/cpp
    When  I run "analizo metrics --exclude test ."
    Then  the output must match "HelloWorld"
    And   the output must not match "hello_test"

  Scenario: excluding a list of directories
    Given I am in t/samples/multidir/cpp
    When  I run "analizo metrics --exclude test:src ."
    Then  the output must not match "HelloWorld"
    And   the output must not match "hello_test"

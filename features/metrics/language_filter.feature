Feature: language filters
  As a software developer in a multi-language project
  I want to analyze only one programming language
  So that the results are as correct as possible

  Scenario: filtering for C code
    Given I am in t/samples/mixed
    When I run "analizo metrics --language c ."
    Then the output must match "native_backend"
    And the output must not match "UI"
    And the output must not match "Backend"

  Scenario: filtering for Java code
    Given I am in t/samples/mixed
    When I run "analizo metrics --language java ."
    Then the output must match "UI"
    And the output must match "Backend"
    And the output must not match "native_backend"

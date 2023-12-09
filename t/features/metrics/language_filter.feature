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
    And the output must not match "CSharp_Backend"

  Scenario: filtering for Java code
    Given I am in t/samples/mixed
    When I run "analizo metrics --language java ."
    Then the output must match "UI"
    And the output must match "Backend"
    And the output must not match "native_backend"
    And the output must not match "CSharp_Backend"

  Scenario: filtering for CSharp code
    Given I am in t/samples/mixed
    When I run "analizo metrics --language csharp ."
    Then the output must match "CSharp_Backend"
    And the output must not match "UI"
    And the output must not match "native_backend"

  Scenario: filtering for Python code
    Given I am in t/samples/mixed
    When I run "analizo metrics --language python ."
    Then the output must match "hello_world"
    And the output must match "polygons"
    And the output must not match "UI"
    And the output must not match "CSharp_Backend"

  Scenario: listing languages
    When I run "analizo metrics --language list"
    Then analizo must present a list of languages

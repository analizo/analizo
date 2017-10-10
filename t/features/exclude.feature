Feature: exclude directories from the analysis
  As a software developer in a large project
  I want to exclude some directories from the source code analysis
  In order to not analyse non-production code such as tests

  Scenario: excluding test directory
    Given I am in t/samples/multidir/<language>
    When I run "analizo metrics --exclude test ."
    Then the output must match "module: HelloWorld"
    And the output must not match "module: hello_test"
    Examples:
      | language |
      | cpp      |
      | csharp   |

  Scenario: excluding a list of directories
    Given I am in t/samples/multidir/<language>
    When I run "analizo metrics --exclude test:src ."
    Then the output must not match "module: HelloWorld"
    And the output must not match "module: hello_test"
    Examples:
      | language |
      | cpp      |
      | csharp   |

  Scenario: excluding src directory
    Given I am in t/samples/multidir/<language>
    When I run "analizo metrics --exclude src ."
    Then the output must match "module: hello_test"
    And the output must not match "module: HelloWorld"
    Examples:
      | language |
      | cpp      |
      | csharp   |

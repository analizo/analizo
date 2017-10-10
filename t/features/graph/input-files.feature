Feature: input files for graph tool

  Scenario: passing specific files in the command line
    Given I am in t/samples/sample_basic/c
    When I run "analizo graph module1.c module2.c"
    Then the output must match "module1"
    And the output must match "module2"
    And the output must not match "module3"

  Scenario: passing unexisting file
    Given I am in t/samples/sample_basic/c
    When I run "analizo graph unexisting-file.c"
    Then analizo must emit a warning matching "is not readable"

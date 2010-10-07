Feature: input files for metrics tool

  Scenario: passing specific files in the command line
    Given I am in t/samples/sample_basic/
    When I run "analizo metrics module1.c module2.c"
    Then the output must match "module1"
    And the output must match "module2"
    And the output must not match "module3"

  Scenario: passing unexisting file
    Given I am in t/samples/sample_basic/
    When I run "analizo metrics unexisting-file.c"
    Then the exit status must not be 0
    And analizo must emit a warning matching "not readable"

  Scenario: passing unreadable file
    Given I am in .
    When I run "touch unreadable.tmp"
    And I run "chmod 000 unreadable.tmp"
    When I run "analizo metrics unreadable.c"
    Then the exit status must not be 0
    And analizo must emit a warning matching "not readable"

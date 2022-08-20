Feature: output file for graph tool

  Scenario: passing output file in the command line
    Given I am in .
    When I run "analizo graph --output output.dot.tmp t/samples/sample_basic/c/"
    Then the contents of "output.dot.tmp" must match "module1"
    And the exit status must be 0

  Scenario: passing output file in an unexisting directory
    Given I am in .
    When I run "analizo graph --output /this/directory/must/not/exists/output.dot t/samples/sample_basic/c/"
    Then analizo must emit a warning matching "No such file or directory"
    And the exit status must not be 0

  Scenario: passing output file without permission to write
    Given I am in .
    When I run "touch output.tmp"
    And I run "chmod 000 output.tmp"
    And I run "analizo graph --output output.tmp t/samples/sample_basic/c/"
    Then the exit status must not be 0
    And analizo must emit a warning matching "Permission denied"

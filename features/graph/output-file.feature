Feature: output file for graph tool

  Scenario: passing output file in the command line
    Given I am in .
    When I run "egypt graph --output output.dot.tmp t/sample/"
    Then the output from "output.dot.tmp" must match "module1"
    And the exit status must be 0

  Scenario: passing output file without permission to write
    Given I am in .
    When I run "egypt graph --output /this/directory/must/not/exists/output.dot t/sample/"
    Then egypt must emit a warning matching "<file> must be writeable but the supplied value .* isn't"
    And the exit status must not be 0

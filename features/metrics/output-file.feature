Feature: output file for metrics tool

  Scenario: passing output file in the command line
    Given I am in .
    When I run "analizo metrics --output output.yml.tmp t/sample"
    Then the output from "output.yml.tmp" must match "module2"
    And the exit status must be 0

  Scenario: passing output file without permission to write
    Given I am in .
    When I run "analizo metrics --output /this/directory/must/not/exists/output.yml t/sample"
    Then analizo must emit a warning matching "<file> must be writeable but the supplied value .* isn't"
    And the exit status must not be 0

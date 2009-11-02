Feature: input files for metrics tool

  Scenario: passing specific files in the command line
    Given I am in t/sample/
    When I run "analizo metrics module1.c module2.c"
    Then the output must match "module1"
    And the output must match "module2"
    And the output must not match "module3"

  Scenario: passing unexisting file
    Given I am in t/sample/
    When I run "analizo metrics unexisting-file.c"
    Then analizo must emit a warning matching "<input> must be readable but the supplied value .* isn't"

  Scenario: passing unexisting file with GCC
    Given I am in t/sample/
    When I run "analizo metrics --extractor gcc unexisting-file.c"
    Then analizo must emit a warning matching "<input> must be readable but the supplied value .* isn't"

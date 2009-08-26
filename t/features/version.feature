Feature: reporting version
  Scenario: running with --version
    When I run "egypt graph --version"
    Then the output must match "version .*$"
    And the exit status must be 0

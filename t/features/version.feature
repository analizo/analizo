Feature: reporting version
  Scenario: running with --version
    When I run "egypt --version"
    Then the output must match "egypt version .*$"
    And the exit status must be 0

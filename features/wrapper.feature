Feature: egypt wrapper script

  Scenario: invoking a tool
    When I run "egypt metrics --help"
    Then the output must match "Usage:"
    And the output must match "egypt.metrics"

  Scenario: must not pass --version ahead
    When I run "egypt metrics --version"
    Then the output must match "Invalid option: --version"
    And the exit status must be 1

  Scenario: display help
    When I run "egypt --help"
    Then the output must match "Usage:"
    And the exit status must be 0

  Scenario: display version
    When I run "egypt --version"
    Then the output must match "egypt version [0-9]+.[0-9]+.[0-9]+$"
    And the exit status must be 0

  Scenario: invalid option
    When I run "egypt --invalid-option"
    Then the output must match "Invalid option"
    And the exit status must be 1

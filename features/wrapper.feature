Feature: analizo wrapper script

  Scenario: invoking a tool
    When I run "analizo metrics"
    Then the output must match "Usage:"
    And the output must match "analizo.metrics"

  Scenario: must not pass --version ahead
    When I run "analizo metrics --version"
    Then the output must match "Invalid option: --version"
    And the exit status must be 1

  Scenario: display help
    When I run "analizo --help"
    Then the output must match "Analizo documentation"
    And the exit status must be 0

  Scenario: display version
    When I run "analizo --version"
    Then the output must match "analizo version [0-9]+.[0-9]+.[0-9]+$"
    And the exit status must be 0

  Scenario: invalid option
    When I run "analizo --invalid-option"
    Then the output must match "Invalid option"
    And the exit status must be 1

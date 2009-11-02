Feature: displaying version
  Scenario: running with --help
    When I run "analizo graph --help"
    Then the output must match "Usage:"

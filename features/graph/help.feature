Feature: displaying version
  Scenario: running with --help
    When I run "egypt graph --help"
    Then the output must match "Usage:"

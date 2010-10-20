Feature: displaying version
  Scenario: running without any arguments
    When I run "analizo graph"
    Then the output must match "Usage:"

Feature: displaying version
  Scenario: running without any arguments
    When I run "analizo graph 2>&1"
    Then the output must match "Usage:"

Feature: displaying version
  Scenario: running without any arguments
    When I run "analizo graph"
    Then analizo must emit a warning matching "Usage:"
    And the exit status must not be 0

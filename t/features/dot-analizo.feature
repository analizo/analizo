Feature: loading command line options from .analizo
  As a analizo user
  I want to store command line options in a file called .analizo inside my project
  So that I don't need to alway pass all those options on the command line

  Scenario: analizo metrics
    Given I copy t/samples/mixed into a temporary directory
    And I create a file called .analizo with the following content
      """
      metrics: --language java
      """
    When I run "analizo metrics ."
    Then the output must not match "native_backend.c"
    And the output must match "UI.java"
    And the exit status must be 0

  Scenario: all others
    Given I change to an empty temporary directory
    And I create a file called .analizo with the following content
      """
      <tool>: --help
      """
    When I run "analizo <tool>"
    Then the output must match "analizo-<tool>(1)"
    Examples:
      | tool             |
      | graph            |
      | metrics          |
      | metrics-batch    |
      | metrics-history  |
      | tree-evolution   |
      | evolution-matrix |

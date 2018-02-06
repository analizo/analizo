Feature: give manpage on --help
  As a user
  I want to read the manpage when passing --help command line option
  In order to get instructions on how to use the tools

  Scenario: display manpage for `analizo <tool>`
    When I run "analizo <tool> --help"
    Then the output must match "NAME\\s+analizo-<tool>"
    Then the output must match "USAGE\\s+analizo <tool> \\[OPTIONS\\]"
    Examples:
      | tool             |
      | evolution-matrix |
      | graph            |
      | metrics          |
      | metrics-batch    |
      | metrics-history  |
      | tree-evolution   |
      | dsm              |

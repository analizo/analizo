Feature: give manpage on --help
  As a user
  I want to read the manpage when passing --help command line option
  In order to get instructions on how to use the tools

  Scenario Outline: display manpage for `analizo <tool>`
    When I run "analizo <tool> --help"
    Then the output must match "analizo-<tool>\(1\)"
  Examples:
    | tool             |
    | doc              |
    | evolution-matrix |
    | graph            |
    | metrics          |
    | metrics-batch    |
    | metrics-history  |
    | tree-evolution   |


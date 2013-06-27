Feature: give manpage on --help
  As a user
  I want to read the manpage when passing --help command line option
  In order to get instructions on how to use the tools

  Scenario Outline: display manpage for `analizo <tool>`
    When I run "analizo <tool> --help"
    Then the output must match "Analizo::Command::<filename>\(1\)"
  Examples:
    | tool             | filename         |
    | evolution-matrix | evolution_matrix |
    | graph            | graph            |
    | metrics          | metrics          |
    | metrics-batch    | metrics_batch    |
    | metrics-history  | metrics_history  |
    | tree-evolution   | tree_evolution   |


Feature: give manpage on --help
  As a user
  I want to read the manpage when passing --help command line option
  In order to get instructions on how to use the tools

  Scenario Outline: display manpage for `analizo <tool>`
    When I run "analizo <tool> --help"
    Then the output must match "Analizo::Command::<tool>\(1\)"
  Examples:
    | tool            |
    | evolutionmatrix |
    | graph           |
    | metrics         |
    | metricsbatch    |
    | metricshistory  |
    | treeevolution   |


Feature: analizo wrapper script

  Scenario: invoking a tool
    When I run "analizo metrics lib t"
    Then analizo must emit a warning matching "Usage:"
    And analizo must emit a warning matching "analizo.metrics"
    And the exit status must not be 0

  Scenario: must not pass --version ahead
    When I run "analizo metrics --version"
    Then analizo must emit a warning matching "Invalid option: --version"
    And the exit status must not be 0

  Scenario: display help
    When I run "analizo --help"
    Then the output must match "[NAME|N^HNA^HAM^HME^HE]\\s+analizo\\s"
    And the output must match "[USAGE|U^HUS^HSA^HAG^HGE^HE]\\s+analizo\\s"
    And the exit status must be 0

  Scenario: display version
    When I run "analizo --version"
    Then the output must match "^analizo version [0-9]+.[0-9]+.[0-9]+"
    And the exit status must be 0

  Scenario: invalid option
    When I run "analizo --invalid-option"
    Then the output must match "Unrecognized command"
    And the exit status must not be 0

Feature: output statistics values of metrics
  As a researcher
  I want to ouput statistics values of metrics
  So that I can evaluate a project at once

  Scenario Outline: "Hello, world" project
    Given I am in samples/hello_world/
    When I run "analizo metrics ."
    Then the output must match "average_<metric>:"
    Then the output must match "maximum_<metric>:"
    Then the output must match "median_<metric>:"
    Then the output must match "mininum_<metric>:"
    Then the output must match "mode_<metric>:"
    Then the output must match "standard_deviation_<metric>:"
    Then the output must match "variance_<metric>:"

  Examples:
    | metric |
    | acc    |
    | accm   |
    | amloc  |
    | anpm   |
    | cbo    |
    | dit    |
    | lcom4  |
    | mmloc  |
    | noc    |
    | nom    |
    | npm    |
    | npv    |
    | rfc    |
    | tloc   |

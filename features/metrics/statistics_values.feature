Feature: output statistics values of metrics
  As a researcher
  I want to ouput statistics values of metrics
  So that I can evaluate a project at once

  Scenario Outline: "Hello, world" project
    Given I am in t/samples/hello_world/
    When I run "analizo metrics ."
    Then the output must match "<metric>_average:"
    Then the output must match "<metric>_maximum:"
    Then the output must match "<metric>_median:"
    Then the output must match "<metric>_mininum:"
    Then the output must match "<metric>_mode:"
    Then the output must match "<metric>_standard_deviation:"
    Then the output must match "<metric>_variance:"
    Then the output must match "<metric>_kurtosis:"
    Then the output must match "<metric>_skewness:"
    Then the output must match "<metric>_sum:"

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
    | noa    |
    | noc    |
    | nom    |
    | npm    |
    | npa    |
    | rfc    |
    | loc    |


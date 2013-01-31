Feature: output statistics values of metrics
  As a researcher
  I want to ouput statistics values of metrics
  So that I can evaluate a project at once

  Scenario Outline: "Hello, world" project
    Given I am in t/samples/hello_world/
    When I run "analizo metrics ."
    Then the output must match "<metric>_mean:"
    Then the output must match "<metric>_mode:"
    Then the output must match "<metric>_standard_deviation:"
    Then the output must match "<metric>_sum:"
    Then the output must match "<metric>_variance:"
    Then the output must match "<metric>_quantile_min:"
    Then the output must match "<metric>_quantile_lower:"
    Then the output must match "<metric>_quantile_median:"
    Then the output must match "<metric>_quantile_upper:"
    Then the output must match "<metric>_quantile_max:"
    Then the output must match "<metric>_kurtosis:"
    Then the output must match "<metric>_skewness:"

  Examples:
    | metric |
    | acc    |
    | accm   |
    | amloc  |
    | anpm   |
    | cbo    |
    | dit    |
    | lcom4  |
    | loc    |
    | mmloc  |
    | noa    |
    | noc    |
    | nom    |
    | npm    |
    | npa    |
    | rfc    |
    | sc     |


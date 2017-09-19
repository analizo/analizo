Feature: analizo metrics without flags that is the default behavior

  Scenario: run analizo metrics without flags
    When I run "analizo metrics t/samples/animals/java"
    Then the number of lines on metrics mean report must be "27"
    Then the output must not match "_median:"
    Then the output must not match "_lower:"
    Then the output must not match "_mode:"
    Then the output must not match "_kurtosis:"


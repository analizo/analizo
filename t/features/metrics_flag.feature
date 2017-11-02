Feature: analizo metrics without flags that is the default behavior

  Scenario: run analizo metrics without flags
    When I run "analizo metrics t/samples/animals/java"
    Then the number of lines on file must be "111"
    Then the output must not match "_median:"
    Then the output must not match "_lower:"
    Then the output must not match "_mode:"
    Then the output must not match "_kurtosis:"

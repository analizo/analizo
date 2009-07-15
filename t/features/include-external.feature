Feature: including external symbols
  Scenario: sample uses printf
    Given I am in t/sample/
    When I run "egypt --include-external ."
    Then egypt must report that "module1::main" depends on "printf"

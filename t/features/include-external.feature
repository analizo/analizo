Feature: including external symbols
  Scenario: sample uses printf
    Given I am in t/sample/
    When I run "make"
    And I run "egypt-graph --extractor GCC --include-external ."
    Then egypt must report that "main" depends on "printf"

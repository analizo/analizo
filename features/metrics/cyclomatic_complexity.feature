Feature: average cyclomatic complexity per method
  As a software developer
  I want to calculate the average cyclomatic complexity per method of my code
  So that I can spot the more complex modules and refactor them

  Scenario: my "conditionals" C project
    Given I am in samples/conditionals/c/
    When I run "analizo metrics ."
    Then analizo must report that module cc1 has accm = 1
    Then analizo must report that module cc2 has accm = 2
    Then analizo must report that module cc3 has accm = 3
    Then analizo must report that module cc4 has accm = 4

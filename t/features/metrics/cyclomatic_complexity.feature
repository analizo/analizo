Feature: average cyclomatic complexity per method
  As a software developer
  I want to calculate the average cyclomatic complexity per method of my code
  So that I can spot the more complex modules and refactor them

  Scenario: my "conditionals" C project
    Given I am in t/samples/conditionals/c/
    When I run "analizo metrics ."
    Then analizo must report that module cc1 has accm = 1
    Then analizo must report that module cc2 has accm = 2
    Then analizo must report that module cc3 has accm = 3
    Then analizo must report that module cc4 has accm = 4
    Then analizo must report that module cc5 has accm = 2
    Then analizo must report that module cc6 has accm = 3
    Then analizo must report that module cc7 has accm = 2
    Then analizo must report that module cc8 has accm = 4
    Then analizo must report that module cc9 has accm = 3
    Then analizo must report that module cc10 has accm = 2
    Then analizo must report that module cc11 has accm = 4
    Then analizo must report that module cc12 has accm = 3
    Then analizo must report that module cc13 has accm = 2
    Then analizo must report that module cc14 has accm = 3
    Then analizo must report that module cc15 has accm = 3
    Then analizo must report that module cc16 has accm = 3
    Then analizo must report that module cc17 has accm = 3
    Then analizo must report that module cc18 has accm = 5

Feature: number of attributes metric
  As a software developer
  I want to calculate the number of attributes per module metric
  So that I can evaluate my code

  Scenario: number of attributes in the "Animals" project
    Given I am in t/samples/animals/<language>
    When I run "analizo metrics ."
    Then analizo must report that module Dog has noa = 1
    And analizo must report that module Cat has noa = 1
    And analizo must report that module <main_module> has noa = 0
    Examples:
      | language | main_module |
      | cpp      | main        |
      | java     | Main        |
      | csharp   | main        |

  Scenario: number of attributes in the "Animals" project
    Given I am in t/samples/animals/<language>
    When I run "analizo metrics --extractor Pyan ."
    Then analizo must report that module Dog has noa = 1
    And analizo must report that module Cat has noa = 1
    And analizo must report that module <main_module> has noa = 0
    Examples:
      | language | main_module |
      | python      | main        |

Feature: average number of parameters metric
  As a software developer
  I want to calculate the average number of arguments per method metric
  So that I can evaluate my code

  Scenario: number of parameters in the "Animals" project
    Given I am in t/samples/animals/<language>
    When I run "analizo metrics -a ."
    Then analizo must report that module Dog has anpm = 0.5
    And analizo must report that module Cat has anpm = 0.5
    And analizo must report that module <main_module> has anpm = <anpm_main>
    Examples:
      | language | main_module | anpm_main |
      | cpp      | main        | 0         |
      | java     | Main        | 1         |

Feature: average number of parameters metric
  As a software developer
  I want to calculate the average number of arguments per method metric
  So that I can evaluate my code

  Scenario: number of parameters in the "Animals" project
    Given I am in t/samples/animals/<language>
    When I run "analizo metrics ."
    Then analizo must report that module Dog has anpm = <anpm_dog>
    And analizo must report that module Cat has anpm = <anpm_cat>
    And analizo must report that module <main_module> has anpm = <anpm_main>
    Examples:
      | language | main_module | anpm_main | anpm_dog | anpm_cat |
      | cpp      | main        | 0         | 0.5      | 0.5      |
      | java     | Main        | 1         | 0.5      | 0.5      |
      | csharp   | main        | 1         | 0.5      | 0.5      |

  Scenario: number of parameters in the "Animals" project
    Given I am in t/samples/animals/<language>
    When I run "analizo metrics --extractor Pyan ."
    Then analizo must report that module Dog has anpm = <anpm_dog>
    And analizo must report that module Cat has anpm = <anpm_cat>
    And analizo must report that module <main_module> has anpm = <anpm_main>
    Examples:
      | language | main_module | anpm_main | anpm_dog | anpm_cat |
      | python   | main        | 0         | 0.5      | 0.5      |

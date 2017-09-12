Feature: coupling between objects
  As a software developer
  I want analizo to report the value of CBO metric in my code
  So that I can evaluate it

  Scenario: "Hello, world" project
    Given I am in t/samples/hello_world/<language>
    When I run "analizo metrics -a ."
    Then analizo must report that module <module> has cbo = 1
    Examples:
      | language | module |
      | c        | main   |
      | cpp      | main   |
      | java     | Main   |

  Scenario: "Animals" project
    Given I am in t/samples/animals/<language>
    When I run "analizo metrics -a ."
    Then analizo must report that module <module> has cbo = <value>
    Examples:
      | language | module | value |
      | cpp      | main   | 1     |
      | java     | Main   | 1     |
      | cpp      | mammal | 0     |
      | java     | Mammal | 0     |

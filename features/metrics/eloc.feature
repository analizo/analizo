Feature: number of abstract classes
  As a software developer
  I want analizo to report the number of abstract classes in my code
  So that I can evaluate it

  Scenario Outline: "Hello, world" project
    Given I am in t/samples/hello_world/<language>
    When I run "analizo metrics ."
    Then analizo must report that the project has total_eloc = <eloc>
  Examples:
    | language | eloc |
    | cpp      |  40  |
    | java     |  28  |
    | c        |  35  |


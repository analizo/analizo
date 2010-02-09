Feature: number of abstract classes
  As a software developer
  I want analizo to report the number of abstract classes in my code
  So that I can evaluate it

  Scenario Outline: "Hello, world" project
    Given I am in samples/hello_world/<language>
    When I run "analizo metrics ."
    Then analizo must report that the project has sum_abstract_classes = 0
  Examples:
    | language |
    | cpp      |
    | java     |

  Scenario Outline: "Animals" project
    Given I am in samples/animals/<language>
    When I run "analizo metrics ."
    Then analizo must report that the project has sum_abstract_classes = 2
  Examples:
    | language |
    | cpp      |
    | java     |


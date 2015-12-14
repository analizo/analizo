Feature: number of abstract classes
  As a software developer
  I want analizo to report the number of abstract classes in my code
  So that I can evaluate it

  Scenario: "Hello, world" project
    Given I am in t/samples/hello_world/<language>
    When I run "analizo metrics ."
    Then analizo must report that the project has total_abstract_classes = 0
    Examples:
      | language |
      | cpp      |
      | java     |

  Scenario: "Animals" project
    Given I am in t/samples/animals/<language>
    When I run "analizo metrics ."
    Then analizo must report that the project has total_abstract_classes = 2
    Examples:
      | language |
      | cpp      |
      | java     |

  Scenario: "Polygons" project
    Given I am in t/samples/polygons/<language>
    When I run "analizo metrics ."
    Then analizo must report that the project has total_abstract_classes = 2
    Examples:
      | language |
      | cpp      |
      | java     |

Feature: total number of methods per abstract class
  As a software developer
  I want analizo to report the number of abstract classes in my code
  So that I can evaluate it

  Scenario: "Hello, world" project
    Given I am in t/samples/hello_world/<language>
    When I run "analizo metrics ."
    Then analizo must report that the project has total_methods_per_abstract_class = 0
    Examples:
      | language |
      | cpp      |
      | java     |

  Scenario: "Animals" project
    Given I am in t/samples/animals/<language>
    When I run "analizo metrics ."
    Then analizo must report that the project has total_methods_per_abstract_class = 1
    Examples:
      | language |
      | cpp      |
      | java     |

  Scenario: "Polygons" project
    Given I am in t/samples/polygons/<language>
    When I run "analizo metrics ."
    Then analizo must report that the project has total_methods_per_abstract_class = <value>
    Examples:
      | language | value |
      | cpp      |  1.5  |
      | java     |   2   |


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
      | csharp   |

  Scenario: "Hello, world" project
    Given I am in t/samples/hello_world/<language>
    When I run "analizo metrics --extractor Pyan ."
    Then analizo must report that the project has total_abstract_classes = 0
    Examples:
      | language |
      | python   |

  Scenario: "Animals" project
    Given I am in t/samples/animals/<language>
    When I run "analizo metrics ."
    Then analizo must report that the project has total_abstract_classes = <total_abstract_classes>
    Examples:
      | language | total_abstract_classes |
      | cpp      | 2                      |
      | java     | 2                      |
      | csharp   | 1                      |
  
  Scenario: "Animals" project
    Given I am in t/samples/animals/<language>
    When I run "analizo metrics --extractor Pyan ."
    Then analizo must report that the project has total_abstract_classes = <total_abstract_classes>
    Examples:
      | language | total_abstract_classes |
      | python   | 2                      |

  Scenario: "Polygons" project
    Given I am in t/samples/polygons/<language>
    When I run "analizo metrics ."
    Then analizo must report that the project has total_abstract_classes = 2
    Examples:
      | language |
      | cpp      |
      | java     |
      | csharp   |

  Scenario: "Polygons" project
    Given I am in t/samples/polygons/<language>
    When I run "analizo metrics --extractor Pyan ."
    Then analizo must report that the project has total_abstract_classes = 2
    Examples:
      | language |
      | python   |

  Scenario: "AbstractClass" project
    Given I am in t/samples/abstract_class/<language>
    When I run "analizo metrics ."
    Then analizo must report that the project has total_abstract_classes = 1
    And analizo must report that the project has total_methods_per_abstract_class = <total_mpac>
    Examples:
      | language | total_mpac |
      | java     | 6          |
      | csharp   | 1          |

  Scenario: "AbstractClass" project
    Given I am in t/samples/abstract_class/<language>
    When I run "analizo metrics --extractor Pyan ."
    Then analizo must report that the project has total_abstract_classes = 1
    And analizo must report that the project has total_methods_per_abstract_class = <total_mpac>
    Examples:
      | language | total_mpac |
      | python   | 1          |

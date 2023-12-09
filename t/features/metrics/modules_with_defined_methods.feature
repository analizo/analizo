Feature: number of abstract classes
  As a software developer
  I want analizo to report the number of modules with at least a defined method in my code
  So that I can evaluate it

  Scenario: "Hello, world" project
    Given I am in t/samples/hello_world/<language>
    When I run "analizo metrics ."
    Then analizo must report that the project has total_modules_with_defined_methods = 2
    Examples:
      | language |
      | cpp      |
      | java     |
      | csharp   |

  Scenario: "Animals" project
    Given I am in t/samples/animals/<language>
    When I run "analizo metrics ."
    Then analizo must report that the project has total_modules_with_defined_methods = 5
    Examples:
      | language |
      | cpp      |
      | java     |
      | csharp   |

  Scenario: "Hello, world" project in Python 
    Given I am in t/samples/hello_world/python
    When I run "analizo metrics --extractor Pyan ."
    Then analizo must report that the project has total_modules_with_defined_methods = 2
    

  Scenario: "Animals" project in Python 
    Given I am in t/samples/animals/python
    When I run "analizo metrics --extractor Pyan ."
    Then analizo must report that the project has total_modules_with_defined_methods = 5
    

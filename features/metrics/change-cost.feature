Feature: change cost degree
  As a software developer
  I want analizo to report the degree of change cost in my code
  So that I can evaluate it

  Scenario Outline: "Hello, world" project
    Given I am in t/samples/hello_world/<language>
    When I run "analizo metrics ."
    Then analizo must report that the project has change_cost = 0.75
  Examples:
    | language |
    | cpp      |
    | java     |

  Scenario Outline: "Animals" project
    Given I am in t/samples/animals/<language>
    When I run "analizo metrics ."
    Then analizo must report that the project has change_cost = 0.44
  Examples:
    | language |
    | cpp      |
    | java     |

  Scenario: "Hieracchical Graph" project
    Given I am in t/samples/hierarchical_graph
    When I run "analizo metrics ."
    Then analizo must report that the project has change_cost = 0.42

  Scenario: "Cyclical Graph" project
    Given I am in t/samples/cyclical_graph
    When I run "analizo metrics ."
    Then analizo must report that the project has change_cost = 0.5

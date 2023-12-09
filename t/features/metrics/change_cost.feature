Feature: change cost degree
  As a software developer
  I want analizo to report the degree of change cost in my code
  So that I can evaluate it

  Scenario: "Hello, world" project
    Given I am in t/samples/hello_world/<language>
    When I run "analizo metrics ."
    Then analizo must report that the project has change_cost = 0.75
    Examples:
      | language |
      | cpp      |
      | java     |
      | csharp   |

  Scenario: "Hello, world" project
    Given I am in t/samples/hello_world/<language>
    When I run "analizo metrics --extractor Pyan ."
    Then analizo must report that the project has change_cost = 0.75
    Examples:
      | language |
      | python   |

  Scenario: "Animals" project
    Given I am in t/samples/animals/<language>
    When I run "analizo metrics ."
    Then analizo must report that the project has change_cost = <change_cost>
    Examples:
      | language | change_cost |
      | cpp      | 0.44        |
      | java     | 0.44        |
      | csharp   | 0.44        |

  Scenario: "Animals" project
    Given I am in t/samples/animals/<language>
    When I run "analizo metrics --extractor Pyan ."
    Then analizo must report that the project has change_cost = <change_cost>
    Examples:
      | language | change_cost |
      | python   | 0.56        |

  Scenario: "Hieracchical Graph" project
    Given I am in t/samples/hierarchical_graph/<language>
    When I run "analizo metrics ."
    Then analizo must report that the project has change_cost = <change_cost>
    Examples:
      | language | change_cost |
      | c        | 0.42        |
      | csharp   | 0.28        |

  Scenario: "Hieracchical Graph" project
    Given I am in t/samples/hierarchical_graph/<language>
    When I run "analizo metrics --extractor Pyan ."
    Then analizo must report that the project has change_cost = <change_cost>
    Examples:
      | language | change_cost |
      | python   | 0.42        |

  Scenario: "Cyclical Graph" project
    Given I am in t/samples/cyclical_graph/<language>
    When I run "analizo metrics ."
    Then analizo must report that the project has change_cost = <change_cost>
    Examples:
      | language | change_cost |
      | c        | 0.5         |
      | csharp   | 0.36        |

  Scenario: "Cyclical Graph" project
    Given I am in t/samples/cyclical_graph/<language>
    When I run "analizo metrics --extractor Pyan ."
    Then analizo must report that the project has change_cost = <change_cost>
    Examples:
      | language | change_cost |
      | python   | 0.36        |

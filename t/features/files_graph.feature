Feature: dependency graph among files
  As a software engineering reasearcher
  I want to know the all relationships between all files on project
  So that I can run analizo files-graph to produces a DOT graph from source-code

  Scenario: relation between function call
    Given I am in t/samples/animals/<language>
    When I run "analizo files-graph ."
    Then analizo must report that "<referent>" depends on "<referenced>"
    Examples:
      | language | referent | referenced |
      | cpp      | main     | animal     |
      | java     | Main     | Animal     |
      | csharp   | Main     | Animal     |

  Scenario: relation between function call
    Given I am in t/samples/animals/<language>
    When I run "analizo files-graph --extractor Pyan ."
    Then analizo must report that "<referent>" depends on "<referenced>"
    Examples:
      | language | referent | referenced |
      | python   | main     | cat     |
      | python   | main     | dog     |

  Scenario: relation between inheritance
    Given I am in t/samples/animals/<language>
    When I run "analizo files-graph ."
    Then analizo must report that "<referent>" depends on "<referenced>"
    Examples:
      | language | referent | referenced |
      | cpp      | dog      | mammal     |
      | java     | Dog      | Mammal     |
      | csharp   | Dog      | Mammal     |
      | cpp      | mammal   | animal     |
      | java     | Mammal   | Animal     |
      | csharp   | Mammal   | Animal     |

  Scenario: relation between inheritance
    Given I am in t/samples/animals/<language>
    When I run "analizo files-graph --extractor Pyan ."
    Then analizo must report that "<referent>" depends on "<referenced>"
    Examples:
      | language | referent | referenced |
      | python   | dog      | mammal     |
      | python   | mammal   | animal     |

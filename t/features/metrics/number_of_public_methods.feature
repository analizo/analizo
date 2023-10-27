Feature: number of public methods metric
  As a software developer
  I want to calculate the number of public methods per module metric
  So that I can evaluate my code

  Scenario: number of public methods in the "Animals" project
    Given I am in t/samples/<sample>/<language>
    When I run "analizo metrics ."
    Then analizo must report that module <module> has npm = <npm>
    Examples:
      | sample   | language |  module    | npm  |
      | polygons | cpp      |  CPolygon  | 2    |
      | polygons | cpp      |  CTetragon | 1    |
      | polygons | java     |  Polygon   | 3    |
      | polygons | csharp   |  Polygon   | 2    |
      | animals  | cpp      |  Animal    | 1    |
      | animals  | cpp      |  Cat       | 2    |
      | animals  | cpp      |  Dog       | 2    |
      | animals  | java     |  Animal    | 1    |
      | animals  | java     |  Cat       | 2    |
      | animals  | java     |  Dog       | 2    |
      | animals  | csharp   |  Animal    | 1    |
      | animals  | csharp   |  Cat       | 2    |
      | animals  | csharp   |  Dog       | 2    |

  Scenario: number of public methods in Python projects
    Given I am in t/samples/<sample>/python
    When I run "analizo metrics --extractor Pyan ."
    Then analizo must report that module <module> has npm = <npm>
    Examples:
      | sample   |  module             | npm  |
      | polygons |  polygon::Polygon   | 2    |
      | polygons |  tetragon::Tetragon | 1    |
      | animals  |  animal::Animal     | 1    |
      | animals  |  cat::Cat           | 2    |
      | animals  |  dog::Dog           | 2    |

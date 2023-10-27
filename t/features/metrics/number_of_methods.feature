Feature: number of methods
  As a software developer
  I want analizo to report the number of methods of each module
  So that I can evaluate it

  Scenario: number of methods of the polygon java sample
    Given I am in t/samples/<sample>/<language>
    When I run "analizo metrics ."
    Then analizo must report that module <module> has nom = <nom>
    Examples:
      | sample   | language |  module    | nom  |
      | polygons | cpp      |  CPolygon  | 3    |
      | polygons | cpp      |  CTetragon | 2    |
      | polygons | java     |  Polygon   | 3    |
      | polygons | csharp   |  Polygon   | 2    |
      | polygons | csharp   |  Tetragon  | 2    |
      | animals  | cpp      |  Animal    | 1    |
      | animals  | cpp      |  Cat       | 2    |
      | animals  | cpp      |  Dog       | 2    |
      | animals  | java     |  Animal    | 1    |
      | animals  | java     |  Cat       | 2    |
      | animals  | java     |  Dog       | 2    |
      | animals  | csharp   |  Animal    | 1    |
      | animals  | csharp   |  Cat       | 2    |
      | animals  | csharp   |  Dog       | 2    |

  Scenario: number of methods in Python samples
    Given I am in t/samples/<sample>/python
    When I run "analizo metrics --extractor Pyan ."
    Then analizo must report that module <module> has nom = <nom>
    Examples:
      | sample   |  module             | nom  |
      | polygons |  polygon::Polygon   | 2    |
      | polygons |  tetragon::Tetragon | 1    |
      | animals  |  animal::Animal     | 1    |
      | animals  |  cat::Cat           | 2    |
      | animals  |  dog::Dog           | 2    |
      
    
  Scenario: not computes macro on C code as method definition
    Given I am in t/samples/macro
    When I run "analizo metrics ."
    Then analizo must report that module using_macro has nom = 1

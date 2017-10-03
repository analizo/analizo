Feature: number of methods
  As a software developer
  I want analizo to report the number of methods of each module
  So that I can evaluate it

  Scenario: number of methods of the polygon java sample
    Given I am in t/samples/<sample>/<language>
    When I run "analizo metrics -a ."
    Then analizo must report that module <module> has nom = <nom>
    Examples:
      | sample   | language |  module    | nom  |
      | polygons | cpp      |  CPolygon  | 3    |
      | polygons | cpp      |  CTetragon | 2    |
      | polygons | java     |  Polygon   | 3    |
      | animals  | cpp      |  Animal    | 1    |
      | animals  | cpp      |  Cat       | 2    |
      | animals  | cpp      |  Dog       | 2    |
      | animals  | java     |  Animal    | 1    |
      | animals  | java     |  Cat       | 2    |
      | animals  | java     |  Dog       | 2    |


Feature: number of methods
  As a software developer
  I want analizo to report the number of methods of each module
  So that I can evaluate it

  Scenario Outline: number of methods of the polygon java sample
    Given I am in t/samples/polygons/java
    When I run "analizo metrics ."
    Then analizo must report that module <module> has nom = <nom>
  Examples:
    | module  | nom |
    | Polygon |  3  |


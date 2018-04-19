Feature: analizing projects with enumerations
  As a software developer
  I want analizo to correctly analize projects with enumerations
  So that I can evaluate it

  Scenario: "Enumeration" project modules
    Given I am in t/samples/enumeration/<language>
    When I run "analizo metrics ."
    Then analizo must report that the project has total_modules = <total_modules>
    And analizo must report that file Enumeration.java declares module Enumeration
    And analizo must report that file Main.java declares module Main::MyEnumeration
    Examples:
      | language | total_modules |
      | java     | 3             |


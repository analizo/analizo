Feature: analizing projects with enumerations
  As a software developer
  I want analizo to correctly analize projects with enumerations
  So that I can evaluate it

  Scenario: "Enumeration" project modules count
    Given I am in t/samples/enumeration/<language>
    When I run "analizo metrics ."
    Then analizo must report that the project has total_modules = <total_modules>
    And analizo must report that file Enumeration.java declares module Enumeration
    And analizo must report that file Main.java declares module Main::MyEnumeration
    Examples:
      | language | total_modules |
      | java     | 3             |

  Scenario: "Enumeration" project modules names
    Given I am in t/samples/enumeration/<language>
    When I run "analizo metrics ."
    Then analizo must report that file <filename> declares module <wildcard_class>
      | language | filename           | enumeration_modules  |
      | java     | Main.java          | Main                 |
      | java     | Main.java          | Main::MyEnumeration  |
      | java     | Enumeration.java   | Enumeration          |

  Scenario: "Enumeration" project, Main module metrics
    Given I am in t/samples/enumeration/<language>
    When I run "analizo metrics ."
    Then analizo must report that the module <main_module> has accm = 0
    And analizo must report that the module <main_module> has accm = 2
    And analizo must report that the module <main_module> has amloc = 8
    And analizo must report that the module <main_module> has anpm = 1
    And analizo must report that the module <main_module> has cbo = 1
    And analizo must report that the module <main_module> has lcom4 = 1
    And analizo must report that the module <main_module> has loc = 8
    And analizo must report that the module <main_module> has mmloc = '8'
    And analizo must report that the module <main_module> has nom = 1
    And analizo must report that the module <main_module> has npm = 1
    And analizo must report that the module <main_module> has rfc = 2
    And analizo must report that the module <main_module> has sc = 1
    Examples:
      | language | main_module |
      | java     | Main        |

  Scenario: "Enumeration" project, Main::MyEnumeration module metrics
    Given I am in t/samples/enumeration/<language>
    When I run "analizo metrics ."
    Then analizo must report that the module <main_enum_module> has acc = 1
    And analizo must report that the module <main_enum_module> has noa = 4
    And analizo must report that the module <main_enum_module> has npa = 4
    Examples:
      | language | main_enum_module    |
      | java     | Main::MyEnumeration |

  Scenario: "Enumeration" project, Enumeration module metrics
    Given I am in t/samples/enumeration/<language>
    When I run "analizo metrics ."
    And analizo must report that the module <enum_module> has noa = 4
    And analizo must report that the module <enum_module> has npa = 4
    Examples:
      | language | enum_module |
      | java     | Enumeration |

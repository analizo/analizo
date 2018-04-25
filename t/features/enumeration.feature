Feature: analizing projects with enumerations
  As a software developer
  I want analizo to correctly analize projects with enumerations
  So that I can evaluate it

  Scenario: "Enumeration" project modules count
    Given I am in t/samples/enumeration/<language>
    When I run "analizo metrics ."
    Then analizo must report that the project has total_modules = <total_modules>
    Examples:
      | language | total_modules |
      | java     | 3             |

  Scenario: "Enumeration" project modules names
    Given I am in t/samples/enumeration/<language>
    When I run "analizo metrics ."
    Then analizo must report that file <filename> declares module <enumeration_modules>
    Examples:
      | language | filename         | enumeration_modules |
      | java     | Main.java        | Main                |
      | java     | Main.java        | Main::MyEnumeration |
      | java     | Enumeration.java | Enumeration         |

  Scenario: "Enumeration" module metrics
    Given I am in t/samples/enumeration/<language>
    When I run "analizo metrics ."
    Then analizo must report that module <module> has <metric> = <value>
    Examples:
      | language | module              | metric | value |
      | java     | Main                | loc    | 8     |
      | java     | Main                | mmloc  | 8     |
      | java     | Main                | nom    | 1     |
      | java     | Main                | npm    | 1     |
      | java     | Main                | rfc    | 2     |
      | java     | Main                | sc     | 1     |
      | java     | Main::MyEnumeration | acc    | 1     |
      | java     | Main::MyEnumeration | noa    | 4     |
      | java     | Main::MyEnumeration | npa    | 4     |
      | java     | Enumeration         | noa    | 4     |
      | java     | Enumeration         | npa    | 4     |

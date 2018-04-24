
Feature: analizing projects with WildCard
    As a software developer
    I want analizo to correctly analize projects with WildCard
    So that I can evaluate it

    Scenario: "WildCard" project metrics number of modules
        Given I am in t/samples/wildcard/<language>
        When I run "analizo metrics ."
        Then analizo must report that the project has total_modules = <total_modules>
        Examples:
            | language | total_modules |
            | java     | 2             |

    Scenario: "WildCard" project metrics modules name
        Given I am in t/samples/wildcard/<language>
        When I run "analizo metrics ."
        Then analizo must report that file <filename> declares module <wildcard_class>
        Examples:
            | language | filename              | wildcard_class |
            | java     | Wildcard_test.java    | Wildcard_sample |
            | java     | Wildcard_test.java    | GenericClass |

    Scenario: "WildCard" project metrics
        Given I am in t/samples/wildcard/<language>
        When I run "analizo metrics ."
        Then analizo must report that module <module> has <metric> = <value>
        Examples:
        | language | module              | metric   | value |
        | java     | Wildcard_sample     | acc      | 1     |
        | java     | Wildcard_sample     | accm     | 1     |
        | java     | Wildcard_sample     | amloc    | 4     |
        | java     | Wildcard_sample     | cbo      | 1     |
        | java     | Wildcard_sample     | lcom4    | 1     |
        | java     | Wildcard_sample     | loc      | 4     |
        | java     | Wildcard_sample     | mmloc    | 4     |
        | java     | Wildcard_sample     | nom      | 1     |
        | java     | Wildcard_sample     | npm      | 1     |
        | java     | Wildcard_sample     | rfc      | 2     |
        | java     | Wildcard_sample     | sc       | 1     |
        | java     | GenericClass        | acc      | 1     |
        | java     | GenericClass        | acc      | 1     |
        | java     | GenericClass        | accm     | 1     |
        | java     | GenericClass        | amloc    | 3     |
        | java     | GenericClass        | lcom4    | 1     |
        | java     | GenericClass        | loc      | 3     |
        | java     | GenericClass        | mmloc    | 3     |
        | java     | GenericClass        | nom      | 1     |
        | java     | GenericClass        | npm      | 1     |
        | java     | GenericClass        | rfc      | 1     |

    Scenario: "WildCard" project metrics must fail
        Given I am in t/samples/wildcard/<language>
        When I run "analizo metrics ."
        Then analizo must report that module <module> has not <metric> = <value>
        Examples:
        | language | module              | metric   | value |
        | java     | Wildcard_sample     | accm     | 0     |
        | java     | Wildcard_sample     | accm     | 0     |
        | java     | Wildcard_sample     | amloc    | 0     |
        | java     | Wildcard_sample     | cbo      | 0     |
        | java     | Wildcard_sample     | lcom4    | 0     |
        | java     | Wildcard_sample     | loc      | 0     |
        | java     | Wildcard_sample     | mmloc    | 0     |
        | java     | Wildcard_sample     | nom      | 0     |
        | java     | Wildcard_sample     | npm      | 0     |
        | java     | Wildcard_sample     | rfc      | 0     |
        | java     | Wildcard_sample     | sc       | 0     |
        | java     | GenericClass        | acc      | 0     |
        | java     | GenericClass        | acc      | 0     |
        | java     | GenericClass        | accm     | 0     |
        | java     | GenericClass        | amloc    | 0     |
        | java     | GenericClass        | lcom4    | 0     |
        | java     | GenericClass        | loc      | 0     |
        | java     | GenericClass        | mmloc    | 0     |
        | java     | GenericClass        | nom      | 0     |
        | java     | GenericClass        | npm      | 0     |
        | java     | GenericClass        | rfc      | 0     |
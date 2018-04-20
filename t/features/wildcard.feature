Feature: analizing projects with WildCard
    As a software developer
    I want analizo to correctly analize projects with WildCard
    So that I can evaluate it

    Scenario: "WildCard" project modules
        Given I am in t/samples/wildcard/<language>
        When I run "analizo metrics ."
        Then analizo must report that the project has total_modules = <total_modules>
        Examples:
            | language | total_modules |
            | java     | 2             |

    Scenario: "WildCard" project metrics
        Given I am in t/samples/wildcard/<language>
        When I run "analizo metrics ."
        Then analizo must report that file <filename> declares module <wildcard_class>
        Examples:
            | language | filename              | wildcard_class |
            | java     | Wildcard_test.java    | Wildcard_sample |
            | java     | Wildcard_test.java    | GenericClass |

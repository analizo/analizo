Feature: group by modules
  Scenario: sample project
    Given I am in t/sample/
    When I run "egypt graph --modules ."
    Then egypt must report that "module1" depends on "module2"
    Then egypt must report that "module1" depends on "module3"

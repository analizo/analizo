Feature: group by modules
  Scenario: sample project
    Given I am in t/samples/sample_basic/c/
    When I run "analizo graph --modules ."
    Then analizo must report that "module1" depends on "module2"
    Then analizo must report that "module1" depends on "module3"

  Scenario: sample project
    Given I am in t/samples/sample_basic/python/
    When I run "analizo graph --extractor Pyan --modules ."
    Then analizo must report that "module1" depends on "module2"
    Then analizo must report that "module1" depends on "module3"
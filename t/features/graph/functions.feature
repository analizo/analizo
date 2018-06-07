Feature: functions calls

  Scenario: detect function calls among classes
    Given I am in t/samples/animals/cpp
    When I run "analizo graph ."
    Then analizo must report that "Cat::Cat(char *)" depends on "Cat::_name"
    And analizo must not report that "Cat::Cat(char *)" depends on "Cat::name()"
    And the exit status must be 0

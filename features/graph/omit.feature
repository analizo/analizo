Feature: omitting certain modules
  Scenario: omitting say_bye
    Given I am in t/sample/
    When I run "analizo graph --omit module2::say_bye ."
    Then the output must not match "module2::say_bye"

  Scenario: omitting two functions
    Given I am in t/sample/
    When I run "analizo graph --omit module2::say_bye,module2::say_hello ."
    Then the output must not match "module2::say_bye"
    Then the output must not match "module2::say_hello"

  Scenario: omitting depending functions
    Given I am in t/sample/
    When I run "analizo graph --omit module1::main ."
    Then the output must not match "module1::main"

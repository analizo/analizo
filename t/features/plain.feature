  Scenario: simply running egypt
    Given I am in t/sample/
    When I run "egypt ."
    Then egypt must report that "module1::main" depends on "module3::variable"
    Then egypt must report that "module1::main" depends on "module3::callback"
    Then egypt must report that "module1::main" depends on "module2::say_bye"
    Then egypt must report that "module1::main" depends on "module2::say_hello"
    And the exit status must be 0

  Scenario: simply running analizo
    Given I am in t/sample/
    When I run "analizo graph ."
    Then analizo must report that "module1::main()" depends on "module3::variable"
    Then analizo must report that "module1::main()" depends on "module3::callback()"
    Then analizo must report that "module1::main()" depends on "module2::say_bye()"
    Then analizo must report that "module1::main()" depends on "module2::say_hello()"
    And the exit status must be 0


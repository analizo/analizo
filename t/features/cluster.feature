  Scenario: clustering dependencies
    Given I am in t/sample/
    When I run "egypt-graph --cluster ."
    Then egypt must report that "module1::main" is part of "module1"
    Then egypt must report that "module2::say_hello" is part of "module2"
    Then egypt must report that "module2::say_bye" is part of "module2"
    Then egypt must report that "module3::variable" is part of "module3"
    Then egypt must report that "module3::callback" is part of "module3"

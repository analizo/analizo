#FIXME: The current version of Graph::Writer::Dot doesn't generate a list of
#		subgraphs
#		(sended pull request: https://github.com/neilbowers/Graph-ReadWrite/pull/1)
#
#Feature: clustering subroutines in the same module together
#
#  Scenario: clustering dependencies
#    Given I am in t/samples/sample_basic/
#    When I run "analizo graph --cluster ."
#    Then analizo must report that "module1::main()" is part of "module1"
#    Then analizo must report that "module2::say_hello()" is part of "module2"
#    Then analizo must report that "module2::say_bye()" is part of "module2"
#    Then analizo must report that "module3::variable" is part of "module3"
#    Then analizo must report that "module3::callback()" is part of "module3"


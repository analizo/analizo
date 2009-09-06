Feature: multi-language support
  As a Researcher or Practioneer
  I want to be able to analyze software in different languages
  In order do compare them

  Scenario Outline: dependency between modules
    Given I am in samples/hello_world/<language>
    When I run "egypt graph --modules ."
    Then egypt must report that "<main_module>" depends on "<hello_world_module>"
  Examples:
    | language | main_module | hello_world_module |
    | c        | main        | hello_world        |
    | c++      | main        | HelloWorld         |
    | java     | Main        | HelloWorld         |

  Scenario Outline: dependency between specific functions
    Given I am in samples/hello_world/<language>
    When I run "egypt graph ."
    Then egypt must report that "<main_function>" depends on "<hello_say>"
    And  egypt must report that "<main_function>" depends on "<hello_destroy>"
  Examples:
    | language | main_function | hello_say                    | hello_destroy                    |
    | c        | main::main    | hello_world::hello_world_say | hello_world::hello_world_destroy |
    | c++      | main::main    | HelloWorld::say              | HelloWorld::destroy              |
    | java     | Main::main    | HelloWorld::say              | HelloWorld::destroy              |

  Scenario Outline: intra-module dependencies
    Given I am in samples/hello_world/<language>
    When I run "egypt graph ."
    Then egypt must report that "<hello_say>" depends on "<hello_id>"
    And  egypt must report that "<hello_destroy>" depends on "<hello_id>"
  Examples:
    | language | hello_say       | hello_destroy       | hello_id        |
    | c        | hello_world::hello_world_say | hello_world::hello_world_destroy | _hello_world::id |
    | c++      | HelloWorld::say | HelloWorld::destroy | HelloWorld::_id |
    | java     | HelloWorld::say | HelloWorld::destroy | HelloWorld::_id |

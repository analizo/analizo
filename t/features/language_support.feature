Feature: multi-language support
  As a Researcher or Practioneer
  I want to be able to analyze software in different languages
  In order do compare them

  Scenario: dependency between modules
    Given I am in t/samples/hello_world/<language>
    When I run "analizo graph --modules ."
    Then analizo must report that "<main_module>" depends on "<hello_world_module>"
    Examples:
      | language | main_module | hello_world_module |
      | c        | main        | hello_world        |
      | cpp      | main        | HelloWorld         |
      | java     | Main        | HelloWorld         |

  Scenario: dependency between specific functions
    Given I am in t/samples/hello_world/<language>
    When I run "analizo graph ."
    Then analizo must report that "<main_function>" depends on "<hello_say>"
    And analizo must report that "<main_function>" depends on "<hello_destroy>"
    Examples:
      | language | main_function         | hello_say                                   | hello_destroy                                   |
      | c        | main::main()          | hello_world::hello_world_say(hello_world *) | hello_world::hello_world_destroy(hello_world *) |
      | cpp      | main::main()          | HelloWorld::say()                           | HelloWorld::destroy()                           |
      | java     | Main::main(String []) | HelloWorld::say()                           | HelloWorld::destroy()                           |

  Scenario: intra-module dependencies
    Given I am in t/samples/hello_world/<language>
    When I run "analizo graph ."
    Then analizo must report that "<hello_say>" depends on "<hello_id>"
    And analizo must report that "<hello_destroy>" depends on "<hello_id>"
    Examples:
      | language | hello_say                                   | hello_destroy                                   | hello_id                      |
      | c        | hello_world::hello_world_say(hello_world *) | hello_world::hello_world_destroy(hello_world *) | hello_world::_hello_world::id |
      | cpp      | HelloWorld::say()                           | HelloWorld::destroy()                           | HelloWorld::_id               |
      | java     | HelloWorld::say()                           | HelloWorld::destroy()                           | HelloWorld::_id               |

  Scenario: some metrics
    Given I am in t/samples/hello_world/<language>
    When I run "analizo metrics -a ."
    Then analizo must report that the project has total_modules = 2
    And analizo must report that module <main_module> has nom = 1
    And analizo must report that module <hello_world_module> has npm = 3
    And analizo must report that module <hello_world_module> has nom = <total_methods>
    And analizo must report that module <hello_world_module> has npa = <public_attributes>
    Examples:
      | language | main_module | hello_world_module | total_methods   | public_attributes |
      | c        | main        | hello_world        | 3               | 2                 |
      | cpp      | main        | HelloWorld         | 4               | 1                 |
      | java     | Main        | HelloWorld         | 4               | 1                 |

  Scenario: inheritance data
    Given I am in t/samples/animals/<language>
    When I run "analizo graph --modules ."
    Then analizo must report that "Cat" depends on "Mammal"
    And analizo must report that "Dog" depends on "Mammal"
    And analizo must report that "Mammal" depends on "Animal"
    When I run "analizo metrics -a ."
    Then analizo must report that module Cat has dit = 2
    And analizo must report that module Dog has dit = 2
    And analizo must report that module Mammal has dit = 1
    And analizo must report that module Animal has dit = 0
    Examples:
      | language |
      | cpp      |
      | java     |

  # TODO doxyparse 1.8.11 doesn't detect dependencies between classes defined
  #      in same file, disabling this test for now in order to release a new analizo
  #      version, but we need to investigate and solve this problem, issue
  #      registered:
  #      https://github.com/analizo/analizo/issues/83
  #
  #Scenario: argument versus instance variable
  #  Given I am in t/samples/printer/<language>
  #  When I run "analizo graph ."
  #  Then analizo must report that "Printer1::Printer1(<msg_type>)" depends on "Printer1::message"
  #  And analizo must report that "Printer2::Printer2(<msg_type>)" depends on "Printer2::message"
  #  Examples:
  #    | language | msg_type |
  #    | cpp      | string       |
  #    | java     | String       |

  # not sure what to expect in this case
  Scenario: mixed Java and C
    Given I am in t/samples/mixed
    When I run "analizo metrics -a ."
    Then the output must match "_module: native_backend"
    And the output must match "_module: UI"
    And the output must match "_module: Backend"


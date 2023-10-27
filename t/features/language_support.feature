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
      | csharp   | main        | HelloWorld         |

  Scenario: dependency between modules in Python
    Given I am in t/samples/hello_world/python
    When I run "analizo graph --extractor Pyan --modules ."
    Then analizo must report that "main" depends on "hello_world::HelloWorld"
 

  Scenario: dependency between specific functions
    Given I am in t/samples/hello_world/<language>
    When I run "analizo graph ."
    Then analizo must report that "<main_function>" depends on "<hello_say>"
    And analizo must report that "<main_function>" depends on "<hello_destroy>"
    Examples:
      | language | main_function         | hello_say                                   | hello_destroy                                   |
      | c        | main::main()          | hello_world::hello_world_say(hello_world *) | hello_world::hello_world_destroy(hello_world *) |
      | cpp      | main::main()          | HelloWorld::say()                           | HelloWorld::destroy()                           |
      | java     | Main::main(String[])  | HelloWorld::say()                           | HelloWorld::destroy()                           |
      | csharp   | main::Main()          | HelloWorld::say()                           | HelloWorld::destroy()                           |


  Scenario: dependency between specific functions in Python
    Given I am in t/samples/hello_world/python
    When I run "analizo graph --extractor Pyan ."
    Then analizo must report that "main::main" depends on "hello_world::HelloWorld::say"
    And analizo must report that "main::main" depends on "hello_world::HelloWorld::destroy"
    

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
      | csharp   | HelloWorld::say()                           | HelloWorld::destroy()                           | HelloWorld::_id               |

  Scenario: intra-module dependencies in Python
  Given I am in t/samples/hello_world/python
  When I run "analizo graph --extractor Pyan ."
  Then analizo must report that "hello_world::HelloWorld::say" depends on "hello_world::HelloWorld::__id"
  And analizo must report that "hello_world::HelloWorld::destroy" depends on "hello_world::HelloWorld::__id"

  Scenario: some metrics
    Given I am in t/samples/hello_world/<language>
    When I run "analizo metrics ."
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
      | csharp   | main        | HelloWorld         | 4               | 1                 |


  Scenario: some metrics in Python
    Given I am in t/samples/hello_world/python
    When I run "analizo metrics --extractor Pyan ."
    Then analizo must report that the project has total_modules = 3
    And analizo must report that module main has nom = 1
    And analizo must report that module hello_world::HelloWorld has npm = 3
    And analizo must report that module hello_world::HelloWorld has nom = 4
    And analizo must report that module hello_world::HelloWorld has npa = 1

  Scenario: inheritance data
    Given I am in t/samples/animals/<language>
    When I run "analizo graph --modules ."
    Then analizo must report that "Cat" depends on "Mammal"
    And analizo must report that "Dog" depends on "Mammal"
    And analizo must report that "Mammal" depends on "Animal"
    When I run "analizo metrics ."
    Then analizo must report that module Cat has dit = 2
    And analizo must report that module Dog has dit = 2
    And analizo must report that module Mammal has dit = 1
    And analizo must report that module Animal has dit = 0
    Examples:
      | language |
      | cpp      |
      | java     |
  
  Scenario: inheritance data in Python
    Given I am in t/samples/animals/python
    When I run "analizo graph --extractor Pyan --modules ."
    Then analizo must report that "cat::Cat" depends on "mammal::Mammal"
    And analizo must report that "dog::Dog" depends on "mammal::Mammal"
    And analizo must report that "mammal::Mammal" depends on "animal::Animal"
    When I run "analizo metrics --extractor Pyan ."
    Then analizo must report that module cat::Cat has dit = 2
    And analizo must report that module dog::Dog has dit = 2
    And analizo must report that module mammal::Mammal has dit = 1
    And analizo must report that module animal::Animal has dit = 0

  # not sure what to expect in this case
  Scenario: mixed Java and C
    Given I am in t/samples/mixed
    When I run "analizo metrics ."
    Then the output must match "_module: native_backend"
    And the output must match "_module: UI"
    And the output must match "_module: Backend"


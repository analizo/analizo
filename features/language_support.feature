Feature: multi-language support
  As a Researcher or Practioneer
  I want to be able to analyze software in different languages
  In order do compare them

  Scenario Outline: "Hello, world!" implemented in several languages
    Given I am in samples/hello_world/<language>
    When I run "egypt graph --modules ."
    Then egypt must report that "<main_module>" depends on "<hello_world_module>"
  Examples:
    | language | main_module | hello_world_module |
    | c        | main        | hello_world        |
    | c++      | main        | HelloWorld         |
    | java     | Main        | HelloWorld         |



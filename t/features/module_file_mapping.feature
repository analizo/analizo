Feature: mapping modules to filenames
  As a software engineering resesearcher
  I want to know in which file each module is declared
  So that I can compare that with data from the VCS

  Scenario: C++, runing against some directory
    When I run "analizo metrics t/samples/animals/cpp"
    Then analizo must report that file animal.h declares module Animal
    And analizo must report that file cat.cc declares module Cat
    And analizo must report that file cat.h declares module Cat
    And analizo must report that file cat.cc not declares module Dog
    And analizo must report that file cat.h not declares module Dog

  Scenario: C++, running against current directory
    Given I am in t/samples/animals/cpp
    When I run "analizo metrics ."
    Then analizo must report that file animal.h declares module Animal
    And analizo must report that file cat.cc declares module Cat
    And analizo must report that file cat.h declares module Cat

  Scenario: Java
    When I run "analizo metrics t/samples/animals/java"
    Then analizo must report that file Animal.java declares module Animal

  Scenario: C
    Given I am in t/samples/hello_world/c
    When I run "analizo metrics ."
    Then analizo must report that file hello_world.c declares module hello_world
    Then analizo must report that file hello_world.h declares module hello_world

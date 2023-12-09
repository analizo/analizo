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
    Then analizo must report that module hello_world has _filename = [hello_world.c,hello_world.h]
    And analizo must report that file hello_world.c declares module hello_world
    And analizo must report that file hello_world.h declares module hello_world

  Scenario: CSharp hello_world
    Given I am in t/samples/hello_world/csharp
    When I run "analizo metrics ."
    Then analizo must report that module HelloWorld has _filename = [HelloWorld.cs]

  Scenario: CSharp polygons
    Given I am in t/samples/polygons/csharp
    When I run "analizo metrics ."
    Then analizo must report that file Polygon.cs declares module Polygon
    And analizo must report that file Rect.cs declares module Rect
    And analizo must report that file Triangle.cs declares module Triangle

  Scenario: Java Generics WildCard sample
    Given I am in t/samples/wildcard
    When I run "analizo metrics ."
    Then analizo must report that file WildcardClass.java declares module WildcardClass
    And analizo must report that file GenericClass.java declares module GenericClass

  Scenario: Java Enumeration sample
    Given I am in t/samples/enumeration/java
    When I run "analizo metrics ."
    Then analizo must report that file Main.java declares module Main::MyEnumeration
    And analizo must report that file Enumeration.java declares module Enumeration

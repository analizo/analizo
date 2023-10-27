Feature: total modules
  As a software developer
  I want analizo to report the total number of modules in my code
  So that I can evaluate it

  Scenario: Java Enumeration sample
    Given I am in t/samples/enumeration/java
    When I run "analizo metrics ."
    Then analizo must report that the project has total_modules = 3

  Scenario: Python Enumeration sample
    Given I am in t/samples/enumeration/python
      When I run "analizo metrics --extractor Pyan ."
      Then analizo must report that the project has total_modules = 4

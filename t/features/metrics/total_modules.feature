Feature: total modules
  As a software developer
  I want analizo to report the total number of modules in my code
  So that I can evaluate it

  Scenario: Java Enumeration sample
    Given I am in t/samples/enumeration
    When I run "analizo metrics ."
    Then analizo must report that the project has total_modules = 3

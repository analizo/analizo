Feature: c code with void argument
  As a software engineering reasearcher
  I want to know the arguments of each function on a project
  So that I can run analizo metrics calculate number of parameters

  Scenario: calculate anpn on function with void argument
    Given I am in t/samples/void/
    When I run "analizo metrics ."
    Then analizo must report that module main has anpm = 0

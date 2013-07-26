Feature: fetch
  As a software engineering reasearcher
  I want to fetch project source-code from the repository
  So that I can analyze that project

  Scenario: fetch sample git project
    When I explode t/samples/tree-evolution.tar.gz
    And I run "analizo fetch Git file://. tree-evolution-fetched"
    Then the output lines must match "fetching... done"
    And the directory "tree-evolution-fetched" should exist

  Scenario: warn about unavailable driver
    When I run "analizo fetch NotValid file:///any any"
    Then analizo must emit a warning matching "Unavailable driver!"

  Scenario: list available drivers
    When I run "analizo fetch --drivers"
    Then the output lines must match "Available drivers:"
    And the output lines must match "Git"
    And the output lines must match "Subversion"

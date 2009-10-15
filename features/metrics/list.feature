Feature: list metrics
  As a Research or Practioner
  I want to extract metrics from source code
  So that I can learn, understand and evaluate it

  Scenario: listing metrics
    When I run "egypt metrics --list"
    Then egypt must present a list of metrics

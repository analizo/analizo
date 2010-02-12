Feature: output only global metrics
  As a researcher
  I want to ouput only the global metrics
  So that I can evaluate several projects at once

  Background:
    Given I am in t/sample/

  Scenario: simple case
    When I run "analizo metrics --global-only ."
    Then the output must match "cbo_average:"
    And the output must not match "_module:"

  Scenario: short version
    When I run "analizo metrics -g ."
    Then the output must match "cbo_average:"
    And the output must not match "_module:"

Feature: doxyparse extractor external tool
  As a Analizo developer
  I want to guarantee that doxyparse deal with any source code
  To provide reliability for Analizo users

  Scenario: don't die parsing MCLinker.cpp from android 5.1.11
    Given I am in t/samples/android-framework/android-5.1.11-r38
    When I run "analizo metrics ."
    Then the exit status must be 0

  Scenario: don't duplicate YAML keys parsing AudioTrackShared.cpp from android 5.1.11
    Given I am in t/samples/android-framework/android-5.1.11-r38
    When I run "analizo metrics ."
    Then analizo must not emit a warning matching "YAML_LOAD_WARN_DUPLICATE_KEY"

  Scenario: don't abort parsing mlpack 3.0.0
    Given I am in t/samples/mlpack-3.0.0
    When I run "analizo metrics ."
    Then analizo must not emit a warning matching "Aborted"
    And the exit status must be 0

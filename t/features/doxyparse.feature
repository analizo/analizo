Feature: doxyparse extractor external tool
  As a Analizo developer
  I want to guarantee that doxyparse deal with any source code
  To provide reliability for Analizo users

  Scenario: don't die parsing MCLinker.cpp from android 5.1.11
    Given I am in t/samples/android-framework/android-5.1.11-r38
    When I run "analizo metrics ."
    Then the exit status must be 0

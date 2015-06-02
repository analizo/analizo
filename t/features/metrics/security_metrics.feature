Feature: Security Metrics
  As a software developer
  I want to analyze the number of bugs in my project
  So that I can correct them

  Scenario: Verifying security metrics in output
	Given I am in .
    When I run "analizo metrics --extractor ClangStaticAnalyzer t/samples/clang_analyzer/"
    Then the exit status must be 0
    And the output must match "rogu: 1"
    And the output must match "pitfc: 1"
    And the output must match "dbz: 2"
    And the output must match "da: 1"
    And the output must match "mlk: 1"
    And the output must match "dnp: 1"
    And the output must match "auv: 1"
    And the output must match "rsva: 1"
    And the output must match "obaa: 1"
    And the output must match "uav: 1"
    And the output must match "bf: 1"
    And the output must match "df: 1"
    And the output must match "bd: 1"
    And the output must match "uaf: 1"
    And the output must match "osf: 3"
    And the output must match "ua: 1"
    And the output must match "fgbo: 1"
    And the output must match "dupv: 1"
    And the output must match "asom: 1"
    And the output must match "an: 1"
    And the output must match "saigv: 1"


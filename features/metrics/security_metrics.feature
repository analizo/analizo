Feature: Security Metrics
  As a software developer
  I want to analyze the number of bugs in my project
  So that I can correct them

  Scenario: Verifying divisions by zero in output
    Given I am in .
    When I run "analizo metrics --extractor ClangStaticAnalyzer t/samples/clang_analyzer/"
	Then the output must match "dbz"
    And the exit status must be 0

  Scenario: Verifying value of divisions by zero in output
    Given I am in .
    When I run "analizo metrics --extractor ClangStaticAnalyzer t/samples/clang_analyzer/dbz"
	Then the output must match "dbz: 2"
    And the exit status must be 0

  Scenario: Verifying dead assignment in output
    Given I am in .
    When I run "analizo metrics --extractor ClangStaticAnalyzer t/samples/clang_analyzer/"
	Then the output must match "da"
    And the exit status must be 0

  Scenario: Verifying value of dead assignment in output
    Given I am in .
    When I run "analizo metrics --extractor ClangStaticAnalyzer t/samples/clang_analyzer"
	Then the output must match "da: 1"
    And the exit status must be 0

  Scenario: Verifying memory leak in output
    Given I am in .
    When I run "analizo metrics --extractor ClangStaticAnalyzer t/samples/clang_analyzer/"
	Then the output must match "mlk"
    And the exit status must be 0

  Scenario: Verifying value of memory leak in output
    Given I am in .
    When I run "analizo metrics --extractor ClangStaticAnalyzer t/samples/clang_analyzer"
    Then the output must match "mlk: 1"
    And the exit status must be 0


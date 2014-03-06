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

  Scenario: Verifying dereference of null pointer in output
    Given I am in .
    When I run "analizo metrics --extractor ClangStaticAnalyzer t/samples/clang_analyzer/"
    Then the output must match "dnp"
    And the exit status must be 0

  Scenario: Verifying value of dereference of null pointer in output
    Given I am in .
    When I run "analizo metrics --extractor ClangStaticAnalyzer t/samples/clang_analyzer"
    Then the output must match "dnp: 1"
    And the exit status must be 0

  Scenario: Verifying assigned undefined value in output
    Given I am in .
    When I run "analizo metrics --extractor ClangStaticAnalyzer t/samples/clang_analyzer/"
    Then the output must match "auv"
    And the exit status must be 0

  Scenario: Verifying value of assigned undefined value in output
    Given I am in .
    When I run "analizo metrics --extractor ClangStaticAnalyzer t/samples/clang_analyzer"
    Then the output must match "auv: 1"
    And the exit status must be 0

  Scenario: Verifying return of stack variable address in output
    Given I am in .
    When I run "analizo metrics --extractor ClangStaticAnalyzer t/samples/clang_analyzer/"
    Then the output must match "rsva"
    And the exit status must be 0

  Scenario: Verifying value of return of stack variable address in output
    Given I am in .
    When I run "analizo metrics --extractor ClangStaticAnalyzer t/samples/clang_analyzer"
    Then the output must match "rsva: 1"
    And the exit status must be 0

  Scenario: Verifying out-of-bound array access in output
    Given I am in .
    When I run "analizo metrics --extractor ClangStaticAnalyzer t/samples/clang_analyzer/"
    Then the output must match "obaa"
    And the exit status must be 0

  Scenario: Verifying value of out-of-bound array access in output
    Given I am in .
    When I run "analizo metrics --extractor ClangStaticAnalyzer t/samples/clang_analyzer"
    Then the output must match "obaa: 1"
    And the exit status must be 0

  Scenario: Verifying uninitialized argument value in output
    Given I am in .
    When I run "analizo metrics --extractor ClangStaticAnalyzer t/samples/clang_analyzer/"
    Then the output must match "uav"
    And the exit status must be 0

  Scenario: Verifying value of uninitialized argument value in output
    Given I am in .
    When I run "analizo metrics --extractor ClangStaticAnalyzer t/samples/clang_analyzer"
    Then the output must match "uav: 1"
    And the exit status must be 0

  Scenario: Verifying bad free in output
    Given I am in .
    When I run "analizo metrics --extractor ClangStaticAnalyzer t/samples/clang_analyzer/"
    Then the output must match "bf"
    And the exit status must be 0

  Scenario: Verifying value of bad free in output
    Given I am in .
    When I run "analizo metrics --extractor ClangStaticAnalyzer t/samples/clang_analyzer"
    Then the output must match "bf: 1"
    And the exit status must be 0

  Scenario: Verifying double free in output
    Given I am in .
    When I run "analizo metrics --extractor ClangStaticAnalyzer t/samples/clang_analyzer/"
    Then the output must match "df"
    And the exit status must be 0

  Scenario: Verifying value of double free in output
    Given I am in .
    When I run "analizo metrics --extractor ClangStaticAnalyzer t/samples/clang_analyzer"
    Then the output must match "df: 1"
    And the exit status must be 0

  Scenario: Verifying bad deallocator in output
    Given I am in .
    When I run "analizo metrics --extractor ClangStaticAnalyzer t/samples/clang_analyzer/"
    Then the output must match "bd"
    And the exit status must be 0

  Scenario: Verifying value of bad deallocator in output
    Given I am in .
    When I run "analizo metrics --extractor ClangStaticAnalyzer t/samples/clang_analyzer"
    Then the output must match "bd: 1"
    And the exit status must be 0

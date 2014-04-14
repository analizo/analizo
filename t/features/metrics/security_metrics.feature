Feature: Security Metrics
  As a software developer
  I want to analyze the number of bugs in my project
  So that I can correct them

  Scenario: Verifying security metrics in output
	Given I am in .
    When I run "analizo metrics --extractor ClangStaticAnalyzer t/samples/clang_analyzer/"
    Then the output must match "<short_name_metric>: <value>"
    And the exit status must be 0
  Examples:
    | short_name_metric | value |
    | dbz               | 2     |
    | da                | 1     |
    | mlk               | 1     |
    | dnp               | 1     |
    | auv               | 1     |
    | rsva              | 1     |
    | obaa              | 1     |
    | uav               | 1     |
    | bf                | 1     |
    | df                | 1     |
    | bd                | 1     |
    | uaf               | 1     |
    | osf               | 3     |
    | ua                | 1     |
    | fgbo              | 1     |
    | dupv              | 1     |
    | asom              | 1     |
    | an                | 1     |
    | saigv             | 1     |


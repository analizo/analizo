Feature: metrics batch
  As a software engineering researcher
  I want to analyze several different projects
  So I can compare their metrics

  Scenario: "hello, world"
    Given I am in t/samples/hello_world
    When I run "analizo metrics-batch && rm -f metrics.csv"
    Then the output must match "I: Processing c ..."
    Then the output must match "I: Processing cpp ..."
    Then the output must match "I: Processing java ..."

  Scenario: summarizing
    Given I am in t/samples/hello_world
    When I run "analizo metrics-batch --quiet -o data.csv && cat data.csv && rm -f data.csv"
    Then the output must match "^id,"
    And the output must not match ",---,"
    And the output must match "^c,"
    And the output must match "^cpp,"
    And the output must match "^java,"
    And the output must not match "I: Processing"

  Scenario: support for parallel processing
    Given I copy t/samples/hello_world/* into a temporary directory
    And I run "analizo metrics-batch -q -o sequential.csv"
    And I run "analizo metrics-batch -q -o parallel.csv -p 2"
    And I run "sort sequential.csv > sequential-sorted.csv"
    And I run "sort parallel.csv > parallel-sorted.csv"
    When I run "diff -u sequential-sorted.csv parallel-sorted.csv"
    Then the output must not match "---"
    Then the exit status must be 0

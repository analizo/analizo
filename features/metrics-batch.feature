Feature: metrics batch
  As a software engineering researcher
  I want to analyze several different projects
  So I can compare their metrics

  Scenario: "hello, world"
    Given I copy t/samples/hello_world/* into a temporary directory
    When I run "analizo metrics-batch"
    Then the output must match "I: Processed c."
    Then the output must match "I: Processed cpp."
    Then the output must match "I: Processed java."

  Scenario: summarizing
    Given I copy t/samples/hello_world/* into a temporary directory
    When I run "analizo metrics-batch --quiet -o data.csv && cat data.csv && rm -f data.csv"
    Then the output must match "^id,"
    And the output must not match ",---,"
    And the output must match "^c,"
    And the output must match "^cpp,"
    And the output must match "^java,"
    And the output must not match "I: Processed"

  Scenario: support for parallel processing
    Given I copy t/samples/hello_world/* into a temporary directory
    And I run "analizo metrics-batch -q -o sequential.csv"
    And I run "analizo metrics-batch -q -o parallel.csv -p 2"
    And I run "sort sequential.csv > sequential-sorted.csv"
    And I run "sort parallel.csv > parallel-sorted.csv"
    When I run "diff -u sequential-sorted.csv parallel-sorted.csv"
    Then the output must not match "---"
    Then the exit status must be 0

  Scenario: CSV details files
    Given I copy t/samples/hello_world/* into a temporary directory
    When I run "analizo metrics-batch && ls -l"
		Then the output must match "c-details.csv"
		Then the output must match "cpp-details.csv"
		Then the output must match "java-details.csv"

  Scenario: CSV details file fields
    Given I copy t/samples/hello_world/* into a temporary directory
    When I run "analizo metrics-batch && cat cpp-details.csv"
		Then the output must match "filename,"
		And the output must match "module,"
		And the output must match "acc,"
		And the output must match "accm,"
		And the output must match "amloc,"
		And the output must match "anpm,"
		And the output must match "cbo,"
		And the output must match "dit,"
		And the output must match "lcom4,"
		And the output must match "loc,"
		And the output must match "mmloc,"
		And the output must match "noa,"
		And the output must match "noc,"
		And the output must match "nom,"
		And the output must match "npm,"
		And the output must match "npa,"
		And the output must match "rfc,"
		And the output must match "sc"

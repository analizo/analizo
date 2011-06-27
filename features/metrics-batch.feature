Feature: metrics batch
  As a software engineering researcher
  I want to analyze several different projects
  So I can compare their metrics

  Scenario: "hello, world"
    Given I copy t/samples/hello_world/* into a temporary directory
    When I run "analizo metrics-batch"
    Then the output must match "I: Processing c ..."
    Then the output must match "I: Processing cpp ..."
    Then the output must match "I: Processing java ..."

  Scenario: summarizing
    Given I am in t/samples/hello_world
    When I run "(analizo metrics-batch -s data.csv >/dev/null) && (cat data.csv && rm -f data.csv *.yml)"
    Then the output must match "^project,"
    Then the output must not match ",---,"

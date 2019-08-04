Feature: design structure matrix
  As a software engineering reasearcher
  I want to know the all relationships between all files on project
  So that I can run analizo dsm to produces DSM from source-code

  Scenario: write to "dsm.png" file by default
    Given I copy t/samples/sample_basic/c/ into a temporary directory
    When I run "analizo dsm ."
    Then the exit status must be 0
    And the file "dsm.png" should exist
    And the file "dsm.png" should have type image/png

  Scenario: write to "sample_basic.png"
    Given I copy t/samples/sample_basic/c/ into a temporary directory
    When I run "analizo dsm --output sample_basic.png ."
    Then the exit status must be 0
    And the file "sample_basic.png" should exist
    And the file "sample_basic.png" should have type image/png

  Scenario: HTML output
    Given I copy t/samples/sample_basic/c/ into a temporary directory
    When I run "analizo dsm --format html --output my-dsm.html ."
    Then the exit status must be 0
    And the file "my-dsm.html" should exist
    And the file "my-dsm.html" should have type text/html

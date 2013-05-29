Feature: design structure matrix
  As a software engineering reasearcher
  I want to know the all relationships between all files on project
  So that I can run analizo dsm to produces DSM from source-code

  Scenario: write to "dsm.png" file by default
    Given I am in t/samples/sample_basic/
    When I run "analizo dsm ."
    Then the exit status must be 0
    And the file "dsm.png" should exists

  Scenario: write to "sample_basic.png"
    Given I am in t/samples/sample_basic/
    When I run "analizo dsm --output sample_basic.png ."
    Then the exit status must be 0
    And the file "sample_basic.png" should exists

Feature: storing VCS data in a database
  As a software engineering researcher
  I want to store data about the changes in a project
  So that I can analyze the development process

  Scenario: basics
    When I explode t/samples/evolution.tar.gz
    And I run "analizo metrics-history -f db -o data.db"
    Then the exit status must be 0
    When I run "select * from modules" on database "data.db"
    Then the output must match "Input"
    And the output must match "Output"
    And the output must match "prog"

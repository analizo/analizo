Feature: analizo metrics-history
  As a software engineering researcher
  I want to analyse the entire history of a project
  To understand its development process

  Scenario: listing what commits should be analyzed
    When I explode t/samples/evolution.tar.gz
    And I run "analizo metrics-history --list ."
    Then the output must match "0a06a6fcc2e7b4fe56d134e89d74ad028bb122ed"
    # merge commit with code change:
    And the output must match "eb67c27055293e835049b58d7d73ce3664d3f90e"
    And the output must match "aa2d0fcb7879485d5ff1cd189743f91f04bea8ce"
    And the output must match "e8faf88f0e20a193d700b6c68eeb31897dd85e53"
    And the output must match "d7f52e74dc3d8f57640e83d41c5e9f8fcf621c00"
    And the output must match "0d3c023120ad4e9f519a03fff275d048c52671ad"
    # non-code commit:
    And the output must not match "ba62278e976944c0334103aa0044535169e1a51e"
    # merge commit without code change
    And the output must not match "0fdaaa7dcc8073332a957024fafc8c98f165e725"

  Scenario: actually processing
    When I explode t/samples/evolution.tar.gz
    And I run "analizo metrics-history --all -o metrics.csv . && cat metrics.csv"
    Then the output must match "^id,previous_commit_id,author_date,author_name,author_email,.*,sc_mean"
    And the output must match "0a06a6fcc2e7b4fe56d134e89d74ad028bb122ed,eb67c27055293e835049b58d7d73ce3664d3f90e"
    # merge commit:
    And the output must match "eb67c27055293e835049b58d7d73ce3664d3f90e,,"
    And the output must match "aa2d0fcb7879485d5ff1cd189743f91f04bea8ce,d7f52e74dc3d8f57640e83d41c5e9f8fcf621c00"
    And the output must match "e8faf88f0e20a193d700b6c68eeb31897dd85e53,d7f52e74dc3d8f57640e83d41c5e9f8fcf621c00"
    And the output must match "d7f52e74dc3d8f57640e83d41c5e9f8fcf621c00,0d3c023120ad4e9f519a03fff275d048c52671ad"
    # first commit:
    And the output must match "0d3c023120ad4e9f519a03fff275d048c52671ad,,"
    # first commit after a non-relevant merge:
    And the output must match "8183eafad3a0f3eff6e8869f1bdbfd255e86825a,0a06a6fcc2e7b4fe56d134e89d74ad028bb122ed"

  Scenario: support for parallel processing
    Given I copy t/samples/evolution.tar.gz into a temporary directory
    When I run "tar xzf evolution.tar.gz"
    And I run "cd evolution && analizo metrics-history -o ../sequential.csv"
    And I run "cd evolution && analizo metrics-history -p 2 -o ../parallel.csv"
    Then the exit status must be 0
    When I run "sort sequential.csv > sequential-sorted.csv"
    And I run "sort parallel.csv > parallel-sorted.csv"
    And I run "diff -u sequential-sorted.csv parallel-sorted.csv"
    Then the output must not match "---"
    And the exit status must be 0

  Scenario: language filters
    Given I copy t/samples/mixed into a temporary directory
    When I run "(cd mixed && git init && git add * && git commit -m 'initial commit')"
    And I run "analizo metrics-history --language java mixed"
    Then the output must not match "native_backend.c"

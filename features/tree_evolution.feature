Feature: tree evolution
  As a software engineering reasearcher
  I want to know what directories existed during the project lifetime
  So that I can analyze only the production code (and not tests etc)

  Scenario: sample git repository
    When I explode t/samples/tree-evolution.tar.gz
    And I run "analizo tree-evolution"
    Then the output lines must match "# 073290fbad0254793bd3ecfb97654c04368d0039\nsrc\n#"
    Then the output lines must match "# 85f7db08f7b7b0b62e3c0023b2743d529b0d5b4b\nsrc\nsrc/input\n#"
    Then the output lines must match "# f41cf7d0351e812285efd60c6d957c330b1f61a1\nsrc\nsrc/input\nsrc/output"

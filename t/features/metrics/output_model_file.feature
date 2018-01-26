Feature: output model file for metrics tool
    
  Scenario: ensuring that the file was created  
    Given I am in .
    When I run "analizo metrics --om name_file.txt t/samples/hello_world"
    Then the file "name_file.txt" must be created 

  Scenario: ensuring that 2 files was created  
    Given I am in .
    When I run "analizo metrics --om name_file.txt --output other_file.yml t/samples/hello_world"
    Then the output must match "name_file.txt" and "other_file.yml" 

  Scenario: passing output model file in not suported directory
    Given I am in .
    When I run "analizo metrics --om name_file.txt t/samples"
    Then the exit status must not be 0
    And analizo must emit a warning matching "Duplicate map key 'inherits' found. Ignoring."
      
  Scenario: passing model output file in the command line
    Given I am in .
    When I run "analizo metrics --om name_file.txt t/samples/hello_world"
    Then objects "my $flags = new Analizo::Flag::Flags" and "my $execute_metrics = new Analizo::Flag::ExecuteMetrics" were created
    Then the contents of "name_file.txt" must match "$execute_metrics->print_model_output"
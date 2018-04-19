Feature: sloccount extractor external tool
  As a Analizo developer
  I want to guarantee that sloccount deal with any source code
  To provide reliability for Analizo users

  Scenario: don't die parsing CSharp source-code
    Given I am in <sample>
    When I run "analizo metrics ."
    Then analizo must not emit a warning matching "Segmentation fault"
    And the exit status must be 0
    Examples:
      | sample                                  |
      | t/samples/sample_basic/csharp/          |
      | t/samples/abstract_class/csharp/        |
      | t/samples/animals/csharp/               |
      | t/samples/conditionals/csharp/          |
      | t/samples/cyclical_graph/csharp/        |
      | t/samples/file_with_two_modules/csharp/ |
      | t/samples/hello_world/csharp/           |
      | t/samples/mixed/                        |
      | t/samples/multidir/csharp/              |

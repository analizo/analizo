Feature: afferent connections with deep inheritance
  As a software developer
  I want analizo to report the afferent connections of each module
  So that I can evaluate it

  Scenario: afferent connections of the dog family java sample
    Given I am in t/samples/deep_inheritance/java
    When I run "analizo metrics ."
    Then analizo must report that module <module> has acc = <acc>
    Examples:
      | module                      | acc  |
      | Dog                         | 8    |
      | DogFirstGreatGrandson       | 1    |
      | DogFirstPuppy               | 4    |
      | DogGrandson                 | 3    |
      | DogSecondGreatGrandson      | 0    |
      | DogSecondPuppy              | 0    |
      | DogSuperYoung               | 0    |
      | Human                       | 2    |
      | ShopController              | 0    |
      | VenderShop                  | 1    |

  Scenario: afferent connections of the dog family java sample
    Given I am in t/samples/deep_inheritance/python
    When I run "analizo metrics --extractor Pyan ."
    Then analizo must report that module <module> has acc = <acc>
    Examples:
      | module                      | acc  |
      | Dog                         | 8    |
      | DogFirstGreatGrandson       | 1    |
      | DogFirstPuppy               | 4    |
      | DogGrandson                 | 3    |
      | DogSecondGreatGrandson      | 0    |
      | DogSecondPuppy              | 0    |
      | DogSuperYoung               | 0    |
      | Human                       | 2    |
      | ShopController              | 0    |
      | VenderShop                  | 1    |

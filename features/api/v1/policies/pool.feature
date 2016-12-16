@api/v1
Feature: Policy pool

  Background:
    Given the following "accounts" exist:
      | Name    | Slug  |
      | Test 1  | test1 |
      | Test 2  | test2 |
    And I send and accept JSON

  Scenario: Admin takes a key from a pool
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 1 "policy"
    And all "policies" have the following attributes:
      """
      { "usePool": true }
      """
    And the current account has 1 "key"
    And all "keys" have the following attributes:
      """
      {
        "policyId": "$policies[0]"
      }
      """
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/policies/$0/pool"
    Then the response status should be "200"
    And the JSON response should be a "key"

  Scenario: Admin attempts to take a key from an empty pool
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 1 "policy"
    And all "policies" have the following attributes:
      """
      { "usePool": true }
      """
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/policies/$0/pool"
    Then the response status should be "422"

  Scenario: Admin attempts to take a key from a policy that doesn't use a pool
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 1 "policy"
    And all "policies" have the following attributes:
      """
      { "usePool": false }
      """
    And the current account has 5 "keys"
    And all "keys" have the following attributes:
      """
      {
        "policyId": "$policies[0]"
      }
      """
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/policies/$0/pool"
    Then the response status should be "422"

  Scenario: Admin attempts to take a key from a pool for another account
    Given I am an admin of account "test2"
    And the current account is "test1"
    And the account "test1" has 1 "policy"
    And the account "test1" has 1 "key"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/policies/$0/pool"
    Then the response status should be "401"

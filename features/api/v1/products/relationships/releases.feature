@api/v1
Feature: Product releases relationship

  Background:
    Given the following "accounts" exist:
      | name    | slug  |
      | Test 1  | test1 |
      | Test 2  | test2 |
    And I send and accept JSON
    # TODO(ezekg) Remove after we switch new accounts to v1.1
    And I use API version "1.1"

  Scenario: Endpoint should be inaccessible when account is disabled
    Given the account "test1" is canceled
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 1 "product"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/products/$0/releases"
    Then the response status should be "403"

  Scenario: Admin retrieves the releases for a product
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 1 "product"
    And the current account has 3 "releases"
    And all "releases" have the following attributes:
      """
      { "productId": "$products[0]" }
      """
    And I use an authentication token
    When I send a GET request to "/accounts/test1/products/$0/releases"
    Then the response status should be "200"
    And the JSON response should be an array with 3 "releases"
    And the first "release" should have the following relationships:
      """
      {
        "artifacts": {
          "links": { "related": "/v1/accounts/$account/releases/$releases[2]/artifacts" }
        }
      }
      """

  Scenario: Admin retrieves the releases for a product (v1.1)
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 1 "product"
    And the current account has 3 "releases"
    And all "releases" have the following attributes:
      """
      { "productId": "$products[0]" }
      """
    And I use an authentication token
    And I use API version "1.1"
    When I send a GET request to "/accounts/test1/products/$0/releases"
    Then the response status should be "200"
    And the JSON response should be an array with 3 "releases"
    And the first "release" should have the following relationships:
      """
      {
        "artifacts": {
          "links": { "related": "/v1/accounts/$account/releases/$releases[2]/artifacts" }
        }
      }
      """

  Scenario: Admin retrieves the releases for a product (v1.0)
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 1 "product"
    And the current account has 3 "releases"
    And all "releases" have the following attributes:
      """
      { "productId": "$products[0]" }
      """
    And I use an authentication token
    And I use API version "1.0"
    When I send a GET request to "/accounts/test1/products/$0/releases"
    Then the response status should be "200"
    And the JSON response should be an array with 3 "releases"
    And the first "release" should have the following relationships:
      """
      {
        "artifact": {
          "links": { "related": "/v1/accounts/$account/releases/$releases[2]/artifact" },
          "data": null
        }
      }
      """

  Scenario: Product retrieves the releases for a product
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 3 "releases"
    And all "releases" have the following attributes:
      """
      { "productId": "$products[0]" }
      """
    And I am a product of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/products/$0/releases"
    Then the response status should be "200"
    And the JSON response should be an array with 3 "releases"

  Scenario: Admin retrieves a release for a product
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "release"
    And all "releases" have the following attributes:
      """
      { "productId": "$products[0]" }
      """
    And I use an authentication token
    When I send a GET request to "/accounts/test1/products/$0/releases/$0"
    Then the response status should be "200"
    And the JSON response should be a "release"

  Scenario: Product retrieves a release for a product
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "release"
    And all "releases" have the following attributes:
      """
      { "productId": "$products[0]" }
      """
    And I am a product of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/products/$0/releases/$0"
    Then the response status should be "200"
    And the JSON response should be a "release"

  Scenario: Product retrieves the releases of another product
    Given the current account is "test1"
    And the current account has 2 "products"
    And the current account has 1 "release"
    And all "releases" have the following attributes:
      """
      { "productId": "$products[1]" }
      """
    And I am a product of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/products/$1/releases"
    Then the response status should be "404"

  Scenario: License attempts to retrieve the releases for their product
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "policy" for the last "product"
    And the current account has 3 "licenses" for the last "policy"
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/products/$0/releases"
    Then the response status should be "200"

  Scenario: License attempts to retrieve the releases for a product
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "policy" for the last "product"
    And the current account has 1 "license"
    And the current account has 3 "licenses" for the last "policy"
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/products/$0/releases"
    Then the response status should be "404"

  Scenario: User attempts to retrieve the releases for their product
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "policy" for the last "product"
    And the current account has 3 "licenses" for the last "policy"
    And the current account has 1 "user"
    And the last "license" belongs to the last "user"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/products/$0/releases"
    Then the response status should be "200"

  Scenario: User attempts to retrieve the releases for a product
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "policy" for the last "product"
    And the current account has 3 "licenses" for the last "policy"
    And the current account has 1 "user"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/products/$0/releases"
    Then the response status should be "404"

  Scenario: Admin attempts to retrieve the releases for a product of another account
    Given I am an admin of account "test2"
    And the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "release"
    And all "releases" have the following attributes:
      """
      { "productId": "$products[0]" }
      """
    And I use an authentication token
    When I send a GET request to "/accounts/test1/products/$0/releases"
    Then the response status should be "401"

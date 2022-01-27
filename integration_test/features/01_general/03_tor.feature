Feature: Tor initializes correctly
  Scenario: Check the Tor version
    Given I tap the icon with type "TorIcon"
    Then I expect the Tor version to be present
    And I expect the string 'Online' to be present within 60 seconds

  Scenario: Reset Tor
    Given I tap the icon with type "TorIcon"
    Then I expect the string 'Online' to be present within 60 seconds
    Then I tap the button with text "Reset"
    Then I expect the text "Online" to be absent

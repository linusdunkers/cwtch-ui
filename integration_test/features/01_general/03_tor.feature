Feature: Tor initializes correctly
  Scenario: Check the Tor version
    Given I wait until the widget with type 'ProfileMgrView' is present
    And I tap the icon with type "TorIcon"
    Then I expect the Tor version to be present
    And I expect the string 'Online' to be present within 120 seconds

  Scenario: Reset Tor
    Given I wait until the widget with type 'ProfileMgrView' is present
    And I tap the icon with type "TorIcon"
    Then I expect the string 'Online' to be present within 120 seconds
    Then I tap the button that contains the text "Reset"
    Then I expect the text "Online" to be absent within 5 seconds

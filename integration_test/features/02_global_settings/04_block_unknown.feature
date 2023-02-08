@env:aliceandbob1
Feature: Block unknown contacts setting
  Scenario: Carol adds Alice but Alice doesn't see it because Block Unknowns is enabled
    Given I wait until the widget with type 'ProfileMgrView' is present
    Given I tap the 'OpenSettingsView' button
    And I wait until the text "Block Unknown Contacts" is present
    When I tap the widget that contains the text "Block Unknown Contacts"
    Then I expect the switch that contains the text "Block Unknown Contacts" to be checked
    Then I tap the back button
    And I wait until the tooltip "Online" is present
    And I wait until the text "Carol" is present
    And I tap the button that contains the text "Carol"
    And I wait until the text "Conversations" is present
    And I tap the button with tooltip "Add a new contact or conversation"
    And I tap the button that contains the text "Add contact"
    And I wait until the text "Paste a cwtch address" is present
    When I fill the "txtAddP2P" field with "vbmmsbx3rhndpfz6t3jkrd7m3yu62xzrldxkdgsw4rsehiwuw3tmo7yd"
    And I wait for 3 seconds
    And I tap the back button
    And I wait until the text "Alice" is present
    And I tap the button that contains the text "Alice"
    And I wait for 20 seconds
    Then I expect the text "yxj2pvhozedflp4g7yitpqkeho63maaffi2qgsj3e6s2fbmosuuas2qd" to be absent
Feature: Settings pane opens and can save settings
  Scenario: Open the Settings pane
    Given I tap the 'OpenSettingsView' button
    Then I expect the text 'Cwtch Settings' to be present
  Scenario: Change the 'Block unknown contacts' setting and restart Cwtch
    When I tap the 'OpenSettingsView' button
    Then I wait for 6 seconds
    Then I expect the 'SwitchBlockUnknown' widget to be unchecked
    Then I tap the 'SwitchBlockUnknown' widget
    Then I expect the 'SwitchBlockUnknown' widget to be checked
    Then I tap the back button
    Then I tap the 'OpenSettingsView' button
    Then I expect the 'SwitchBlockUnknown' widget to be checked
Feature: Global 'Theme' setting
  Scenario: Change the theme to Mermaid
    Given I tap the 'OpenSettingsView' button
    And I wait for 2 second
    When I tap the "DropdownTheme" button
    And I tap the element that contains the text "Mermaid"
  Scenario: Change the theme to Light Mode
    Given I tap the 'OpenSettingsView' button
    And I wait for 2 second
    And I tap the widget that contains the text "Theme"
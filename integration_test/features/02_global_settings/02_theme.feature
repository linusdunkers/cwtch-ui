Feature: Global 'Theme' setting
  Scenario: Change the theme to Mermaid
    Given I wait until the widget with type 'ProfileMgrView' is present
    Given I tap the 'OpenSettingsView' button
    And I wait for 1 second
    When I tap the "DropdownTheme" button
    And I tap the element that contains the text "Mermaid"
  Scenario: Change the theme to Light Mode
    Given I wait until the widget with type 'ProfileMgrView' is present
    Given I tap the 'OpenSettingsView' button
    And I wait for 1 second
    And I tap the widget that contains the text "Theme"
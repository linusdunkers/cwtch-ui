Feature: Global 'Theme' setting
  Scenario: Change the theme to Mermaid
    Given I wait until the widget with type 'ProfileMgrView' is present
    Given I tap the 'OpenSettingsView' button
    And I wait until the text 'Use Light Themes' is present
    When I tap the "DropdownTheme" button
    And I wait until the text 'Mermaid' is present
    And I tap the dropdown button that contains the text "Mermaid"
  Scenario: Change the theme to Light Mode
    Given I wait until the widget with type 'ProfileMgrView' is present
    Given I tap the 'OpenSettingsView' button
    And I wait until the text 'Use Light Themes' is present
    And I tap the widget that contains the text "Use Light Themes"
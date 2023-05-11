@env:persist
Feature: Settings pane opens and can save settings persistently
  Scenario: Open the Settings pane
    Given I wait until the widget with type 'ProfileMgrView' is present
    And I tap the 'OpenSettingsView' button
    And I wait until the text 'Cwtch Settings' is present
    And I take a screenshot

  Scenario: Change every setting (except Language)
    Given I wait until the widget with type 'ProfileMgrView' is present
    Given I tap the 'OpenSettingsView' button
    And I wait until the text 'Use Light Themes' is present
    When I tap the widget that contains the text "Use Light Themes"
    And I tap the widget that contains the text "Block Unknown Contacts"
    And I tap the widget that contains the text "Streamer/Presentation Mode"
    And I tap the widget that contains the text "Enable Experiments"
    Then I wait until the text 'Enable Group Chat' is present
    And I tap the widget that contains the text "Enable Group Chat"
    And I tap the widget that contains the text "Hosting Servers"
    And I tap the widget that contains the text "File Sharing"
    Then I wait until the text 'Image Previews and Profile Pictures' is present
    And I tap the widget that contains the text "Image Previews and Profile Pictures"
    And I wait until the text 'Download Folder' is present
    And I fill the "DownloadFolderPicker" field with "/this/is/a/test"
    And I tap the widget that contains the text "Enable Clickable Links"
    Then I expect the switch that contains the text "Use Light Themes" to be checked
    And I expect the switch that contains the text "Block Unknown Contacts" to be checked
    And I expect the switch that contains the text "Streamer/Presentation Mode" to be checked
    And I expect the switch that contains the text "Enable Experiments" to be checked
    And I expect the switch that contains the text "Enable Group Chat" to be checked
    # Not every version of Cwtch Supports Hosting Servers..
    # Leaving this undeleted for future documentation / interest
    # And I expect the switch that contains the text "Hosting Servers" to be checked
    And I expect the switch that contains the text "File Sharing" to be checked
    And I expect the switch that contains the text "Image Previews and Profile Pictures" to be checked
    And I expect the "DownloadFolderPicker" to be "/this/is/a/test"
    And I expect the switch that contains the text "Enable Clickable Links" to be checked

  Scenario: When the app is reloaded, settings from the previous scenario have persisted
    Given I wait until the widget with type 'ProfileMgrView' is present
    Given I tap the 'OpenSettingsView' button
    And I wait until the text 'Use Light Themes' is present
    Then I expect the switch that contains the text "Use Light Themes" to be checked
    And I expect the switch that contains the text "Block Unknown Contacts" to be checked
    And I expect the switch that contains the text "Streamer/Presentation Mode" to be checked
    And I expect the switch that contains the text "Enable Experiments" to be checked
    And I expect the switch that contains the text "Enable Group Chat" to be checked
    # And I expect the switch that contains the text "Hosting Servers" to be checked
    And I expect the switch that contains the text "File Sharing" to be checked
    And I expect the switch that contains the text "Image Previews and Profile Pictures" to be checked
    And I expect the "DownloadFolderPicker" to be "/this/is/a/test"
    And I expect the switch that contains the text "Enable Clickable Links" to be checked

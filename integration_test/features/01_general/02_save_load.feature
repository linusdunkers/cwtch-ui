@env:persist
Feature: Settings pane opens and can save settings persistently
  Scenario: Open the Settings pane
    Given I tap the 'OpenSettingsView' button
    Then I expect the text 'Cwtch Settings' to be present
    And I take a screenshot

  Scenario: Change every setting (except Language)
    Given I tap the 'OpenSettingsView' button
    And I wait for 4 second
    When I tap the widget that contains the text "Use Light Themes"
    #And I choose option 3 from the "DropdownTheme" dropdown
    #When I tap the "DropdownTheme" button
    #And I tap the first "ddi_mermaid" element
    #And I tap the element that contains the text "Mermaid"
    #And I tap the element that contains the text "Mermaid" within the "DropdownTheme"
    And I tap the widget that contains the text "Block Unknown Contacts"
    And I tap the widget that contains the text "Streamer/Presentation Mode"
    And I tap the widget that contains the text "Enable Experiments"
    And I tap the widget that contains the text "Enable Group Chat"
    And I tap the widget that contains the text "Hosting Servers"
    And I tap the widget that contains the text "File Sharing"
    And I tap the widget that contains the text "Image Previews and Profile Pictures"
    And I fill the "DownloadFolderPicker" field with "/this/is/a/test"
    And I tap the widget that contains the text "Enable Clickable Links"
    Then I expect the switch that contains the text "Use Light Themes" to be checked
    And I expect the switch that contains the text "Block Unknown Contacts" to be checked
    And I expect the switch that contains the text "Streamer/Presentation Mode" to be checked
    And I expect the switch that contains the text "Enable Experiments" to be checked
    And I expect the switch that contains the text "Enable Group Chat" to be checked
    And I expect the switch that contains the text "Hosting Servers" to be checked
    And I expect the switch that contains the text "File Sharing" to be checked
    And I expect the switch that contains the text "Image Previews and Profile Pictures" to be checked
    And I expect the "DownloadFolderPicker" to be "/this/is/a/test"
    And I expect the switch that contains the text "Enable Clickable Links" to be checked

  Scenario: When the app is reloaded, settings from the previous scenario have persisted
    Given I tap the 'OpenSettingsView' button
    And I wait for 2 second
    Then I expect the switch that contains the text "Use Light Themes" to be checked
    And I expect the switch that contains the text "Block Unknown Contacts" to be checked
    And I expect the switch that contains the text "Streamer/Presentation Mode" to be checked
    And I expect the switch that contains the text "Enable Experiments" to be checked
    And I expect the switch that contains the text "Enable Group Chat" to be checked
    And I expect the switch that contains the text "Hosting Servers" to be checked
    And I expect the switch that contains the text "File Sharing" to be checked
    And I expect the switch that contains the text "Image Previews and Profile Pictures" to be checked
    And I expect the "DownloadFolderPicker" to be "/this/is/a/test"
    And I expect the switch that contains the text "Enable Clickable Links" to be checked

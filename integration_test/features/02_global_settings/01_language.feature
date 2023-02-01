Feature: Global 'language' setting
  Scenario: Change the language to French and back
    Given I wait until the widget with type 'ProfileMgrView' is present
    Given I tap the 'OpenSettingsView' button
    And I wait until the text 'Language' is present
    Then I expect the text 'Language' to be present
    And I expect the text 'Langue' to be absent
    When I tap the widget that contains the text "English"
    And I wait until the text 'French' is present
    And I tap the widget that contains the text "French"
    And I wait until the text 'Langue' is present
    And I expect the text 'Language' to be absent
    When I tap the widget that contains the text "Français"
    And I tap the widget that contains the text "Anglais"
    And I wait until the text 'Language' is present
    And I expect the text 'Langue' to be absent
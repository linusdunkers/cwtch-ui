Feature: Global 'language' setting
  Scenario: Change the language to French and back
    Given I tap the 'OpenSettingsView' button
    And I wait for 2 second
    Then I expect the text 'Language' to be present
    And I expect the text 'Langue' to be absent
    When I tap the widget that contains the text "English"
    And I tap the widget that contains the text "Frances"
    Then I expect the text 'Langue' to be present
    And I expect the text 'Language' to be absent
    When I tap the widget that contains the text "Français"
    And I tap the widget that contains the text "Anglais"
    Then I expect the text 'Language' to be present
    And I expect the text 'Langue' to be absent
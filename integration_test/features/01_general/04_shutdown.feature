Feature: Shutdown Cwtch button works correctly
  Scenario: Clicking 'Shutdown Cwtch' shuts down Cwtch
    Given I tap the button with tooltip 'Shutdown Cwtch'
    Then I expect the text 'Shutdown Cwtch?' to be present
    #this also kills the testing framework sadly. will have to find a workaround
    #And I tap the button that contains the text 'Shutdown Cwtch'
    #Then I wait until the widget with type 'ProfileMgrView' is absent

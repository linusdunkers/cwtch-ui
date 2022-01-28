Feature: Basic Profile Management
    Scenario: Error on Creating a Profile without a Display Name
        Given I wait until the widget with type 'ProfileMgrView' is present
        And I tap the button with tooltip "Add new profile"
        Then I expect the text 'Display Name' to be present
        And I expect the text 'New Password' to be present
        And I expect the text 'Please enter a display name' to be absent
        Then I tap the "button" widget with label "Add new profile"
        And I expect the text 'Please enter a display name' to be present
        And I take a screenshot

    Scenario: Create Unencrypted Profile
        Given I wait until the widget with type 'ProfileMgrView' is present
        And I tap the button with tooltip "Add new profile"
        Then I expect the text 'Display Name' to be present
        And I expect the text 'New Password' to be present
        And I take a screenshot
        Then I tap the "passwordCheckBox" widget
        And I expect the text 'New Password' to be absent
        And I take a screenshot
        Then I fill the "displayNameFormElement" field with "Alice (<h1>hello</h1>)"
        Then I tap the "button" widget with label "Add new profile"
        And I expect a "ProfileRow" widget with text "Alice (<h1>hello</h1>)"
        And I take a screenshot
        Then I tap the "ProfileRow" widget with label "Alice (<h1>hello</h1>)"
        And I expect the text 'Alice (<h1>hello</h1>) » Conversations' to be present
        And I take a screenshot

    Scenario: Create Encrypted Profile
        Given I wait until the widget with type 'ProfileMgrView' is present
        And I tap the button with tooltip "Add new profile"
        Then I expect the text 'Display Name' to be present
        And I expect the text 'New Password' to be present
        And I take a screenshot
        Then I fill the "displayNameFormElement" field with "Alice (Encrypted)"
        Then I fill the "passwordFormElement" field with "password1"
        Then I fill the "confirmPasswordFormElement" field with "password1"
        And I take a screenshot
        Then I tap the "button" widget with label "Add new profile"
        And I expect a "ProfileRow" widget with text "Alice (Encrypted)"
        And I take a screenshot
        Then I tap the "ProfileRow" widget with label "Alice (Encrypted)"
        And I expect the text 'Alice (Encrypted) » Conversations' to be present
        And I take a screenshot
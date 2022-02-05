@env:persist
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
        Then I fill the "displayNameFormElement" field with "Alice (Unencrypted)"
        Then I tap the "button" widget with label "Add new profile"
        And I expect a "ProfileRow" widget with text "Alice (Unencrypted)"
        And I take a screenshot
        Then I tap the "ProfileRow" widget with label "Alice (Unencrypted)"
        And I expect the text "Alice (Unencrypted) » Conversations" to be present
        And I take a screenshot

    Scenario: Load Unencrypted Profile
        Given I wait until the widget with type 'ProfileMgrView' is present
        Then I expect a "ProfileRow" widget with text "Alice (Unencrypted)"

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

    Scenario: Load an Encrypted Profile by Unlocking it with a Password
        Given I wait until the widget with type 'ProfileMgrView' is present
        Then I expect the text 'Enter a password to view your profiles' to be absent
        And I tap the button with tooltip "Unlock encrypted profiles by entering their password."
        Then I expect the text 'Enter a password to view your profiles' to be present
        When I fill the "unlockPasswordProfileElement" field with "password1"
        And I tap the "button" widget with label "Unlock"
        Then I expect a "ProfileRow" widget with text "Alice (Encrypted)"

    Scenario: Load an Encrypted Profile by Unlocking it with a Password and Change the Name
        Given I wait until the widget with type 'ProfileMgrView' is present
        Then I expect the text 'Enter a password to view your profiles' to be absent
        And I tap the button with tooltip "Unlock encrypted profiles by entering their password."
        Then I expect the text 'Enter a password to view your profiles' to be present
        When I fill the "unlockPasswordProfileElement" field with "password1"
        And I tap the "button" widget with label "Unlock"
        Then I expect a "ProfileRow" widget with text "Alice (Encrypted)"
        When I tap the "IconButton" widget with tooltip "Edit Profile Alice (Encrypted)"
        Then I expect the text 'Display Name' to be present
        Then I fill the "displayNameFormElement" field with "Carol (Encrypted)"
        And I tap the "button" widget with label "Save Profile"
        And I wait until the widget with type 'ProfileMgrView' is present
        Then I expect a "ProfileRow" widget with text "Carol (Encrypted)"

     Scenario: Delete an Encrypted Profile
         Given I wait until the widget with type 'ProfileMgrView' is present
         Then I expect the text 'Enter a password to view your profiles' to be absent
         And I tap the button with tooltip "Unlock encrypted profiles by entering their password."
         Then I expect the text 'Enter a password to view your profiles' to be present
         When I fill the "unlockPasswordProfileElement" field with "password1"
         And I tap the "button" widget with label "Unlock"
         Then I expect a "ProfileRow" widget with text "Carol (Encrypted)"
         And I take a screenshot
         When I tap the "IconButton" widget with tooltip "Edit Profile Carol (Encrypted)"
         Then I expect the text 'Display Name' to be present
         When I tap the button that contains the text "Delete"
         Then I expect the text "Really Delete Profile" to be present
         When I tap the "button" widget with label "Really Delete Profile"
         And I wait until the widget with type 'ProfileMgrView' is present
         Then I expect a "ProfileRow" widget with text "Carol (Encrypted)" to be absent

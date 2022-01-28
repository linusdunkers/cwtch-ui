@env:aliceandbob1
Feature: Sending and receiving chat messages
  Background:
    Given I wait until the widget with type "ProfileRow" is present
    And I wait for 4 seconds
    Given I tap the button that contains the text "Alice"
    And I tap the button that contains the text "Bob"
    And I wait until the text "Contact is offline, messages can't be delivered right now" is absent
    #And I wait for 6 seconds
    When I fill the "txtCompose" field with "hello! this is a test!"
    And I tap the "btnSend" button
    Then I expect a "MessageBubble" widget with text "hello! this is a test!\u202F" to be present within 5 seconds
    #Then I expect the text "hello! this is a test!" to be present
    And I tap the back button
    And I tap the back button

  Scenario: Bob receives the message from Alice
    Given I tap the button that contains the text "Bob"
    And I tap the button that contains the text "Alice"
    Then I expect a "MessageBubble" widget with text "hello! this is a test!\u202F" to be present within 5 seconds

  Scenario: Bob replies to a message from Alice
    Given I tap the button that contains the text "Bob"
    And I tap the button that contains the text "Alice"
    #When I swipe right by 15 pixels on the element that contains the text "hello! this is a test!\u202F"
    #When I swipe right by 15 pixels on the widget of type "MessageBubble" with text "hello! this is a test!\u202F"
    And I tap the button with tooltip "Reply to this message"
    And I fill the "txtCompose" field with "yay the test worked"
    And I tap the "btnSend" button
    Then I expect to see the message "yay the test worked\u202F" replying to "hello! this is a test!" within 5 seconds
    And I take a screenshot

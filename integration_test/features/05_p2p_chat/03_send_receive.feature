@env:aliceandbob1
Feature: Sending and receiving chat messages
  Background:
    Given I tap the button containing the text "Alice"
    And I tap the button containing the text "Bob"
    When I fill the "ComposeTextField" with "hello! this is a test!"
    And I tap the button with tooltip "Send"
    Then I expect to see a "MessageBubble" widget with the text "hello! this is a test!"
    And I press the back button
    And I press the back button

  Scenario: Bob receives the message from Alice
    Given I tap the button containing the text "Bob"
    And I tap the button containing the text "Alice"
    Then I expect to see a "MessageBubble" widget with the text "hello! this is a test!"

  Scenario: Bob replies to a message from Alice
    Given I tap the button containing the text "Bob"
    And I tap the button containing the text "Alice"
    When I tap the button with tooltip "Reply"
    And I fill the "ComposeTextField" with "yay the test worked"
    And I tap the button with tooltip "Send"
    Then I expect to see the message "yay the test worked" replying to "hello! this is a test!"

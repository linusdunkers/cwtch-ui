@env:aliceandbob1
Feature: Streamer mode
  Scenario: All onions disappear when Streamer Mode is enabled
    Given I wait until the widget with type 'ProfileMgrView' is present
    And I wait until the text "vbmmsbx3rhndpfz6t3jkrd7m3yu62xzrldxkdgsw4rsehiwuw3tmo7yd" is present
    And I wait until the text "pjurzypqui3dnpxj6aemk6cqz22yx6zfr5lq4jzu7muwe2yyx2zrnzyd" is present
    Given I tap the 'OpenSettingsView' button
    And I wait for 2 second
    And I tap the widget that contains the text "Streamer/Presentation Mode"
    Then I expect the switch that contains the text "Streamer/Presentation Mode" to be checked
    When I tap the back button
    And I wait until the text "Alice" is present
    And I wait until the text "Bob" is present
    Then I expect the text "vbmmsbx3rhndpfz6t3jkrd7m3yu62xzrldxkdgsw4rsehiwuw3tmo7yd" to be absent
    And I expect the text "pjurzypqui3dnpxj6aemk6cqz22yx6zfr5lq4jzu7muwe2yyx2zrnzyd" to be absent
    When I tap the button that contains the text "Alice"
    Then I expect the text "vbmmsbx3rhndpfz6t3jkrd7m3yu62xzrldxkdgsw4rsehiwuw3tmo7yd" to be absent
    And I expect the text "pjurzypqui3dnpxj6aemk6cqz22yx6zfr5lq4jzu7muwe2yyx2zrnzyd" to be absent

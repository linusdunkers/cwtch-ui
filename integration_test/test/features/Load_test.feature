Feature: Splash screen displays and then closes
  Scenario: splash screen appears
    Then I expect the widget 'SplashView' to be present within 1 second
  Scenario: splash screen completes
    Then I expect the widget 'ProfileManagerView' to be present within 10 seconds

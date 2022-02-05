@env:clean
Feature: Splash screen displays and then closes
  Scenario: splash screen appears
    Then I expect the widget 'SplashView' to be present within 1 second
  Scenario: splash screen completes
    Then I expect the widget 'ProfileManagerView' to be present within 10 seconds
  Scenario: first-run of cwtch creates expected files and folders
    Given I expect the widget 'ProfileManagerView' to be present within 10 seconds
    Then I expect the folder 'integration_test/env/temp' to exist
    And I expect the folder 'integration_test/env/temp/dev' to exist
    And I expect the file 'integration_test/env/temp/dev/SALT' to exist
    And I expect the file 'integration_test/env/temp/dev/ui.globals' to exist
    And I expect the folder 'integration_test/env/temp/dev/tor' to exist
    And I expect the file 'integration_test/env/temp/dev/tor/torrc' to exist
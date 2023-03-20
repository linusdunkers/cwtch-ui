const dev_version = "development";

class EnvironmentConfig {
  static const BUILD_VER = String.fromEnvironment('BUILD_VER', defaultValue: dev_version);
  static const BUILD_DATE = String.fromEnvironment('BUILD_DATE', defaultValue: "now");
  // set by the automated testing harness to circumvent untestable behaviours
  // for example:
  // * MessageRow: always show "reply" button (because can't test onHover or swipe)
  static const TEST_MODE = String.fromEnvironment('TEST_MODE', defaultValue: "false") == "true";

  static void debugLog(String log) {
    if (EnvironmentConfig.BUILD_VER == dev_version) {
      String datetime = DateTime.now().toIso8601String();
      print("$datetime $log");
    }
  }
}

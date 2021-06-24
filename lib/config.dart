const dev_version = "development";

class EnvironmentConfig {
  static const BUILD_VER = String.fromEnvironment('BUILD_VER', defaultValue: dev_version);
  static const BUILD_DATE = String.fromEnvironment('BUILD_DATE', defaultValue: "now");
}

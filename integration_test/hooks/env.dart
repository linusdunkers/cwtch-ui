import 'dart:io';

import 'package:gherkin/gherkin.dart';

class ResetCwtchEnvironment extends Hook {
  @override
  int get priority => 10;

  @override
  Future<void> onBeforeRun(TestConfiguration config) async {
    // initialize @env:persist
    await Process.run("cp", ["-R", "integration_test/env/persist", "integration_test/env/temp-persist"]);

    return super.onBeforeRun(config);
  }

  @override
  Future<void> onAfterRun(TestConfiguration config) async {
    await Process.run("rm", ["-rf", "integration_test/env/temp-persist"]);
    return super.onAfterRun(config);
  }

  @override
  Future<void> onBeforeScenario(TestConfiguration config, String scenario, Iterable<Tag> tags) async {
    if (tags.any((t) => t.name == "@env:persist")) {
      await Process.run("mv", ["integration_test/env/temp-persist", "integration_test/env/temp"]);
    } else if (tags.any((t) => t.name == "@env:aliceandbob1")) {
      await Process.run("cp", ["-R", "integration_test/env/aliceandbob1", "integration_test/env/temp"]);
    } else if (!(tags.any((t) => t.name == "@env:clean"))) {
      // use the default environment if no @env: tag specified
      await Process.run("cp", ["-R", "integration_test/env/default", "integration_test/env/temp"]);
    } else {
      print("no environment initialized");
    }
    return super.onBeforeScenario(config, scenario, tags);
  }

  @override
  Future<void> onAfterScenario(TestConfiguration config, String scenario, Iterable<Tag> tags) async {
    if (tags.any((t) => t.name == "@env:persist")) {
      await Process.run("mv", ["integration_test/env/temp", "integration_test/env/temp-persist"]);
    } else {
      await Process.run("rm", ["-rf", "integration_test/env/temp"]);
    }
    return super.onAfterScenario(config, scenario, tags);
  }
}
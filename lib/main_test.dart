import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cwtch/errorHandler.dart';
import 'package:cwtch/settings.dart';
import 'licenses.dart';
import 'main.dart';
import 'opaque.dart';

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:glob/glob.dart';

var globalSettings = Settings(Locale("en", ''), OpaqueDark());
var globalErrorHandler = ErrorHandler();

void main() {
  LicenseRegistry.addLicense(() => licenses());
  DiskAssetBundle.loadGlob(['profiles/*.png']).then((assetBundle) {
    runApp(DefaultAssetBundle(
      bundle: assetBundle,
      child: Flwtch(),
    ));
  });
}

class DiskAssetBundle extends CachingAssetBundle {
  static const _assetManifestDotJson = 'AssetManifest.json';

  /// Creates a [DiskAssetBundle] by loading [globs] of assets under `assets/`.
  static Future<AssetBundle> loadGlob(
    Iterable<String> globs, {
    String from = 'assets',
  }) async {
    final cache = <String, ByteData>{};
    for (final pattern in globs) {
      await for (final path in Glob(pattern).list(root: from)) {
        if (path is File) {
          final bytes = await (path as File).readAsBytes() /* as Uint8List*/;
          cache[path.path] = ByteData.view(bytes.buffer);
        }
      }
    }
    final manifest = <String, List<String>>{};
    cache.forEach((key, _) {
      manifest[key] = [key];
    });

    cache[_assetManifestDotJson] = ByteData.view(
      Uint8List.fromList(jsonEncode(manifest).codeUnits).buffer,
    );

    return DiskAssetBundle._(cache);
  }

  final Map<String, ByteData> _cache;

  DiskAssetBundle._(this._cache);

  @override
  Future<ByteData> load(String key) async {
    return _cache[key]!;
  }
}

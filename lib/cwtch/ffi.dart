import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:io' show Platform;
import 'package:cwtch/cwtch/cwtchNotifier.dart';
import 'package:path/path.dart' as path;

import 'package:ffi/ffi.dart';
import 'package:cwtch/cwtch/cwtch.dart';

import '../config.dart';

import "package:path/path.dart" show dirname, join;
import 'dart:io' show Platform;

/////////////////////
///   Cwtch API   ///
/////////////////////

typedef start_cwtch_function = Int8 Function(Pointer<Utf8> str, Int32 length, Pointer<Utf8> str2, Int32 length2);
typedef StartCwtchFn = int Function(Pointer<Utf8> dir, int len, Pointer<Utf8> tor, int torLen);

typedef void_from_void_funtion = Void Function();
typedef VoidFromVoidFunction = void Function();

typedef free_function = Void Function(Pointer<Utf8>);
typedef FreeFn = void Function(Pointer<Utf8>);

typedef void_from_string_string_function = Void Function(Pointer<Utf8>, Int32, Pointer<Utf8>, Int32);
typedef VoidFromStringStringFn = void Function(Pointer<Utf8>, int, Pointer<Utf8>, int);

typedef void_from_string_string_string_function = Void Function(Pointer<Utf8>, Int32, Pointer<Utf8>, Int32, Pointer<Utf8>, Int32);
typedef VoidFromStringStringStringFn = void Function(Pointer<Utf8>, int, Pointer<Utf8>, int, Pointer<Utf8>, int);

typedef void_from_string_string_string_string_function = Void Function(Pointer<Utf8>, Int32, Pointer<Utf8>, Int32, Pointer<Utf8>, Int32, Pointer<Utf8>, Int32);
typedef VoidFromStringStringStringStringFn = void Function(Pointer<Utf8>, int, Pointer<Utf8>, int, Pointer<Utf8>, int, Pointer<Utf8>, int);

// DownloadFile
typedef void_from_string_int_string_string_string_function = Void Function(Pointer<Utf8>, Int32, Int32, Pointer<Utf8>, Int32, Pointer<Utf8>, Int32, Pointer<Utf8>, Int32);
typedef VoidFromStringIntStringStringStringFn = void Function(Pointer<Utf8>, int, int, Pointer<Utf8>, int, Pointer<Utf8>, int, Pointer<Utf8>, int);

typedef void_from_string_string_int_int_function = Void Function(Pointer<Utf8>, Int32, Pointer<Utf8>, Int32, Int64, Int64);
typedef VoidFromStringStringIntIntFn = void Function(Pointer<Utf8>, int, Pointer<Utf8>, int, int, int);

typedef void_from_string_string_byte_function = Void Function(Pointer<Utf8>, Int32, Pointer<Utf8>, Int32, Int8);
typedef VoidFromStringStringByteFn = void Function(Pointer<Utf8>, int, Pointer<Utf8>, int, int);

typedef string_to_void_function = Void Function(Pointer<Utf8> str, Int32 length);
typedef StringFn = void Function(Pointer<Utf8> dir, int);

typedef string_string_to_void_function = Void Function(Pointer<Utf8> str, Int32 length, Pointer<Utf8> str2, Int32 length2);
typedef StringStringFn = void Function(Pointer<Utf8>, int, Pointer<Utf8>, int);

typedef string_string_to_string_function = Pointer<Utf8> Function(Pointer<Utf8> str, Int32 length, Pointer<Utf8> str2, Int32 length2);
typedef StringFromStringStringFn = Pointer<Utf8> Function(Pointer<Utf8>, int, Pointer<Utf8>, int);

typedef string_int_to_void_function = Void Function(Pointer<Utf8> str, Int32 length, Int32 handle);
typedef VoidFromStringIntFn = void Function(Pointer<Utf8>, int, int);

typedef get_json_blob_string_function = Pointer<Utf8> Function(Pointer<Utf8> str, Int32 length);
typedef GetJsonBlobStringFn = Pointer<Utf8> Function(Pointer<Utf8> str, int len);

typedef get_json_blob_from_string_int_string_function = Pointer<Utf8> Function(Pointer<Utf8>, Int32, Int32, Pointer<Utf8>, Int32);
typedef GetJsonBlobFromStrIntStrFn = Pointer<Utf8> Function(Pointer<Utf8>, int, int, Pointer<Utf8>, int);

//func GetMessage(profile_ptr *C.char, profile_len C.int, handle_ptr *C.char, handle_len C.int, message_index C.int) *C.char {
typedef get_json_blob_from_str_str_int_function = Pointer<Utf8> Function(Pointer<Utf8>, Int32, Pointer<Utf8>, Int32, Int32);
typedef GetJsonBlobFromStrStrIntFn = Pointer<Utf8> Function(Pointer<Utf8>, int, Pointer<Utf8>, int, int);

typedef get_json_blob_from_str_int_int_function = Pointer<Utf8> Function(Pointer<Utf8>, Int32, Int32, Int32);
typedef GetJsonBlobFromStrIntIntFn = Pointer<Utf8> Function(Pointer<Utf8>, int, int, int);

typedef get_json_blob_from_str_int_int_int_function = Pointer<Utf8> Function(Pointer<Utf8>, Int32, Int32, Int32, Int32);
typedef GetJsonBlobFromStrIntIntIntFn = Pointer<Utf8> Function(Pointer<Utf8>, int, int, int, int);

typedef get_json_blob_from_str_int_string_function = Pointer<Utf8> Function(Pointer<Utf8>, Int32, Int32, Pointer<Utf8>, Int32);
typedef GetJsonBlobFromStrIntStringFn = Pointer<Utf8> Function(
  Pointer<Utf8>,
  int,
  int,
  Pointer<Utf8>,
  int,
);

// func c_GetMessagesByContentHash(profile_ptr *C.char, profile_len C.int, handle_ptr *C.char, handle_len C.int, contenthash_ptr *C.char, contenthash_len C.int) *C.char
typedef get_json_blob_from_str_str_str_function = Pointer<Utf8> Function(Pointer<Utf8>, Int32, Pointer<Utf8>, Int32, Pointer<Utf8>, Int32);
typedef GetJsonBlobFromStrStrStrFn = Pointer<Utf8> Function(Pointer<Utf8>, int, Pointer<Utf8>, int, Pointer<Utf8>, int);

typedef void_from_string_int_string_function = Void Function(Pointer<Utf8>, Int32, Int32, Pointer<Utf8>, Int32);
typedef VoidFromStringIntStringFn = void Function(Pointer<Utf8>, int, int, Pointer<Utf8>, int);

typedef void_from_string_int_string_string_function = Void Function(Pointer<Utf8>, Int32, Int32, Pointer<Utf8>, Int32, Pointer<Utf8>, Int32);
typedef VoidFromStringIntStringStringFn = void Function(Pointer<Utf8>, int, int, Pointer<Utf8>, int, Pointer<Utf8>, int);

typedef void_from_string_int_int_int_string_string_function = Void Function(Pointer<Utf8>, Int32, Int32, Int32, Int32, Pointer<Utf8>, Int32, Pointer<Utf8>, Int32);
typedef VoidFromStringIntIntIntStringStringFn = void Function(Pointer<Utf8>, int, int, int, int, Pointer<Utf8>, int, Pointer<Utf8>, int);

typedef void_from_string_int_int_function = Void Function(Pointer<Utf8>, Int32, Int32, Int32);
typedef VoidFromStringIntIntFn = void Function(Pointer<Utf8>, int, int, int);

typedef appbus_events_function = Pointer<Utf8> Function();
typedef AppbusEventsFn = Pointer<Utf8> Function();

typedef void_to_string = Pointer<Utf8> Function();
typedef StringFromVoid = Pointer<Utf8> Function();

const String UNSUPPORTED_OS = "unsupported-os";

class CwtchFfi implements Cwtch {
  late DynamicLibrary library;
  late CwtchNotifier cwtchNotifier;
  late Isolate cwtchIsolate;
  ReceivePort _receivePort = ReceivePort();
  bool _isL10nInit = false;

  static String getLibraryPath() {
    if (Platform.isWindows) {
      return "libCwtch.dll";
    } else if (Platform.isLinux) {
      return "libCwtch.so";
    } else if (Platform.isMacOS) {
      print(dirname(Platform.script.path));
      return "libCwtch.dylib";
    } else {
      return UNSUPPORTED_OS;
    }
  }

  CwtchFfi(CwtchNotifier _cwtchNotifier) {
    String libraryPath = getLibraryPath();
    if (libraryPath == UNSUPPORTED_OS) {
      print("OS ${Platform.operatingSystem} not supported by cwtch/ffi");
      // emergency, ideally the app stays on splash and just posts the error till user closes
      exit(0);
    }
    library = DynamicLibrary.open(libraryPath);
    cwtchNotifier = _cwtchNotifier;
    cwtchNotifier.setMessageSeenCallback((String profile, int conversation, DateTime time) => {this.SetConversationAttribute(profile, conversation, LastMessageSeenTimeKey, time.toIso8601String())});
  }

  // ignore: non_constant_identifier_names
  Future<void> Start() async {
    String home = "";
    String bundledTor = "";
    Map<String, String> envVars = Platform.environment;
    String cwtchDir = "";
    if (Platform.isLinux) {
      cwtchDir = envVars['CWTCH_HOME'] ?? path.join(envVars['HOME']!, ".cwtch");
      if (await File("linux/tor").exists()) {
        bundledTor = "linux/tor";
      } else if (await File("lib/tor").exists()) {
        bundledTor = "lib/tor";
      } else if (await File(path.join(home, ".local/lib/cwtch/tor")).exists()) {
        bundledTor = path.join(home, ".local/lib/cwtch/tor");
      } else if (await File("/usr/lib/cwtch/tor").exists()) {
        bundledTor = "/usr/lib/cwtch/tor";
      } else {
        bundledTor = "tor";
      }
    } else if (Platform.isWindows) {
      cwtchDir = envVars['CWTCH_DIR'] ?? path.join(envVars['UserProfile']!, ".cwtch");
      String currentTor = path.join(Directory.current.absolute.path, "Tor\\Tor\\tor.exe");
      if (await File(currentTor).exists()) {
        bundledTor = currentTor;
      } else {
        String exeDir = path.dirname(Platform.resolvedExecutable);
        bundledTor = path.join(exeDir, "Tor\\Tor\\tor.exe");
      }
    } else if (Platform.isMacOS) {
      cwtchDir = envVars['CWTCH_HOME'] ?? path.join(envVars['HOME']!, "Library/Application Support/Cwtch");
      if (await File("Cwtch.app/Contents/MacOS/Tor/tor.real").exists()) {
        bundledTor = "Cwtch.app/Contents/MacOS/Tor/tor.real";
      } else if (await File("/Applications/Cwtch.app/Contents/MacOS/Tor/tor.real").exists()) {
        bundledTor = "/Applications/Cwtch.app/Contents/MacOS/Tor/tor.real";
      } else if (await File("/Volumes/Cwtch/Cwtch.app/Contents/MacOS/Tor/tor.real").exists()) {
        bundledTor = "/Volumes/Cwtch/Cwtch.app/Contents/MacOS/Tor/tor.real";
      } else if (await File("/Applications/Tor Browser.app/Contents/MacOS/Tor/tor.real").exists()) {
        bundledTor = "/Applications/Tor Browser.app/Contents/MacOS/Tor/tor.real";
        print("We couldn't find Tor in the Cwtch app directory, however we can fall back to the Tor Browser binary");
      } else {
        var splitPath = path.split(dirname(Platform.script.path));
        if (splitPath[0] == "/" && splitPath[1] == "Applications") {
          var appName = splitPath[2];
          print("We're running in /Applications in a non standard app name: $appName");
          if (await File("/Applications/$appName/Contents/MacOS/Tor/tor.real").exists()) {
            bundledTor = "/Applications/$appName/Contents/MacOS/Tor/tor.real";
          }
        }
      }
    }

    // the first Cwtch MacOS release (1.2) accidently was a dev build
    // we need to temporarily remedy this for a release or two then delete
    // if macOs and release build and no profile and is dev profile
    // copy dev profile to release profile
    if (Platform.isMacOS && EnvironmentConfig.BUILD_VER != dev_version) {
      var devProfileExists = await Directory(path.join(cwtchDir, "dev", "profiles")).exists();
      var releaseProfileExists = await Directory(path.join(cwtchDir, "profiles")).exists();
      if (devProfileExists && !releaseProfileExists) {
        print("MacOS one time dev -> release profile migration...");
        await Process.run("cp", ["-r", "-p", path.join(cwtchDir, "dev", "profiles"), cwtchDir]);
        await Process.run("cp", ["-r", "-p", path.join(cwtchDir, "dev", "SALT"), cwtchDir]);
        await Process.run("cp", ["-r", "-p", path.join(cwtchDir, "dev", "ui.globals"), cwtchDir]);
      }
    }

    if (EnvironmentConfig.BUILD_VER == dev_version) {
      cwtchDir = path.join(cwtchDir, "dev");
    }

    print("StartCwtch( cwtchdir: $cwtchDir, torPath: $bundledTor )");

    var startCwtchC = library.lookup<NativeFunction<start_cwtch_function>>("c_StartCwtch");
    // ignore: non_constant_identifier_names
    final StartCwtch = startCwtchC.asFunction<StartCwtchFn>();

    final utf8CwtchDir = cwtchDir.toNativeUtf8();
    StartCwtch(utf8CwtchDir, utf8CwtchDir.length, bundledTor.toNativeUtf8(), bundledTor.length);
    malloc.free(utf8CwtchDir);

    // Spawn an isolate to listen to events from libcwtch-go and then dispatch them when received on main thread to cwtchNotifier
    cwtchIsolate = await Isolate.spawn(_checkAppbusEvents, _receivePort.sendPort);
    _receivePort.listen((message) {
      var env = jsonDecode(message);
      cwtchNotifier.handleMessage(env["EventType"], env["Data"]);
    });
  }

  // ignore: non_constant_identifier_names
  Future<void> ReconnectCwtchForeground() async {
    var reconnectCwtch = library.lookup<NativeFunction<Void Function()>>("c_ReconnectCwtchForeground");
    // ignore: non_constant_identifier_names
    final ReconnectCwtchForeground = reconnectCwtch.asFunction<void Function()>();
    ReconnectCwtchForeground();
  }

  // Called on object being disposed to (presumably on app close) to close the isolate that's listening to libcwtch-go events
  @override
  void dispose() {
    cwtchIsolate.kill(priority: Isolate.immediate);
  }

  // Entry point for an isolate to listen to a stream of events pulled from libcwtch-go and return them on the sendPort
  static void _checkAppbusEvents(SendPort sendPort) async {
    var stream = pollAppbusEvents();
    await for (var value in stream) {
      sendPort.send(value);
    }
    print("checkAppBusEvents finished...");
  }

  // Steam of appbus events. Call blocks in libcwtch-go GetAppbusEvent.  Static so the isolate can use it
  static Stream<String> pollAppbusEvents() async* {
    late DynamicLibrary library = DynamicLibrary.open(getLibraryPath());

    var getAppbusEventC = library.lookup<NativeFunction<appbus_events_function>>("c_GetAppBusEvent");
    // ignore: non_constant_identifier_names
    final GetAppbusEvent = getAppbusEventC.asFunction<AppbusEventsFn>();

    // Embedded Version of _UnsafeFreePointerAnyUseOfThisFunctionMustBeDoubleApproved
    var free = library.lookup<NativeFunction<free_function>>("c_FreePointer");
    final Free = free.asFunction<FreeFn>();

    // ignore: non_constant_identifier_names
    final GetAppBusEvent = () {
      // ignore: non_constant_identifier_names
      Pointer<Utf8> result = GetAppbusEvent();
      String event = result.toDartString();
      Free(result);
      return event;
    };

    while (true) {
      final event = GetAppBusEvent();

      if (event.startsWith("{\"EventType\":\"Shutdown\"")) {
        print("Shutting down isolate thread: $event");
        return;
      }
      yield event;
    }
  }

  // ignore: non_constant_identifier_names
  void CreateProfile(String nick, String pass) {
    var createProfileC = library.lookup<NativeFunction<void_from_string_string_function>>("c_CreateProfile");
    // ignore: non_constant_identifier_names
    final CreateProfile = createProfileC.asFunction<VoidFromStringStringFn>();
    final utf8nick = nick.toNativeUtf8();
    final ut8pass = pass.toNativeUtf8();
    CreateProfile(utf8nick, utf8nick.length, ut8pass, ut8pass.length);
    malloc.free(utf8nick);
    malloc.free(ut8pass);
  }

  // ignore: non_constant_identifier_names
  void LoadProfiles(String pass) {
    var loadProfileC = library.lookup<NativeFunction<string_to_void_function>>("c_LoadProfiles");
    // ignore: non_constant_identifier_names
    final LoadProfiles = loadProfileC.asFunction<StringFn>();
    final ut8pass = pass.toNativeUtf8();
    LoadProfiles(ut8pass, ut8pass.length);
    malloc.free(ut8pass);
  }

  // ignore: non_constant_identifier_names
  Future<String> GetMessage(String profile, int handle, int index) async {
    var getMessageC = library.lookup<NativeFunction<get_json_blob_from_str_int_int_function>>("c_GetMessage");
    // ignore: non_constant_identifier_names
    final GetMessage = getMessageC.asFunction<GetJsonBlobFromStrIntIntFn>();
    final utf8profile = profile.toNativeUtf8();
    Pointer<Utf8> jsonMessageBytes = GetMessage(utf8profile, utf8profile.length, handle, index);
    String jsonMessage = jsonMessageBytes.toDartString();
    _UnsafeFreePointerAnyUseOfThisFunctionMustBeDoubleApproved(jsonMessageBytes);
    malloc.free(utf8profile);
    return jsonMessage;
  }

  // ignore: non_constant_identifier_names
  Future<dynamic> GetMessages(String profile, int handle, int index, int count) async {
    var getMessagesC = library.lookup<NativeFunction<get_json_blob_from_str_int_int_int_function>>("c_GetMessages");
    // ignore: non_constant_identifier_names
    final GetMessages = getMessagesC.asFunction<GetJsonBlobFromStrIntIntIntFn>();
    final utf8profile = profile.toNativeUtf8();
    Pointer<Utf8> jsonMessageBytes = GetMessages(utf8profile, utf8profile.length, handle, index, count);
    String jsonMessage = jsonMessageBytes.toDartString();
    _UnsafeFreePointerAnyUseOfThisFunctionMustBeDoubleApproved(jsonMessageBytes);
    malloc.free(utf8profile);

    return jsonMessage;
  }

  @override
  // ignore: non_constant_identifier_names
  void SendProfileEvent(String onion, String json) {
    var sendAppBusEvent = library.lookup<NativeFunction<string_string_to_void_function>>("c_SendProfileEvent");
    // ignore: non_constant_identifier_names
    final SendAppBusEvent = sendAppBusEvent.asFunction<StringStringFn>();
    final utf8onion = onion.toNativeUtf8();
    final utf8json = json.toNativeUtf8();
    SendAppBusEvent(utf8onion, utf8onion.length, utf8json, utf8json.length);
    malloc.free(utf8onion);
    malloc.free(utf8json);
  }

  @override
  // ignore: non_constant_identifier_names
  void SendAppEvent(String json) {
    var sendAppBusEvent = library.lookup<NativeFunction<string_to_void_function>>("c_SendAppEvent");
    // ignore: non_constant_identifier_names
    final SendAppBusEvent = sendAppBusEvent.asFunction<StringFn>();
    final utf8json = json.toNativeUtf8();
    SendAppBusEvent(utf8json, utf8json.length);
    malloc.free(utf8json);
  }

  @override
  // ignore: non_constant_identifier_names
  void AcceptContact(String profileOnion, int contactHandle) {
    var acceptContact = library.lookup<NativeFunction<string_int_to_void_function>>("c_AcceptConversation");
    // ignore: non_constant_identifier_names
    final AcceptContact = acceptContact.asFunction<VoidFromStringIntFn>();
    final u1 = profileOnion.toNativeUtf8();
    AcceptContact(u1, u1.length, contactHandle);
    malloc.free(u1);
  }

  @override
  // ignore: non_constant_identifier_names
  void BlockContact(String profileOnion, int contactHandle) {
    var blockContact = library.lookup<NativeFunction<string_int_to_void_function>>("c_BlockContact");
    // ignore: non_constant_identifier_names
    final BlockContact = blockContact.asFunction<VoidFromStringIntFn>();
    final u1 = profileOnion.toNativeUtf8();
    BlockContact(u1, u1.length, contactHandle);
    malloc.free(u1);
  }

  @override
  // ignore: non_constant_identifier_names
  void UnblockContact(String profileOnion, int contactHandle) {
    var unblockContact = library.lookup<NativeFunction<string_int_to_void_function>>("c_UnblockContact");
    // ignore: non_constant_identifier_names
    final UnblockContact = unblockContact.asFunction<VoidFromStringIntFn>();
    final u1 = profileOnion.toNativeUtf8();
    UnblockContact(u1, u1.length, contactHandle);
    malloc.free(u1);
  }

  @override
  // ignore: non_constant_identifier_names
  Future<dynamic> SendMessage(String profileOnion, int contactHandle, String message) async {
    var sendMessage = library.lookup<NativeFunction<get_json_blob_from_string_int_string_function>>("c_SendMessage");
    // ignore: non_constant_identifier_names
    final SendMessage = sendMessage.asFunction<GetJsonBlobFromStrIntStrFn>();
    final u1 = profileOnion.toNativeUtf8();
    final u3 = message.toNativeUtf8();
    Pointer<Utf8> jsonMessageBytes = SendMessage(u1, u1.length, contactHandle, u3, u3.length);
    String jsonMessage = jsonMessageBytes.toDartString();
    _UnsafeFreePointerAnyUseOfThisFunctionMustBeDoubleApproved(jsonMessageBytes);
    malloc.free(u1);
    malloc.free(u3);
    return jsonMessage;
  }

  @override
  // ignore: non_constant_identifier_names
  Future<dynamic> SendInvitation(String profileOnion, int contactHandle, int target) async {
    var sendInvitation = library.lookup<NativeFunction<get_json_blob_from_str_int_int_function>>("c_SendInvitation");
    // ignore: non_constant_identifier_names
    final SendInvitation = sendInvitation.asFunction<GetJsonBlobFromStrIntIntFn>();
    final u1 = profileOnion.toNativeUtf8();
    Pointer<Utf8> jsonMessageBytes = SendInvitation(u1, u1.length, contactHandle, target);
    String jsonMessage = jsonMessageBytes.toDartString();
    _UnsafeFreePointerAnyUseOfThisFunctionMustBeDoubleApproved(jsonMessageBytes);
    malloc.free(u1);
    return jsonMessage;
  }

  @override
  // ignore: non_constant_identifier_names
  Future<dynamic> ShareFile(String profileOnion, int contactHandle, String filepath) async {
    var shareFile = library.lookup<NativeFunction<get_json_blob_from_string_int_string_function>>("c_ShareFile");
    // ignore: non_constant_identifier_names
    final ShareFile = shareFile.asFunction<GetJsonBlobFromStrIntStrFn>();
    final u1 = profileOnion.toNativeUtf8();
    final u3 = filepath.toNativeUtf8();
    Pointer<Utf8> jsonMessageBytes = ShareFile(u1, u1.length, contactHandle, u3, u3.length);
    String jsonMessage = jsonMessageBytes.toDartString();
    _UnsafeFreePointerAnyUseOfThisFunctionMustBeDoubleApproved(jsonMessageBytes);
    malloc.free(u1);
    malloc.free(u3);
    return jsonMessage;
  }

  @override
  // ignore: non_constant_identifier_names
  void DownloadFile(String profileOnion, int contactHandle, String filepath, String manifestpath, String filekey) {
    var dlFile = library.lookup<NativeFunction<void_from_string_int_string_string_string_function>>("c_DownloadFile");
    // ignore: non_constant_identifier_names
    final DownloadFile = dlFile.asFunction<VoidFromStringIntStringStringStringFn>();
    final u1 = profileOnion.toNativeUtf8();
    final u3 = filepath.toNativeUtf8();
    final u4 = manifestpath.toNativeUtf8();
    final u5 = filekey.toNativeUtf8();
    DownloadFile(u1, u1.length, contactHandle, u3, u3.length, u4, u4.length, u5, u5.length);
    malloc.free(u1);
    malloc.free(u3);
    malloc.free(u4);
    malloc.free(u5);
  }

  @override
  // ignore: non_constant_identifier_names
  void CreateDownloadableFile(String profileOnion, int contactHandle, String filenameSuggestion, String filekey) {
    // android only - do nothing
  }

  // ignore: non_constant_identifier_names
  void ExportPreviewedFile(String sourceFile, String suggestion) {
    // android only - do nothing
  }

  @override
  // ignore: non_constant_identifier_names
  void CheckDownloadStatus(String profileOnion, String fileKey) {
    var checkDownloadStatus = library.lookup<NativeFunction<string_string_to_void_function>>("c_CheckDownloadStatus");
    // ignore: non_constant_identifier_names
    final CheckDownloadStatus = checkDownloadStatus.asFunction<VoidFromStringStringFn>();
    final u1 = profileOnion.toNativeUtf8();
    final u2 = fileKey.toNativeUtf8();
    CheckDownloadStatus(u1, u1.length, u2, u2.length);
    malloc.free(u1);
    malloc.free(u2);
  }

  @override
  // ignore: non_constant_identifier_names
  void VerifyOrResumeDownload(String profileOnion, int contactHandle, String filekey) {
    var fn = library.lookup<NativeFunction<void_from_string_int_string_function>>("c_VerifyOrResumeDownload");
    // ignore: non_constant_identifier_names
    final VerifyOrResumeDownload = fn.asFunction<VoidFromStringIntStringFn>();
    final u1 = profileOnion.toNativeUtf8();
    final u3 = filekey.toNativeUtf8();
    VerifyOrResumeDownload(u1, u1.length, contactHandle, u3, u3.length);
    malloc.free(u1);
    malloc.free(u3);
  }

  @override
  // ignore: non_constant_identifier_names
  void ResetTor() {
    var resetTor = library.lookup<NativeFunction<Void Function()>>("c_ResetTor");
    // ignore: non_constant_identifier_names
    final ResetTor = resetTor.asFunction<void Function()>();
    ResetTor();
  }

  @override
  // ignore: non_constant_identifier_names
  void ImportBundle(String profileOnion, String bundle) {
    var importBundle = library.lookup<NativeFunction<string_string_to_void_function>>("c_ImportBundle");
    // ignore: non_constant_identifier_names
    final ImportBundle = importBundle.asFunction<VoidFromStringStringFn>();
    final u1 = profileOnion.toNativeUtf8();
    final u2 = bundle.toNativeUtf8();
    ImportBundle(u1, u1.length, u2, u2.length);
    malloc.free(u1);
    malloc.free(u2);
  }

  @override
  // ignore: non_constant_identifier_names
  void CreateGroup(String profileOnion, String server, String groupName) {
    var createGroup = library.lookup<NativeFunction<void_from_string_string_string_function>>("c_CreateGroup");
    // ignore: non_constant_identifier_names
    final CreateGroup = createGroup.asFunction<VoidFromStringStringStringFn>();
    final u1 = profileOnion.toNativeUtf8();
    final u2 = server.toNativeUtf8();
    final u3 = groupName.toNativeUtf8();
    CreateGroup(u1, u1.length, u2, u2.length, u3, u3.length);

    malloc.free(u1);
    malloc.free(u2);
    malloc.free(u3);
  }

  @override
  // ignore: non_constant_identifier_names
  void ArchiveConversation(String profileOnion, int handle) {
    var archiveConversation = library.lookup<NativeFunction<string_int_to_void_function>>("c_ArchiveConversation");
    // ignore: non_constant_identifier_names
    final ArchiveConversation = archiveConversation.asFunction<VoidFromStringIntFn>();
    final u1 = profileOnion.toNativeUtf8();
    ArchiveConversation(u1, u1.length, handle);
    malloc.free(u1);
  }

  @override
  // ignore: non_constant_identifier_names
  void DeleteContact(String profileOnion, int handle) {
    var deleteContact = library.lookup<NativeFunction<string_int_to_void_function>>("c_DeleteContact");
    // ignore: non_constant_identifier_names
    final DeleteContact = deleteContact.asFunction<VoidFromStringIntFn>();
    final u1 = profileOnion.toNativeUtf8();
    DeleteContact(u1, u1.length, handle);
    malloc.free(u1);
  }

  @override
  // ignore: non_constant_identifier_names
  void DeleteProfile(String onion, String currentPassword) {
    var deleteprofile = library.lookup<NativeFunction<string_string_to_void_function>>("c_DeleteProfile");
    // ignore: non_constant_identifier_names
    final DeleteProfile = deleteprofile.asFunction<VoidFromStringStringFn>();
    final u1 = onion.toNativeUtf8();
    final u2 = currentPassword.toNativeUtf8();
    DeleteProfile(u1, u1.length, u2, u2.length);
    malloc.free(u1);
    malloc.free(u2);
  }

  @override
  // ignore: non_constant_identifier_names
  void SetProfileAttribute(String profile, String key, String val) {
    var setProfileAttribute = library.lookup<NativeFunction<void_from_string_string_string_function>>("c_SetProfileAttribute");
    // ignore: non_constant_identifier_names
    final SetProfileAttribute = setProfileAttribute.asFunction<VoidFromStringStringStringFn>();
    final u1 = profile.toNativeUtf8();
    final u2 = key.toNativeUtf8();
    final u3 = val.toNativeUtf8();
    SetProfileAttribute(u1, u1.length, u2, u2.length, u3, u3.length);
    malloc.free(u1);
    malloc.free(u2);
    malloc.free(u3);
  }

  @override
  // ignore: non_constant_identifier_names
  void SetConversationAttribute(String profile, int contact, String key, String val) {
    var setContactAttribute = library.lookup<NativeFunction<void_from_string_int_string_string_function>>("c_SetConversationAttribute");
    // ignore: non_constant_identifier_names
    final SetContactAttribute = setContactAttribute.asFunction<VoidFromStringIntStringStringFn>();
    final u1 = profile.toNativeUtf8();
    final u3 = key.toNativeUtf8();
    final u4 = val.toNativeUtf8();
    SetContactAttribute(u1, u1.length, contact, u3, u3.length, u4, u4.length);
    malloc.free(u1);
    malloc.free(u3);
    malloc.free(u4);
  }

  @override
  // ignore: non_constant_identifier_names
  void SetMessageAttribute(String profile, int conversation, int channel, int message, String key, String val) {
    var setMessageAttribute = library.lookup<NativeFunction<void_from_string_int_int_int_string_string_function>>("c_SetMessageAttribute");
    // ignore: non_constant_identifier_names
    final SetMessageAttribute = setMessageAttribute.asFunction<VoidFromStringIntIntIntStringStringFn>();
    final u1 = profile.toNativeUtf8();
    final u3 = key.toNativeUtf8();
    final u4 = val.toNativeUtf8();
    SetMessageAttribute(u1, u1.length, conversation, channel, message, u3, u3.length, u4, u4.length);
    malloc.free(u1);
    malloc.free(u3);
    malloc.free(u4);
  }

  @override
  // ignore: non_constant_identifier_names
  void LoadServers(String password) {
    var loadServers = library.lookup<NativeFunction<string_to_void_function>>("c_LoadServers");
    // ignore: non_constant_identifier_names
    final LoadServers = loadServers.asFunction<StringFn>();
    final u1 = password.toNativeUtf8();
    LoadServers(u1, u1.length);
    malloc.free(u1);
  }

  @override
  // ignore: non_constant_identifier_names
  void CreateServer(String password, String description, bool autostart) {
    var createServer = library.lookup<NativeFunction<void_from_string_string_byte_function>>("c_CreateServer");
    // ignore: non_constant_identifier_names
    final CreateServer = createServer.asFunction<VoidFromStringStringByteFn>();
    final u1 = password.toNativeUtf8();
    final u2 = description.toNativeUtf8();
    CreateServer(u1, u1.length, u2, u2.length, autostart ? 1 : 0);
    malloc.free(u1);
    malloc.free(u2);
  }

  @override
  // ignore: non_constant_identifier_names
  void DeleteServer(String serverOnion, String password) {
    var deleteServer = library.lookup<NativeFunction<string_string_to_void_function>>("c_DeleteServer");
    // ignore: non_constant_identifier_names
    final DeleteServer = deleteServer.asFunction<VoidFromStringStringFn>();
    final u1 = serverOnion.toNativeUtf8();
    final u2 = password.toNativeUtf8();
    DeleteServer(u1, u1.length, u2, u2.length);
    malloc.free(u1);
    malloc.free(u2);
  }

  @override
  // ignore: non_constant_identifier_names
  void LaunchServers() {
    var launchServers = library.lookup<NativeFunction<Void Function()>>("c_LaunchServers");
    // ignore: non_constant_identifier_names
    final LaunchServers = launchServers.asFunction<void Function()>();
    LaunchServers();
  }

  @override
  // ignore: non_constant_identifier_names
  void LaunchServer(String serverOnion) {
    var launchServer = library.lookup<NativeFunction<string_to_void_function>>("c_LaunchServer");
    // ignore: non_constant_identifier_names
    final LaunchServer = launchServer.asFunction<StringFn>();
    final u1 = serverOnion.toNativeUtf8();
    LaunchServer(u1, u1.length);
    malloc.free(u1);
  }

  @override
  // ignore: non_constant_identifier_names
  void StopServer(String serverOnion) {
    var shutdownServer = library.lookup<NativeFunction<string_to_void_function>>("c_StopServer");
    // ignore: non_constant_identifier_names
    final ShutdownServer = shutdownServer.asFunction<StringFn>();
    final u1 = serverOnion.toNativeUtf8();
    ShutdownServer(u1, u1.length);
    malloc.free(u1);
  }

  @override
  // ignore: non_constant_identifier_names
  void StopServers() {
    var shutdownServers = library.lookup<NativeFunction<Void Function()>>("c_StopServers");
    // ignore: non_constant_identifier_names
    final ShutdownServers = shutdownServers.asFunction<void Function()>();
    ShutdownServers();
  }

  @override
  // ignore: non_constant_identifier_names
  void DestroyServers() {
    var destroyServers = library.lookup<NativeFunction<Void Function()>>("c_DestroyServers");
    // ignore: non_constant_identifier_names
    final DestroyServers = destroyServers.asFunction<void Function()>();
    DestroyServers();
  }

  @override
  // ignore: non_constant_identifier_names
  void SetServerAttribute(String serverOnion, String key, String val) {
    var setServerAttribute = library.lookup<NativeFunction<void_from_string_string_string_function>>("c_SetServerAttribute");
    // ignore: non_constant_identifier_names
    final SetServerAttribute = setServerAttribute.asFunction<VoidFromStringStringStringFn>();
    final u1 = serverOnion.toNativeUtf8();
    final u2 = key.toNativeUtf8();
    final u3 = val.toNativeUtf8();
    SetServerAttribute(u1, u1.length, u2, u2.length, u3, u3.length);
    malloc.free(u1);
    malloc.free(u2);
    malloc.free(u3);
  }

  @override
  // ignore: non_constant_identifier_names
  Future<void> Shutdown() async {
    var shutdown = library.lookup<NativeFunction<void_from_void_funtion>>("c_ShutdownCwtch");
    // ignore: non_constant_identifier_names

    // Shutdown Cwtch + Tor...
    // ignore: non_constant_identifier_names
    final Shutdown = shutdown.asFunction<VoidFromVoidFunction>();
    Shutdown();

    // Kill our Isolate
    cwtchIsolate.kill(priority: Isolate.immediate);
    print("Isolate killed");

    _receivePort.close();
    print("Receive Port Closed");
  }

  @override
  // ignore: non_constant_identifier_names
  Future GetMessageByContentHash(String profile, int handle, String contentHash) async {
    var getMessagesByContentHashC = library.lookup<NativeFunction<get_json_blob_from_str_int_string_function>>("c_GetMessagesByContentHash");
    // ignore: non_constant_identifier_names
    final GetMessagesByContentHash = getMessagesByContentHashC.asFunction<GetJsonBlobFromStrIntStringFn>();
    final utf8profile = profile.toNativeUtf8();
    final utf8contentHash = contentHash.toNativeUtf8();
    Pointer<Utf8> jsonMessageBytes = GetMessagesByContentHash(utf8profile, utf8profile.length, handle, utf8contentHash, utf8contentHash.length);
    String jsonMessage = jsonMessageBytes.toDartString();

    _UnsafeFreePointerAnyUseOfThisFunctionMustBeDoubleApproved(jsonMessageBytes);
    malloc.free(utf8profile);
    malloc.free(utf8contentHash);
    return jsonMessage;
  }

  // ignore: non_constant_identifier_names
  // Incredibly dangerous function which invokes a free in libCwtch, should only be used
  // as documented in `MEMORY.md` in libCwtch repo.
  void _UnsafeFreePointerAnyUseOfThisFunctionMustBeDoubleApproved(Pointer<Utf8> ptr) {
    var free = library.lookup<NativeFunction<free_function>>("c_FreePointer");
    final Free = free.asFunction<FreeFn>();
    Free(ptr);
  }

  @override
  String defaultDownloadPath() {
    Map<String, String> envVars = Platform.environment;
    return path.join(envVars[Platform.isWindows ? 'UserProfile' : 'HOME']!, "Downloads");
  }

  @override
  // ignore: non_constant_identifier_names
  Future<String> GetMessageByID(String profile, int handle, int index) async {
    var getMessageC = library.lookup<NativeFunction<get_json_blob_from_str_int_int_function>>("c_GetMessageByID");
    // ignore: non_constant_identifier_names
    final GetMessage = getMessageC.asFunction<GetJsonBlobFromStrIntIntFn>();
    final utf8profile = profile.toNativeUtf8();
    Pointer<Utf8> jsonMessageBytes = GetMessage(utf8profile, utf8profile.length, handle, index);
    String jsonMessage = jsonMessageBytes.toDartString();
    _UnsafeFreePointerAnyUseOfThisFunctionMustBeDoubleApproved(jsonMessageBytes);
    malloc.free(utf8profile);
    return jsonMessage;
  }

  @override
  // ignore: non_constant_identifier_names
  void ChangePassword(String profile, String pass, String newpass, String newpassAgain) {
    var changePasswordC = library.lookup<NativeFunction<void_from_string_string_string_string_function>>("c_ChangePassword");
    // ignore: non_constant_identifier_names
    final ChangePasswordFn = changePasswordC.asFunction<VoidFromStringStringStringStringFn>();
    final utf8profile = profile.toNativeUtf8();
    final utf8pass = pass.toNativeUtf8();
    final utf8newpass = newpass.toNativeUtf8();
    final utf8newpasssagain = newpassAgain.toNativeUtf8();
    ChangePasswordFn(utf8profile, utf8profile.length, utf8pass, utf8pass.length, utf8newpass, utf8newpass.length, utf8newpasssagain, utf8newpasssagain.length);
    malloc.free(utf8profile);
    malloc.free(utf8pass);
    malloc.free(utf8newpass);
    malloc.free(utf8newpasssagain);
  }

  @override
  bool isL10nInit() {
    return _isL10nInit;
  }

  @override
  void l10nInit(String notificationSimple, String notificationConversationInfo) {
    cwtchNotifier.l10nInit(notificationSimple, notificationConversationInfo);
    _isL10nInit = true;
  }

  @override
  // ignore: non_constant_identifier_names
  void ExportProfile(String profile, String file) {
    final utf8profile = profile.toNativeUtf8();
    final utf8file = file.toNativeUtf8();
    var exportProfileC = library.lookup<NativeFunction<void_from_string_string_function>>("c_ExportProfile");
    // ignore: non_constant_identifier_names
    final ExportProfileFn = exportProfileC.asFunction<VoidFromStringStringFn>();
    ExportProfileFn(utf8profile, utf8profile.length, utf8file, utf8file.length);
    malloc.free(utf8profile);
    malloc.free(utf8file);
  }

  @override
  // ignore: non_constant_identifier_names
  Future<String> ImportProfile(String file, String pass) async {
    final utf8pass = pass.toNativeUtf8();
    final utf8file = file.toNativeUtf8();
    var exportProfileC = library.lookup<NativeFunction<string_string_to_string_function>>("c_ImportProfile");
    // ignore: non_constant_identifier_names
    final ExportProfileFn = exportProfileC.asFunction<StringFromStringStringFn>();
    Pointer<Utf8> result = ExportProfileFn(utf8file, utf8file.length, utf8pass, utf8pass.length);
    String importResult = result.toDartString();
    _UnsafeFreePointerAnyUseOfThisFunctionMustBeDoubleApproved(result);
    malloc.free(utf8pass);
    malloc.free(utf8file);
    return importResult;
  }

  @override
  Future<String> GetDebugInfo() async {
    var getDebugInfo = library.lookup<NativeFunction<void_to_string>>("c_GetDebugInfo");
    final GetDebugInfo = getDebugInfo.asFunction<StringFromVoid>();
    Pointer<Utf8> result = GetDebugInfo();
    String debugResult = result.toDartString();
    _UnsafeFreePointerAnyUseOfThisFunctionMustBeDoubleApproved(result);
    return debugResult;
  }
}

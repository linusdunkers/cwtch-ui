import 'dart:async';
import 'dart:convert';
import 'package:cwtch/config.dart';
import 'package:cwtch/notification_manager.dart';
import 'package:cwtch/themes/cwtch.dart';
import 'package:cwtch/views/doublecolview.dart';
import 'package:cwtch/views/messageview.dart';
import 'package:flutter/foundation.dart';
import 'package:cwtch/cwtch/ffi.dart';
import 'package:cwtch/cwtch/gomobile.dart';
import 'package:flutter/material.dart';
import 'package:cwtch/errorHandler.dart';
import 'package:cwtch/settings.dart';
import 'package:cwtch/torstatus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'cwtch/cwtch.dart';
import 'cwtch/cwtchNotifier.dart';
import 'l10n/custom_material_delegate.dart';
import 'licenses.dart';
import 'models/appstate.dart';
import 'models/contactlist.dart';
import 'models/profile.dart';
import 'models/profilelist.dart';
import 'models/servers.dart';
import 'views/profilemgrview.dart';
import 'views/splashView.dart';
import 'dart:io' show Platform, exit;
import 'themes/opaque.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:intl/intl.dart' as intl;

var globalSettings = Settings(Locale("en", ''), CwtchDark());
var globalErrorHandler = ErrorHandler();
var globalTorStatus = TorStatus();
var globalAppState = AppState();
var globalServersList = ServerListState();

Future<void> main() async {
  print("Cwtch version: ${EnvironmentConfig.BUILD_VER} built on: ${EnvironmentConfig.BUILD_DATE}");
  LicenseRegistry.addLicense(() => licenses());
  WidgetsFlutterBinding.ensureInitialized();
  print("runApp()");
  return runApp(Flwtch());
}

class Flwtch extends StatefulWidget {
  final Key flwtch = GlobalKey();

  @override
  FlwtchState createState() => FlwtchState();
}

enum ConnectivityState { assumed_online, confirmed_offline, confirmed_online }

class FlwtchState extends State<Flwtch> with WindowListener {
  late Cwtch cwtch;
  late ProfileListState profs;
  final MethodChannel notificationClickChannel = MethodChannel('im.cwtch.flwtch/notificationClickHandler');
  final MethodChannel shutdownMethodChannel = MethodChannel('im.cwtch.flwtch/shutdownClickHandler');
  final MethodChannel shutdownLinuxMethodChannel = MethodChannel('im.cwtch.linux.shutdown');
  late StreamSubscription? connectivityStream;
  ConnectivityState connectivityState = ConnectivityState.assumed_online;

  final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

  Future<dynamic> shutdownDirect(MethodCall call) async {
    EnvironmentConfig.debugLog("$call");
    await cwtch.Shutdown();
    return Future.value({});
  }

  @override
  initState() {
    globalSettings = Settings(Locale("en", ''), CwtchDark());
    globalErrorHandler = ErrorHandler();
    globalTorStatus = TorStatus();
    globalAppState = AppState();
    globalServersList = ServerListState();

    print("initState: running...");
    windowManager.addListener(this);


    print("initState: registering notification, shutdown handlers...");
    profs = ProfileListState();
    notificationClickChannel.setMethodCallHandler(_externalNotificationClicked);
    shutdownMethodChannel.setMethodCallHandler(modalShutdown);
    shutdownLinuxMethodChannel.setMethodCallHandler(shutdownDirect);
    print("initState: creating cwtchnotifier, ffi");
    if (Platform.isAndroid) {
      var cwtchNotifier = new CwtchNotifier(profs, globalSettings, globalErrorHandler, globalTorStatus, NullNotificationsManager(), globalAppState, globalServersList, this);
      cwtch = CwtchGomobile(cwtchNotifier);
    } else if (Platform.isLinux) {
      var cwtchNotifier =
          new CwtchNotifier(profs, globalSettings, globalErrorHandler, globalTorStatus, newDesktopNotificationsManager(_notificationSelectConvo), globalAppState, globalServersList, this);
      cwtch = CwtchFfi(cwtchNotifier);
    } else {
      var cwtchNotifier =
          new CwtchNotifier(profs, globalSettings, globalErrorHandler, globalTorStatus, newDesktopNotificationsManager(_notificationSelectConvo), globalAppState, globalServersList, this);
      cwtch = CwtchFfi(cwtchNotifier);
    }
    startConnectivityListener();
    print("initState: invoking cwtch.Start()");
    cwtch.Start();
    print("initState: done!");
    super.initState();
  }

  // connectivity listening is an optional enhancement feature that tries to listen for OS events about the network
  // and if it detects coming back online, restarts the ACN/tor
  // gracefully fails and NOPs, as it's not a required functionality
  startConnectivityListener() async {
    try {
      connectivityStream = await Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
        // Got a new connectivity status!
        if (result == ConnectivityResult.none) {
          connectivityState = ConnectivityState.confirmed_offline;
        } else {
          // were we offline?
          if (connectivityState == ConnectivityState.confirmed_offline) {
            EnvironmentConfig.debugLog("Network appears to have come back online, restarting Tor");
            cwtch.ResetTor();
          }
          connectivityState = ConnectivityState.confirmed_online;
        }
      }, onError: (Object error) {
        print("Error listening to connectivity for network state: {$error}");
        return null;
      }, cancelOnError: true);
    } catch (e) {
      print("Warning: Unable to open connectivity for listening to network state: {$e}");
      connectivityStream = null;
    }
  }

  ChangeNotifierProvider<TorStatus> getTorStatusProvider() => ChangeNotifierProvider.value(value: globalTorStatus);
  ChangeNotifierProvider<ErrorHandler> getErrorHandlerProvider() => ChangeNotifierProvider.value(value: globalErrorHandler);
  ChangeNotifierProvider<Settings> getSettingsProvider() => ChangeNotifierProvider.value(value: globalSettings);
  ChangeNotifierProvider<AppState> getAppStateProvider() => ChangeNotifierProvider.value(value: globalAppState);
  Provider<FlwtchState> getFlwtchStateProvider() => Provider<FlwtchState>(create: (_) => this);
  ChangeNotifierProvider<ProfileListState> getProfileListProvider() => ChangeNotifierProvider(create: (context) => profs);
  ChangeNotifierProvider<ServerListState> getServerListStateProvider() => ChangeNotifierProvider.value(value: globalServersList);

  @override
  Widget build(BuildContext context) {
    globalSettings.initPackageInfo();
    return MultiProvider(
      providers: [
        getFlwtchStateProvider(),
        getProfileListProvider(),
        getSettingsProvider(),
        getErrorHandlerProvider(),
        getTorStatusProvider(),
        getAppStateProvider(),
        getServerListStateProvider(),
      ],
      builder: (context, widget) {
        return Consumer2<Settings, AppState>(
          builder: (context, settings, appState, child) => MaterialApp(
            key: Key('app'),
            navigatorKey: navKey,
            locale: settings.locale,
            showPerformanceOverlay: settings.profileMode,
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              MaterialLocalizationDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            title: 'Cwtch',
            showSemanticsDebugger: settings.useSemanticDebugger,
            theme: mkThemeData(settings),
            home: (!appState.cwtchInit || appState.modalState != ModalState.none) ? SplashView() : ProfileMgrView(),
          ),
        );
      },
    );
  }

  // invoked from either ProfileManagerView's appbar close button, or a ShutdownClicked event on
  // the MyBroadcastReceiver method channel
  Future<void> modalShutdown(MethodCall mc) async {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: Text(AppLocalizations.of(navKey.currentContext!)!.cancel),
      onPressed: () {
        Navigator.of(navKey.currentContext!).pop(); // dismiss dialog
      },
    );
    Widget continueButton = ElevatedButton(
        child: Text(AppLocalizations.of(navKey.currentContext!)!.shutdownCwtchAction),
        onPressed: () {
          Provider.of<AppState>(navKey.currentContext!, listen: false).cwtchIsClosing = true;
          Navigator.of(navKey.currentContext!).pop(); // dismiss dialog
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(navKey.currentContext!)!.shutdownCwtchDialogTitle),
      content: Text(AppLocalizations.of(navKey.currentContext!)!.shutdownCwtchDialog),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: navKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    ).then((val) {
      if (Provider.of<AppState>(navKey.currentContext!, listen: false).cwtchIsClosing) {
        globalAppState.SetModalState(ModalState.shutdown);
        // Directly call the shutdown command, Android will do this for us...
        Provider.of<FlwtchState>(navKey.currentContext!, listen: false).shutdown();
      }
    });
  }

  Future<void> shutdown() async {
    globalAppState.SetModalState(ModalState.shutdown);
    EnvironmentConfig.debugLog("shutting down");
    await cwtch.Shutdown();
    // Wait a few seconds as shutting down things takes a little time..
    {
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        print("Exiting...");
        exit(0);
      }
    }
    ;
  }

  // Invoked via notificationClickChannel by MyBroadcastReceiver in MainActivity.kt
  // coder beware: args["RemotePeer"] is actually a handle, and could be eg a groupID
  Future<void> _externalNotificationClicked(MethodCall call) async {
    var args = jsonDecode(call.arguments);
    _notificationSelectConvo(args["ProfileOnion"], args["Handle"]);
  }

  Future<void> _notificationSelectConvo(String profileOnion, int convoId) async {
    var profile = profs.getProfile(profileOnion)!;
    var convo = profile.contactList.getContact(convoId)!;
    if (profileOnion.isEmpty) {
      return;
    }
    Provider.of<AppState>(navKey.currentContext!, listen: false).initialScrollIndex = convo.unreadMessages;
    convo.unreadMessages = 0;

    // Clear nav path back to root
    while (navKey.currentState!.canPop()) {
      navKey.currentState!.pop();
    }

    Provider.of<AppState>(navKey.currentContext!, listen: false).selectedConversation = null;
    Provider.of<AppState>(navKey.currentContext!, listen: false).selectedProfile = profileOnion;
    Provider.of<AppState>(navKey.currentContext!, listen: false).selectedConversation = convoId;

    Navigator.of(navKey.currentContext!).push(
      PageRouteBuilder(
        settings: RouteSettings(name: "conversations"),
        pageBuilder: (c, a1, a2) {
          return OrientationBuilder(builder: (orientationBuilderContext, orientation) {
            return MultiProvider(
                providers: [ChangeNotifierProvider<ProfileInfoState>.value(value: profile), ChangeNotifierProvider<ContactListState>.value(value: profile.contactList)],
                builder: (innercontext, widget) {
                  var appState = Provider.of<AppState>(navKey.currentContext!);
                  var settings = Provider.of<Settings>(navKey.currentContext!);
                  return settings.uiColumns(appState.isLandscape(innercontext)).length > 1 ? DoubleColumnView() : MessageView();
                });
          });
        },
        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: Duration(milliseconds: 200),
      ),
    );
    // On Gnome follows up a clicked notification with a "Cwtch is ready" notification that takes you to the app. AFAICT just because Gnome is bad
    // https://askubuntu.com/questions/1286206/how-to-skip-the-is-ready-notification-and-directly-open-apps-in-ubuntu-20-4
    windowManager.focus();
  }

  // using windowManager flutter plugin until proper lifecycle management lands in desktop

  @override
  void onWindowFocus() {
    globalAppState.focus = true;
  }

  @override
  void onWindowBlur() {
    globalAppState.focus = false;
  }

  @override
  void dispose() {
    globalAppState.SetModalState(ModalState.shutdown);
    cwtch.Shutdown();
    windowManager.removeListener(this);
    cwtch.dispose();
    connectivityStream?.cancel();
    super.dispose();
  }
}

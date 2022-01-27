import 'dart:convert';
import 'package:cwtch/config.dart';
import 'package:cwtch/notification_manager.dart';
import 'package:cwtch/themes/cwtch.dart';
import 'package:cwtch/views/messageview.dart';
import 'package:flutter/foundation.dart';
import 'package:cwtch/cwtch/ffi.dart';
import 'package:cwtch/cwtch/gomobile.dart';
import 'package:flutter/material.dart';
import 'package:cwtch/errorHandler.dart';
import 'package:cwtch/settings.dart';
import 'package:cwtch/torstatus.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'cwtch/cwtch.dart';
import 'cwtch/cwtchNotifier.dart';
import 'licenses.dart';
import 'model.dart';
import 'models/servers.dart';
import 'views/profilemgrview.dart';
import 'views/splashView.dart';
import 'dart:io' show Platform, exit, sleep;
import 'themes/opaque.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  runApp(Flwtch());
  sleep(Duration(seconds:1));
}

class Flwtch extends StatefulWidget {
  final Key flwtch = GlobalKey();

  @override
  FlwtchState createState() => FlwtchState();

  String yay() {
    return "yay!";
  }
}

class FlwtchState extends State<Flwtch> {
  final TextStyle biggerFont = const TextStyle(fontSize: 18);
  late Cwtch cwtch;
  late ProfileListState profs;
  final MethodChannel notificationClickChannel = MethodChannel('im.cwtch.flwtch/notificationClickHandler');
  final MethodChannel shutdownMethodChannel = MethodChannel('im.cwtch.flwtch/shutdownClickHandler');
  final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

  @override
  initState() {
    print("initState: running...");
    super.initState();

    print("initState: registering notification, shutdown handlers...");
    profs = ProfileListState();
    notificationClickChannel.setMethodCallHandler(_externalNotificationClicked);
    shutdownMethodChannel.setMethodCallHandler(modalShutdown);
    print("initState: creating cwtchnotifier, ffi");
    if (Platform.isAndroid) {
      var cwtchNotifier = new CwtchNotifier(profs, globalSettings, globalErrorHandler, globalTorStatus, NullNotificationsManager(), globalAppState, globalServersList);
      cwtch = CwtchGomobile(cwtchNotifier);
    } else if (Platform.isLinux) {
      var cwtchNotifier = new CwtchNotifier(profs, globalSettings, globalErrorHandler, globalTorStatus, newDesktopNotificationsManager(), globalAppState, globalServersList);
      cwtch = CwtchFfi(cwtchNotifier);
    } else {
      var cwtchNotifier = new CwtchNotifier(profs, globalSettings, globalErrorHandler, globalTorStatus, NullNotificationsManager(), globalAppState, globalServersList);
      cwtch = CwtchFfi(cwtchNotifier);
    }
    print("initState: invoking cwtch.Start()");
    cwtch.Start();
    print("initState: done!");
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
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            title: 'Cwtch',
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
          // Directly call the shutdown command, Android will do this for us...
          Provider.of<FlwtchState>(navKey.currentContext!, listen: false).shutdown();
          Provider.of<AppState>(navKey.currentContext!, listen: false).cwtchIsClosing = true;
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
    );
  }

  Future<void> shutdown() async {
    cwtch.Shutdown();
    // Wait a few seconds as shutting down things takes a little time..
    Future.delayed(Duration(seconds: 2)).then((value) {
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        print("Exiting...");
        exit(0);
      }
    });
  }

  // Invoked via notificationClickChannel by MyBroadcastReceiver in MainActivity.kt
  // coder beware: args["RemotePeer"] is actually a handle, and could be eg a groupID
  Future<void> _externalNotificationClicked(MethodCall call) async {
    var args = jsonDecode(call.arguments);
    var profile = profs.getProfile(args["ProfileOnion"])!;
    var convo = profile.contactList.getContact(args["Handle"])!;
    Provider.of<AppState>(navKey.currentContext!, listen: false).initialScrollIndex = convo.unreadMessages;
    convo.unreadMessages = 0;

    // single pane mode pushes; double pane mode reads AppState.selectedProfile/Conversation
    var isLandscape = Provider.of<AppState>(navKey.currentContext!, listen: false).isLandscape(navKey.currentContext!);
    if (Provider.of<Settings>(navKey.currentContext!, listen: false).uiColumns(isLandscape).length == 1) {
      while (navKey.currentState!.canPop()) {
        print("messageview already open; popping before pushing replacement");
        navKey.currentState!.pop();
      }
      navKey.currentState?.push(
        MaterialPageRoute<void>(
          builder: (BuildContext builderContext) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: profile),
                ChangeNotifierProvider.value(value: convo),
              ],
              builder: (context, child) => MessageView(),
            );
          },
        ),
      );
    } else {
      //dual pane
      Provider.of<AppState>(navKey.currentContext!, listen: false).selectedProfile = args["ProfileOnion"];
      Provider.of<AppState>(navKey.currentContext!, listen: false).selectedConversation = args["Handle"];
    }
  }

  @override
  void dispose() {
    cwtch.Shutdown();
    cwtch.dispose();
    super.dispose();
  }
}

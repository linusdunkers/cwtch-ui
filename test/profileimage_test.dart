// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:cwtch/themes/opaque.dart';
import 'package:cwtch/settings.dart';
import 'package:cwtch/widgets/profileimage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

var settingsEnglishDark = Settings(Locale("en", ''), OpaqueDark());
var settingsEnglishLight = Settings(Locale("en", ''), OpaqueLight());
ChangeNotifierProvider<Settings> getSettingsEnglishDark() => ChangeNotifierProvider.value(value: settingsEnglishDark);

String file(String slug) {
  return "profileimage_" + slug + ".png";
}

void main() {

  testWidgets('ProfileImage widget test', (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = Size(200, 200);
    // await tester.pumpWidget(MultiProvider(
    //     providers:[getSettingsEnglishDark()],
    //     child: Directionality(textDirection: TextDirection.ltr, child: CwtchLabel(label: testingStr))
    // ));

    Widget testWidget = ProfileImage(
      imagePath: "profiles/001-centaur.png",
      badgeTextColor: settingsEnglishDark.theme.portraitProfileBadgeTextColor,
      badgeColor: settingsEnglishDark.theme.portraitProfileBadgeColor,
      maskOut: false,
      border: settingsEnglishDark.theme.portraitOfflineBorderColor,
      diameter: 64.0,
      badgeCount: 10,
    );

    Widget testHarness = MultiProvider(
        providers:[getSettingsEnglishDark()],
        builder: (context, child) { return MaterialApp(
          locale: Provider.of<Settings>(context).locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          title: 'Test',
          theme: mkThemeData(Provider.of<Settings>(context)),
          home: Card(child: testWidget),
        );}
    );

    // Verify that our counter starts at 0.
    //expect(find.text(testingStr), findsOneWidget);
    //expect(find.text('1'), findsNothing);

    await tester.pumpWidget(testHarness);
    await expectLater(find.byWidget(testHarness), matchesGoldenFile(file('init')));

    // Tap the '+' icon and trigger a frame.
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();
    //
    // // Verify that our counter has incremented.
    // expect(find.text('0'), findsNothing);
    // expect(find.text('1'), findsOneWidget);
  });
}

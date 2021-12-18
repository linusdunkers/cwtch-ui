// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:cwtch/themes/cwtch.dart';
import 'package:flutter/material.dart';
import 'package:cwtch/themes/opaque.dart';
import 'package:cwtch/settings.dart';
import 'package:cwtch/widgets/cwtchlabel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

var settingsEnglishDark = Settings(Locale("en", ''), CwtchDark());
var settingsEnglishLight = Settings(Locale("en", ''), CwtchLight());
ChangeNotifierProvider<Settings> getSettingsEnglishDark() => ChangeNotifierProvider.value(value: settingsEnglishDark);

void main() {
  testWidgets('CwtchLabel widget test', (WidgetTester tester) async {
    final String testingStr = "A wonderful label";

    // await tester.pumpWidget(MultiProvider(
    //     providers:[getSettingsEnglishDark()],
    //     child: Directionality(textDirection: TextDirection.ltr, child: CwtchLabel(label: testingStr))
    // ));

    await tester.pumpWidget(MultiProvider(
        providers:[getSettingsEnglishDark()],
        builder: (context, child) { return MaterialApp(
          locale: Provider.of<Settings>(context).locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          title: 'Test',
          theme: mkThemeData(Provider.of<Settings>(context)),
          home: CwtchLabel(label: testingStr),
        );}
    ));

    // Verify that our counter starts at 0.
    expect(find.text(testingStr), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await expectLater(find.text(testingStr), matchesGoldenFile('cwtchlabel01.png'));

    // Tap the '+' icon and trigger a frame.
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();
    //
    // // Verify that our counter has incremented.
    // expect(find.text('0'), findsNothing);
    // expect(find.text('1'), findsOneWidget);
  });
}

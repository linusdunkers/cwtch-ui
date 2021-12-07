// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:cwtch/themes/opaque.dart';
import 'package:cwtch/settings.dart';
import 'package:cwtch/widgets/buttontextfield.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

var settingsEnglishDark = Settings(Locale("en", ''), OpaqueDark());
var settingsEnglishLight = Settings(Locale("en", ''), OpaqueLight());
ChangeNotifierProvider<Settings> getSettingsEnglishDark() => ChangeNotifierProvider.value(value: settingsEnglishDark);

void main() {
  testWidgets('CwtchButtonTextField widget test', (WidgetTester tester) async {
    final String testingStr = "A wonderful label";
    final TextEditingController ctrlr1 = TextEditingController(text: testingStr);

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
          home: Card(child: CwtchButtonTextField(
              icon: Icon(Icons.bug_report_outlined),
              tooltip: testingStr,
              controller: ctrlr1, onPressed: () {  },
          )),
        );}
    ));

    // Verify that our counter starts at 0.
    expect(find.text(testingStr), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await expectLater(find.text(testingStr), matchesGoldenFile('buttontextfield01.png'));

    // Tap the '+' icon and trigger a frame.
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();
    //
    // // Verify that our counter has incremented.
    // expect(find.text('0'), findsNothing);
    // expect(find.text('1'), findsOneWidget);
  });
}

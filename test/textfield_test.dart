// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:cwtch/themes/opaque.dart';
import 'package:cwtch/themes/cwtch.dart';
import 'package:cwtch/settings.dart';
import 'package:cwtch/widgets/textfield.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

var settingsEnglishDark = Settings(Locale("en", ''), CwtchDark());
var settingsEnglishLight = Settings(Locale("en", ''), CwtchLight());
ChangeNotifierProvider<Settings> getSettingsEnglishDark() => ChangeNotifierProvider.value(value: settingsEnglishDark);

String file(String slug) {
  return "textfield_" + slug + ".png";
}

void main() {
  testWidgets('Textfield widget test', (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = Size(800, 300);
    final TextEditingController ctrlr1 = TextEditingController();

    Widget testWidget = CwtchTextField(controller: ctrlr1, validator: (value) {  }, hintText: '',);

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

    // Check base state appearance
    await tester.pumpWidget(testHarness);
    await expectLater(find.byWidget(testHarness), matchesGoldenFile(file('init')));

    // Type "hello there"
    await tester.tap(find.byWidget(testWidget));
    await tester.pump();
    await tester.enterText(find.byWidget(testWidget), "hello there");
    await tester.pumpAndSettle();
    await expectLater(find.byWidget(testHarness), matchesGoldenFile(file('basic')));

    // Verify that text is displayed normally
    expect(find.text("hello there"), findsOneWidget);
    expect(find.text('nada'), findsNothing);
  });

  //=\\

  testWidgets('Textfield form validation test', (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = Size(800, 300);
    final formKey = GlobalKey<FormState>();
    final TextEditingController ctrlr1 = TextEditingController();
    final String strLabel1 = "Age (*Required)";
    final String strFail1 = "Required field";
    final String strFail2 = "Please enter an integer";

    Widget testWidget = CwtchTextField(
      controller: ctrlr1,
      hintText: strLabel1,
      validator: (value) {
        if (value == null || value == "") return strFail1;
        final number = num.tryParse(value);
        if (number == null) return strFail2;
        return null;
      },
      onChanged: (value) => formKey.currentState!.validate(),
    );

    Widget testHarness = MultiProvider(
        providers: [getSettingsEnglishDark()],
        builder: (context, child) {
          return MaterialApp(
            locale: Provider
                .of<Settings>(context)
                .locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            title: 'Test',
            theme: mkThemeData(Provider.of<Settings>(context)),
            home: Card(child: Form(key: formKey, child: testWidget)),
          );
        }
    );

    // Check base state appearance
    await tester.pumpWidget(testHarness);
    await expectLater(find.byWidget(testHarness), matchesGoldenFile(file('form_init')));
    expect(find.text(strLabel1), findsOneWidget);

    // 42
    await tester.tap(find.byWidget(testWidget));
    await tester.pump();
    await tester.enterText(find.byWidget(testWidget), "42");
    await tester.pumpAndSettle();
    await expectLater(find.byWidget(testHarness), matchesGoldenFile(file('form_42')));
    expect(find.text("42"), findsOneWidget);
    expect(find.text(strFail1), findsNothing);
    expect(find.text(strFail2), findsNothing);
    ctrlr1.clear();
    await tester.pumpAndSettle();

    // alpha quadrant
    await tester.tap(find.byWidget(testWidget));
    await tester.pump();
    await tester.enterText(find.byWidget(testWidget), "alpha quadrant");
    await tester.pumpAndSettle();
    await expectLater(find.byWidget(testHarness), matchesGoldenFile(file('form_alpha')));
    expect(find.text("alpha quadrant"), findsOneWidget);
    expect(find.text(strFail1), findsNothing);
    expect(find.text(strFail2), findsOneWidget);
    ctrlr1.clear();
    await tester.pumpAndSettle();

    // empty string
    formKey.currentState!.validate(); //(ctrlr1.clear() doesn't trigger validate like keypress does)
    await tester.pumpAndSettle();
    await expectLater(find.byWidget(testHarness), matchesGoldenFile(file('form_final')));
    expect(find.text(strFail1), findsOneWidget);
    expect(find.text(strFail2), findsNothing);
  });
}

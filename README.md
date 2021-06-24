# flwtch

A Flutter based Cwtch UI

## Getting Started

click the play button in android studio

### Linux

- libCwtch-go: required to be on the link path (linux/cwtch.destktop demonstrates with `env LD_LIBRARY_PATH=./lib/` on the front of the comman)
	- fetch-libcwtch-go.sh will fetch a prebuilt version
	- or compile from source from libcwtch-go with `make linux`
- `tor` should be in the PATH

### Windows

- run `fetch-libcwtch-go.ps1` to get `libCwtch.dll` which is required to run
- run `fetch-tor-win.ps1` to fetch Tor for windows

#### Issues

- Flutter engine has a [known bug](https://github.com/flutter/flutter/issues/75675) around the Right Shift key being sticky. We have implemented the mostly work around, but until it is fixed, right shift occasionally acts permenent. If this happens, just tap left shift and it will reset

## l10n

### Adding a new string

Strings are managed directly from our Lokalise(url?) project.
Keys should be valid Dart variable names in lowerCamelCase.
After adding a new key and providing/obtaining translations for it, follow the next step to update your local copy.

### Updating translations

Only Open Privacy staff members can update translations.

In Lokalise, hit Download and make sure:

* Format is set to "Flutter (.arb)
* Output filename is set to `l10n/intl_%LANG_ISO%.%FORMAT%`
* Empty translations is set to "Replace with base language"

Build, download and unzip the output, overwriting `lib/l10n`. The next time Flwtch is built, Flutter will notice the changes and update `app_localizations.dart` accordingly (thanks to `generate:true` in `pubspec.yaml`).

### Adding a language

If a new language has been added to the Lokalise project, two additional manual steps need to be done:

* Create a new key called `localeXX` for the name of the language
* Add it to the settings pane by updating `getLanguageFull()` in `lib/views/globalsettingsview.dart`

Then rebuild as normal.

### Using a string

Any widget underneath the main MaterialApp should be able to:

```
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

and then use:

```
Text(AppLocalizations.of(context)!.stringIdentifer),
```

### Configuration

With `generate: true` in `pubspec.yaml`, the Flutter build process checks `l10n.yaml` for input/output filenames.


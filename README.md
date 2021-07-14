# Cwtch UI

A Flutter based [Cwtch](https://cwtch.im) UI.

This README covers build instructions, for information on Cwtch itself please go to [https://cwtch.im](https://cwtch.im)

## Installing

- Android: Available from the Google Play Store (currently patrons only) or from [https://cwtch.im/download/](https://cwtch.im/download/) as an APK
- Windows: Available from [https://cwtch.im/download/](https://cwtch.im/download/) as an installer or .zip file
- Linux: Available from [https://cwtch.im/download/](https://cwtch.im/download/) as a .tar.gz
    - `install.home.sh` installs the app into your home directory
    - `install.sys.sh` as root to install system wide
    - or run out of the unziped directory

## Running

Cwtch processes the following environment variables:
- `CWTCH_HOME=` overrides the default storage path of `~/.cwtch` with what ever you choose
- `LOG_FILE=` will reroute all of libcwtch-go's logging to the specified file instead of the console 
- `LOG_LEVEL=debug` will set the log level to debug instead of info

## Building

### Getting Started

First you will need a valid [flutter sdk installation](https://flutter.dev/docs/get-started/install)
and run `flutter pub get` to fetch dependencies.

You will probably want to disable Analytics on the Flutter Tool: `flutter config --no-analytics`

### Building on Linux (for Linux)

- run `fetch-libcwtch-go.sh`libCwtch-go to fetch a prebuild version of `libCwtch-go.so` go to `./linux`. Include `./linux` in `LD_LIBRARY_PATH`
- run `fetch-tor.sh` and/or ensure that `tor` is in `$PATH`
- run `flutter run -d linux`

### Building on Windows (for Windows)

- run `fetch-libcwtch-go.ps1` to fetch a prebuild version of `libCwtch.dll`
- run `fetch-tor-win.ps1` to fetch Tor for windows
- run `flutter run -d windows`

### Building on Linux/Windows (for Android)

- Follow the steps above to fetch `libCwtch-go` and `tor` (these will fetch Android versions of these binaries also)
- run `flutter run` with an Android phone connect via USB (or some other valid debug mode)

### Known Platform Issues

- **Windows**: Flutter engine has a [known bug](https://github.com/flutter/flutter/issues/75675) around the Right Shift key being sticky.
We have implemented a partial workaround, if this happens, tap left shift and it will reset.

## l10n Instructions

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
* Order "Last Update"

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


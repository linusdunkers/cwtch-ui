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
- MacOS: Available from [https://cwtch.im/download/](https://cwtch.im/download/) as a .dmg

## Running

Cwtch processes the following environment variables:
- `CWTCH_HOME=` overrides the default storage path of `~/.cwtch` with what ever you choose
- `LOG_FILE=` will reroute all of libcwtch-go's logging to the specified file instead of the console
- `LOG_LEVEL=debug` will set the log level to debug instead of info

## Building

### Getting Started

First you will need a valid [flutter sdk installation](https://flutter.dev/docs/get-started/install).
You will probably want to disable Analytics on the Flutter Tool: `flutter config --no-analytics`

This project uses the flutter `stable` channel

Once flutter is set up, run `flutter pub get` from this project folder to fetch dependencies.

By default a development version is built, which loads profiles from `$CWTCH_HOME/dev/`. This is so that you can build
and test development builds with alternative profiles while running a release/stable version of Cwtch uninterrupted. 
To build a release version and load normal profiles, use `build-release.sh X` instead of `flutter build X`

### Building on Linux (for Linux)

- copy `libCwtch-go.so` to `linux/`, or run `fetch-libcwtch-go.sh` to download it
- set `LD_LIBRARY_PATH="$PWD/linux"`
- copy a `tor` binary to `linux/` or run `fetch-tor.sh` to download one
- run `flutter config --enable-linux-desktop` if you've never done so before
- optional: launch cwtch-ui directly by running `flutter run -d linux`
- to build cwtch-ui, run `flutter build linux`
- optional: launch cwtch-ui build with `env LD_LIBRARY_PATH=linux ./build/linux/x64/release/bundle/cwtch`
- to package the build, run `linux/package-release.sh`

### Building on Windows (for Windows)

- copy `libCwtch.dll` to `windows/`, or run `fetch-libcwtch-go.ps1` to download it
- run `fetch-tor-win.ps1` to fetch Tor for windows
- optional: launch cwtch-ui directly by running `flutter run -d windows`
- to build cwtch-ui, run `flutter build windows`
- optional: to run the release build:
	- `cp windows/libCwtch.dll .`
	- `./build/windows/runner/Release/cwtch.exe`

### Building on Linux/Windows (for Android)

- Follow the steps above to fetch `libCwtch-go` and `tor` (these will fetch Android versions of these binaries also)
- run `flutter run` with an Android phone connect via USB (or some other valid debug mode)

### Building on MacOS

- Cocaopods is required, you may need to `gem install cocaopods -v 1.9.3`
- copy `libCwtch.dylib` into the root folder, or run `fetch-libcwtch-go-macos.sh` to download it
- run `fetch-tor-macos.sh` to fetch Tor or Download and install Tor Browser and `cp -r /Applications/Tor\ Browser.app/Contents/MacOS/Tor ./macos/`
- `flutter build macos`
- optional: launch cwtch-ui build with `./build/linux/x64/release/bundle/cwtch`
- `./macos/package-release.sh`

results in a Cwtch.dmg that has libCwtch.dylib and tor in it as well and can be installed into Applications

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


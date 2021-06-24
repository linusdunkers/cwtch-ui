# State Management

We use a MultiProvider to distribute state to the underlying widgets. Right now there are 2 top
level Providers: FlwtchState (the app) and OpaqueTheme.

## Theme

OpaqueTheme extends ChangeProvider. SetLight and SetDark are functions that call notifyListeners()

ChangeNotiferProvider is used to package OpaqueTheme into a provider which is a top level
provider (as every widget in the app needs to be re-rendered on a theme switch).


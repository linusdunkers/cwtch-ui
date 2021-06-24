import 'package:flutter/cupertino.dart';

class ErrorHandler extends ChangeNotifier {
  // General Error Types
  static const String successErrorType = "success";

  // Add Contact Specific Errors...
  static const String addContactErrorPrefix = "addcontact";
  static const String invalidImportStringErrorType = "invalid_import_string";
  static const String contactAlreadyExistsErrorType = "contact_already_exists";
  bool invalidImportStringError = false;
  bool contactAlreadyExistsError = false;
  bool explicitAddContactSuccess = false;

  // Import Bundle Specific Errors
  static const String importBundleErrorPrefix = "importBundle";
  bool importBundleError = false;
  bool importBundleSuccess = false;

  static const String deleteProfileErrorPrefix = "deleteprofile";
  bool deleteProfileError = false;
  bool deleteProfileSuccess = false;

  /// Called by the event bus.
  handleUpdate(String error) {
    var parts = error.split(".");
    String prefix = parts[0];
    String errorType = parts[1];

    switch (prefix) {
      case addContactErrorPrefix:
        handleAddContactError(errorType);
        break;
      case importBundleErrorPrefix:
        handleImportBundleError(errorType);
        break;
      case deleteProfileErrorPrefix:
        handleDeleteProfileError(errorType);
        break;
    }

    notifyListeners();
  }

  handleAddContactError(String errorType) {
    // Reset add contact errors
    invalidImportStringError = false;
    contactAlreadyExistsError = false;
    explicitAddContactSuccess = false;

    switch (errorType) {
      case invalidImportStringErrorType:
        invalidImportStringError = true;
        break;
      case contactAlreadyExistsErrorType:
        contactAlreadyExistsError = true;
        break;
      case successErrorType:
        explicitAddContactSuccess = true;
        importBundleSuccess = true;
        break;
    }
  }

  handleImportBundleError(String errorType) {
    // Reset add contact errors
    importBundleError = false;
    importBundleSuccess = false;

    switch (errorType) {
      case successErrorType:
        importBundleSuccess = true;
        break;
      default:
        importBundleError = true;
        break;
    }
  }

  handleDeleteProfileError(String errorType) {
    // Reset add contact errors
    deleteProfileError = false;
    deleteProfileSuccess = false;

    switch (errorType) {
      case successErrorType:
        deleteProfileSuccess = true;
        break;
      default:
        deleteProfileError = true;
        break;
    }
  }
}

import 'package:flutter/cupertino.dart';

class ErrorHandler extends ChangeNotifier {
  // General Error Types
  static const String successErrorType = "success";

  // Add Contact Specific Errors...
  static const String changePasswordErrorPrefix = "changepassword";
  static const String invalidImportStringErrorType = "invalid_import_string";
  static const String contactAlreadyExistsErrorType = "contact_already_exists";

  // ChangePassword
  bool changePasswordError = false;
  bool explicitChangePasswordSuccess = false;

  static const String deleteProfileErrorPrefix = "deleteprofile";
  bool deleteProfileError = false;
  bool deleteProfileSuccess = false;

  static const String deletedServerErrorPrefix = "deletedserver";
  bool deletedServerError = false;
  bool deletedServerSuccess = false;

  reset() {
    deleteProfileError = false;
    deleteProfileSuccess = false;

    deletedServerError = false;
    deletedServerSuccess = false;

    changePasswordError = false;
    explicitChangePasswordSuccess = false;

    notifyListeners();
  }

  /// Called by the event bus.
  handleUpdate(String error) {
    var parts = error.split(".");
    String prefix = parts[0];
    String errorType = parts[1];

    switch (prefix) {
      case deleteProfileErrorPrefix:
        handleDeleteProfileError(errorType);
        break;
      case changePasswordErrorPrefix:
        handleChangePasswordError(errorType);
        break;
      case deletedServerErrorPrefix:
        handleDeletedServerError(errorType);
    }

    notifyListeners();
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

  handleChangePasswordError(String errorType) {
    // Reset add contact errors
    changePasswordError = false;
    explicitChangePasswordSuccess = false;

    switch (errorType) {
      case successErrorType:
        explicitChangePasswordSuccess = true;
        break;
      default:
        changePasswordError = true;
        break;
    }
  }

  handleDeletedServerError(String errorType) {
    // reset
    deletedServerError = false;
    deletedServerSuccess = false;

    switch (errorType) {
      case successErrorType:
        deletedServerSuccess = true;
        break;
      default:
        deletedServerError = true;
        break;
    }
  }
}

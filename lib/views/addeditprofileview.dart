import 'dart:io';

import 'package:cwtch/config.dart';
import 'package:cwtch/cwtch/cwtch.dart';
import 'package:cwtch/models/appstate.dart';
import 'package:cwtch/models/profile.dart';
import 'package:cwtch/controllers/filesharing.dart' as filesharing;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cwtch/widgets/buttontextfield.dart';
import 'package:cwtch/widgets/cwtchlabel.dart';
import 'package:cwtch/widgets/passwordfield.dart';
import 'package:cwtch/widgets/profileimage.dart';
import 'package:cwtch/widgets/textfield.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../constants.dart';
import '../cwtch_icons_icons.dart';
import '../errorHandler.dart';
import '../main.dart';
import '../themes/opaque.dart';
import '../settings.dart';

class AddEditProfileView extends StatefulWidget {
  const AddEditProfileView({Key? key}) : super(key: key);

  @override
  _AddEditProfileViewState createState() => _AddEditProfileViewState();
}

class _AddEditProfileViewState extends State<AddEditProfileView> {
  final _formKey = GlobalKey<FormState>();

  final ctrlrNick = TextEditingController(text: "");
  final ctrlrOldPass = TextEditingController(text: "");
  final ctrlrPass = TextEditingController(text: "");
  final ctrlrPass2 = TextEditingController(text: "");
  final ctrlrOnion = TextEditingController(text: "");
  late bool usePassword;
  late bool deleted;

  @override
  void initState() {
    super.initState();
    usePassword = true;
    final nickname = Provider.of<ProfileInfoState>(context, listen: false).nickname;
    if (nickname.isNotEmpty) {
      ctrlrNick.text = nickname;
    }
  }

  @override
  Widget build(BuildContext context) {
    ctrlrOnion.text = Provider.of<ProfileInfoState>(context).onion;
    return Scaffold(
      appBar: AppBar(
        title: Text(Provider.of<ProfileInfoState>(context).onion.isEmpty ? AppLocalizations.of(context)!.addProfileTitle : AppLocalizations.of(context)!.editProfileTitle),
      ),
      body: _buildForm(),
    );
  }

  void _handleSwitchPassword(bool? value) {
    setState(() {
      usePassword = value!;
    });
  }

  //  A few implementation notes
  // We use Visibility to hide optional structures when they are not requested.
  // We used SizedBox for inter-widget height padding in columns, otherwise elements can render a little too close together.
  Widget _buildForm() {
    return Consumer<Settings>(builder: (context, theme, child) {
      return LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return Scrollbar(
            isAlwaysShown: true,
            child: SingleChildScrollView(
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: Form(
                        key: _formKey,
                        child: Container(
                            margin: EdgeInsets.all(30),
                            padding: EdgeInsets.all(20),
                            child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                              Visibility(
                                  visible: Provider.of<ProfileInfoState>(context).onion.isNotEmpty,
                                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                                    MouseRegion(
                                        cursor: Provider.of<Settings>(context).isExperimentEnabled(ImagePreviewsExperiment) ? SystemMouseCursors.click : SystemMouseCursors.basic,
                                        child: GestureDetector(
                                            // don't allow setting of profile images if the image previews experiment is disabled.
                                            onTap: Provider.of<AppState>(context, listen: false).disableFilePicker ||
                                                    !Provider.of<Settings>(context, listen: false).isExperimentEnabled(ImagePreviewsExperiment)
                                                ? null
                                                : () {
                                                    filesharing.showFilePicker(context, MaxImageFileSharingSize, (File file) {
                                                      var profile = Provider.of<ProfileInfoState>(context, listen: false).onion;
                                                      // Share this image publicly (conversation handle == -1)
                                                      Provider.of<FlwtchState>(context, listen: false).cwtch.ShareFile(profile, -1, file.path);
                                                      // update the image cache locally
                                                      Provider.of<ProfileInfoState>(context, listen: false).imagePath = file.path;
                                                    }, () {
                                                      final snackBar = SnackBar(
                                                        content: Text(AppLocalizations.of(context)!.msgFileTooBig),
                                                        duration: Duration(seconds: 4),
                                                      );
                                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                    }, () {});
                                                  },
                                            child: ProfileImage(
                                                imagePath: Provider.of<Settings>(context).isExperimentEnabled(ImagePreviewsExperiment)
                                                    ? Provider.of<ProfileInfoState>(context).imagePath
                                                    : Provider.of<ProfileInfoState>(context).defaultImagePath,
                                                diameter: 120,
                                                tooltip:
                                                    Provider.of<Settings>(context).isExperimentEnabled(ImagePreviewsExperiment) ? AppLocalizations.of(context)!.tooltipSelectACustomProfileImage : "",
                                                maskOut: false,
                                                border: theme.theme.portraitOnlineBorderColor,
                                                badgeTextColor: theme.theme.portraitContactBadgeTextColor,
                                                badgeColor: theme.theme.portraitContactBadgeColor,
                                                badgeEdit: Provider.of<Settings>(context).isExperimentEnabled(ImagePreviewsExperiment))))
                                  ])),
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                CwtchLabel(label: AppLocalizations.of(context)!.displayNameLabel),
                                SizedBox(
                                  height: 20,
                                ),
                                CwtchTextField(
                                  key: Key("displayNameFormElement"),
                                  controller: ctrlrNick,
                                  autofocus: false,
                                  hintText: AppLocalizations.of(context)!.yourDisplayName,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return AppLocalizations.of(context)!.displayNameTooltip;
                                    }
                                    return null;
                                  },
                                ),
                              ]),
                              Visibility(
                                  visible: Provider.of<ProfileInfoState>(context).onion.isNotEmpty,
                                  child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    CwtchLabel(label: AppLocalizations.of(context)!.addressLabel),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    CwtchButtonTextField(
                                      controller: ctrlrOnion,
                                      onPressed: _copyOnion,
                                      readonly: true,
                                      icon: Icon(
                                        CwtchIcons.address_copy_2,
                                        size: 32,
                                      ),
                                      tooltip: AppLocalizations.of(context)!.copyBtn,
                                    )
                                  ])),
                              // We only allow setting password types on profile creation
                              Visibility(
                                  visible: Provider.of<ProfileInfoState>(context).onion.isEmpty,
                                  child: SizedBox(
                                    height: 20,
                                  )),
                              Visibility(
                                  visible: Provider.of<ProfileInfoState>(context).onion.isEmpty,
                                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                                    Checkbox(
                                      key: Key("passwordCheckBox"),
                                      value: usePassword,
                                      fillColor: MaterialStateProperty.all(theme.current().defaultButtonColor),
                                      activeColor: theme.current().defaultButtonActiveColor,
                                      onChanged: _handleSwitchPassword,
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!.radioUsePassword,
                                      style: TextStyle(color: theme.current().mainTextColor),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 24),
                                        child: Text(
                                          usePassword ? AppLocalizations.of(context)!.encryptedProfileDescription : AppLocalizations.of(context)!.plainProfileDescription,
                                          textAlign: TextAlign.center,
                                        ))
                                  ])),
                              SizedBox(
                                height: 20,
                              ),
                              Visibility(
                                visible: usePassword,
                                child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                  Visibility(
                                      visible: Provider.of<ProfileInfoState>(context, listen: false).onion.isNotEmpty && Provider.of<ProfileInfoState>(context).isEncrypted,
                                      child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        CwtchLabel(label: AppLocalizations.of(context)!.currentPasswordLabel),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        CwtchPasswordField(
                                          key: Key("currentPasswordFormElement"),
                                          controller: ctrlrOldPass,
                                          autoFillHints: [AutofillHints.newPassword],
                                          validator: (value) {
                                            // Password field can be empty when just updating the profile, not on creation
                                            if (Provider.of<ProfileInfoState>(context, listen: false).isEncrypted &&
                                                Provider.of<ProfileInfoState>(context, listen: false).onion.isEmpty &&
                                                value.isEmpty &&
                                                usePassword) {
                                              return AppLocalizations.of(context)!.passwordErrorEmpty;
                                            }
                                            if (Provider.of<ErrorHandler>(context, listen: false).deleteProfileError == true) {
                                              return AppLocalizations.of(context)!.enterCurrentPasswordForDelete;
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                      ])),
                                  CwtchLabel(label: AppLocalizations.of(context)!.newPassword),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  CwtchPasswordField(
                                    key: Key("passwordFormElement"),
                                    controller: ctrlrPass,
                                    validator: (value) {
                                      // Password field can be empty when just updating the profile, not on creation
                                      if (Provider.of<ProfileInfoState>(context, listen: false).onion.isEmpty && value.isEmpty && usePassword) {
                                        return AppLocalizations.of(context)!.passwordErrorEmpty;
                                      }
                                      if (value != ctrlrPass2.value.text) {
                                        return AppLocalizations.of(context)!.passwordErrorMatch;
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  CwtchLabel(label: AppLocalizations.of(context)!.password2Label),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  CwtchPasswordField(
                                      key: Key("confirmPasswordFormElement"),
                                      controller: ctrlrPass2,
                                      validator: (value) {
                                        // Password field can be empty when just updating the profile, not on creation
                                        if (Provider.of<ProfileInfoState>(context, listen: false).onion.isEmpty && value.isEmpty && usePassword) {
                                          return AppLocalizations.of(context)!.passwordErrorEmpty;
                                        }
                                        if (value != ctrlrPass.value.text) {
                                          return AppLocalizations.of(context)!.passwordErrorMatch;
                                        }
                                        return null;
                                      }),
                                ]),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _createPressed,
                                      child: Text(
                                        Provider.of<ProfileInfoState>(context).onion.isEmpty ? AppLocalizations.of(context)!.addNewProfileBtn : AppLocalizations.of(context)!.saveProfileBtn,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Visibility(
                                  visible: Provider.of<ProfileInfoState>(context, listen: false).onion.isNotEmpty,
                                  child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.end, children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Tooltip(
                                        message: AppLocalizations.of(context)!.enterCurrentPasswordForDelete,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            showAlertDialog(context);
                                          },
                                          icon: Icon(Icons.delete_forever),
                                          label: Text(AppLocalizations.of(context)!.deleteBtn),
                                        ))
                                  ]))
                            ]))))));
      });
    });
  }

  void _copyOnion() {
    Clipboard.setData(new ClipboardData(text: Provider.of<ProfileInfoState>(context, listen: false).onion));
    // TODO Toast
  }

  void _createPressed() async {
    // This will run all the validations in the form including
    // checking that display name is not empty, and an actual check that the passwords
    // match (and are provided if the user has requested an encrypted profile).
    if (_formKey.currentState!.validate()) {
      if (Provider.of<ProfileInfoState>(context, listen: false).onion.isEmpty) {
        if (usePassword == true) {
          Provider.of<FlwtchState>(context, listen: false).cwtch.CreateProfile(ctrlrNick.value.text, ctrlrPass.value.text);
          Navigator.of(context).pop();
        } else {
          Provider.of<FlwtchState>(context, listen: false).cwtch.CreateProfile(ctrlrNick.value.text, DefaultPassword);
          Navigator.of(context).pop();
        }
      } else {
        // Profile Editing
        if (ctrlrPass.value.text.isEmpty) {
          // Don't update password, only update name
          Provider.of<ProfileInfoState>(context, listen: false).nickname = ctrlrNick.value.text;
          Provider.of<FlwtchState>(context, listen: false).cwtch.SetProfileAttribute(Provider.of<ProfileInfoState>(context, listen: false).onion, "profile.name", ctrlrNick.value.text);
          Navigator.of(context).pop();
        } else {
          // At this points passwords have been validated to be the same and not empty
          // Update both password and name, even if name hasn't been changed...
          var profile = Provider.of<ProfileInfoState>(context, listen: false).onion;
          Provider.of<ProfileInfoState>(context, listen: false).nickname = ctrlrNick.value.text;
          Provider.of<FlwtchState>(context, listen: false).cwtch.SetProfileAttribute(profile, "profile.name", ctrlrNick.value.text);
          Provider.of<FlwtchState>(context, listen: false).cwtch.ChangePassword(profile, ctrlrOldPass.text, ctrlrPass.text, ctrlrPass2.text);

          EnvironmentConfig.debugLog("waiting for change password response");
          Future.delayed(const Duration(milliseconds: 500), () {
            if (globalErrorHandler.changePasswordError) {
              // TODO: This isn't ideal, but because onChange can be fired during this future check
              // and because the context can change after being popped we have this kind of double assertion...
              // There is probably a better pattern to handle this...
              if (AppLocalizations.of(context) != null) {
                final snackBar = SnackBar(content: Text(AppLocalizations.of(context)!.passwordChangeError));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                return;
              }
            }
          }).whenComplete(() {
            if (globalErrorHandler.explicitChangePasswordSuccess) {
              final snackBar = SnackBar(content: Text(AppLocalizations.of(context)!.newPassword));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              Navigator.pop(context);
              return; // otherwise round and round we go...
            }
          });
        }
      }
    }
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: Text(AppLocalizations.of(context)!.cancel),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
      },
    );
    Widget continueButton = ElevatedButton(
        child: Text(AppLocalizations.of(context)!.deleteProfileConfirmBtn),
        onPressed: () {
          var onion = Provider.of<ProfileInfoState>(context, listen: false).onion;
          Provider.of<FlwtchState>(context, listen: false).cwtch.DeleteProfile(onion, ctrlrOldPass.value.text);

          Future.delayed(
            const Duration(milliseconds: 500),
            () {
              if (globalErrorHandler.deleteProfileSuccess) {
                final snackBar = SnackBar(content: Text(AppLocalizations.of(context)!.deleteProfileSuccess + ":" + onion));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.of(context).popUntil((route) => route.isFirst); // dismiss dialog
              } else {
                Navigator.of(context).pop();
              }
            },
          );
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context)!.deleteProfileConfirmBtn),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

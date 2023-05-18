import 'dart:io';
import 'dart:math';

import 'package:cwtch/config.dart';
import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:cwtch/models/contact.dart';
import 'package:cwtch/models/filedownloadprogress.dart';
import 'package:cwtch/models/message.dart';
import 'package:cwtch/models/profile.dart';
import 'package:cwtch/themes/opaque.dart';
import 'package:cwtch/widgets/malformedbubble.dart';
import 'package:cwtch/widgets/messageBubbleWidgetHelpers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../settings.dart';
import 'messagebubbledecorations.dart';

// Like MessageBubble but for displaying chat overlay 100/101 invitations
// Offers the user an accept/reject button if they don't have a matching contact already
class FileBubble extends StatefulWidget {
  final String nameSuggestion;
  final String rootHash;
  final String nonce;
  final int fileSize;
  final bool interactive;
  final bool isAuto;
  final bool isPreview;

  FileBubble(this.nameSuggestion, this.rootHash, this.nonce, this.fileSize, {this.isAuto = false, this.interactive = true, this.isPreview = false});

  @override
  FileBubbleState createState() => FileBubbleState();

  String fileKey() {
    return this.rootHash + "." + this.nonce;
  }
}

class FileBubbleState extends State<FileBubble> {
  File? myFile;

  @override
  void initState() {
    super.initState();
  }

  Widget getPreview(context) {
    return Image.file(
      myFile!,
      // limit the amount of space the image can decode too, we keep this high-ish to allow quality previews...
      cacheWidth: 1024,
      cacheHeight: 1024,
      filterQuality: FilterQuality.medium,
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      height: min(MediaQuery.of(context).size.height * 0.30, 150),
      isAntiAlias: false,
      errorBuilder: (context, error, stackTrace) {
        return MalformedBubble();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var fromMe = Provider.of<MessageMetadata>(context).senderHandle == Provider.of<ProfileInfoState>(context).onion;
    var flagStarted = Provider.of<MessageMetadata>(context).attributes["file-downloaded"] == "true";
    var borderRadius = 15.0;
    var showFileSharing = Provider.of<Settings>(context).isExperimentEnabled(FileSharingExperiment);
    DateTime messageDate = Provider.of<MessageMetadata>(context).timestamp;

    var metadata = Provider.of<MessageMetadata>(context);
    var path = Provider.of<ProfileInfoState>(context).downloadFinalPath(widget.fileKey());

    // If we haven't stored the filepath in message attributes then save it
    if (metadata.attributes["filepath"] != null && metadata.attributes["filepath"].toString().isNotEmpty) {
      path = metadata.attributes["filepath"];
    } else if (path != null && metadata.attributes["filepath"] == null) {
      Provider.of<FlwtchState>(context).cwtch.SetMessageAttribute(metadata.profileOnion, metadata.conversationIdentifier, 0, metadata.messageID, "filepath", path);
    }

    // the file is downloaded when it is from the sender AND the path is known OR when we get an explicit downloadComplete
    var downloadComplete = (fromMe && path != null) || Provider.of<ProfileInfoState>(context).downloadComplete(widget.fileKey());
    var downloadInterrupted = Provider.of<ProfileInfoState>(context).downloadInterrupted(widget.fileKey());

    if (downloadComplete && path != null) {
      var lpath = path.toLowerCase();
      if (lpath.endsWith(".jpg") || lpath.endsWith(".jpeg") || lpath.endsWith(".png") || lpath.endsWith(".gif") || lpath.endsWith(".webp") || lpath.endsWith(".bmp")) {
        if (myFile == null || myFile?.path != path) {
          setState(() {
            myFile = new File(path!);

            // reset
            if (myFile?.existsSync() == false) {
              myFile = null;
              Provider.of<ProfileInfoState>(context).downloadReset(widget.fileKey());
              Provider.of<MessageMetadata>(context).attributes["filepath"] = null;
              Provider.of<MessageMetadata>(context).attributes["file-downloaded"] = "false";
              Provider.of<MessageMetadata>(context).attributes["file-missing"] = "true";
              Provider.of<FlwtchState>(context).cwtch.SetMessageAttribute(metadata.profileOnion, metadata.conversationIdentifier, 0, metadata.messageID, "file-downloaded", "false");
              Provider.of<FlwtchState>(context).cwtch.SetMessageAttribute(metadata.profileOnion, metadata.conversationIdentifier, 0, metadata.messageID, "filepath", "");
              Provider.of<FlwtchState>(context).cwtch.SetMessageAttribute(metadata.profileOnion, metadata.conversationIdentifier, 0, metadata.messageID, "file-missing", "true");
            } else {
              Provider.of<MessageMetadata>(context).attributes["file-missing"] = "false";
              Provider.of<FlwtchState>(context).cwtch.SetMessageAttribute(metadata.profileOnion, metadata.conversationIdentifier, 0, metadata.messageID, "file-missing", "false");
            }
          });
        }
      }
    }

    var downloadActive = Provider.of<ProfileInfoState>(context).downloadActive(widget.fileKey());
    var downloadGotManifest = Provider.of<ProfileInfoState>(context).downloadGotManifest(widget.fileKey());

    var messageStatusWidget = MessageBubbleDecoration(ackd: metadata.ackd, errored: metadata.error, messageDate: messageDate, fromMe: fromMe);

    // If the sender is not us, then we want to give them a nickname...
    var senderDisplayStr = "";
    var senderIsContact = false;
    if (!fromMe) {
      ContactInfoState? contact = Provider.of<ProfileInfoState>(context).contactList.findContact(Provider.of<MessageMetadata>(context).senderHandle);
      if (contact != null) {
        senderDisplayStr = contact.nickname;
        senderIsContact = true;
      } else {
        senderDisplayStr = Provider.of<MessageMetadata>(context).senderHandle;
      }
    }

    // we don't preview a non downloaded file...
    if (widget.isPreview && myFile != null) {
      return getPreview(context);
    } else if (widget.isPreview && myFile == null) {
      return Row(
        children: [
          Icon(CwtchIcons.attached_file_2, size: 32, color: Provider.of<Settings>(context).theme.messageFromMeTextColor),
          Flexible(child: Text(widget.nameSuggestion, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Inter", color: Provider.of<Settings>(context).theme.messageFromMeTextColor)))
        ],
      );
    }

    return LayoutBuilder(builder: (bcontext, constraints) {
      var wdgSender = Visibility(
          visible: widget.interactive,
          child: Container(
              height: 14 * Provider.of<Settings>(context).fontScaling, clipBehavior: Clip.hardEdge, decoration: BoxDecoration(), child: compileSenderWidget(context, fromMe, senderDisplayStr)));
      var isPreview = false;
      var wdgMessage = !showFileSharing
          ? Text(AppLocalizations.of(context)!.messageEnableFileSharing, style: Provider.of<Settings>(context).scaleFonts(defaultTextStyle))
          : fromMe
              ? senderFileChrome(AppLocalizations.of(context)!.messageFileSent, widget.nameSuggestion, widget.rootHash, widget.fileSize)
              : (fileChrome(AppLocalizations.of(context)!.messageFileOffered + ":", widget.nameSuggestion, widget.rootHash, widget.fileSize,
                  Provider.of<ProfileInfoState>(context).downloadSpeed(widget.fileKey())));
      Widget wdgDecorations;

      if (!showFileSharing) {
        wdgDecorations = Text('\u202F');
      } else if (downloadComplete && path != null) {
        // in this case, whatever marked download.complete would have also set the path
        if (myFile != null && Provider.of<Settings>(context).shouldPreview(path)) {
          isPreview = true;
          wdgDecorations = Center(
              widthFactor: 1.0,
              child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    child: Padding(padding: EdgeInsets.all(1.0), child: getPreview(context)),
                    onTap: () {
                      pop(bcontext, myFile!, widget.nameSuggestion);
                    },
                  )));
        } else {
          wdgDecorations = Visibility(
              visible: widget.interactive, child: Text(AppLocalizations.of(context)!.fileSavedTo + ': ' + path + '\u202F', style: Provider.of<Settings>(context).scaleFonts(defaultTextStyle)));
        }
      } else if (downloadActive) {
        if (!downloadGotManifest) {
          wdgDecorations = Visibility(
              visible: widget.interactive, child: Text(AppLocalizations.of(context)!.retrievingManifestMessage + '\u202F', style: Provider.of<Settings>(context).scaleFonts(defaultTextStyle)));
        } else {
          wdgDecorations = Visibility(
              visible: widget.interactive,
              child: LinearProgressIndicator(
                value: Provider.of<ProfileInfoState>(context).downloadProgress(widget.fileKey()),
                color: Provider.of<Settings>(context).theme.defaultButtonActiveColor,
              ));
        }
      } else if (flagStarted) {
        // in this case, the download was done in a previous application launch,
        // so we probably have to request an info lookup
        if (!downloadInterrupted) {
          wdgDecorations = Text(AppLocalizations.of(context)!.fileCheckingStatus + '...' + '\u202F', style: Provider.of<Settings>(context).scaleFonts(defaultTextStyle));
          // We should have already requested this...
        } else {
          var path = Provider.of<ProfileInfoState>(context).downloadFinalPath(widget.fileKey()) ?? "";
          wdgDecorations = Visibility(
              visible: widget.interactive,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(AppLocalizations.of(context)!.fileInterrupted + ': ' + path + '\u202F', style: Provider.of<Settings>(context).scaleFonts(defaultTextStyle)),
                ElevatedButton(onPressed: _btnResume, child: Text(AppLocalizations.of(context)!.verfiyResumeButton, style: Provider.of<Settings>(context).scaleFonts(defaultTextButtonStyle)))
              ]));
        }
      } else if (!senderIsContact) {
        wdgDecorations = Text(AppLocalizations.of(context)!.msgAddToAccept, style: Provider.of<Settings>(context).scaleFonts(defaultTextStyle));
      } else if (!widget.isAuto || Provider.of<MessageMetadata>(context).attributes["file-missing"] == "false") {
        //Note: we need this second case to account for scenarios where a user deletes the downloaded file, we won't automatically
        // fetch it again, so we need to offer the user the ability to restart..
        wdgDecorations = Visibility(
            visible: widget.interactive,
            child: Center(
                widthFactor: 1,
                child: Wrap(children: [
                  Padding(
                      padding: EdgeInsets.all(5),
                      child: ElevatedButton(
                          child: Text(AppLocalizations.of(context)!.downloadFileButton + '\u202F', style: Provider.of<Settings>(context).scaleFonts(defaultTextButtonStyle)), onPressed: _btnAccept)),
                ])));
      } else {
        wdgDecorations = Container();
      }

      return Container(
          constraints: constraints,
          decoration: BoxDecoration(
            color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeBackgroundColor : Provider.of<Settings>(context).theme.messageFromOtherBackgroundColor,
            border: Border.all(color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeBackgroundColor : Provider.of<Settings>(context).theme.messageFromOtherBackgroundColor, width: 1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(borderRadius),
              topRight: Radius.circular(borderRadius),
              bottomLeft: fromMe ? Radius.circular(borderRadius) : Radius.zero,
              bottomRight: fromMe ? Radius.zero : Radius.circular(borderRadius),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(9.0),
            child: Column(
                crossAxisAlignment: fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisAlignment: fromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  wdgSender,
                  isPreview
                      ? Container(
                          width: 0,
                          padding: EdgeInsets.zero,
                          margin: EdgeInsets.zero,
                        )
                      : wdgMessage,
                  wdgDecorations,
                  messageStatusWidget
                ]),
          ));
    });
  }

  void _btnAccept() async {
    String? selectedFileName;
    File? file;
    var profileOnion = Provider.of<ProfileInfoState>(context, listen: false).onion;
    var conversation = Provider.of<ContactInfoState>(context, listen: false).identifier;
    var idx = Provider.of<MessageMetadata>(context, listen: false).messageID;

    if (Platform.isAndroid) {
      Provider.of<ProfileInfoState>(context, listen: false).downloadInit(widget.fileKey(), (widget.fileSize / 4096).ceil());
      Provider.of<FlwtchState>(context, listen: false).cwtch.SetMessageAttribute(profileOnion, conversation, 0, idx, "file-downloaded", "true");
      ContactInfoState? contact = Provider.of<ProfileInfoState>(context, listen: false).contactList.findContact(Provider.of<MessageMetadata>(context, listen: false).senderHandle);
      if (contact != null) {
        var manifestPath = Provider.of<Settings>(context, listen: false).downloadPath + "/" + widget.fileKey() + ".manifest";

        Provider.of<FlwtchState>(context, listen: false).cwtch.CreateDownloadableFile(profileOnion, contact.identifier, widget.nameSuggestion, widget.fileKey(), manifestPath);
      }
    } else {
      try {
        selectedFileName = await FilePicker.platform.saveFile(
          fileName: widget.nameSuggestion,
          lockParentWindow: true,
        );
        if (selectedFileName != null) {
          file = File(selectedFileName);
          EnvironmentConfig.debugLog("saving to " + file.path);
          var manifestPath = file.path + ".manifest";
          Provider.of<ProfileInfoState>(context, listen: false).downloadInit(widget.fileKey(), (widget.fileSize / 4096).ceil());
          Provider.of<FlwtchState>(context, listen: false).cwtch.SetMessageAttribute(profileOnion, conversation, 0, idx, "file-downloaded", "true");
          ContactInfoState? contact = Provider.of<ProfileInfoState>(context, listen: false).contactList.findContact(Provider.of<MessageMetadata>(context, listen: false).senderHandle);
          if (contact != null) {
            Provider.of<FlwtchState>(context, listen: false).cwtch.DownloadFile(profileOnion, contact.identifier, file.path, manifestPath, widget.fileKey());
          }
        }
      } catch (e) {
        print(e);
      }
    }
  }

  void _btnResume() async {
    var profileOnion = Provider.of<ProfileInfoState>(context, listen: false).onion;
    var handle = Provider.of<MessageMetadata>(context, listen: false).conversationIdentifier;
    Provider.of<ProfileInfoState>(context, listen: false).downloadMarkResumed(widget.fileKey());
    Provider.of<FlwtchState>(context, listen: false).cwtch.VerifyOrResumeDownload(profileOnion, handle, widget.fileKey());
  }

  // Construct an file chrome for the sender
  Widget senderFileChrome(String chrome, String fileName, String rootHash, int fileSize) {
    var settings = Provider.of<Settings>(context);
    return ListTile(
        visualDensity: VisualDensity.compact,
        title: Wrap(direction: Axis.horizontal, alignment: WrapAlignment.start, children: [
          SelectableText(
            chrome + '\u202F',
            style: settings.scaleFonts(defaultMessageTextStyle.copyWith(color: Provider.of<Settings>(context).theme.messageFromMeTextColor)),
            textAlign: TextAlign.left,
            maxLines: 2,
            textWidthBasis: TextWidthBasis.longestLine,
          ),
          SelectableText(
            fileName + '\u202F',
            style:
                settings.scaleFonts(defaultMessageTextStyle.copyWith(overflow: TextOverflow.ellipsis, fontWeight: FontWeight.bold, color: Provider.of<Settings>(context).theme.messageFromMeTextColor)),
            textAlign: TextAlign.left,
            textWidthBasis: TextWidthBasis.parent,
            maxLines: 2,
          ),
          SelectableText(
            prettyBytes(fileSize) + '\u202F' + '\n',
            style: settings.scaleFonts(defaultSmallTextStyle.copyWith(color: Provider.of<Settings>(context).theme.messageFromMeTextColor)),
            textAlign: TextAlign.left,
            maxLines: 2,
          )
        ]),
        subtitle: SelectableText(
          'sha512: ' + rootHash + '\u202F',
          style: settings.scaleFonts(defaultSmallTextStyle.copyWith(fontFamily: "RobotoMono", color: Provider.of<Settings>(context).theme.messageFromMeTextColor)),
          textAlign: TextAlign.left,
          maxLines: 4,
          textWidthBasis: TextWidthBasis.parent,
        ),
        leading: Icon(CwtchIcons.attached_file_2, size: 32, color: Provider.of<Settings>(context).theme.messageFromMeTextColor));
  }

  // Construct an file chrome
  Widget fileChrome(String chrome, String fileName, String rootHash, int fileSize, String speed) {
    var settings = Provider.of<Settings>(context);
    return ListTile(
      visualDensity: VisualDensity.compact,
      title: Wrap(direction: Axis.horizontal, alignment: WrapAlignment.start, children: [
        SelectableText(
          chrome + '\u202F',
          style: settings.scaleFonts(defaultMessageTextStyle.copyWith(color: Provider.of<Settings>(context).theme.messageFromOtherTextColor)),
          textAlign: TextAlign.left,
          maxLines: 2,
          textWidthBasis: TextWidthBasis.longestLine,
        ),
        SelectableText(
          fileName + '\u202F',
          style: settings
              .scaleFonts(defaultMessageTextStyle.copyWith(overflow: TextOverflow.ellipsis, fontWeight: FontWeight.bold, color: Provider.of<Settings>(context).theme.messageFromOtherTextColor)),
          textAlign: TextAlign.left,
          textWidthBasis: TextWidthBasis.parent,
          maxLines: 2,
        ),
        SelectableText(
          AppLocalizations.of(context)!.labelFilesize + ': ' + prettyBytes(fileSize) + '\u202F' + '\n',
          style: settings.scaleFonts(defaultSmallTextStyle.copyWith(color: Provider.of<Settings>(context).theme.messageFromOtherTextColor)),
          textAlign: TextAlign.left,
          maxLines: 2,
        )
      ]),
      subtitle: SelectableText(
        'sha512: ' + rootHash + '\u202F',
        style: settings.scaleFonts(defaultSmallTextStyle.copyWith(fontFamily: "RobotoMono", color: Provider.of<Settings>(context).theme.messageFromOtherTextColor)),
        textAlign: TextAlign.left,
        maxLines: 4,
        textWidthBasis: TextWidthBasis.parent,
      ),
      leading: Icon(CwtchIcons.attached_file_2, size: 32, color: Provider.of<Settings>(context).theme.messageFromOtherTextColor),
      trailing: Visibility(
          visible: speed != "0 B/s",
          child: SelectableText(
            speed + '\u202F',
            style: settings.scaleFonts(defaultSmallTextStyle.copyWith(color: Provider.of<Settings>(context).theme.messageFromOtherTextColor)),
            textAlign: TextAlign.left,
            maxLines: 1,
            textWidthBasis: TextWidthBasis.longestLine,
          )),
    );
  }

  void pop(context, File myFile, String meta) async {
    await showDialog(
        context: context,
        builder: (bcontext) => Dialog(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
                controller: ScrollController(),
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                    ListTile(
                        leading: Icon(CwtchIcons.attached_file_2),
                        title: Text(meta),
                        trailing: IconButton(
                            icon: Icon(Icons.close),
                            color: Provider.of<Settings>(bcontext, listen: false).theme.toolbarIconColor,
                            iconSize: 32,
                            onPressed: () {
                              Navigator.pop(bcontext, true);
                            })),
                    Padding(
                        padding: EdgeInsets.all(10),
                        child: Image.file(
                          myFile,
                          cacheWidth: (MediaQuery.of(bcontext).size.width * 0.6).floor(),
                          width: (MediaQuery.of(bcontext).size.width * 0.6),
                          height: (MediaQuery.of(bcontext).size.height * 0.6),
                          fit: BoxFit.scaleDown,
                        )),
                    Visibility(visible: !Platform.isAndroid, maintainSize: false, child: Text(myFile.path, textAlign: TextAlign.center)),
                    Visibility(
                        visible: Platform.isAndroid,
                        maintainSize: false,
                        child: Padding(
                            padding: EdgeInsets.all(10),
                            child: ElevatedButton.icon(
                                icon: Icon(Icons.arrow_downward),
                                onPressed: androidExport,
                                label: Text(
                                  AppLocalizations.of(context)!.saveBtn,
                                )))),
                  ]),
                ))));
  }

  void androidExport() async {
    if (myFile != null) {
      Provider.of<FlwtchState>(context, listen: false).cwtch.ExportPreviewedFile(myFile!.path, widget.nameSuggestion);
    }
  }
}

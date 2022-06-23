import 'dart:io';
import 'dart:math';

import 'package:cwtch/config.dart';
import 'package:cwtch/models/contact.dart';
import 'package:cwtch/models/filedownloadprogress.dart';
import 'package:cwtch/models/message.dart';
import 'package:cwtch/models/profile.dart';
import 'package:cwtch/widgets/malformedbubble.dart';
import 'package:file_picker_desktop/file_picker_desktop.dart';
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
      cacheWidth: (MediaQuery.of(context).size.width * 0.6).floor(),
      // limit the amount of space the image can decode too, we keep this high-ish to allow quality previews...
      filterQuality: FilterQuality.medium,
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      height: min(MediaQuery.of(context).size.height * 0.30, 100),
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
    }

    return LayoutBuilder(builder: (bcontext, constraints) {
      var wdgSender = Visibility(
          visible: widget.interactive,
          child: SelectableText(senderDisplayStr + '\u202F',
              style: TextStyle(fontSize: 9.0, color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeTextColor : Provider.of<Settings>(context).theme.messageFromOtherTextColor)));
      var isPreview = false;
      var wdgMessage = !showFileSharing
          ? Text(AppLocalizations.of(context)!.messageEnableFileSharing)
          : fromMe
              ? senderFileChrome(AppLocalizations.of(context)!.messageFileSent, widget.nameSuggestion, widget.rootHash, widget.fileSize)
              : (fileChrome(AppLocalizations.of(context)!.messageFileOffered + ":", widget.nameSuggestion, widget.rootHash, widget.fileSize,
                  Provider.of<ProfileInfoState>(context).downloadSpeed(widget.fileKey())));
      Widget wdgDecorations;

      if (!showFileSharing) {
        wdgDecorations = Text('\u202F');
      } else if (downloadComplete && path != null) {
        // in this case, whatever marked download.complete would have also set the path
        if (Provider.of<Settings>(context).shouldPreview(path)) {
          isPreview = true;
          wdgDecorations = Center(
              widthFactor: 1.0,
              child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    child: Padding(padding: EdgeInsets.all(1.0), child: getPreview(context)),
                    onTap: () {
                      pop(bcontext, myFile!, wdgMessage);
                    },
                  )));
        } else {
          wdgDecorations = Visibility(visible: widget.interactive, child: Text(AppLocalizations.of(context)!.fileSavedTo + ': ' + path + '\u202F'));
        }
      } else if (downloadActive) {
        if (!downloadGotManifest) {
          wdgDecorations = Visibility(visible: widget.interactive, child: Text(AppLocalizations.of(context)!.retrievingManifestMessage + '\u202F'));
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
          wdgDecorations = Text(AppLocalizations.of(context)!.fileCheckingStatus + '...' + '\u202F');
        } else {
          var path = Provider.of<ProfileInfoState>(context).downloadFinalPath(widget.fileKey()) ?? "";
          wdgDecorations = Visibility(
              visible: widget.interactive,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(AppLocalizations.of(context)!.fileInterrupted + ': ' + path + '\u202F'),
                ElevatedButton(onPressed: _btnResume, child: Text(AppLocalizations.of(context)!.verfiyResumeButton))
              ]));
        }
      } else if (!senderIsContact) {
        wdgDecorations = Text(AppLocalizations.of(context)!.msgAddToAccept);
      } else if (!widget.isAuto || Provider.of<MessageMetadata>(context).attributes["file-missing"] == "false") {
        //Note: we need this second case to account for scenarios where a user deletes the downloaded file, we won't automatically
        // fetch it again, so we need to offer the user the ability to restart..
        wdgDecorations = Visibility(
            visible: widget.interactive,
            child: Center(
                widthFactor: 1,
                child: Wrap(children: [
                  Padding(padding: EdgeInsets.all(5), child: ElevatedButton(child: Text(AppLocalizations.of(context)!.downloadFileButton + '\u202F'), onPressed: _btnAccept)),
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
      ContactInfoState? contact = Provider.of<ProfileInfoState>(context).contactList.findContact(Provider.of<MessageMetadata>(context).senderHandle);
      if (contact != null) {
        Provider.of<FlwtchState>(context, listen: false).cwtch.CreateDownloadableFile(profileOnion, contact.identifier, widget.nameSuggestion, widget.fileKey());
      }
    } else {
      try {
        selectedFileName = await saveFile(
          defaultFileName: widget.nameSuggestion,
        );
        if (selectedFileName != null) {
          file = File(selectedFileName);
          EnvironmentConfig.debugLog("saving to " + file.path);
          var manifestPath = file.path + ".manifest";
          Provider.of<ProfileInfoState>(context, listen: false).downloadInit(widget.fileKey(), (widget.fileSize / 4096).ceil());
          Provider.of<FlwtchState>(context, listen: false).cwtch.SetMessageAttribute(profileOnion, conversation, 0, idx, "file-downloaded", "true");
          ContactInfoState? contact = Provider.of<ProfileInfoState>(context, listen: false).contactList.findContact(Provider.of<MessageMetadata>(context).senderHandle);
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
    return ListTile(
        visualDensity: VisualDensity.compact,
        title: Wrap(direction: Axis.horizontal, alignment: WrapAlignment.start, children: [
          SelectableText(
            chrome + '\u202F',
            style: TextStyle(
              color: Provider.of<Settings>(context).theme.messageFromMeTextColor,
            ),
            textAlign: TextAlign.left,
            maxLines: 2,
            textWidthBasis: TextWidthBasis.longestLine,
          ),
          SelectableText(
            fileName + '\u202F',
            style: TextStyle(
              color: Provider.of<Settings>(context).theme.messageFromMeTextColor,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
            textAlign: TextAlign.left,
            textWidthBasis: TextWidthBasis.parent,
            maxLines: 2,
          ),
          SelectableText(
            prettyBytes(fileSize) + '\u202F' + '\n',
            style: TextStyle(
              color: Provider.of<Settings>(context).theme.messageFromMeTextColor,
            ),
            textAlign: TextAlign.left,
            maxLines: 2,
          )
        ]),
        subtitle: SelectableText(
          'sha512: ' + rootHash + '\u202F',
          style: TextStyle(
            color: Provider.of<Settings>(context).theme.messageFromMeTextColor,
            fontSize: 10,
            fontFamily: "monospace",
          ),
          textAlign: TextAlign.left,
          maxLines: 4,
          textWidthBasis: TextWidthBasis.parent,
        ),
        leading: Icon(Icons.attach_file, size: 32, color: Provider.of<Settings>(context).theme.messageFromMeTextColor));
  }

  // Construct an file chrome
  Widget fileChrome(String chrome, String fileName, String rootHash, int fileSize, String speed) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      title: Wrap(direction: Axis.horizontal, alignment: WrapAlignment.start, children: [
        SelectableText(
          chrome + '\u202F',
          style: TextStyle(
            color: Provider.of<Settings>(context).theme.messageFromOtherTextColor,
          ),
          textAlign: TextAlign.left,
          maxLines: 2,
          textWidthBasis: TextWidthBasis.longestLine,
        ),
        SelectableText(
          fileName + '\u202F',
          style: TextStyle(
            color: Provider.of<Settings>(context).theme.messageFromOtherTextColor,
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.ellipsis,
          ),
          textAlign: TextAlign.left,
          textWidthBasis: TextWidthBasis.parent,
          maxLines: 2,
        ),
        SelectableText(
          AppLocalizations.of(context)!.labelFilesize + ': ' + prettyBytes(fileSize) + '\u202F' + '\n',
          style: TextStyle(
            color: Provider.of<Settings>(context).theme.messageFromOtherTextColor,
          ),
          textAlign: TextAlign.left,
          maxLines: 2,
        )
      ]),
      subtitle: SelectableText(
        'sha512: ' + rootHash + '\u202F',
        style: TextStyle(
          color: Provider.of<Settings>(context).theme.messageFromMeTextColor,
          fontSize: 10,
          fontFamily: "monospace",
        ),
        textAlign: TextAlign.left,
        maxLines: 4,
        textWidthBasis: TextWidthBasis.parent,
      ),
      leading: Icon(Icons.attach_file, size: 32, color: Provider.of<Settings>(context).theme.messageFromOtherTextColor),
      trailing: Visibility(
          visible: speed != "0 B/s",
          child: SelectableText(
            speed + '\u202F',
            style: TextStyle(
              color: Provider.of<Settings>(context).theme.messageFromMeTextColor,
            ),
            textAlign: TextAlign.left,
            maxLines: 1,
            textWidthBasis: TextWidthBasis.longestLine,
          )),
    );
  }

  void pop(context, File myFile, Widget meta) async {
    await showDialog(
        context: context,
        builder: (bcontext) => Dialog(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(children: [
                ListTile(
                    title: meta,
                    trailing: IconButton(
                        icon: Icon(Icons.close),
                        color: Provider.of<Settings>(bcontext, listen: false).theme.toolbarIconColor,
                        iconSize: 32,
                        onPressed: () {
                          Navigator.pop(bcontext, true);
                        })),
                Image.file(
                  myFile,
                  cacheWidth: (MediaQuery.of(bcontext).size.width * 0.6).floor(),
                  width: (MediaQuery.of(bcontext).size.width * 0.6),
                  height: (MediaQuery.of(bcontext).size.height * 0.6),
                  fit: BoxFit.scaleDown,
                ),
                SizedBox(
                  height: 20,
                ),
                Visibility(visible: !Platform.isAndroid, child: Text(myFile.path, textAlign: TextAlign.center)),
                Visibility(visible: Platform.isAndroid, child: IconButton(icon: Icon(Icons.arrow_downward), onPressed: androidExport)),
              ]),
            )));
  }

  void androidExport() async {
    if (myFile != null) {
      Provider.of<FlwtchState>(context, listen: false).cwtch.ExportPreviewedFile(myFile!.path, widget.nameSuggestion);
    }
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:cwtch/models/message.dart';
import 'package:cwtch/widgets/malformedbubble.dart';
import 'package:file_picker/file_picker.dart' as androidPicker;
import 'package:file_picker_desktop/file_picker_desktop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../model.dart';
import 'package:intl/intl.dart';
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

  FileBubble(this.nameSuggestion, this.rootHash, this.nonce, this.fileSize);

  @override
  FileBubbleState createState() => FileBubbleState();

  String fileKey() {
    return this.rootHash + "." + this.nonce;
  }
}

class FileBubbleState extends State<FileBubble> {
  @override
  Widget build(BuildContext context) {
    var fromMe = Provider.of<MessageMetadata>(context).senderHandle == Provider.of<ProfileInfoState>(context).onion;
    //isAccepted = Provider.of<ProfileInfoState>(context).contactList.getContact(widget.inviteTarget) != null;
    var borderRadiousEh = 15.0;
    var showFileSharing = Provider.of<Settings>(context).isExperimentEnabled(FileSharingExperiment);
    var prettyDate = DateFormat.yMd(Platform.localeName).add_jm().format(Provider.of<MessageMetadata>(context).timestamp);

    // If the sender is not us, then we want to give them a nickname...
    var senderDisplayStr = "";
    if (!fromMe) {
      ContactInfoState? contact = Provider.of<ProfileInfoState>(context).contactList.getContact(Provider.of<MessageMetadata>(context).senderHandle);
      if (contact != null) {
        senderDisplayStr = contact.nickname;
      } else {
        senderDisplayStr = Provider.of<MessageMetadata>(context).senderHandle;
      }
    }

    var wdgSender = Center(
        widthFactor: 1,
        child: SelectableText(senderDisplayStr + '\u202F',
            style: TextStyle(fontSize: 9.0, color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeTextColor() : Provider.of<Settings>(context).theme.messageFromOtherTextColor())));

    var wdgMessage = !showFileSharing
        ? Text(AppLocalizations.of(context)!.messageEnableFileSharing)
        : fromMe
            ? senderInviteChrome(
              AppLocalizations.of(context)!.messageFileSent, widget.nameSuggestion, widget.rootHash, widget.fileSize)
            : (inviteChrome(AppLocalizations.of(context)!.messageFileOffered + ":", widget.nameSuggestion, widget.rootHash, widget.fileSize));

    Widget wdgDecorations;
    if (!showFileSharing) {
      wdgDecorations = Text('\u202F');
    } else if (fromMe) {
      wdgDecorations = MessageBubbleDecoration(ackd: Provider.of<MessageMetadata>(context).ackd, errored: Provider.of<MessageMetadata>(context).error, fromMe: fromMe, prettyDate: prettyDate);
    } else if (Provider.of<ProfileInfoState>(context).downloadComplete(widget.fileKey())) {
      wdgDecorations = Center(
          widthFactor: 1,
          child: Wrap(children: [
            Padding(padding: EdgeInsets.all(5), child: ElevatedButton(child: Text(AppLocalizations.of(context)!.openFolderButton + '\u202F'), onPressed: _btnAccept)),
          ]));
    } else if (Provider.of<ProfileInfoState>(context).downloadActive(widget.fileKey())) {
      if (!Provider.of<ProfileInfoState>(context).downloadGotManifest(widget.fileKey())) {
        wdgDecorations = Text(AppLocalizations.of(context)!.retrievingManifestMessage + '\u202F');
      } else {
        wdgDecorations = LinearProgressIndicator(
          value: Provider.of<ProfileInfoState>(context).downloadProgress(widget.fileKey()),
          color: Provider.of<Settings>(context).theme.defaultButtonActiveColor(),
        );
      }
    } else {
      wdgDecorations = Center(
          widthFactor: 1,
          child: Wrap(children: [
            Padding(padding: EdgeInsets.all(5), child: ElevatedButton(child: Text(AppLocalizations.of(context)!.downloadFileButton + '\u202F'), onPressed: _btnAccept)),
          ]));
    }

    return LayoutBuilder(builder: (context, constraints) {
      //print(constraints.toString()+", "+constraints.maxWidth.toString());
      return Center(
          widthFactor: 1.0,
          child: Container(
              decoration: BoxDecoration(
                color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeBackgroundColor() : Provider.of<Settings>(context).theme.messageFromOtherBackgroundColor(),
                border:
                    Border.all(color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeBackgroundColor() : Provider.of<Settings>(context).theme.messageFromOtherBackgroundColor(), width: 1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadiousEh),
                  topRight: Radius.circular(borderRadiousEh),
                  bottomLeft: fromMe ? Radius.circular(borderRadiousEh) : Radius.zero,
                  bottomRight: fromMe ? Radius.zero : Radius.circular(borderRadiousEh),
                ),
              ),
              child: Center(
                  widthFactor: 1.0,
                  child: Padding(
                      padding: EdgeInsets.all(9.0),
                      child: Wrap(runAlignment: WrapAlignment.spaceEvenly, alignment: WrapAlignment.spaceEvenly, runSpacing: 1.0, crossAxisAlignment: WrapCrossAlignment.center, children: [
                        Center(
                            widthFactor: 1, child: Padding(padding: EdgeInsets.all(10.0), child: Icon(Icons.attach_file, size: 32))),
                        Center(
                          widthFactor: 1.0,
                          child: Column(
                              crossAxisAlignment: fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              mainAxisAlignment: fromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: fromMe ? [wdgMessage, wdgDecorations] : [wdgSender, wdgMessage, wdgDecorations]),
                        )
                      ])))));
    });
  }

  void _btnAccept() async {
    String? selectedFileName;
    File? file;
    var profileOnion = Provider.of<ProfileInfoState>(context, listen: false).onion;
    var handle = Provider.of<MessageMetadata>(context, listen: false).senderHandle;

    if (Platform.isAndroid) {
      //todo: would be better to only call downloadInit if CreateDownloadableFile results in a user-pick (they might cancel)
      Provider.of<ProfileInfoState>(context, listen: false).downloadInit(widget.fileKey(), (widget.fileSize / 4096).ceil());
      Provider.of<FlwtchState>(context, listen: false).cwtch.CreateDownloadableFile(profileOnion, handle, widget.nameSuggestion, widget.fileKey());
    } else {
      try {
         selectedFileName = await saveFile(defaultFileName: widget.nameSuggestion,);
         if (selectedFileName != null) {
           file = File(selectedFileName);
           print("saving to " + file.path);
           var manifestPath = file.path + ".manifest";
           setState(() {
             Provider.of<FlwtchState>(context, listen: false).cwtch.DownloadFile(profileOnion, handle, file!.path, manifestPath, widget.fileKey());
           });
         }
      } catch (e) {
        print(e);
      }
    }
  }

  // Construct an invite chrome for the sender
  Widget senderInviteChrome(String chrome, String fileName, String rootHash, int fileSize) {
    return Wrap(children: [
      SelectableText(
        chrome + '\u202F',
        style: TextStyle(
          color: Provider.of<Settings>(context).theme.messageFromMeTextColor(),
        ),
        textAlign: TextAlign.left,
        maxLines: 2,
        textWidthBasis: TextWidthBasis.longestLine,
      ),
      SelectableText(
        fileName + '\u202F',
        style: TextStyle(
          color: Provider.of<Settings>(context).theme.messageFromMeTextColor(),
        ),
        textAlign: TextAlign.left,
        maxLines: 2,
        textWidthBasis: TextWidthBasis.longestLine,
      ),
      SelectableText(
        fileSize.toString() + 'B\u202F',
        style: TextStyle(
          color: Provider.of<Settings>(context).theme.messageFromMeTextColor(),
        ),
        textAlign: TextAlign.left,
        maxLines: 2,
        textWidthBasis: TextWidthBasis.longestLine,
      ),
      SelectableText(
        'sha512: ' + rootHash + '\u202F',
        style: TextStyle(
          color: Provider.of<Settings>(context).theme.messageFromMeTextColor(),
        ),
        textAlign: TextAlign.left,
        maxLines: 2,
        textWidthBasis: TextWidthBasis.longestLine,
      ),
    ]);
  }

  // Construct an invite chrome
  Widget inviteChrome(String chrome, String fileName, String rootHash, int fileSize) {
    var prettyHash = rootHash;
    if (rootHash.length == 128) {
      prettyHash = rootHash.substring(0, 32) + '\n' +
          rootHash.substring(32, 64) + '\n' +
          rootHash.substring(64, 96) + '\n' +
          rootHash.substring(96);
    }

    return Wrap(direction: Axis.vertical,
        children: [
      SelectableText(
        chrome + '\u202F',
        style: TextStyle(
          color: Provider.of<Settings>(context).theme.messageFromOtherTextColor(),
        ),
        textAlign: TextAlign.left,
        textWidthBasis: TextWidthBasis.longestLine,
        maxLines: 2,
      ),
      SelectableText(
        AppLocalizations.of(context)!.labelFilename +': ' + fileName + '\u202F',
        style: TextStyle(
          color: Provider.of<Settings>(context).theme.messageFromMeTextColor(),
        ),
        textAlign: TextAlign.left,
        maxLines: 2,
        textWidthBasis: TextWidthBasis.longestLine,
      ),
      SelectableText(
        AppLocalizations.of(context)!.labelFilesize + ': ' + fileSize.toString() + 'B\u202F',
        style: TextStyle(
          color: Provider.of<Settings>(context).theme.messageFromMeTextColor(),
        ),
        textAlign: TextAlign.left,
        maxLines: 2,
        textWidthBasis: TextWidthBasis.longestLine,
      ),
      SelectableText(
        'sha512: ' + prettyHash + '\u202F',
        style: TextStyle(
          color: Provider.of<Settings>(context).theme.messageFromMeTextColor(),
        ),
        textAlign: TextAlign.left,
        maxLines: 4,
        textWidthBasis: TextWidthBasis.longestLine,
      ),
    ]);
  }
}

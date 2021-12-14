import 'dart:io';

import 'package:cwtch/models/message.dart';
import 'package:file_picker_desktop/file_picker_desktop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  final bool interactive;

  FileBubble(this.nameSuggestion, this.rootHash, this.nonce, this.fileSize, {this.interactive = true});

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

  @override
  Widget build(BuildContext context) {
    var fromMe = Provider.of<MessageMetadata>(context).senderHandle == Provider.of<ProfileInfoState>(context).onion;
    var flagStarted = Provider.of<MessageMetadata>(context).flags & 0x02 > 0;
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
    } else if (fromMe) {
      wdgDecorations = MessageBubbleDecoration(ackd: Provider.of<MessageMetadata>(context).ackd, errored: Provider.of<MessageMetadata>(context).error, fromMe: fromMe, prettyDate: prettyDate);
    } else if (Provider.of<ProfileInfoState>(context).downloadComplete(widget.fileKey())) {
      // in this case, whatever marked download.complete would have also set the path
      var path = Provider.of<ProfileInfoState>(context).downloadFinalPath(widget.fileKey())!;
      var lpath = path.toLowerCase();
      if (lpath.endsWith("jpg") || lpath.endsWith("jpeg") || lpath.endsWith("png") || lpath.endsWith("gif") || lpath.endsWith("webp") || lpath.endsWith("bmp")) {
        if (myFile == null) {
          setState(() { myFile = new File(path); });
        }

        isPreview = true;
        wdgDecorations = GestureDetector(child: Image.file(myFile!, width: 200), onTap:(){pop(myFile!, wdgMessage);},);
      } else {
        wdgDecorations = Text(AppLocalizations.of(context)!.fileSavedTo + ': ' + path + '\u202F');
      }
    } else if (Provider.of<ProfileInfoState>(context).downloadActive(widget.fileKey())) {
      if (!Provider.of<ProfileInfoState>(context).downloadGotManifest(widget.fileKey())) {
        wdgDecorations = Text(AppLocalizations.of(context)!.retrievingManifestMessage + '\u202F');
      } else {
        wdgDecorations = LinearProgressIndicator(
          value: Provider.of<ProfileInfoState>(context).downloadProgress(widget.fileKey()),
          color: Provider.of<Settings>(context).theme.defaultButtonActiveColor(),
        );
      }
    } else if (flagStarted) {
      // in this case, the download was done in a previous application launch,
      // so we probably have to request an info lookup
      if (!Provider.of<ProfileInfoState>(context).downloadInterrupted(widget.fileKey()) ) {
        wdgDecorations = Text(AppLocalizations.of(context)!.fileCheckingStatus + '...' + '\u202F');
        Provider.of<FlwtchState>(context, listen: false).cwtch.CheckDownloadStatus(Provider.of<ProfileInfoState>(context, listen: false).onion, widget.fileKey());
      } else {
        var path = Provider.of<ProfileInfoState>(context).downloadFinalPath(widget.fileKey()) ?? "";
        wdgDecorations = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[Text(AppLocalizations.of(context)!.fileInterrupted + ': ' + path + '\u202F'),ElevatedButton(onPressed: _btnResume, child: Text(AppLocalizations.of(context)!.verfiyResumeButton))]
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
                      child: Wrap(alignment: WrapAlignment.start, children: [
                        Center(
                          widthFactor: 1.0,
                          child: Column(
                              crossAxisAlignment: fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              mainAxisAlignment: fromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: fromMe
                                  ? [wdgMessage, Visibility(visible: widget.interactive, child: wdgDecorations)]
                                  : [wdgSender, isPreview ? Container() : wdgMessage, Visibility(visible: widget.interactive, child: wdgDecorations)]),
                        )
                      ])))));
    });
  }

  void _btnAccept() async {
    String? selectedFileName;
    File? file;
    var profileOnion = Provider.of<ProfileInfoState>(context, listen: false).onion;
    var handle = Provider.of<MessageMetadata>(context, listen: false).senderHandle;
    var contact = Provider.of<ContactInfoState>(context, listen: false).onion;
    var idx = Provider.of<MessageMetadata>(context, listen: false).messageIndex;

    if (Platform.isAndroid) {
      Provider.of<ProfileInfoState>(context, listen: false).downloadInit(widget.fileKey(), (widget.fileSize / 4096).ceil());
      Provider.of<FlwtchState>(context, listen: false).cwtch.UpdateMessageFlags(profileOnion, contact, idx, Provider.of<MessageMetadata>(context, listen: false).flags | 0x02);
      Provider.of<MessageMetadata>(context, listen: false).flags |= 0x02;
      Provider.of<FlwtchState>(context, listen: false).cwtch.CreateDownloadableFile(profileOnion, handle, widget.nameSuggestion, widget.fileKey());
    } else {
      try {
        selectedFileName = await saveFile(
          defaultFileName: widget.nameSuggestion,
        );
        if (selectedFileName != null) {
          file = File(selectedFileName);
          print("saving to " + file.path);
          var manifestPath = file.path + ".manifest";
          Provider.of<ProfileInfoState>(context, listen: false).downloadInit(widget.fileKey(), (widget.fileSize / 4096).ceil());
          Provider.of<FlwtchState>(context, listen: false).cwtch.UpdateMessageFlags(profileOnion, contact, idx, Provider.of<MessageMetadata>(context, listen: false).flags | 0x02);
          Provider.of<MessageMetadata>(context, listen: false).flags |= 0x02;
          Provider.of<FlwtchState>(context, listen: false).cwtch.DownloadFile(profileOnion, handle, file.path, manifestPath, widget.fileKey());
        }
      } catch (e) {
        print(e);
      }
    }
  }

  void _btnResume() async {
    var profileOnion = Provider.of<ProfileInfoState>(context, listen: false).onion;
    var handle = Provider.of<MessageMetadata>(context, listen: false).senderHandle;
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
              color: Provider.of<Settings>(context).theme.messageFromMeTextColor(),
            ),
            textAlign: TextAlign.left,
            maxLines: 2,
          )
        ]),
        subtitle: SelectableText(
          'sha512: ' + rootHash + '\u202F',
          style: TextStyle(
            color: Provider.of<Settings>(context).theme.messageFromMeTextColor(),
            fontSize: 10,
            fontFamily: "monospace",
          ),
          textAlign: TextAlign.left,
          maxLines: 4,
          textWidthBasis: TextWidthBasis.parent,
        ),
        leading: Icon(Icons.attach_file, size: 32, color: Provider.of<Settings>(context).theme.messageFromMeTextColor()));
  }

  // Construct an file chrome
  Widget fileChrome(String chrome, String fileName, String rootHash, int fileSize, String speed) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      title: Wrap(direction: Axis.horizontal, alignment: WrapAlignment.start, children: [
        SelectableText(
          chrome + '\u202F',
          style: TextStyle(
            color: Provider.of<Settings>(context).theme.messageFromOtherTextColor(),
          ),
          textAlign: TextAlign.left,
          maxLines: 2,
          textWidthBasis: TextWidthBasis.longestLine,
        ),
        SelectableText(
          fileName + '\u202F',
          style: TextStyle(
            color: Provider.of<Settings>(context).theme.messageFromOtherTextColor(),
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
            color: Provider.of<Settings>(context).theme.messageFromOtherTextColor(),
          ),
          textAlign: TextAlign.left,
          maxLines: 2,
        )
      ]),
      subtitle: SelectableText(
        'sha512: ' + rootHash + '\u202F',
        style: TextStyle(
          color: Provider.of<Settings>(context).theme.messageFromMeTextColor(),
          fontSize: 10,
          fontFamily: "monospace",
        ),
        textAlign: TextAlign.left,
        maxLines: 4,
        textWidthBasis: TextWidthBasis.parent,
      ),
      leading: Icon(Icons.attach_file, size: 32, color: Provider.of<Settings>(context).theme.messageFromOtherTextColor()),
      trailing: Visibility(
          visible: speed != "0 B/s",
          child: SelectableText(
            speed + '\u202F',
            style: TextStyle(
              color: Provider.of<Settings>(context).theme.messageFromMeTextColor(),
            ),
            textAlign: TextAlign.left,
            maxLines: 1,
            textWidthBasis: TextWidthBasis.longestLine,
          )),
    );
  }

  void pop(File myFile, Widget meta) async {
    await showDialog(
        context: context,
        builder: (_) => Dialog(
          child: Container(padding: EdgeInsets.all(10), width: 500, height: 550, child:Column(children:[meta,Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: Image.file(myFile).image,
                    fit: BoxFit.scaleDown
                )
            ),
          ),Icon(Icons.arrow_downward)]),
        ))
    );
  }
}

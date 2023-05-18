import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

/// A "MessageDraft" structure that stores information about in-progress message drafts.
/// MessageDraft stores text, quoted replies, and attached images.
/// Only one draft is stored per conversation.
class MessageDraft extends ChangeNotifier {
  QuotedReference? _quotedReference;

  TextEditingController ctrlCompose = TextEditingController();

  static MessageDraft empty() {
    return MessageDraft();
  }

  bool isEmpty() {
    return (this._quotedReference == null) || (this.messageText.isEmpty);
  }

  String get messageText => ctrlCompose.text;

  set messageText(String text) {
    this.ctrlCompose.text = text;
    notifyListeners();
  }

  set quotedReference(int index) {
    this._quotedReference = QuotedReference(index);
    notifyListeners();
  }

  QuotedReference? getQuotedMessage() {
    return this._quotedReference;
  }

  void clearQuotedReference() {
    this._quotedReference = null;
    notifyListeners();
  }

  void clearDraft() {
    this._quotedReference = null;
    this.ctrlCompose.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    ctrlCompose.dispose();
    super.dispose();
  }
}

/// A QuotedReference encapsulates the state of replied-to message.
class QuotedReference {
  int index;
  QuotedReference(this.index);
}

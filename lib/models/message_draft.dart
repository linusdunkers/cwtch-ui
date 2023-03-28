import 'package:flutter/foundation.dart';

/// A "MessageDraft" structure that stores information about in-progress message drafts.
/// MessageDraft stores text, quoted replies, and attached images.
/// Only one draft is stored per conversation.
class MessageDraft extends ChangeNotifier {
  String? _messageText;
  QuotedReference? _quotedReference;

  static MessageDraft empty() {
    return MessageDraft();
  }

  bool isEmpty() {
    return (this._messageText == null && this._quotedReference == null) || (this._messageText != null && this._messageText!.isEmpty);
  }

  String? get messageText => _messageText;

  set messageText(String? text) {
    this._messageText = text;
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
}

/// A QuotedReference encapsulates the state of replied-to message.
class QuotedReference {
  int index;
  QuotedReference(this.index);
}

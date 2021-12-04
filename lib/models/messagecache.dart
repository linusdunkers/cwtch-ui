import 'dart:collection';

import 'package:cwtch/widgets/messagerow.dart';
import 'package:flutter/material.dart';

int MinCacheSize = 20;

class MessageCache extends ChangeNotifier {
  final String profile;

  Queue<MessageRowState> cacheByIndex = Queue();
  Map<int, MessageRowState> cacheById = Map();

  MessageCache(this.profile) {}

  // So we internall need to fetch by N (new libcwtch API)
  // then double store by index and id to support both calls
  // monitor activeConversation for unlimited growth and when
  // change to not active convo, trigger a shrink
  // bonus: dont prune cache by id messages refed in core list

  GetMessageByIndex(conversationIdentifier, index);

  GetMessageById(conversationIdentifier, index);

}

class ChatMessage {
  final int o;
  final String d;

  ChatMessage({required this.o, required this.d});

  ChatMessage.fromJson(Map<String, dynamic> json)
      : o = json['o'],
        d = json['d'];

  Map<String, dynamic> toJson() => {
    'o': o,
    'd': d,
  };
}
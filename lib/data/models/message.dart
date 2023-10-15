class Message {
  Message({
    required this.msg,
    required this.senderId,
    required this.read,
    required this.receiverId,
    required this.type,
    required this.sent,
  });
  late final String msg;
  late final String senderId;
  late final String read;
  late final String receiverId;
  late final Type type;
  late final String sent;

  Message.fromJson(Map<String, dynamic> json) {
    msg = json['msg'].toString();
    senderId = json['senderId'].toString();
    read = json['read'].toString();
    receiverId = json['receiverId'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['msg'] = msg;
    data['senderId'] = senderId;
    data['read'] = read;
    data['receiverId'] = receiverId;
    data['type'] = type.name;
    data['sent'] = sent;
    return data;
  }
}

enum Type { text, image }

class ChatUsers {
  String name;
  String messageText;
  String imageURL;
  String time;
  ChatUsers(
      {required this.name,
      required this.messageText,
      required this.imageURL,
      required this.time});
}

class ChatMessage {
  String messageContent;
  String messageType;
  String messageProduct;
  ChatMessage(
      {required this.messageContent,
      required this.messageType,
      required this.messageProduct});
}

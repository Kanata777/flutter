// models/chat.dart
class Chat {
  final String sender;
  final String message;
  final DateTime timeStamp;

  Chat({required this.sender, required this.message, required this.timeStamp});

  // Method to convert Chat object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'message': message,
      'timeStamp': timeStamp.toIso8601String(),
    };
  }

  // Method to create Chat object from Firestore document
  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      sender: map['sender'] ?? '',
      message: map['message'] ?? '',
      timeStamp: DateTime.parse(map['timeStamp']),
    );
  }
}

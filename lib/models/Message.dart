import 'Profile.dart';

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final Profile sender; // ✅ Add sender details
  int unreadCount; // Add this field


  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.createdAt,
    required this.isRead,
    required this.sender, // ✅ Required sender object
    this.unreadCount = 0, // Default to 0
  });

  /// Factory constructor to create a Message object from a Map (e.g., Supabase response).
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      senderId: map['sender_id'] as String,
      receiverId: map['receiver_id'] as String,
      message: map['message'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      isRead: map['is_read'] as bool? ?? false,
      sender: Profile.fromJson(map['users'] ?? {}), // ✅ Extract sender details
      unreadCount: 0, // Ensure it initializes to 0
    );
  }

  /// Converts a Message object to a Map (useful for inserting into Supabase).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'users': sender.toJson(), // ✅ Include sender details
      'unreadCount': 0, // Ensure it initializes to 0
    };
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat_box/screens/NewChatScreen.dart';
import 'package:flutter_chat_box/screens/SettingScreen.dart';
import 'package:flutter_chat_box/utils/Constants.dart';
import 'ChatDetailScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final String title;

  const ChatScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  /// Fetch image from gallery.
  Future<void> getImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  /// Fetch image from camera.
  Future<void> getImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes back arrow.
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: getImageFromCamera,
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Handle search action.
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'New Group':
                // Navigate to New Group Screen.
                  break;
                case 'New Broadcast':
                // Navigate to New Broadcast Screen.
                  break;
                case 'Linked Devices':
                // Navigate to Linked Devices Screen.
                  break;
                case 'Payments':
                // Navigate to Payments Screen.
                  break;
                case 'Settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingScreen(title: 'Settings'),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'New Group',
                  child: Text('New Group'),
                ),
                PopupMenuItem(
                  value: 'New Broadcast',
                  child: Text('New Broadcast'),
                ),
                PopupMenuItem(
                  value: 'Linked Devices',
                  child: Text('Linked Devices'),
                ),
                PopupMenuItem(
                  value: 'Payments',
                  child: Text('Payments'),
                ),
                PopupMenuItem(
                  value: 'Settings',
                  child: Text('Settings'),
                ),
              ];
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewChatScreen(title: 'New Chat'),
            ),
          );
        },
        child: Icon(Icons.contacts),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getChatListStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!;
          if (chats.isEmpty) {
            return Center(child: Text('No chats available'));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final unreadCount = chat['unread_count'] ?? 0;
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(Constants.PLACEHOLDER_URL),
                ),
                title: Text(chat['contact_name'] ?? 'Unknown'),
                subtitle: Text(chat['last_message'] ?? 'No messages yet'),
                trailing: unreadCount > 0
                    ? CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Text(
                    unreadCount.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                )
                    : Text(chat['last_message_time'] ?? ''),
                onTap: () {
                  // Mark messages as read and navigate to chat detail screen.
                  _markMessagesAsRead(chat['chat_id']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(
                        receiverId: chat['receiver_id'],
                        receiverEmail: '',
                        receiverPhone: '',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Returns a stream of chat data grouped by sender_id.
  Stream<List<Map<String, dynamic>>> _getChatListStream() {
    final String? userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      // If there is no authenticated user, return an empty stream.
      return Stream.value([]);
    }

    return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', userId) // Only messages for the current user.
        .order('created_at', ascending: false)
        .map((messages) {
      // Group messages by sender_id.
      final Map<String, Map<String, dynamic>> chatData = {};

      for (var message in messages) {
        final String senderId = message['sender_id'];

        // Initialize the chat data for a new sender.
        if (chatData[senderId] == null) {
          chatData[senderId] = {
            'chat_id': senderId, // Using sender_id as chat identifier.
            'contact_name': 'User Name', // Placeholder; fetch actual name as needed.
            'last_message': message['message'],
            'last_message_time': _formatTime(message['created_at']),
            'unread_count': 0,
          };
        }

        // Since we ordered messages descending by created_at,
        // the first message encountered is the latest message.
        // Count unread messages. If the 'is_read' flag is missing, assume it's unread.
        if (message['is_read'] == null || message['is_read'] == false) {
          chatData[senderId]!['unread_count'] += 1;
        }
      }

      return chatData.values.toList();
    });
  }

  /// Marks all messages from the sender (chat) as read.
  Future<void> _markMessagesAsRead(String chatId) async {
    final String? userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase
        .from('messages')
        .update({'is_read': true})
        .eq('sender_id', chatId)
        .eq('receiver_id', userId);
  }

  /// Helper to format the created_at timestamp to a human-readable time string.
  String _formatTime(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    int hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '$hour:$minute $period';
  }
}

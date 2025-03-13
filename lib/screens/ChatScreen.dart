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
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  /// Fetch image from camera.
  Future<void> getImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: getImageFromCamera,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingScreen(title: 'Settings'),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'New Group', child: Text('New Group')),
              const PopupMenuItem(value: 'New Broadcast', child: Text('New Broadcast')),
              const PopupMenuItem(value: 'Linked Devices', child: Text('Linked Devices')),
              const PopupMenuItem(value: 'Payments', child: Text('Payments')),
              const PopupMenuItem(value: 'Settings', child: Text('Settings')),
            ],
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
        child: const Icon(Icons.contacts),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getChatListStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!;
          if (chats.isEmpty) {
            return const Center(child: Text('No chats available'));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final unreadCount = chat['unread_count'] ?? 0;
              return ListTile(
                leading: const CircleAvatar(
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
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                )
                    : Text(chat['last_message_time'] ?? ''),
                onTap: () {
                  _markMessagesAsRead(chat['chat_id']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(
                        receiverId: chat['chat_id'],
                        receiverEmail: chat['contact_email'] ?? '',
                        receiverPhone: chat['contact_phone'] ?? '',
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

  Stream<List<Map<String, dynamic>>> _getChatListStream() {
    final String? userId = supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return supabase.from('messages').stream(primaryKey: ['id']).eq('receiver_id', userId).order('created_at', ascending: false).map((messages) {
      final Map<String, Map<String, dynamic>> chatData = {};

      for (var message in messages) {
        final String senderId = message['sender_id'];

        chatData[senderId] ??= {
          'chat_id': senderId,
          'contact_name': 'User Name',
          'contact_email': message['sender_email'],
          'contact_phone': message['sender_phone'],
          'last_message': message['message'],
          'last_message_time': _formatTime(message['created_at']),
          'unread_count': 0,
        };

        if (message['is_read'] == null || message['is_read'] == false) {
          chatData[senderId]!['unread_count'] += 1;
        }
      }
      return chatData.values.toList();
    });
  }

  Future<void> _markMessagesAsRead(String chatId) async {
    final String? userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase.from('messages').update({'is_read': true}).eq('sender_id', chatId).eq('receiver_id', userId);
  }

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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat_box/models/Message.dart'; // Import Message model
import 'package:flutter_chat_box/screens/NewChatScreen.dart';
import 'package:flutter_chat_box/screens/SettingScreen.dart';
import 'package:flutter_chat_box/utils/Constants.dart';
import 'ChatDetailScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecentChatScreen extends StatefulWidget {
  final String title;

  const RecentChatScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<RecentChatScreen> createState() => _RecentChatScreenState();
}

class _RecentChatScreenState extends State<RecentChatScreen> {
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
        child: const Icon(Icons.add_circle),
      ),
      body: FutureBuilder<List<Message>>(
        future: fetchChatList(), // Fetch chat list
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final chats = snapshot.data ?? [];
          if (chats.isEmpty) {
            return const Center(child: Text('No chats available'));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundImage: NetworkImage(Constants.PLACEHOLDER_URL),
                  // backgroundImage: NetworkImage(user?.userMetadata?['image_path'] ?? 'https://gravatar.com/avatar/${user!.email}'),
                ),
                title: Text(chat.sender.name),
                subtitle: Text(chat.message),
                trailing: chat.unreadCount > 0
                    ? CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Text(
                    chat.unreadCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                )
                    : Text(_formatTime(chat.createdAt.toIso8601String())),
                onTap: () async {
                  await _markMessagesAsRead(chat.senderId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(
                        receiverId: chat.senderId,
                        receiverEmail: chat.sender.email,
                        receiverPhone: chat.sender.phone,
                      ),
                    ),
                  ).then((_) {
                    setState(() {}); // Refresh chat list
                  });
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Fetch chat list using Supabase query with JOIN and unread count
  Future<List<Message>> fetchChatList() async {
    final String? userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase
        .from('messages')
        .select('''
      id, sender_id, receiver_id, message, created_at, is_read,
      users!messages_sender_id_fkey (id, name, email, phone)
      ''')
        .eq('receiver_id', userId)
        .order('created_at', ascending: false);

    print(response.toString());

    // Map to store the latest message per sender and unread count
    Map<String, Message> latestMessages = {};
    Map<String, int> unreadCountMap = {};

    for (var data in response) {
      Message message = Message.fromMap(data);

      // Keep only the latest message from each sender
      if (!latestMessages.containsKey(message.senderId) ||
          message.createdAt.isAfter(latestMessages[message.senderId]!.createdAt)) {
        latestMessages[message.senderId] = message;
      }

      // Count unread messages per sender
      if (message.isRead == false) {
        unreadCountMap[message.senderId] = (unreadCountMap[message.senderId] ?? 0) + 1;
      }
    }

    // Update unread count in Message objects
    latestMessages.forEach((senderId, message) {
      message.unreadCount = unreadCountMap[senderId] ?? 0;
    });

    return latestMessages.values.toList();
  }

  /// Mark messages as read when opening chat
  Future<void> _markMessagesAsRead(String chatId) async {
    final String? userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase
        .from('messages')
        .update({'is_read': true})
        .eq('sender_id', chatId)
        .eq('receiver_id', userId);

    setState(() {}); // Refresh UI to update unread count
  }

  /// Format timestamp into a readable time string (e.g., 12:30 PM)
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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_box/screens/NewChatScreen.dart';
import 'package:flutter_chat_box/screens/SettingScreen.dart';
import 'package:flutter_chat_box/utils/Constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'ChatDetailScreen.dart';

final SupabaseClient supabase = Supabase.instance.client;

class ChatScreen extends StatefulWidget {
  final String title;

  const ChatScreen({super.key, required this.title});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final user = Supabase.instance.client.auth.currentUser; // Logged-in user
  final Map<String, Map<String, String>> userCache = {}; // Caching user info

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery
  Future<void> getImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) _imageFile = File(pickedFile.path);
    });
  }

  /// Pick an image from camera
  Future<void> getImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) _imageFile = File(pickedFile.path);
    });
  }

  /// Fetch real-time messages and group by unique sender
  Stream<List<Map<String, dynamic>>> fetchMessages() {
    return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', user?.id as Object)
        .order('created_at', ascending: false)
        .map((data) {
      final Map<String, Map<String, dynamic>> uniqueMessages = {};
      for (var message in data) {
        String senderId = message['sender_id'];
        if (!uniqueMessages.containsKey(senderId)) {
          uniqueMessages[senderId] = message; // Keep only the latest message per sender
        }
      }
      return uniqueMessages.values.toList();
    });
  }

  /// Fetch user details (email & phone) from `auth.users`
  Future<void> fetchUserNames(List<String> userIds) async {
    final idsToFetch = userIds.where((id) => !userCache.containsKey(id)).toList();
    if (idsToFetch.isEmpty) return;

    final response = await supabase
        .from('users') // Ensure `users` table exists in Supabase
        .select('id, email, phone')
        .inFilter('id', idsToFetch);

    if (response is List) {
      setState(() {
        for (var user in response) {
          userCache[user['id']] = {
            'id': user['id'] ?? 'Unknown',
            'email': user['email'] ?? 'Unknown',
            'phone': user['phone'] ?? 'N/A',
          };
        }
      });
    }
  }

  /// Build the chat list tile
  Widget _buildMessageTile(Map<String, dynamic> message) {
    final senderId = message['sender_id'];
    final senderInfo = userCache[senderId] ?? {'email': 'Loading...', 'phone': 'Loading...', 'id': 'Loading...'};

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage('https://gravatar.com/avatar/$senderId'),
      ),
      title: Text(senderInfo['email']!), // Display sender email
      // subtitle: Text("Phone: ${senderInfo['phone']}\n${message['message'] ?? ''}"), // Show phone & message
      subtitle: Text("${message['message'] ?? ''}"), // Show phone & message
      trailing: Text(message['created_at'].toString().substring(11, 16)), // Show HH:mm
      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(receiverId: senderId, receiverEmail: senderInfo['email']!, receiverPhone: senderInfo['phone']!,),
          ),
        );

      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes back arrow
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: getImageFromCamera,
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search action
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingScreen(title: 'Settings')),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'New Group', child: Text('New Group')),
              PopupMenuItem(value: 'New Broadcast', child: Text('New Broadcast')),
              PopupMenuItem(value: 'Linked Devices', child: Text('Linked Devices')),
              PopupMenuItem(value: 'Payments', child: Text('Payments')),
              PopupMenuItem(value: 'Settings', child: Text('Settings')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewChatScreen(title: 'New Chat')),
          );
        },
        child: Icon(Icons.contacts),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fetchMessages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching messages'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No messages yet.'));
          }

          final messages = snapshot.data!;
          final senderIds = messages.map((m) => m['sender_id'].toString()).toSet().toList();

          return FutureBuilder(
            future: fetchUserNames(senderIds),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting && userCache.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }
              if (userSnapshot.hasError) {
                return Center(child: Text('Error fetching user names'));
              }

              return ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) => _buildMessageTile(messages[index]),
              );
            },
          );
        },
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../provider/UiProvider.dart';

final SupabaseClient _supabase = Supabase.instance.client;

class ChatDetailScreen extends StatefulWidget {
  final String receiverId;
  final String receiverEmail;
  final String receiverPhone;

  const ChatDetailScreen({
    super.key,
    required this.receiverId,
    required this.receiverEmail,
    required this.receiverPhone,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final user = _supabase.auth.currentUser;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _fetchMessages(); // Fetch messages when screen loads
  }

  /// Fetch Messages Between Current User & Receiver
  Future<void> _fetchMessages() async {
    if (user == null) return;

    try {
      final response = await _supabase
          .from('messages')
          .select()
          .or('sender_id.eq.${user!.id},receiver_id.eq.${user!.id}')
          .order('created_at', ascending: false);

      setState(() {
        _messages = response;
      });
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  /// Send a text message
  void _sendMessage() async {
    if (_controller.text.isNotEmpty && user != null) {
      String messageText = _controller.text.trim();
      _controller.clear();

      try {
        await _supabase.from('messages').insert({
          'message': messageText,
          'receiver_id': widget.receiverId,
          'sender_id': user!.id,
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        });

        _fetchMessages(); // Refresh message list after sending
      } catch (e) {
        print("Error sending message: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);

    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          image: uiProvider.wallpaperPath != null
              ? DecorationImage(
            image: FileImage(File(uiProvider.wallpaperPath!)),
            fit: BoxFit.cover,
          )
              : null,
        ),
        child: Column(
          children: [
            _buildMessageList(),
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  /// App Bar UI
  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
                'https://gravatar.com/avatar/${widget.receiverEmail}'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverEmail,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  widget.receiverPhone,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
        IconButton(icon: const Icon(Icons.call), onPressed: () {}),
        IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
      ],
    );
  }

  /// Message List UI with ListView
  Widget _buildMessageList() {
    return Expanded(
      child: _messages.isEmpty
          ? const Center(child: Text("No messages yet."))
          : ListView.builder(
        reverse: true,
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];

          return ChatBubble(
            message: message["message"],
            isSentByMe: message["sender_id"] == user!.id,
            isRead: message["is_read"] ?? false,
          );
        },
      ),
    );
  }

  /// Input field UI
  Widget _buildInputField() {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

// Chat Bubble Widget
class ChatBubble extends StatelessWidget {
  final String? message;
  final bool isSentByMe;
  final bool isRead;

  const ChatBubble({
    super.key,
    this.message,
    required this.isSentByMe,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSentByMe ? Colors.green.shade600 : Colors.blue.shade600,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isSentByMe ? const Radius.circular(15) : Radius.zero,
            bottomRight: isSentByMe ? Radius.zero : const Radius.circular(15),
          ),
        ),
        child: Column(
          crossAxisAlignment:
          isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message ?? "",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              isSentByMe ? (isRead ? "✔️ Read" : "⏳ Sent") : "",
              style: TextStyle(
                fontSize: 12,
                color: isRead ? Colors.white70 : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

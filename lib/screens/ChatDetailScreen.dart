import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../provider/UiProvider.dart';
import 'package:http/http.dart' as http;

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
    _subscribeToMessages(); // Listen for new messages in real-time
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

  /// Listen for new messages in real-time
  void _subscribeToMessages() {
    _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .listen((data) {
      setState(() {
        _messages = data;
      });
    });
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty && user != null) {
      String messageText = _controller.text.trim();
      _controller.clear();

      try {
        // Store message in Supabase
        await _supabase.from('messages').insert({
          'message': messageText,
          'receiver_id': widget.receiverId,
          'sender_id': user!.id,
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        });

        // Ensure .env is loaded
        final flaskUrl = dotenv.env['FLASK_IP'] ?? '';

        if (flaskUrl.isEmpty) {
          print("Error: FLASK_IP is not set in .env");
          return;
        }

        // Send message to Flask bot API
        // Call bot API asynchronously
        Future.delayed(Duration(seconds: 5), () async {
          try {
            final botResponse = await http.post(
              Uri.parse("$flaskUrl/chatbot"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({"message": messageText}),
            );

            if (botResponse.statusCode == 200) {
              final data = jsonDecode(botResponse.body);
              String botReply = data["reply"] ?? "No response from bot";

              // Insert bot's reply into Supabase after 5 seconds
              await _supabase.from('messages').insert({
                'message': botReply,
                'receiver_id': user!.id,
                'sender_id': widget.receiverId,
                'is_read': false,
                'created_at': DateTime.now().toIso8601String(),
              });
            }
          } catch (e) {
            print("Error fetching bot reply: $e");
          }
        });

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
      title: Text(widget.receiverEmail),
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
      padding: const EdgeInsets.all(8.0),
      color: Colors.black87,
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
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: isSentByMe ? Colors.green.shade600 : Colors.blue.shade600,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message ?? "",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

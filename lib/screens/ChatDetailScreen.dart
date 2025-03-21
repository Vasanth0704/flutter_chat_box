import 'dart:convert';
import 'dart:io';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_box/screens/call/CallScreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import '../provider/UiProvider.dart';
import 'call/NewCallScreen.dart';

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
  final TextEditingController _messageController = TextEditingController();
  final user = _supabase.auth.currentUser;
  List<Map<String, dynamic>> _messages = [];

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

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

  Future<void> _fetchMessages() async {
    if (user == null) return;

    try {
      final response = await _supabase
          .from('messages')
          .select()
          // .eq("receiver_id", widget.receiverId)
          .or('sender_id.eq.${user!.id},receiver_id.eq.${user!.id}')
          .or('sender_id.eq.${widget.receiverId},receiver_id.eq.${widget.receiverId}')
          .order('created_at', ascending: false);

      // print(response.toString());

      // print(widget.receiverEmail);

      setState(() {
        _messages = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  // 🔹 Function to send a new message
  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty && user != null) {
      String messageText = _messageController.text.trim();
      _messageController.clear();

      try {
        await _supabase.from('messages').insert({
          'message': messageText,
          'receiver_id': widget.receiverId,
          'sender_id': user!.id,
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        });

        final flaskUrl = dotenv.env['FLASK_IP'] ?? '';

        if (flaskUrl.isEmpty) {
          print("Error: FLASK_IP is not set in .env");
          return;
        }

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

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(widget.receiverEmail, overflow: TextOverflow.ellipsis,),
      actions: [
        IconButton(
            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CallScreen(userID: user!.id, userName: user!.email, callID: user?.phone, ),
                ),
              );

            },
            icon: Icon(Icons.call)
        ),
        IconButton(
            onPressed: () {

            },
            icon: Icon(Icons.videocam)
        )
      ],
    );
  }

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

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.black87,
      child: MessageBar(
        onSend: (text) async {
          if (text.trim().isEmpty) return;
          _messageController.text = text;
          await _sendMessage();
          _fetchMessages();
        },
        actions: [
          InkWell(
            child: const Icon(Icons.add, color: Colors.black, size: 24),
            onTap: () {
              getImageFromGallery();
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: InkWell(
              child: const Icon(Icons.camera_alt, color: Colors.green, size: 24),
              onTap: () {
                getImageFromCamera();
              },
            ),
          ),
        ],
      )
    );
  }
}

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

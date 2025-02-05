import 'dart:io'; // Import File
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/UiProvider.dart';

class ChatDetailScreen extends StatefulWidget {
  final String contactName;

  const ChatDetailScreen({super.key, required this.contactName});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  TextEditingController _controller = TextEditingController();
  List<String> messages = [];

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/profile.jpg'),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.contactName,
                overflow: TextOverflow.ellipsis, // Add ellipsis for long text
                maxLines: 1, // Limit to one line
                style: TextStyle(fontSize: 16), // Optional: Adjust font size
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: Icon(Icons.call), onPressed: () {}),
          IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: uiProvider.wallpaperPath != null
              ? DecorationImage(
            image: FileImage(File(uiProvider.wallpaperPath!)), // Use FileImage
            fit: BoxFit.cover,
          )
              : null, // No wallpaper if null
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return Bubble(
                    margin: BubbleEdges.only(top: 10),
                    alignment: index % 2 == 0 ? Alignment.topLeft : Alignment.topRight,
                    nip: index % 2 == 0 ? BubbleNip.leftTop : BubbleNip.rightTop,
                    color: index % 2 == 0 ? Colors.blueAccent : Colors.green,
                    child: Text(
                      messages[index],
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.camera_alt), onPressed: () {}),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ),
          IconButton(icon: Icon(Icons.mic), onPressed: () {}),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                setState(() {
                  messages.insert(0, _controller.text);
                  _controller.clear();
                });
              }
            },
          ),
        ],
      ),
    );
  }
}

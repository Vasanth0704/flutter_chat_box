import 'dart:io';
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import "package:video_player/video_player.dart";
import '../provider/UiProvider.dart';

class ChatDetailScreen extends StatefulWidget {
  final String contactName;

  const ChatDetailScreen({super.key, required this.contactName});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> messages = []; // Stores text, image & video messages

  // Function to pick media (Image or Video)
  Future<void> _pickMedia(ImageSource source, bool isVideo) async {
    final pickedFile = isVideo
        ? await _picker.pickVideo(source: source)
        : await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        if (isVideo) {
          messages.insert(0, {"text": null, "video": File(pickedFile.path)});
        } else {
          messages.insert(0, {"text": null, "image": File(pickedFile.path)});
        }
      });
    }
  }

  // Function to show media picker options (Image or Video)
  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.camera, false); // false for image
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.gallery, false); // false for image
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.orange),
              title: const Text('Record a Video'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.camera, true); // true for video
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library, color: Colors.red),
              title: const Text('Choose Video from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.gallery, true); // true for video
              },
            ),
          ],
        );
      },
    );
  }

  // Function to send text message
  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        messages.insert(0, {"text": _controller.text, "image": null, "video": null});
        _controller.clear();
      });
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

  // App Bar Widget
  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          const CircleAvatar(
            backgroundImage: AssetImage('assets/profile.jpg'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.contactName,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(fontSize: 16),
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

  // Message List Widget (Handles Text, Image, and Video Messages)
  Expanded _buildMessageList() {
    return Expanded(
      child: ListView.builder(
        reverse: true,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return ChatBubble(
            message: messages[index]["text"],
            image: messages[index]["image"],
            video: messages[index]["video"],
            isSentByMe: index % 2 != 0,
          );
        },
      ),
    );
  }

  // Input Field Widget
  Widget _buildInputField() {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: _showMediaPicker, // Updated method to pick image or video
          ),
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
            icon: const Icon(Icons.mic, color: Colors.lightGreen),
            onPressed: () {},
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

// Chat Bubble Widget (Supports Text, Image, and Video Messages)
class ChatBubble extends StatefulWidget {
  final String? message;
  final File? image;
  final File? video;
  final bool isSentByMe;

  const ChatBubble({super.key, this.message, this.image, this.video, required this.isSentByMe});

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    if (widget.video != null) {
      _videoPlayerController = VideoPlayerController.file(widget.video!)
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    if (widget.video != null) {
      _videoPlayerController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isSentByMe ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.isSentByMe ? Colors.green : Colors.blueAccent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: widget.isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (widget.message != null) ...[
              Text(
                widget.message!,
                style: const TextStyle(color: Colors.white),
              ),
            ],
            if (widget.image != null) ...[
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(widget.image!, width: 200, height: 200, fit: BoxFit.cover),
              ),
            ],
            if (widget.video != null) ...[
              const SizedBox(height: 5),
              _videoPlayerController.value.isInitialized
                  ? GestureDetector(
                onTap: () {
                  if (_videoPlayerController.value.isPlaying) {
                    _videoPlayerController.pause();
                  } else {
                    _videoPlayerController.play();
                  }
                },
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: VideoPlayer(_videoPlayerController),
                ),
              )
                  : const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}

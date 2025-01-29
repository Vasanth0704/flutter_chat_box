import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_box/screens/SettingScreen.dart';
import 'package:flutter_chat_box/utils/Constants.dart';

import 'ChatDetailScreen.dart';

import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final String title;

  const ChatScreen({super.key, required this.title});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  File? _imageFile;

  final ImagePicker _picker = ImagePicker();

  Future getImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future getImageFromCamera() async {
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
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () {
              getImageFromCamera();
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Handle search action
            },
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'New Group':
                // Navigate to New Group Screen
                  break;
                case 'New Broadcast':
                // Navigate to New Broadcast Screen
                  break;
                case 'Linked Devices':
                // Navigate to Linked Devices Screen
                  break;
                case 'Payments':
                // Navigate to Payments Screen
                  break;
                case 'Settings':
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingScreen(
                          title: 'Settings',
                        ),
                      ),
                    );
                  },
                ),
              ];
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(Constants.PLACEHOLDER_URL),
            ),
            title: Text("Contact Name"),
            subtitle: Text("Last message..."),
            trailing: Text("12.00 PM"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(contactName: 'Contact Name'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
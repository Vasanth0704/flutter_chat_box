import 'package:flutter/material.dart';
import 'package:flutter_chat_box/utils/Constants.dart';

import 'ChatDetailScreen.dart';

class ChatScreen extends StatefulWidget {
  final String title;

  const ChatScreen({super.key, required this.title});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () {

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(),
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
                  builder: (context) => ChatDetailScreen(
                    title: 'Chat Detail',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Center(
        child: Text("Settings Screen"),
      ),
    );
  }
}

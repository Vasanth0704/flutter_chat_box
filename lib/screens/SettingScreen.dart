import 'package:flutter/material.dart';
import 'package:flutter_chat_box/screens/ChatsScreen.dart';
import 'package:flutter_chat_box/screens/ProfileScreen.dart';

class SettingScreen extends StatefulWidget {
  final String title;

  const SettingScreen({super.key, required this.title});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String _userName = "Your Name";
  String _about = "Hey there! I am using WhatsApp.";
  String _profileImage = "https://via.placeholder.com/150"; // Replace with a valid profile image URL

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: [
          // User Profile Section
          ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(_profileImage),
            ),
            title: Text(
              _userName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_about),
            onTap: () async {
              // Navigate to ProfileScreen and wait for updated user data
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    name: _userName,
                    about: _about,
                    profileImage: _profileImage,
                  ),
                ),
              );

              // Update user data if the user makes changes on ProfileScreen
              if (result != null && result is Map<String, String>) {
                setState(() {
                  _userName = result['name'] ?? _userName;
                  _about = result['about'] ?? _about;
                  _profileImage = result['profileImage'] ?? _profileImage;
                });
              }
            },
          ),
          const Divider(),

          // Settings Options
          ListTile(
            leading: const Icon(Icons.key, color: Colors.teal),
            title: const Text("Account"),
            subtitle: const Text("Privacy, security, change number"),
            onTap: () {
              // Navigate to Account Settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.teal),
            title: const Text("Privacy"),
            subtitle: const Text("Control your privacy settings"),
            onTap: () {
              // Navigate to Privacy Settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat, color: Colors.teal),
            title: const Text("Chats"),
            subtitle: const Text("Theme, wallpapers, chat history"),
            onTap: () {
              Navigator.push(
                context,
              MaterialPageRoute(builder: (context) => ChatsScreen())
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.teal),
            title: const Text("Notifications"),
            subtitle: const Text("Message, group, and call tones"),
            onTap: () {
              // Navigate to Notifications Settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.data_usage, color: Colors.teal),
            title: const Text("Storage and Data"),
            subtitle: const Text("Network usage, auto-download"),
            onTap: () {
              // Navigate to Storage and Data Settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.help, color: Colors.teal),
            title: const Text("Help"),
            subtitle: const Text("Help center, contact us, privacy policy"),
            onTap: () {
              // Navigate to Help Section
            },
          ),
          ListTile(
            leading: const Icon(Icons.group, color: Colors.teal),
            title: const Text("Invite a Friend"),
            onTap: () {
              // Share Invite
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_chat_box/screens/ChatsScreen.dart';
import 'package:flutter_chat_box/screens/HomePage.dart';
import 'package:flutter_chat_box/screens/ProfileScreen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth/LoginScreen.dart';

class SettingScreen extends StatefulWidget {
  final String title;

  const SettingScreen({super.key, required this.title});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  final user = supabase.auth.currentUser;

  final storage = FlutterSecureStorage(); // Secure storage instance

  // String _userName = ;
  String _about = "Hey there! I am using WhatsApp.";
  String _profileImage = "https://via.placeholder.com/150"; // Replace with a valid profile image URL

  Future<void> signOut() async {
    await supabase.auth.signOut();
    await storage.delete(key: 'session');

    // Navigate to login screen and remove all previous routes
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        // builder: (context) => LoginScreen(title: 'Login'),
        builder: (context) => HomePage(title: 'Home'),
      ),
    );
  }

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
              backgroundImage: NetworkImage('https://gravatar.com/avatar/${user!.email}'),
            ),
            title: Text(
              user?.userMetadata?['name'] ?? "Your Name",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_about),
            onTap: () async {
              // Navigate to ProfileScreen and wait for updated user data
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    name: user?.userMetadata?['name'] ?? "Your Name",
                    about: _about,
                    profileImage: _profileImage,
                  ),
                ),
              );

              // Update user data if the user makes changes on ProfileScreen
              if (result != null && result is Map<String, String>) {
                setState(() {
                  // _userName = result['name'] ?? _userName;
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
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () {
              // Share Invite
              signOut();

              // Handle logout action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out')),
              );
            },
          ),
        ],
      ),
    );
  }
}

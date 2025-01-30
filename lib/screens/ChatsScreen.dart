import 'package:flutter/material.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  bool darkMode = false;
  String selectedWallpaper = "Default";
  bool enterIsSend = false;
  bool mediaVisibility = true;
  bool voiceMessageTranscripts = true;
  bool keepChatsArchived = true;

  void _changeTheme(bool value) {
    setState(() {
      darkMode = value;
    });
  }

  void _changeWallpaper(String wallpaper) {
    setState(() {
      selectedWallpaper = wallpaper;
    });
  }

  void _toggleEnterIsSend(bool value) {
    setState(() {
      enterIsSend = value;
    });
  }

  void _toggleMediaVisibility(bool value) {
    setState(() {
      mediaVisibility = value;
    });
  }

  void _toggleVoiceMessageTranscripts(bool value) {
    setState(() {
      voiceMessageTranscripts = value;
    });
  }

  void _toggleKeepChatsArchived(bool value) {
    setState(() {
      keepChatsArchived = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chats")),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Display", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ListTile(
            leading: Icon(Icons.brightness_6),
            title: Text("Theme"),
            subtitle: Text("System default"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.wallpaper),
            title: Text("Wallpaper"),
            onTap: () {},
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Chat settings", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          SwitchListTile(
            title: Text("Enter is send"),
            subtitle: Text("Enter key will send your message"),
            value: enterIsSend,
            onChanged: _toggleEnterIsSend,
          ),
          SwitchListTile(
            title: Text("Media visibility"),
            subtitle: Text("Show newly downloaded media in your device's gallery"),
            value: mediaVisibility,
            onChanged: _toggleMediaVisibility,
          ),
          ListTile(
            title: Text("Font size"),
            subtitle: Text("Medium"),
            onTap: () {},
          ),
          SwitchListTile(
            title: Text("Voice message transcripts"),
            subtitle: Text("Read new voice messages"),
            value: voiceMessageTranscripts,
            onChanged: _toggleVoiceMessageTranscripts,
          ),
          ListTile(
            title: Text("Transcript language"),
            subtitle: Text("English"),
            onTap: () {
              {
                showModalBottomSheet(
                  context: context,
                  builder: (context) =>
                      ListView(
                        children: [
                          ListTile(
                            title: Text("English"),
                            onTap: () => _changeTranscriptLanguage("English"),
                          ),
                          ListTile(
                            title: Text("Spanish"),
                            onTap: () => _changeTranscriptLanguage("Spanish"),
                          ),
                          ListTile(
                            title: Text("French"),
                            onTap: () => _changeTranscriptLanguage("French"),
                          ),
                        ],
                      ),
                );
              }
            },
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Archived chats", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          SwitchListTile(
            title: Text("Keep chats archived"),
            subtitle: Text("Archived chats will remain archived when you receive a new message"),
            value: keepChatsArchived,
            onChanged: _toggleKeepChatsArchived,
          ),
        ],
      ),
    );
  }
}

class _changeTranscriptLanguage {
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/UiProvider.dart';


class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  String theme = "System default";

  Future<void> _pickWallpaper() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      Provider.of<UiProvider>(context, listen: false).setWallpaper(pickedImage.path);
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempTheme = theme;
        return AlertDialog(
          title: Text("Select Theme"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text("Light"),
                value: "Light",
                groupValue: tempTheme,
                onChanged: (value) {
                  Provider.of<UiProvider>(context, listen: false).changeTheme(false);
                  setState(() {
                    theme = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: Text("Dark"),
                value: "Dark",
                groupValue: tempTheme,
                onChanged: (value) {
                  Provider.of<UiProvider>(context, listen: false).changeTheme(true);
                  setState(() {
                    theme = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: Text("System default"),
                value: "System default",
                groupValue: tempTheme,
                onChanged: (value) {
                  setState(() {
                    theme = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
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
            subtitle: Text(theme),
            onTap: _showThemeDialog,
          ),
          ListTile(
            leading: Icon(Icons.wallpaper),
            title: Text("Wallpaper"),
            onTap: _pickWallpaper,
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Chat settings", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          SwitchListTile(
            title: Text("Enter is send"),
            subtitle: Text("Enter key will send your message"),
            value: false,
            onChanged: (value) {},
          ),
          SwitchListTile(
            title: Text("Media visibility"),
            subtitle: Text("Show newly downloaded media in your device's gallery"),
            value: true,
            onChanged: (value) {},
          ),
          ListTile(
            title: Text("Font size"),
            subtitle: Text("Medium"),
            onTap: () {},
          ),
          SwitchListTile(
            title: Text("Voice message transcripts"),
            subtitle: Text("Read new voice messages"),
            value: true,
            onChanged: (value) {},
          ),
          ListTile(
            title: Text("Transcript language"),
            subtitle: Text("English"),
            onTap: () {},
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Archived chats", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          SwitchListTile(
            title: Text("Keep chats archived"),
            subtitle: Text("Archived chats will remain archived when you receive a new message"),
            value: true,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }
}

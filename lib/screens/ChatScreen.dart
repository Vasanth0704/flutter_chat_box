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
            onTap: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatDetailScreen(title: 'Chat Detail',))
              );
            },
          );
        },
      )
    );
  }
}

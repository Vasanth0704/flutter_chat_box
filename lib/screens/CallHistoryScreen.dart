import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'NewCallScreen.dart';
import 'NewChatScreen.dart';

class CallHistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> callLogs = [
    {'name': 'John Doe', 'type': 'incoming', 'time': 'Yesterday, 10:30 AM'},
    {'name': 'Alice Smith', 'type': 'missed', 'time': 'Yesterday, 8:15 PM'},
    {'name': 'David Miller', 'type': 'outgoing', 'time': 'Today, 2:00 PM'},
  ];

  IconData getCallIcon(String type) {
    switch (type) {
      case 'incoming':
        return LucideIcons.phoneIncoming;
      case 'outgoing':
        return LucideIcons.phoneOutgoing;
      case 'missed':
        return LucideIcons.phoneMissed;
      default:
        return Icons.phone;
    }
  }

  Color getCallIconColor(String type) {
    switch (type) {
      case 'incoming':
        return Colors.green;
      case 'outgoing':
        return Colors.blue;
      case 'missed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calls', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        itemCount: callLogs.length,
        itemBuilder: (context, index) {
          final call = callLogs[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              child: Icon(Icons.person, color: Colors.black),
            ),
            title: Text(call['name'], style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(call['time']),
            trailing: Icon(getCallIcon(call['type']), color: getCallIconColor(call['type'])),
            onTap: () {},
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_ic_call, color: Colors.white),
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewCallScreen(title: 'New Call'),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_chat_box/screens/ChatDetailScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewChatScreen extends StatefulWidget {
  final String title;

  const NewChatScreen({super.key, required this.title});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final supabase = Supabase.instance.client;

  // Stream to get real-time updates
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return supabase
        .from('users')
        .stream(primaryKey: ['id']) // Ensures real-time updates
        .map((data) {
      print("Real-time data update: $data"); // Debugging print statement
      return data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getUsersStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final users = snapshot.data!;
          final currentUser = supabase.auth.currentUser?.id;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              // Prevent showing the current user in the list
              if (user['id'] == currentUser) return SizedBox.shrink();

              return ListTile(
                title: Text(user['email']),
                subtitle: Text(user['phone'] ?? 'No phone number'),
                leading: CircleAvatar(
                  child: Icon(Icons.person),
                ),
                onTap: () {
                  // Navigate to ChatDetailScreen with the selected user
                  // Navigator.pushNamed(context, '/chat_detail', arguments: {
                  //   'receiverId': user['id'],
                  //   'receiverEmail': user['email'],
                  //   'receiverPhone': user['phone'],
                  // });

                  print(user['id']);
                  print(user['email']);
                  print(user['phone']);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(receiverId: user['id'], receiverEmail: user['email'], receiverPhone: user['phone'],),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

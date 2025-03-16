import 'package:flutter/material.dart';
import 'package:flutter_chat_box/screens/CallScreen.dart';
import 'package:flutter_chat_box/screens/RecentChatScreen.dart';
import 'package:flutter_chat_box/screens/StatusScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final SupabaseClient _supabase = Supabase.instance.client;

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = _supabase.auth.currentUser;
    final String userName = user?.userMetadata?['name'] ?? 'User';

    final List<Widget> _screens = [
      RecentChatScreen(title: 'Chat $userName'),
      StatusScreen(title: 'Status'),
      CallScreen(title: 'Call'),
    ];

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle),
            label: 'Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: 'Call',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter_chat_box/screens/CallScreen.dart';
import 'package:flutter_chat_box/screens/ChatScreen.dart';
import 'package:flutter_chat_box/screens/StatusScreen.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _currentIndex = 0;

  final List<Widget> _screens =[
    ChatScreen(title: 'Chat',),
    StatusScreen(title: 'Status',),
    CallScreen(title: 'Call',)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,

          onTap: (index){
            setState(() {
              _currentIndex = index;
            });
          },

          items: [
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
          ]
      ),
    );
  }
}

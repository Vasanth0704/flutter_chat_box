import 'package:flutter/material.dart';

class CallScreen extends StatefulWidget {
  
  final String title;
  
  const CallScreen({super.key, required this.title});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text(widget.title),
      ),
    );
  }
}

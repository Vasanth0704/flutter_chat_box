import 'package:flutter/material.dart';

class StatusScreen extends StatefulWidget {

  final String title;

  const StatusScreen({super.key, required this.title});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: false, // Removes back arrow
      ),
      body: Center(
        child: Text(widget.title),
      ),
    );
  }
}

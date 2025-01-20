import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Bubble(
              margin: const BubbleEdges.only(top: 10),
              alignment: Alignment.topLeft,
              nip: BubbleNip.leftTop,
              color: Colors.blueAccent,
              child: Text(
                'Hello, this is a message inside a bubble!',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            Bubble(
              margin: const BubbleEdges.only(top: 10),
              alignment: Alignment.topRight,
              nip: BubbleNip.rightTop,
              color: Colors.green,
              child: Text(
                'This is another bubble message!',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

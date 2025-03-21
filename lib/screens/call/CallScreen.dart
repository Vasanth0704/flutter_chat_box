import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallScreen extends StatelessWidget {
  final String? userID;
  final String? userName;
  final String? callID;

  const CallScreen({
    Key? key,
    this.userID,
    this.userName,
    required this.callID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final userId = Random().nextInt(9999);

    return Scaffold(
      body: ZegoUIKitPrebuiltCall(
        appID: int.parse(dotenv.env['ZEGOCLOUD_APP_ID'] ?? '0'), // Convert to int
        appSign: dotenv.env['ZEGOCLOUD_APP_SIGN'] ?? '', // Fetch App Sign
        userID: userId.toString(),
        userName: "User name $userId",
        callID: callID!,
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
      ),
    );
  }
}

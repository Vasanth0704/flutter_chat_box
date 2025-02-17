import 'package:flutter/material.dart';
// import 'package:jitsi_meet/jitsi_meet.dart';

class VideoCallButton extends StatefulWidget {
  @override
  _VideoCallButtonState createState() => _VideoCallButtonState();
}

class _VideoCallButtonState extends State<VideoCallButton> {
  void _joinVideoCall() async {
    try {
      // var options = JitsiMeetingOptions(room: "test_room") // Unique room ID
      //   ..userDisplayName = "User Name"
      //   ..userEmail = "user@example.com"
      //   ..userAvatarURL = "https://example.com/avatar.png" // Optional
      //   ..audioOnly = false
      //   ..videoMuted = false
      //   ..audioMuted = false;
      //
      // await JitsiMeet.joinMeeting(options);
    } catch (error) {
      print("Error joining video call: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.videocam),
      onPressed: _joinVideoCall,
    );
  }
}

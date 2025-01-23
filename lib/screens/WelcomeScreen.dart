import 'package:flutter/material.dart';
import 'package:flutter_chat_box/screens/HomeScreen.dart';
import 'package:flutter_chat_box/utils/ColorConstants.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.BLACK,
      body: Column(
        children: [
          Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 5),
                  child: Image.asset(
                    'assets/images/circle.png',
                    color: ColorConstants.GREEN,
                  ),
                ),
              )
          ),
          SizedBox(height: 60,),
          Expanded(
              child: Column(
                children: [
                  Text(
                    'Welcome To My World',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: RichText(
                        textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Read our ',
                        style: TextStyle(color: ColorConstants.GRAY, height: 1.5),
                        children: [
                          TextSpan(text: 'Privacy Policy ',style: TextStyle(color: ColorConstants.SKY_BLUE)),
                          TextSpan(text: 'Tap "Agree and continue" to accept the '),
                          TextSpan(text: 'Terms of Services ',style: TextStyle(color: ColorConstants.SKY_BLUE)),
                        ]

                      ),
                    ),
                  )
                ],
              )
          ),
          SizedBox(
            height: 42,
            width: MediaQuery.of(context).size.width - 100,
            child: ElevatedButton(
                onPressed: (){

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(title: 'Home'),
                    ),
                  );

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.GREEN,
                  foregroundColor: ColorConstants.CHARCAOL_BLACK,
                  splashFactory: NoSplash.splashFactory,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius:BorderRadius.zero,
                  ),
                ),
                child: Text("AGREE AND CONTINUE")
            ),
          ),
          SizedBox(height: 50,),
          Material(
            color: ColorConstants.DEEP_BLUE_GRAY,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () {

              },
              borderRadius: BorderRadius.circular(20),
              splashFactory: NoSplash.splashFactory,
              highlightColor: ColorConstants.DARK_CYAN_BLACK,
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.language,
                      color: ColorConstants.GREEN,
                    ),
                    SizedBox(width: 10,),
                    Text(
                      'English',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 10,),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: ColorConstants.GREEN,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      )
    );
  }
}

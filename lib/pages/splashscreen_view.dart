import 'package:flutter/material.dart';
import 'dart:async';
import 'welcome_view.dart'; 

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({Key? key}) : super(key: key);

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeView()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD0EDF5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/tagit_logo.png', width: 150, height: 150),
            const SizedBox(height: 50),
            const Column(
              children: [
                Text('Loading...',
                    style: TextStyle(fontSize: 18, color: Colors.black87)),
                SizedBox(height: 10),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

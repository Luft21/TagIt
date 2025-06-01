import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tag_it/providers/auth_provider.dart';
import 'package:tag_it/screens/home_screen.dart';
import 'package:tag_it/screens/welcome_screen.dart';
import 'package:tag_it/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.user != null) {
      if (authProvider.isNewUser) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFD0EDF5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/images/tagit_logo.png'),
              width: 150,
              height: 150,
            ),
            SizedBox(height: 50),
            Column(
              children: [
                Text(
                  'Loading...',
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
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

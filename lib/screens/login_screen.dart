import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tag_it/services/auth_service.dart';
import 'package:tag_it/screens/welcome_screen.dart';
import 'package:tag_it/screens/navigation_screen.dart';

const Color primaryColor = Color(0xFF4A90E2);
const Color backgroundColor = Color(0xFFFFFFFF);
const Color textColor = Color(0xFF2D3748);
const Color secondaryTextColor = Color(0xFF718096);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  final AuthService _authService = AuthService();

  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null && mounted) {
        final isNew = await _authService.isNewUser(user);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) =>
                    isNew ? const WelcomeScreen() : const NavigationScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal melakukan login. Silakan coba lagi.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/tagit_logo.png', height: 60),
              const SizedBox(height: 32),
              Text(
                'Selamat Datang\ndi TagIt',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Aplikasi pengingat lokasi cerdas Anda.',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  color: secondaryTextColor,
                ),
              ),

              Expanded(
                child: Center(
                  child: Icon(
                    Icons.explore_outlined,
                    size: MediaQuery.of(context).size.width * 0.6,
                    color: Colors.grey.withOpacity(0.1),
                  ),
                ),
              ),

              if (_errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        color: Colors.redAccent,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/google-logo.png',
                                height: 24.0,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Masuk dengan Google',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Dengan masuk, Anda menyetujui Syarat & Ketentuan kami.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tag_it/services/auth_service.dart';
import 'navigation_screen.dart';
import 'package:animate_do/animate_do.dart';

const Color primaryColor = Color(0xFF4A90E2);
const Color backgroundColor = Color(0xFFF4F6F8);
const Color textColor = Color(0xFF2D3748);
const Color secondaryTextColor = Color(0xFF718096);

class OnboardingPageContent {
  final String imagePath;
  final String title;
  final String description;

  OnboardingPageContent({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageContent> onboardingPages = [
    OnboardingPageContent(
      imagePath: 'assets/images/board2.png',
      title: 'Jelajahi Dunia di Sekitarmu',
      description:
          'Temukan berbagai lokasi menarik seperti halte, restoran, atau tempat hiburan di dekatmu.',
    ),
    OnboardingPageContent(
      imagePath: 'assets/images/board1.png',
      title: 'Tandai Lokasi Favoritmu',
      description:
          'Tambahkan penanda pada lokasi yang ingin kamu selalu ingat atau kunjungi kembali.',
    ),
    OnboardingPageContent(
      imagePath: 'assets/images/board3.png',
      title: 'Notifikasi Pintar',
      description:
          'Kami akan memberimu notifikasi otomatis saat mendekati lokasi yang kamu tandai.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _navigateToHomeOrBack() async {
    final user = AuthService().currentUser;

    if (user != null) {
      await AuthService().markOnboardingComplete(user);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavigationScreen()),
        );
      }
    } else {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingPages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final page = onboardingPages[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      child: Image.asset(page.imagePath, height: 280),
                    ),
                    const SizedBox(height: 48),
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 100),
                      child: Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        page.description,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: secondaryTextColor,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(onboardingPages.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color:
                            _currentPage == index
                                ? primaryColor
                                : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 50,
                  child: Stack(
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity:
                            _currentPage == onboardingPages.length - 1
                                ? 1.0
                                : 0.0,
                        child: Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: _navigateToHomeOrBack,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: Text(
                              'Mulai Aplikasi',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity:
                            _currentPage != onboardingPages.length - 1
                                ? 1.0
                                : 0.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: _navigateToHomeOrBack,
                              child: Text(
                                'Lewati',
                                style: GoogleFonts.poppins(
                                  color: secondaryTextColor,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                'Lanjut',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (canPop)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.05),
                child: IconButton(
                  icon: const Icon(Icons.close, color: secondaryTextColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

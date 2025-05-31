import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

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
      title: 'Tag Lokasi Favoritmu',
      description:
          'Tambahkan tag pada lokasi yang ingin kamu kunjungi, seperti halte, restoran, atau tempat hiburan.',
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

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _onLoginPressed() {
    _navigateToLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFD0EDF5,
      ),
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
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      page.imagePath,
                      width: 250,
                      height: 250,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      page.title,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      page.description,
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
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
                // Indikator Halaman
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(onboardingPages.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            _currentPage == index
                                ? const Color(0xFF87AFFF)
                                : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                // Button navigasi
                _currentPage < onboardingPages.length - 1
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _navigateToLogin,
                          child: Text(
                            'Lewati',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeIn,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF87AFFF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 12,
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'Lanjut',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                    :
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed:
                              _onLoginPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF87AFFF,
                            ),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: const Size(
                              double.infinity,
                              50,
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'Log In',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

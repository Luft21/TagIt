import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tag_it/services/auth_service.dart';
import 'package:tag_it/screens/login_screen.dart';
import 'package:tag_it/screens/welcome_screen.dart';

const Color primaryColor = Color(0xFF4A90E2);
const Color backgroundColor = Color(0xFFF4F6F8);
const Color textColor = Color(0xFF2D3748);
const Color secondaryTextColor = Color(0xFF718096);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi,';
    }
    if (hour < 15) {
      return 'Selamat Siang,';
    }
    if (hour < 18) {
      return 'Selamat Sore,';
    }
    return 'Selamat Malam,';
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: primaryColor.withOpacity(0.1),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  currentUser?.photoURL != null
                      ? NetworkImage(currentUser!.photoURL!)
                      : null,
              child:
                  currentUser?.photoURL == null
                      ? Text(
                        currentUser?.displayName
                                ?.substring(0, 1)
                                .toUpperCase() ??
                            'T',
                        style: GoogleFonts.poppins(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      )
                      : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getGreeting(),
            style: GoogleFonts.lato(fontSize: 16, color: secondaryTextColor),
          ),
          const SizedBox(height: 4),
          Text(
            currentUser?.displayName ?? 'Pengguna TagIt',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String label,
    required int? count,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.8),
              foregroundColor: Colors.white,
              radius: 20,
              child: Icon(icon, size: 22),
            ),
            const SizedBox(height: 12),
            count == null
                ? const SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: secondaryTextColor,
                  ),
                )
                : Text(
                  count.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.lato(fontSize: 14, color: secondaryTextColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required String title,
    required IconData icon,
    VoidCallback? onTap,
    Color color = textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: secondaryTextColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    final authService = AuthService();
    void handleLogout() async {
      bool? confirmLogout = await showDialog<bool>(
        context: context,
        builder:
            (BuildContext dialogContext) => AlertDialog(
              title: Text(
                'Konfirmasi Logout',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              content: Text(
                'Apakah Anda yakin ingin keluar?',
                style: GoogleFonts.lato(),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: secondaryTextColor,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(
                    'Logout',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            ),
      );

      if (confirmLogout == true && context.mounted) {
        await authService.signOut();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildProfileHeader(),
          _buildSectionTitle('Statistik'),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('reminders')
                    .where('userId', isEqualTo: currentUser!.uid)
                    .snapshots(),
            builder: (context, snapshot) {
              int? activeCount;
              int? inactiveCount;

              if (snapshot.hasData) {
                final docs = snapshot.data!.docs;
                activeCount =
                    docs.where((doc) => doc.get('isActive') == true).length;
                inactiveCount =
                    docs.where((doc) => doc.get('isActive') == false).length;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _buildStatCard(
                      icon: Icons.notifications_active,
                      color: primaryColor,
                      label: 'Aktif',
                      count: activeCount,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      icon: Icons.notifications_off,
                      color: secondaryTextColor,
                      label: 'Nonaktif',
                      count: inactiveCount,
                    ),
                  ],
                ),
              );
            },
          ),
          _buildSectionTitle('Bantuan'),
          _buildMenuOption(
            icon: Icons.help_outline_rounded,
            title: 'Guide Aplikasi',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
              );
            },
          ),
          const Divider(height: 32, thickness: 1, indent: 24, endIndent: 24),
          _buildMenuOption(
            icon: Icons.logout,
            title: 'Logout',
            color: Colors.redAccent,
            onTap: handleLogout,
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'TagIt v1.0.0',
              style: GoogleFonts.lato(color: Colors.grey[400], fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

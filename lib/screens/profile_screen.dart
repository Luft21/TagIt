import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tag_it/services/auth_service.dart';
import 'package:tag_it/screens/login_screen.dart';

const Color primaryColor = Color(0xFF4A90E2);
const Color backgroundColor = Color(0xFFF4F6F8);
const Color cardColor = Colors.white;
const Color textColor = Color(0xFF2D3748);
const Color secondaryTextColor = Color(0xFF718096);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _buildProfileHeader(User currentUser) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  currentUser.photoURL != null
                      ? NetworkImage(currentUser.photoURL!)
                      : null,
              child:
                  currentUser.photoURL == null
                      ? Text(
                        currentUser.displayName
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
            currentUser.displayName ?? 'Pengguna TagIt',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentUser.email ?? 'Email tidak tersedia',
            style: GoogleFonts.lato(fontSize: 16, color: secondaryTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption({
    required BuildContext context,
    required IconData icon,
    required String title,
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
    final currentUser = FirebaseAuth.instance.currentUser;

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
          _buildProfileHeader(currentUser),

          _buildSectionTitle('Aktivitas'),
          _buildMenuOption(
            context: context,
            icon: Icons.history_outlined,
            title: 'Riwayat Pengingat',
            onTap: () {},
          ),

          _buildSectionTitle('Pengaturan'),
          _buildMenuOption(
            context: context,
            icon: Icons.person_outline,
            title: 'Edit Profil',
            onTap: () {},
          ),
          _buildMenuOption(
            context: context,
            icon: Icons.notifications_outlined,
            title: 'Notifikasi',
            onTap: () {},
          ),
          _buildMenuOption(
            context: context,
            icon: Icons.privacy_tip_outlined,
            title: 'Kebijakan Privasi',
            onTap: () {},
          ),

          const Divider(height: 32, thickness: 1, indent: 24, endIndent: 24),

          _buildMenuOption(
            context: context,
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

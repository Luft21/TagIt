import 'package:flutter/material.dart';

class NavbarView extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const NavbarView({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      selectedItemColor: Color(0xFF7EA5FF), // Warna saat aktif
      unselectedItemColor: Color(0xFF717777), // Warna default
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
        BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: 'Kontribusi'),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'Disimpan'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}

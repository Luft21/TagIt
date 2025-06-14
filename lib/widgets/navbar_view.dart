import 'dart:ui';
import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF4A90E2);
const Color inactiveColor = Color(0xFF718096);
const Color navBackgroundColor = Colors.white;

class NavbarView extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const NavbarView({Key? key, required this.selectedIndex, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: navBackgroundColor.withOpacity(0.85),
              borderRadius: BorderRadius.circular(30),
            ),
            child: SizedBox(
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.map_outlined, 'Map', 0),
                  _buildNavItem(Icons.format_list_bulleted_rounded, 'List', 1),
                  _buildNavItem(Icons.person_outline, 'Profile', 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
          decoration: BoxDecoration(
            color:
                isActive ? primaryColor.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 26,
                color: isActive ? primaryColor : inactiveColor,
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? primaryColor : inactiveColor,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

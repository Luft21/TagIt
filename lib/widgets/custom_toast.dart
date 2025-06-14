import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showSuccessToast(BuildContext context, String message) {
  _showCustomToast(
    context,
    message,
    const Color(0xFF4CAF50),
    Icons.check_circle,
  );
}

void showErrorToast(BuildContext context, String message) {
  _showCustomToast(context, message, const Color(0xFFD32F2F), Icons.error);
}

void _showCustomToast(
  BuildContext context,
  String message,
  Color color,
  IconData icon,
) {
  final overlayEntry = OverlayEntry(
    builder:
        (context) => Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: CustomToastWidget(message: message, color: color, icon: icon),
        ),
  );

  Overlay.of(context).insert(overlayEntry);

  Future.delayed(const Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}

class CustomToastWidget extends StatefulWidget {
  final String message;
  final Color color;
  final IconData icon;

  const CustomToastWidget({
    super.key,
    required this.message,
    required this.color,
    required this.icon,
  });

  @override
  State<CustomToastWidget> createState() => _CustomToastWidgetState();
}

class _CustomToastWidgetState extends State<CustomToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -2.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.message,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
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

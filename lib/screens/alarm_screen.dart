import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tag_it/services/alarm_service.dart';
import 'package:animate_do/animate_do.dart';
import 'package:slide_to_act/slide_to_act.dart';

const Color primaryColor = Color(0xFF4A90E2);

class AlarmScreen extends StatelessWidget {
  final String reminderId;
  final String reminderName;

  const AlarmScreen({
    Key? key,
    required this.reminderId,
    required this.reminderName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox.shrink(),
              Column(
                children: [
                  Pulse(
                    infinite: true,
                    duration: const Duration(seconds: 2),
                    child: const Icon(
                      Icons.location_on,
                      size: 120,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'PENGINGAT LOKASI',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reminderName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SlideAction(
                  borderRadius: 16,
                  elevation: 4,
                  innerColor: primaryColor,
                  outerColor: Colors.white,
                  sliderButtonIcon: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                  ),
                  text: 'Geser untuk Matikan',
                  textStyle: GoogleFonts.poppins(
                    color: primaryColor.withOpacity(0.8),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  onSubmit: () {
                    AlarmService().stopAlarm(reminderId: reminderId);
                    Navigator.of(context).pop();
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

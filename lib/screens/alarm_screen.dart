import 'package:flutter/material.dart';
import 'package:tag_it/services/alarm_service.dart';

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
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.alarm, size: 120, color: Colors.white),
            const SizedBox(height: 32),
            const Text(
              'ALARM LOKASI',
              style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                reminderName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              onPressed: () {
                // Stop the alarm and pop the screen
                AlarmService().stopAlarm(reminderId: reminderId);
                Navigator.of(context).pop();
              },
              child: const Text(
                'MATIKAN',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
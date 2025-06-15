import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tag_it/models/reminder_model.dart';
import 'package:tag_it/services/alarm_service.dart';
import 'screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterForegroundTask.initCommunicationPort();
  runApp(
    const MyApp(),
  );
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      print('[FGTask] Firebase already initialized or error: $e');
    }
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      final snapshot = await FirebaseFirestore.instance
          .collection('reminders')
          .where('userId', isEqualTo: user.uid)
          .where('isActive', isEqualTo: true)
          .get();


      for (var doc in snapshot.docs) {
        final docData = doc.data(); 
        final reminder = ReminderModel.fromMap(docData); 


        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          reminder.latitude,
          reminder.longitude,
        );

        final isAlarmActive = docData['alarmActive'] ?? false;
        
        if (distance <= reminder.triggerRadius && !isAlarmActive) {
          final alarmData = {'id': doc.id, 'name': reminder.name};
          FlutterForegroundTask.sendDataToMain(jsonEncode(alarmData));
          await AlarmService().playAlarm(
            name: reminder.name,
            ringtone: reminder.ringtone,
            vibrate: reminder.vibrate,
            ttsEnabled: reminder.ttsEnabled,
            duration: const Duration(minutes: 1),
          );

          await FlutterForegroundTask.updateService(
            notificationTitle: 'ALARM AKTIF: ${reminder.name}',
            notificationText: 'Sentuh untuk mematikan alarm.',
          );

          await doc.reference.update({'alarmActive': true});
        }
      }
    } catch (e, stack) {
      print(stack);
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    print('onDestroy(isTimeout: $isTimeout)');
  }

  @override
  void onReceiveData(Object data) {
    print('onReceiveData: $data');
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    print('onNotificationButtonPressed: $id');
  }

  // Called when the notification itself is pressed.
  @override
  void onNotificationPressed() {
    print('onNotificationPressed');
  }

  // Called when the notification itself is dismissed.
  @override
  void onNotificationDismissed() {
    print('onNotificationDismissed');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TagIt App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
    );
  }
}

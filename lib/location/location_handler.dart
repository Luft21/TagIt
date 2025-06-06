import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/location_provider.dart';
import '../utils/distance_util.dart';
import '../services/alert_service.dart';
import '../models/reminder_model.dart';

class LocationHandler {
  static void startMonitoring({
    required WidgetRef ref,
    required ReminderModel targetLocation,
  }) {
    Geolocator.getPositionStream().listen((Position position) {
      ref.read(positionProvider.notifier).state = position;

      double distance = DistanceUtil.calculateDistance(
        position.latitude,
        position.longitude,
        targetLocation.latitude,
        targetLocation.longitude,
      );

      if (distance <= targetLocation.triggerRadius) {
        AlertService.triggerAlert();
      }
    });
  }
}

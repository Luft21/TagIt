class ReminderModel {
  final String userId;
  final String name;
  final double latitude;
  final double longitude;
  final double triggerRadius;
  final bool isActive;

  ReminderModel({
    required this.userId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.triggerRadius,
    required this.isActive,
  });
}
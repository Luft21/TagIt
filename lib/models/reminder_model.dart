class ReminderModel {
  final String userId;
  final String name;
  final double latitude;
  final double longitude;
  final double triggerRadius;
  final bool isActive;
  final String ringtone;
  final bool vibrate;
  final bool ttsEnabled;

  ReminderModel({
    required this.userId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.triggerRadius,
    required this.isActive,
    required this.ringtone,
    required this.vibrate,
    required this.ttsEnabled,
  });

  ReminderModel.fromMap(Map<String, dynamic> map)
      : userId = map['userId'] ?? '',
        name = map['name'] ?? '',
        latitude = (map['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude = (map['longitude'] as num?)?.toDouble() ?? 0.0,
        triggerRadius = (map['triggerRadius'] as num?)?.toDouble() ?? 100.0,
        isActive = map['isActive'] ?? true,
        ringtone = map['ringtone'] ?? 'Nada Dering Alarm Default', // Default value
        vibrate = map['vibrate'] ?? true,
        ttsEnabled = map['ttsEnabled'] ?? false;
}
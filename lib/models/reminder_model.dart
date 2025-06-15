class ReminderModel {
  final String userId;
  final String name;
  final bool alarmActive;
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
    required this.alarmActive,
    required this.latitude,
    required this.longitude,
    required this.triggerRadius,
    required this.isActive,
    required this.ringtone,
    required this.vibrate,
    required this.ttsEnabled,
  });

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      alarmActive: map['alarmActive'] ?? false,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      triggerRadius: (map['triggerRadius'] as num?)?.toDouble() ?? 100.0,
      isActive: map['isActive'] ?? true,
      ringtone: map['ringtone'] ?? 'Default Alarm Ringtone',
      vibrate: map['vibrate'] ?? true,
      ttsEnabled: map['ttsEnabled'] ?? false,
    );
  }
}
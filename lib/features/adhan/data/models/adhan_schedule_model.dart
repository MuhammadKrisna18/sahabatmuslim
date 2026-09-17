import 'package:adhan_reminder/features/adhan/domain/entities/adhan_schedule.dart';

class AdhanScheduleModel extends AdhanSchedule {
  AdhanScheduleModel({
    required super.id,
    required super.hour,
    required super.minute,
    required super.soundName,
    required super.soundUrl,
    super.isLocal = false,
    super.isActive = true,
    super.volume = 1.0,
  });

  factory AdhanScheduleModel.fromJson(Map<String, dynamic> json) {
    return AdhanScheduleModel(
      id: json['id'],
      hour: json['time_hour'],
      minute: json['time_minute'],
      soundName: json['soundName'],
      soundUrl: json['soundUrl'],
      isLocal: json['isLocal'] ?? false,
      isActive: json['isActive'] ?? true,
      volume: json['volume']?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time_hour': hour,
      'time_minute': minute,
      'soundName': soundName,
      'soundUrl': soundUrl,
      'isLocal': isLocal,
      'isActive': isActive,
      'volume': volume,
    };
  }

  AdhanSchedule toEntity() {
    return AdhanSchedule(
      id: id,
      hour: hour,
      minute: minute,
      soundName: soundName,
      soundUrl: soundUrl,
      isLocal: isLocal,
      isActive: isActive,
      volume: volume,
    );
  }

  factory AdhanScheduleModel.fromEntity(AdhanSchedule entity) {
    return AdhanScheduleModel(
      id: entity.id,
      hour: entity.hour,
      minute: entity.minute,
      soundName: entity.soundName,
      soundUrl: entity.soundUrl,
      isLocal: entity.isLocal,
      isActive: entity.isActive,
      volume: entity.volume,
    );
  }
}

class AdhanSchedule {
  final String id;
  final int hour;
  final int minute;
  final String soundName;
  final String soundUrl;
  final bool isLocal;
  final bool isActive;
  final double volume;

  AdhanSchedule({
    required this.id,
    required this.hour,
    required this.minute,
    required this.soundName,
    required this.soundUrl,
    this.isLocal = false,
    this.isActive = true,
    this.volume = 1.0,
  });

  AdhanSchedule copyWith({
    String? id,
    int? hour,
    int? minute,
    String? soundName,
    String? soundUrl,
    bool? isLocal,
    bool? isActive,
    double? volume,
  }) {
    return AdhanSchedule(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      soundName: soundName ?? this.soundName,
      soundUrl: soundUrl ?? this.soundUrl,
      isLocal: isLocal ?? this.isLocal,
      isActive: isActive ?? this.isActive,
      volume: volume ?? this.volume,
    );
  }

  String get formattedTime =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

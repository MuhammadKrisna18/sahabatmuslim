import 'package:flutter_test/flutter_test.dart';
import 'package:adhan_reminder/features/adhan/data/models/adhan_schedule_model.dart';

void main() {
  group('AdhanSchedule Model Test', () {
    test('fromJson and toJson should work correctly', () {
      final jsonMap = {
        'id': 'Subuh',
        'time_hour': 4,
        'time_minute': 30,
        'soundName': 'Makkah',
        'soundUrl': 'assets/adzan_default.mp3',
        'isActive': true,
      };

      final schedule = AdhanScheduleModel.fromJson(jsonMap);

      expect(schedule.id, 'Subuh');
      expect(schedule.hour, 4);
      expect(schedule.minute, 30);
      expect(schedule.soundName, 'Makkah');
      expect(schedule.soundUrl, 'assets/adzan_default.mp3');
      expect(schedule.isActive, true);

      final outJson = schedule.toJson();
      expect(outJson['id'], 'Subuh');
      expect(outJson['time_hour'], 4);
      expect(outJson['time_minute'], 30);
      expect(outJson['soundName'], 'Makkah');
      expect(outJson['soundUrl'], 'assets/adzan_default.mp3');
      expect(outJson['isActive'], true);
    });
  });
}

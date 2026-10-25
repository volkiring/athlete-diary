/// Вид тренировки.
enum WorkoutType {
  running('Бег', '🏃'),
  cycling('Велосипед', '🚴'),
  swimming('Плавание', '🏊'),
  gym('Тренажёрный зал', '🏋️'),
  other('Другое', '⭐');

  const WorkoutType(this.title, this.emoji);

  final String title;
  final String emoji;
}

/// Одна запись в дневнике тренировок.
class Workout {
  Workout({
    required this.id,
    required this.type,
    required this.date,
    required this.durationMinutes,
    this.distanceKm,
    this.note = '',
  });

  final String id;
  final WorkoutType type;
  final DateTime date;
  final int durationMinutes;
  final double? distanceKm;
  final String note;

  /// Средний темп в минутах на километр (если указана дистанция).
  double? get paceMinPerKm {
    final distance = distanceKm;
    if (distance == null || distance <= 0) return null;
    return durationMinutes / distance;
  }
}

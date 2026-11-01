import 'package:flutter/foundation.dart';

import '../models/workout.dart';

/// Хранилище тренировок в памяти.
/// Сохранение на устройство — следующий шаг (см. README).
class WorkoutStore extends ChangeNotifier {
  final List<Workout> _workouts = [];

  /// Сколько тренировок спортсмен хочет делать за неделю.
  int _weeklyGoal = 3;

  /// Тренировки, отсортированные от новых к старым.
  List<Workout> get workouts {
    final sorted = [..._workouts]..sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(sorted);
  }

  void add(Workout workout) {
    _workouts.add(workout);
    notifyListeners();
  }

  void remove(String id) {
    _workouts.removeWhere((w) => w.id == id);
    notifyListeners();
  }

  int get totalCount => _workouts.length;

  int get totalMinutes =>
      _workouts.fold(0, (sum, w) => sum + w.durationMinutes);

  double get totalDistanceKm =>
      _workouts.fold(0.0, (sum, w) => sum + (w.distanceKm ?? 0));

  /// Количество тренировок за последние 7 дней (включая сегодня).
  int countLastDays(int days, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final from = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: days - 1));
    return _workouts.where((w) => !w.date.isBefore(from)).length;
  }

  int get weeklyGoal => _weeklyGoal;

  void setWeeklyGoal(int goal) {
    _weeklyGoal = goal;
    notifyListeners();
  }

  /// Доля выполнения недельной цели от 0 до 1.
  double goalProgress({DateTime? now}) =>
      (countLastDays(7, now: now) / _weeklyGoal).clamp(0.0, 1.0);
}

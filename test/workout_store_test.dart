import 'package:athlete_diary/data/workout_store.dart';
import 'package:athlete_diary/models/workout.dart';
import 'package:flutter_test/flutter_test.dart';

Workout _workout(String id, DateTime date, {int minutes = 30, double? km}) =>
    Workout(
      id: id,
      type: WorkoutType.running,
      date: date,
      durationMinutes: minutes,
      distanceKm: km,
    );

void main() {
  test('считает общую статистику', () {
    final store = WorkoutStore()
      ..add(_workout('1', DateTime(2026, 10, 1), minutes: 30, km: 5))
      ..add(_workout('2', DateTime(2026, 10, 2), minutes: 60));

    expect(store.totalCount, 2);
    expect(store.totalMinutes, 90);
    expect(store.totalDistanceKm, 5);
  });

  test('сортирует от новых к старым и удаляет', () {
    final store = WorkoutStore()
      ..add(_workout('old', DateTime(2026, 1, 1)))
      ..add(_workout('new', DateTime(2026, 2, 1)));

    expect(store.workouts.first.id, 'new');
    store.remove('new');
    expect(store.workouts.map((w) => w.id), ['old']);
  });

  test('считает тренировки за последние 7 дней', () {
    final now = DateTime(2026, 10, 25, 18);
    final store = WorkoutStore()
      ..add(_workout('a', DateTime(2026, 10, 25)))
      ..add(_workout('b', DateTime(2026, 10, 19)))
      ..add(_workout('c', DateTime(2026, 10, 18)));

    expect(store.countLastDays(7, now: now), 2);
  });

  test('прогресс недельной цели не больше 100%', () {
    final now = DateTime(2026, 10, 25, 18);
    final store = WorkoutStore()
      ..add(_workout('a', DateTime(2026, 10, 24)))
      ..add(_workout('b', DateTime(2026, 10, 25)));

    expect(store.weeklyGoal, 3);
    expect(store.goalProgress(now: now), closeTo(2 / 3, 0.001));
    store.setWeeklyGoal(1);
    expect(store.goalProgress(now: now), 1.0);
  });

  test('темп считается только при наличии дистанции', () {
    expect(_workout('1', DateTime(2026), minutes: 50, km: 10).paceMinPerKm, 5);
    expect(_workout('2', DateTime(2026)).paceMinPerKm, isNull);
  });
}

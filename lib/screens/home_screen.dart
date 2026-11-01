import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/workout_store.dart';
import '../models/workout.dart';
import 'add_workout_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.store});

  final WorkoutStore store;

  Future<void> _openAddScreen(BuildContext context) async {
    final workout = await Navigator.of(context).push<Workout>(
      MaterialPageRoute(builder: (_) => const AddWorkoutScreen()),
    );
    if (workout != null) store.add(workout);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Дневник спортсмена')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddScreen(context),
        icon: const Icon(Icons.add),
        label: const Text('Тренировка'),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final workouts = store.workouts;
          return Column(
            children: [
              _StatsCard(store: store),
              _GoalCard(store: store),
              Expanded(
                child: workouts.isEmpty
                    ? const Center(
                        child: Text('Пока нет тренировок.\nДобавьте первую!',
                            textAlign: TextAlign.center),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: workouts.length,
                        itemBuilder: (context, i) => _WorkoutTile(
                          workout: workouts[i],
                          onDelete: () => store.remove(workouts[i].id),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.store});

  final WorkoutStore store;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Stat(label: 'Тренировок', value: '${store.totalCount}'),
            _Stat(label: 'За 7 дней', value: '${store.countLastDays(7)}'),
            _Stat(label: 'Минут', value: '${store.totalMinutes}'),
            _Stat(
                label: 'Км',
                value: store.totalDistanceKm.toStringAsFixed(1)),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.store});

  final WorkoutStore store;

  Future<void> _editGoal(BuildContext context) async {
    final goal = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Тренировок в неделю'),
        children: [
          for (var i = 1; i <= 7; i++)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, i),
              child: Text('$i', style: const TextStyle(fontSize: 18)),
            ),
        ],
      ),
    );
    if (goal != null) store.setWeeklyGoal(goal);
  }

  @override
  Widget build(BuildContext context) {
    final done = store.countLastDays(7);
    final reached = done >= store.weeklyGoal;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: ListTile(
        onTap: () => _editGoal(context),
        leading: Icon(reached ? Icons.emoji_events : Icons.flag_outlined,
            color: reached ? Colors.amber : null),
        title: Text(reached
            ? 'Цель на неделю выполнена!'
            : 'Цель на неделю: $done из ${store.weeklyGoal}'),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: LinearProgressIndicator(value: store.goalProgress()),
        ),
        trailing: const Icon(Icons.edit_outlined),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.headlineSmall),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _WorkoutTile extends StatelessWidget {
  const _WorkoutTile({required this.workout, required this.onDelete});

  final Workout workout;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('d MMMM, EEE', 'ru').format(workout.date);
    final details = <String>[
      '${workout.durationMinutes} мин',
      if (workout.distanceKm != null)
        '${workout.distanceKm!.toStringAsFixed(1)} км',
      if (workout.paceMinPerKm != null)
        '${workout.paceMinPerKm!.toStringAsFixed(1)} мин/км',
    ].join(' · ');

    return Dismissible(
      key: ValueKey(workout.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        leading: Text(workout.type.emoji, style: const TextStyle(fontSize: 28)),
        title: Text(workout.type.title),
        subtitle: Text(
          workout.note.isEmpty ? '$date\n$details' : '$date\n$details\n${workout.note}',
        ),
        isThreeLine: true,
      ),
    );
  }
}

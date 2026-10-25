import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/workout.dart';

/// Экран добавления тренировки. Возвращает [Workout] через Navigator.pop.
class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();
  final _distanceController = TextEditingController();
  final _noteController = TextEditingController();

  WorkoutType _type = WorkoutType.running;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _durationController.dispose();
    _distanceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final distanceText = _distanceController.text.trim().replaceAll(',', '.');
    Navigator.of(context).pop(Workout(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: _type,
      date: _date,
      durationMinutes: int.parse(_durationController.text.trim()),
      distanceKm: distanceText.isEmpty ? null : double.parse(distanceText),
      note: _noteController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новая тренировка')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<WorkoutType>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Вид тренировки'),
              items: [
                for (final t in WorkoutType.values)
                  DropdownMenuItem(value: t, child: Text('${t.emoji}  ${t.title}')),
              ],
              onChanged: (t) => setState(() => _type = t!),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(DateFormat('d MMMM y', 'ru').format(_date)),
              trailing: TextButton(onPressed: _pickDate, child: const Text('Изменить')),
            ),
            TextFormField(
              key: const Key('duration'),
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Длительность, мин *'),
              validator: (v) {
                final n = int.tryParse(v?.trim() ?? '');
                if (n == null || n <= 0) return 'Введите число минут больше 0';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('distance'),
              controller: _distanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Дистанция, км'),
              validator: (v) {
                final text = v?.trim().replaceAll(',', '.') ?? '';
                if (text.isEmpty) return null;
                final n = double.tryParse(text);
                if (n == null || n <= 0) return 'Введите положительное число';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Заметка'),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}

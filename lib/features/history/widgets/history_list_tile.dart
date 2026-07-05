import 'package:flutter/material.dart';
import '../../meal_record/data/meal_record_model.dart';

const _labels = {
  'breakfast': '朝食',
  'lunch': '昼食',
  'dinner': '夕食',
  'snack': '間食',
};

class HistoryListTile extends StatelessWidget {
  const HistoryListTile({super.key, required this.record});
  final MealRecord record;

  @override
  Widget build(BuildContext context) {
    final label = _labels[record.mealType] ?? record.mealType;
    return ListTile(
      leading: CircleAvatar(child: Text(label[0])),
      title: Text(record.dishName),
      subtitle: Text('$label · ${_fmt(record.date)}'),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
}

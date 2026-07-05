import 'package:flutter/material.dart';

const _mealTypes = [
  ('breakfast', '朝食'),
  ('lunch', '昼食'),
  ('dinner', '夕食'),
  ('snack', '間食'),
];

class MealTypeSelector extends StatelessWidget {
  const MealTypeSelector({super.key, required this.selected, required this.onChanged});
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: _mealTypes
          .map((t) => ButtonSegment(value: t.$1, label: Text(t.$2)))
          .toList(),
      selected: {selected},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

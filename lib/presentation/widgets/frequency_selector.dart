import 'package:flutter/material.dart';

import 'package:loop_habit_tracker/data/models/frequency_model.dart';
import 'package:loop_habit_tracker/l10n/app_localizations.dart';

class FrequencySelector extends StatefulWidget {
  final Frequency initialFrequency;
  final ValueChanged<Frequency> onFrequencyChanged;

  const FrequencySelector({
    super.key,
    required this.initialFrequency,
    required this.onFrequencyChanged,
  });

  @override
  State<FrequencySelector> createState() => _FrequencySelectorState();
}

class _FrequencySelectorState extends State<FrequencySelector> {
  late Frequency _currentFrequency;
  final TextEditingController _customIntervalController =
      TextEditingController();
  List<int> _selectedDays = [];
  Set<int> _selectedMonths = {}; // 1-12
  int _selectedDayOfMonth = 1;

  @override
  void initState() {
    super.initState();
    _currentFrequency = widget.initialFrequency;
    _initializeValues();
  }

  @override
  void dispose() {
    _customIntervalController.dispose();
    super.dispose();
  }

  void _initializeValues() {
    if (_currentFrequency.type == FrequencyType.weekly &&
        _currentFrequency.value != null) {
      _selectedDays = WeekdayUtility.fromDatabaseString(
        _currentFrequency.value!,
      );
    } else if (_currentFrequency.type == FrequencyType.monthly &&
        _currentFrequency.value != null) {
      if (_currentFrequency.value!.contains(':')) {
        final parts = _currentFrequency.value!.split(':');
        _selectedDayOfMonth = int.tryParse(parts[0]) ?? 1;
        if (parts.length > 1 && parts[1].isNotEmpty) {
          _selectedMonths = parts[1]
              .split(',')
              .map((e) => int.tryParse(e) ?? 0)
              .toSet();
        } else {
          _selectedMonths = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12};
        }
      } else {
        _selectedDayOfMonth = int.tryParse(_currentFrequency.value!) ?? 1;
        _selectedMonths = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12};
      }
    } else if (_currentFrequency.type == FrequencyType.custom &&
        _currentFrequency.value != null) {
      // content is like "every_x_days:5"
      final parts = _currentFrequency.value!.split(':');
      if (parts.length > 1) {
        _customIntervalController.text = parts[1];
      } else {
        _customIntervalController.text = '1';
      }
    } else {
      // Default initialization
      _selectedDayOfMonth = DateTime.now().day;
      _selectedMonths = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12};
    }
  }

  void _onTypeChanged(FrequencyType? newType) {
    if (newType == null || newType == _currentFrequency.type) return;

    setState(() {
      String? newValue;
      if (newType == FrequencyType.monthly) {
        _selectedDayOfMonth = DateTime.now().day;
        _selectedMonths = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12};
        _updateMonthlyFrequency(); // Ensure value is generated correctly immediately
        // Note: we need to generate the value here because _updateMonthlyFrequency does it
        // but it relies on state variables we just set.
        String value = _selectedDayOfMonth.toString();
        // Since all months are selected by default, we can just send the day?
        // Or if we want to be consistent with "all months selected" logic:
        if (_selectedMonths.length != 12 && _selectedMonths.isNotEmpty) {
          final sortedMonths = _selectedMonths.toList()..sort();
          value += ':${sortedMonths.join(',')}';
        }
        newValue = value;
      } else if (newType == FrequencyType.custom) {
        _customIntervalController.text = '1';
        newValue = 'every_x_days:1';
      } else if (newType == FrequencyType.daily) {
        newValue = 'everyday';
      }

      _currentFrequency = Frequency(type: newType, value: newValue);
      _selectedDays = []; // Clear weekly selection
      widget.onFrequencyChanged(_currentFrequency);
    });
  }

  void _onWeekdaySelected(int weekday) {
    setState(() {
      if (_selectedDays.contains(weekday)) {
        _selectedDays.remove(weekday);
      } else {
        _selectedDays.add(weekday);
      }
      _currentFrequency = Frequency(
        type: FrequencyType.weekly,
        value: WeekdayUtility.toDatabaseString(_selectedDays),
      );
      widget.onFrequencyChanged(_currentFrequency);
    });
  }

  void _onMonthSelected(int month) {
    setState(() {
      if (_selectedMonths.contains(month)) {
        _selectedMonths.remove(month);
      } else {
        _selectedMonths.add(month);
      }
      _updateMonthlyFrequency();
    });
  }

  void _updateMonthlyFrequency() {
    String value = _selectedDayOfMonth.toString();
    if (_selectedMonths.length != 12 && _selectedMonths.isNotEmpty) {
      final sortedMonths = _selectedMonths.toList()..sort();
      value += ':${sortedMonths.join(',')}';
    }
    _currentFrequency = Frequency(type: FrequencyType.monthly, value: value);
    widget.onFrequencyChanged(_currentFrequency);
  }

  void _onCustomIntervalChanged(String value) {
    final interval = int.tryParse(value);
    if (interval != null && interval > 0) {
      setState(() {
        _currentFrequency = Frequency(
          type: FrequencyType.custom,
          value: 'every_x_days:$interval',
        );
        widget.onFrequencyChanged(_currentFrequency);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile<FrequencyType>(
          title: Text(AppLocalizations.of(context)!.daily),
          value: FrequencyType.daily,
          groupValue: _currentFrequency.type,
          onChanged: _onTypeChanged,
        ),
        if (_currentFrequency.type == FrequencyType.daily)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: DropdownButton<String>(
              value: _currentFrequency.value ?? 'everyday',
              onChanged: (String? newValue) {
                setState(() {
                  _currentFrequency = Frequency(
                    type: FrequencyType.daily,
                    value: newValue,
                  );
                  widget.onFrequencyChanged(_currentFrequency);
                });
              },
              items: <String>['everyday', 'weekdays', 'weekends']
                  .map<DropdownMenuItem<String>>((String value) {
                    String label;
                    final l10n = AppLocalizations.of(context)!;
                    switch (value) {
                      case 'everyday':
                        label = l10n.everyday;
                        break;
                      case 'weekdays':
                        label = l10n.weekdays;
                        break;
                      case 'weekends':
                        label = l10n.weekends;
                        break;
                      default:
                        label = value;
                    }
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(label),
                    );
                  })
                  .toList(),
            ),
          ),
        RadioListTile<FrequencyType>(
          title: Text(AppLocalizations.of(context)!.weekly),
          value: FrequencyType.weekly,
          groupValue: _currentFrequency.type,
          onChanged: _onTypeChanged,
        ),
        if (_currentFrequency.type == FrequencyType.weekly)
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 8.0,
            ),

            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.center, // Center the chips
              children: List.generate(7, (index) {
                final weekday = index + 1; // 1 = Monday, 7 = Sunday
                final l10n = AppLocalizations.of(context)!;
                final weekdays = [
                  l10n.mon,
                  l10n.tue,
                  l10n.wed,
                  l10n.thu,
                  l10n.fri,
                  l10n.sat,
                  l10n.sun,
                ];
                return ChoiceChip(
                  label: Text(weekdays[index]),
                  selected: _selectedDays.contains(weekday),
                  onSelected: (selected) {
                    _onWeekdaySelected(weekday);
                  },
                );
              }),
            ),
          ),
        RadioListTile<FrequencyType>(
          title: Text(AppLocalizations.of(context)!.monthly),
          value: FrequencyType.monthly,
          groupValue: _currentFrequency.type,
          onChanged: _onTypeChanged,
        ),
        if (_currentFrequency.type == FrequencyType.monthly)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 4.0,
                  runSpacing: 4.0,
                  children: List.generate(12, (index) {
                    final month = index + 1;
                    final l10n = AppLocalizations.of(context)!;
                    final months = [
                      l10n.jan,
                      l10n.feb,
                      l10n.mar,
                      l10n.apr,
                      l10n.may,
                      l10n.jun,
                      l10n.jul,
                      l10n.aug,
                      l10n.sep,
                      l10n.oct,
                      l10n.nov,
                      l10n.dec,
                    ];
                    return ChoiceChip(
                      label: Text(
                        months[index],
                        style: TextStyle(fontSize: 12),
                      ),
                      visualDensity: VisualDensity.compact,
                      selected: _selectedMonths.contains(month),
                      onSelected: (selected) {
                        _onMonthSelected(month);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        RadioListTile<FrequencyType>(
          title: Text(AppLocalizations.of(context)!.custom),
          value: FrequencyType.custom,
          groupValue: _currentFrequency.type,
          onChanged: _onTypeChanged,
        ),
        if (_currentFrequency.type == FrequencyType.custom)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Row(
              children: [
                Text(AppLocalizations.of(context)!.repeatEvery),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _customIntervalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _onCustomIntervalChanged,
                  ),
                ),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.days),
              ],
            ),
          ),
      ],
    );
  }
}

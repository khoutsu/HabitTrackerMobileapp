import 'package:home_widget/home_widget.dart';
import 'package:loop_habit_tracker/data/models/habit_model.dart';
import 'package:loop_habit_tracker/data/repositories/habit_repository.dart';

class WidgetService {
  static const String _appGroupId = 'group.com.example.loop_habit_tracker'; // For iOS
  static const String _iosWidgetName = 'HabitWidget'; // For iOS

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  static Future<void> updateWidget() async {
    final HabitRepository habitRepository = HabitRepository();
    final List<Habit> habits = await habitRepository.getHabits();
    
    // For simplicity, we'll send the name of the first habit to the widget.
    // A real implementation would serialize the list and handle it in the native code.
    final String habitListString = habits.map((h) => h.name).join('\n');
    
    await HomeWidget.saveWidgetData<String>('habit_list', habitListString);
    await HomeWidget.updateWidget(
      name: _iosWidgetName,
      iOSName: _iosWidgetName,
      androidName: 'HomeWidgetProvider',
    );
  }

  // This can be called from a background service to periodically update the widget
  static Future<void> backgroundCallback(Uri? uri) async {
    await updateWidget();
  }
}

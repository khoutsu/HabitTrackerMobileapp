import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:loop_habit_tracker/data/models/habit_model.dart';
import 'package:loop_habit_tracker/data/repositories/habit_repository.dart';
import 'package:loop_habit_tracker/presentation/widgets/habit_card.dart';
import 'package:loop_habit_tracker/presentation/widgets/loading_habit_list.dart';
import 'package:loop_habit_tracker/presentation/widgets/empty_state.dart';
import 'package:loop_habit_tracker/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:loop_habit_tracker/presentation/providers/habit_update_provider.dart';

class ArchivedHabitsScreen extends StatefulWidget {
  const ArchivedHabitsScreen({super.key});

  @override
  State<ArchivedHabitsScreen> createState() => _ArchivedHabitsScreenState();
}

class _ArchivedHabitsScreenState extends State<ArchivedHabitsScreen> {
  final HabitRepository _habitRepository = HabitRepository();
  List<Habit> _archivedHabits = [];
  bool _isLoading = true;

  int _lastUpdateCount = -1;

  @override
  void initState() {
    super.initState();
    _loadArchivedHabits();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen for updates when this screen is visible/active
    final updateCount = context.watch<HabitUpdateProvider>().updateCount;
    if (updateCount != _lastUpdateCount) {
      _lastUpdateCount = updateCount;
      _loadArchivedHabits();
    }
  }

  Future<void> _loadArchivedHabits() async {
    // Only set loading true if it's the first load or explicit refresh interaction
    // to avoid flickering on every provider update if desired.
    // However, for simplicity and ensuring user sees update, we keep it or optimize.
    // Let's optimize: only show full loading if list is empty.
    if (_archivedHabits.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final habits = await _habitRepository.getArchivedHabits();
      if (mounted) {
        setState(() {
          _archivedHabits = habits;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading archived habits: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _unarchiveHabit(int habitId) async {
    await _habitRepository.unarchiveHabit(habitId);
    if (mounted) {
      context.read<HabitUpdateProvider>().notifyUpdated();
      _loadArchivedHabits();
    }
  }

  Future<void> _deleteHabit(BuildContext context, Habit habit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deletePermanently),
        content: Text(
          AppLocalizations.of(context)!.deleteHabitConfirmation(habit.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _habitRepository.deleteHabit(habit.id!);
      if (mounted) {
        context.read<HabitUpdateProvider>().notifyUpdated();
        _loadArchivedHabits();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.archivedHabits)),
      body: _isLoading
          ? const LoadingHabitList()
          : _archivedHabits.isEmpty
          ? EmptyState(message: AppLocalizations.of(context)!.noArchivedHabits)
          : ListView.builder(
              itemCount: _archivedHabits.length,
              itemBuilder: (context, index) {
                final habit = _archivedHabits[index];
                return Slidable(
                  key: ValueKey(habit.id),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) => _unarchiveHabit(habit.id!),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        icon: Icons.unarchive,
                        label: AppLocalizations.of(context)!.restoreHabit,
                      ),
                      SlidableAction(
                        onPressed: (context) => _deleteHabit(context, habit),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete_forever,
                        label: AppLocalizations.of(context)!.deletePermanently,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                    ],
                  ),
                  child: HabitCard(
                    habit: habit,
                    streak: 0, // No streak for archived habits
                    repetitionsToday: [], // No repetitions for archived habits
                    onTap: () {
                      // No-op, handled by slidable
                    },
                    onStateChanged: () {
                      // Do nothing, or maybe refresh list if needed in future
                      _loadArchivedHabits();
                    },
                  ),
                );
              },
            ),
    );
  }
}

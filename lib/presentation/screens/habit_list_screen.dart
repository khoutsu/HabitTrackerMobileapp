import 'package:flutter/material.dart';
import 'package:loop_habit_tracker/data/models/habit_model.dart';
import 'package:loop_habit_tracker/data/models/repetition_model.dart';
import 'package:loop_habit_tracker/data/repositories/habit_repository.dart';
import 'package:loop_habit_tracker/data/repositories/repetition_repository.dart';
import 'package:loop_habit_tracker/data/repositories/skip_repository.dart';
import 'package:loop_habit_tracker/domain/usecases/calculate_streak.dart';
import 'package:loop_habit_tracker/presentation/screens/habit_form_screen.dart';
import 'package:loop_habit_tracker/presentation/screens/habit_detail_screen.dart';

import 'package:loop_habit_tracker/presentation/widgets/custom_page_route.dart';
import 'package:loop_habit_tracker/presentation/widgets/empty_state.dart';
import 'package:loop_habit_tracker/presentation/widgets/habit_card.dart';
import 'package:loop_habit_tracker/presentation/widgets/loading_habit_list.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:loop_habit_tracker/data/models/category_model.dart';
import 'package:loop_habit_tracker/l10n/app_localizations.dart';

import 'package:provider/provider.dart';
import 'package:loop_habit_tracker/presentation/providers/habit_update_provider.dart';

enum HabitSortType { manual, name, color, createdNewest, createdOldest, streak }

class HabitListScreen extends StatefulWidget {
  const HabitListScreen({super.key});

  @override
  State<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen>
    with WidgetsBindingObserver {
  final HabitRepository _habitRepository = HabitRepository();
  final RepetitionRepository _repetitionRepository = RepetitionRepository();
  final SkipRepository _skipRepository = SkipRepository();
  final CalculateStreak _calculateStreak = CalculateStreak();

  Map<String, List<Habit>> _groupedHabits = {};
  List<Habit> _allHabits = [];
  List<Habit> _uncategorizedHabits = [];
  List<String> _categoryOrder = [];
  Map<String, bool> _isPanelExpanded = {};

  Map<int, List<Repetition>> _todaysRepetitions = {};
  Map<int, int> _streaks = {};
  Map<int, Map<String, num>> _goalProgress = {};
  bool _isLoading = true;
  int _lastUpdateCount = -1; // Track updates from provider

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  HabitSortType _currentSortType = HabitSortType.manual;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(_onSearchChanged);
    _loadHabits();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadHabits();
    }
  }

  Future<void> _loadHabits() async {
    if (mounted && _groupedHabits.isEmpty && _uncategorizedHabits.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      final allHabits = await _habitRepository.getHabits();

      final newGroupedHabits = <String, List<Habit>>{};
      final newUncategorizedHabits = <Habit>[];
      final newCategoryOrder = <String>[];

      for (final habit in allHabits) {
        if (habit.categories == null || habit.categories!.isEmpty) {
          newUncategorizedHabits.add(habit);
        } else {
          for (final category in habit.categories!) {
            if (!newGroupedHabits.containsKey(category.name)) {
              newGroupedHabits[category.name] = [];
              newCategoryOrder.add(category.name);
            }
            newGroupedHabits[category.name]!.add(habit);
          }
        }
      }

      newCategoryOrder.sort();

      final newStreaks = <int, int>{};
      final newTodaysRepetitions = <int, List<Repetition>>{};
      final newGoalProgress = <int, Map<String, num>>{};

      for (final habit in allHabits) {
        try {
          final repetitions = await _repetitionRepository
              .getRepetitionsForHabit(habit.id!);
          final skips = await _skipRepository.getSkipsForHabit(habit.id!);
          final today = DateTime.now();

          final streakData = _calculateStreak(habit, repetitions, skips, today);
          newStreaks[habit.id!] = streakData['currentStreak'] ?? 0;

          newTodaysRepetitions[habit.id!] = repetitions
              .where(
                (rep) =>
                    rep.timestamp.year == today.year &&
                    rep.timestamp.month == today.month &&
                    rep.timestamp.day == today.day,
              )
              .toList();

          // Calculate Goal Progress
          if (habit.goalType != GoalType.off &&
              habit.goalValue != null &&
              habit.goalValue! > 0) {
            final todayMidnight = DateTime(today.year, today.month, today.day);
            DateTime startDate;
            switch (habit.goalPeriod) {
              case GoalPeriod.daily:
                startDate = todayMidnight.subtract(
                  const Duration(microseconds: 1),
                ); // Include today 00:00
                break;
              case GoalPeriod.weekly:
                startDate = todayMidnight
                    .subtract(Duration(days: todayMidnight.weekday - 1))
                    .subtract(const Duration(microseconds: 1));
                break;
              case GoalPeriod.monthly:
                startDate = DateTime(
                  today.year,
                  today.month,
                  1,
                ).subtract(const Duration(microseconds: 1));
                break;
              case GoalPeriod.allTime:
                startDate = habit.createdAt.subtract(
                  const Duration(microseconds: 1),
                );
                break;
            }

            final relevantRepetitions = repetitions
                .where((rep) => rep.timestamp.isAfter(startDate))
                .toList();

            num currentValue = 0;
            if (habit.habitType == HabitType.numeric ||
                habit.habitType == HabitType.yesNo) {
              // Now we sum values even for yesNo, so we can support 'bulk' completion (value > 1)
              currentValue = relevantRepetitions.fold(
                0,
                (sum, rep) => sum + (rep.value ?? 0),
              );
            } else {
              // timed
              // If timed habits store duration in value, we should sum it too.
              // Assuming 'value' is what we track against goal.
              currentValue = relevantRepetitions.fold(
                0,
                (sum, rep) => sum + (rep.value ?? 0),
              );
            }

            newGoalProgress[habit.id!] = {
              'current': currentValue,
              'goal': habit.goalValue!,
            };
          }
        } catch (e) {
          print('Error calculating stats for habit ${habit.id}: $e');
        }
      }

      if (mounted) {
        setState(() {
          _allHabits = allHabits;
          _groupedHabits = newGroupedHabits;
          _uncategorizedHabits = newUncategorizedHabits;
          _categoryOrder = newCategoryOrder;
          _streaks = newStreaks;
          _todaysRepetitions = newTodaysRepetitions;
          _goalProgress = newGoalProgress;
          _isPanelExpanded = {for (var v in _categoryOrder) v: true};
          if (_uncategorizedHabits.isNotEmpty) {
            _isPanelExpanded['Uncategorized'] = true;
          }
        });
      }
    } catch (e) {
      print('Error loading habits: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _archiveHabit(Habit habit) async {
    await _habitRepository.archiveHabit(habit.id!);
    // Notify provider so ArchivedHabitsScreen updates
    if (mounted) {
      context.read<HabitUpdateProvider>().notifyUpdated();
      await _loadHabits();
    }
  }

  Future<void> _deleteHabit(Habit habit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteHabit),
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
        await _loadHabits();
      }
    }
  }

  Future<void> _editHabit(Habit habit) async {
    final result = await Navigator.of(
      context,
    ).push(CustomPageRoute(page: HabitFormScreen(habit: habit)));
    if (result == true) {
      // Notify provider so ArchivedHabitsScreen updates if properties changed
      if (mounted) {
        context.read<HabitUpdateProvider>().notifyUpdated();
        _loadHabits();
      }
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (_selectedCategoryFilter != 'All' ||
        _searchQuery.isNotEmpty ||
        _currentSortType != HabitSortType.manual)
      return;

    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final habit = _allHabits.removeAt(oldIndex);
      _allHabits.insert(newIndex, habit);
    });

    _habitRepository.updateHabitSortOrder(_allHabits);
  }

  Widget _buildHabitList(List<Habit> habits) {
    // Determine if reordering should be enabled
    final isReorderable =
        _selectedCategoryFilter == 'All' &&
        _searchQuery.isEmpty &&
        _currentSortType == HabitSortType.manual;

    if (!isReorderable) {
      // Fallback to simpler list or non-reorderable for now to avoid confusion
      // or implement generic list
      return RefreshIndicator(
        onRefresh: _loadHabits,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final habit = habits[index];
            final todaysReps = _todaysRepetitions[habit.id] ?? [];
            final streak = _streaks[habit.id] ?? 0;
            final goalProgress = _goalProgress[habit.id];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Slidable(
                key: ValueKey(habit.id),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) => _editHabit(habit),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: AppLocalizations.of(context)!.edit,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(12),
                      ),
                    ),
                    SlidableAction(
                      onPressed: (context) => _archiveHabit(habit),
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      icon: Icons.archive,
                      label: AppLocalizations.of(context)!.archive,
                    ),
                    SlidableAction(
                      onPressed: (context) => _deleteHabit(habit),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: AppLocalizations.of(context)!.delete,
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(12),
                      ),
                    ),
                  ],
                ),
                child: HabitCard(
                  habit: habit,
                  onTap: () async {
                    await Navigator.of(context).push(
                      CustomPageRoute(page: HabitDetailScreen(habit: habit)),
                    );
                    _loadHabits();
                  },
                  onStateChanged: () => _loadHabits(),
                  streak: streak,
                  repetitionsToday: todaysReps,
                  goalProgress: goalProgress,
                ),
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHabits,
      child: ReorderableListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      spreadRadius: -2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: child,
          );
        },
        onReorder: _onReorder,
        children: habits.map((habit) {
          final todaysReps = _todaysRepetitions[habit.id] ?? [];
          final streak = _streaks[habit.id] ?? 0;
          final goalProgress = _goalProgress[habit.id];

          return Container(
            key: ValueKey(habit.id),
            margin: const EdgeInsets.only(bottom: 8.0),
            child: Slidable(
              key: ValueKey(habit.id),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) => _editHabit(habit),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: AppLocalizations.of(context)!.edit,
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(12),
                    ),
                  ),
                  SlidableAction(
                    onPressed: (context) => _archiveHabit(habit),
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    icon: Icons.archive,
                    label: AppLocalizations.of(context)!.archive,
                  ),
                  SlidableAction(
                    onPressed: (context) => _deleteHabit(habit),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: AppLocalizations.of(context)!.delete,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(12),
                    ),
                  ),
                ],
              ),
              child: HabitCard(
                habit: habit,
                onTap: () async {
                  await Navigator.of(context).push(
                    CustomPageRoute(page: HabitDetailScreen(habit: habit)),
                  );
                  _loadHabits();
                },
                onStateChanged: () => _loadHabits(),
                streak: streak,
                repetitionsToday: todaysReps,
                goalProgress: goalProgress,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _selectedCategoryFilter = 'All';
  bool _isCategoryExpanded = false;

  Widget _buildChip(String category) {
    final isSelected = _selectedCategoryFilter == category;
    String label = category;
    if (category == 'All') label = AppLocalizations.of(context)!.all;
    if (category == 'Uncategorized')
      label = AppLocalizations.of(context)!.uncategorized;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? Colors.white
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedCategoryFilter = category;
          });
        }
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
        ),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', ..._categoryOrder];
    if (_uncategorizedHabits.isNotEmpty) {
      categories.add('Uncategorized');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.categories.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              if (categories.length > 4) // Only show toggle if meaningful
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isCategoryExpanded = !_isCategoryExpanded;
                    });
                  },
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    _isCategoryExpanded
                        ? AppLocalizations.of(context)!.showLess
                        : AppLocalizations.of(context)!.showAll,
                  ),
                ),
            ],
          ),
        ),
        if (_isCategoryExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: categories.map((c) => _buildChip(c)).toList(),
              ),
            ),
          )
        else
          SizedBox(
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) => _buildChip(categories[index]),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  List<Habit> _getFilteredHabits() {
    List<Habit> habits;
    if (_selectedCategoryFilter == 'All') {
      habits = _allHabits;
    } else if (_selectedCategoryFilter == 'Uncategorized') {
      habits = _uncategorizedHabits;
    } else {
      habits = _groupedHabits[_selectedCategoryFilter] ?? [];
    }

    if (_searchQuery.isNotEmpty) {
      habits = habits
          .where(
            (h) => h.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    } else if (_currentSortType != HabitSortType.manual) {
      // Create a copy to avoid mutating the original list when sorting
      habits = List.of(habits);
    }

    switch (_currentSortType) {
      case HabitSortType.name:
        habits.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case HabitSortType.color:
        habits.sort((a, b) => a.color.value.compareTo(b.color.value));
        break;
      case HabitSortType.createdNewest:
        habits.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case HabitSortType.createdOldest:
        habits.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case HabitSortType.streak:
        habits.sort((a, b) {
          final streakA = _streaks[a.id] ?? 0;
          final streakB = _streaks[b.id] ?? 0;
          return streakB.compareTo(streakA);
        });
        break;
      case HabitSortType.manual:
      default:
        break;
    }

    return habits;
  }

  @override
  Widget build(BuildContext context) {
    // Listen for global updates (e.g. from BackupScreen)
    final updateCount = context.watch<HabitUpdateProvider>().updateCount;
    if (updateCount != _lastUpdateCount) {
      _lastUpdateCount = updateCount;
      // Use addPostFrameCallback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadHabits();
      });
    }

    final filteredHabits = _getFilteredHabits();
    final hasHabits =
        _groupedHabits.isNotEmpty || _uncategorizedHabits.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search habits...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              )
            : Text(
                AppLocalizations.of(context)!.myHabits,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          PopupMenuButton<HabitSortType>(
            icon: const Icon(Icons.sort),
            tooltip: AppLocalizations.of(context)!.sort,
            onSelected: (HabitSortType result) {
              setState(() {
                _currentSortType = result;
              });
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<HabitSortType>>[
                  PopupMenuItem<HabitSortType>(
                    value: HabitSortType.manual,
                    child: Text(AppLocalizations.of(context)!.sortDefault),
                  ),
                  PopupMenuItem<HabitSortType>(
                    value: HabitSortType.name,
                    child: Text(AppLocalizations.of(context)!.habitName),
                  ),
                  PopupMenuItem<HabitSortType>(
                    value: HabitSortType.color,
                    child: Text(AppLocalizations.of(context)!.color),
                  ),
                  PopupMenuItem<HabitSortType>(
                    value: HabitSortType.createdNewest,
                    child: Text(AppLocalizations.of(context)!.sortNewest),
                  ),
                  PopupMenuItem<HabitSortType>(
                    value: HabitSortType.createdOldest,
                    child: Text(AppLocalizations.of(context)!.sortOldest),
                  ),
                  PopupMenuItem<HabitSortType>(
                    value: HabitSortType.streak,
                    child: Text(AppLocalizations.of(context)!.sortStreak),
                  ),
                ],
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingHabitList()
          : !hasHabits
          ? EmptyState(message: AppLocalizations.of(context)!.addFirstHabit)
          : Column(
              children: [
                if (!_isSearching) _buildCategoryFilter(),
                Expanded(
                  child: filteredHabits.isEmpty
                      ? Center(child: Text("No habits found"))
                      : _buildHabitList(filteredHabits),
                ),
              ],
            ),
    );
  }
}

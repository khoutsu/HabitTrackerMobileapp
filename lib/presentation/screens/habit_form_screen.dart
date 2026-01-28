import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:loop_habit_tracker/core/themes/app_colors.dart';

import 'package:loop_habit_tracker/data/models/habit_model.dart';
import 'package:loop_habit_tracker/data/repositories/habit_repository.dart';
import 'package:loop_habit_tracker/l10n/app_localizations.dart';
import 'package:loop_habit_tracker/data/models/frequency_model.dart'; // Import Frequency model
import 'package:loop_habit_tracker/data/models/category_model.dart';
import 'package:loop_habit_tracker/data/repositories/category_repository.dart';
import 'package:loop_habit_tracker/presentation/widgets/frequency_selector.dart'; // Import FrequencySelector
import 'package:flutter_slidable/flutter_slidable.dart';

class HabitFormScreen extends StatefulWidget {
  final Habit? habit;

  const HabitFormScreen({super.key, this.habit});

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  void _updateTotalMinutes() {
    final hours = int.tryParse(_hoursController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final totalMinutes = (hours * 60) + minutes;

    // Store timer duration in numericUnit, leaving goalValueController alone
    _numericUnitController.text = totalMinutes.toString();
  }

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  Color _currentColor = AppColors.primary;
  Frequency _selectedFrequency = Frequency(
    type: FrequencyType.daily,
  ); // Use Frequency object

  // New state variables
  HabitType _selectedHabitType = HabitType.yesNo;
  final _numericUnitController = TextEditingController();
  GoalType _selectedGoalType = GoalType.off;
  final _goalValueController = TextEditingController();
  GoalPeriod _selectedGoalPeriod = GoalPeriod.allTime;
  final _hoursController = TextEditingController();
  final _minutesController = TextEditingController();

  final CategoryRepository _categoryRepository = CategoryRepository();
  List<Category> _allCategories = [];
  Set<int> _selectedCategoryIds = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.habit != null) {
      _nameController.text = widget.habit!.name;
      _descriptionController.text = widget.habit!.description ?? '';
      _currentColor = widget.habit!.color;
      _selectedFrequency = widget.habit!.frequency;
      _selectedCategoryIds = (widget.habit!.categories ?? [])
          .map((c) => c.id!)
          .toSet();

      // Initialize new fields
      _selectedHabitType = widget.habit!.habitType;
      _numericUnitController.text = widget.habit!.numericUnit ?? '';
      _selectedGoalType = widget.habit!.goalType;
      _goalValueController.text = widget.habit!.goalValue?.toString() ?? '';
      _selectedGoalPeriod = widget.habit!.goalPeriod;

      if (_selectedHabitType == HabitType.timed) {
        // Try to parse duration from numericUnit first (string)
        final savedDuration = int.tryParse(widget.habit!.numericUnit ?? '');
        if (savedDuration != null) {
          _hoursController.text = (savedDuration ~/ 60).toString();
          _minutesController.text = (savedDuration % 60).toString();
        }
      }
      _selectedGoalPeriod = widget.habit!.goalPeriod;
    }
  }

  Future<void> _loadCategories() async {
    final categories = await _categoryRepository.getCategories();
    setState(() {
      _allCategories = categories;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _numericUnitController.dispose();
    _goalValueController.dispose();
    super.dispose();
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectColor),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _currentColor,
            onColorChanged: (color) {
              setState(() {
                _currentColor = color;
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.select),
          ),
        ],
      ),
    );
  }

  Future<Category?> _showAddCategoryDialog() async {
    final newCategoryController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          child: Text(
            AppLocalizations.of(context)!.addNewCategory,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newCategoryController,
              autofocus: true,
              style: Theme.of(context).textTheme.bodyLarge,
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.categoryName,
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (newCategoryController.text.isNotEmpty) {
                      Navigator.of(context).pop(newCategoryController.text);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.add,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final newCategory = await _categoryRepository.createCategory(
        Category(name: result),
      );
      // Reload main categories
      await _loadCategories();
      // Add to selected
      setState(() {
        _selectedCategoryIds.add(newCategory.id!);
      });
      return newCategory;
    }
    return null;
  }

  Future<void> _showManageCategoriesDialog() async {
    // Helper function to create new category within the dialog
    Future<void> createNewCategoryInDialog(StateSetter setStateDialog) async {
      // We can reuse the existing dialog logic but we need to handle the result locally
      final newCategoryController = TextEditingController();
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text(
              AppLocalizations.of(context)!.addNewCategory,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newCategoryController,
                autofocus: true,
                style: Theme.of(context).textTheme.bodyLarge,
                cursorColor: AppColors.primary,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.categoryName,
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (newCategoryController.text.isNotEmpty) {
                        Navigator.of(context).pop(newCategoryController.text);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.add,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      if (result != null && result.isNotEmpty) {
        final newCategory = await _categoryRepository.createCategory(
          Category(name: result),
        );
        // Reload all categories to update the list in the dialog
        final categories = await _categoryRepository.getCategories();

        setStateDialog(() {
          _allCategories = categories;
          _selectedCategoryIds.add(newCategory.id!);
        });
        // Also update parent state
        setState(() {
          _allCategories = categories;
          _selectedCategoryIds.add(newCategory.id!);
        });
      }
    }

    Future<void> _editCategoryInDialog(
      Category category,
      StateSetter setStateDialog,
    ) async {
      final editController = TextEditingController(text: category.name);
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text(
              AppLocalizations.of(
                context,
              )!.edit, // Reuse 'Edit' string, or specific 'Edit Category'
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editController,
                autofocus: true,
                style: Theme.of(context).textTheme.bodyLarge,
                cursorColor: AppColors.primary,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.categoryName,
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (editController.text.isNotEmpty) {
                        Navigator.of(context).pop(editController.text);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.saveChanges,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      if (result != null && result.isNotEmpty && result != category.name) {
        // Update category
        final updatedCategory = category.copyWith(name: result);
        await _categoryRepository.updateCategory(
          updatedCategory,
        ); // Assuming updateCategory exists, may need to create it

        // Reload
        final categories = await _categoryRepository.getCategories();
        setStateDialog(() {
          _allCategories = categories;
        });
        setState(() {
          _allCategories = categories;
        });
      }
    }

    Future<void> _deleteCategoryInDialog(
      Category category,
      StateSetter setStateDialog,
    ) async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.delete),
          content: Text(
            AppLocalizations.of(
              context,
            )!.deleteCategoryConfirmation(category.name),
          ), // Localization needed ideally
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
        await _categoryRepository.deleteCategory(category.id!);
        final categories = await _categoryRepository.getCategories();
        setStateDialog(() {
          _allCategories = categories;
          _selectedCategoryIds.remove(category.id);
        });
        setState(() {
          _allCategories = categories;
          _selectedCategoryIds.remove(category.id);
        });
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.categories),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: _allCategories.isEmpty
                          ? Center(
                              child: Text(
                                AppLocalizations.of(context)!.noCategories,
                              ),
                            )
                          : ListView(
                              shrinkWrap: true,
                              children: _allCategories.map((category) {
                                return Slidable(
                                  key: ValueKey(category.id),
                                  endActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) {
                                          // Edit logic
                                          _editCategoryInDialog(
                                            category,
                                            setStateDialog,
                                          );
                                        },
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        icon: Icons.edit,
                                        label: AppLocalizations.of(
                                          context,
                                        )!.edit,
                                        borderRadius: BorderRadius.horizontal(
                                          left: Radius.circular(12),
                                        ),
                                      ),
                                      SlidableAction(
                                        onPressed: (context) {
                                          // Delete logic
                                          _deleteCategoryInDialog(
                                            category,
                                            setStateDialog,
                                          );
                                        },
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                        label: AppLocalizations.of(
                                          context,
                                        )!.delete,
                                        borderRadius: BorderRadius.horizontal(
                                          right: Radius.circular(12),
                                        ),
                                      ),
                                    ],
                                  ),
                                  child: CheckboxListTile(
                                    title: Text(category.name),
                                    value: _selectedCategoryIds.contains(
                                      category.id,
                                    ),
                                    onChanged: (bool? value) {
                                      setStateDialog(() {
                                        if (value == true) {
                                          _selectedCategoryIds.add(
                                            category.id!,
                                          );
                                        } else {
                                          _selectedCategoryIds.remove(
                                            category.id!,
                                          );
                                        }
                                      });
                                      // Update main state as well so UI reflects immediately if partially visible content
                                      setState(() {});
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => createNewCategoryInDialog(setStateDialog),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 18),
                      SizedBox(width: 4),
                      Text(AppLocalizations.of(context)!.addNewCategory),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    AppLocalizations.of(context)!.saveChanges,
                  ), // or OK
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.categories,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: [
            // Only show selected categories
            ..._allCategories
                .where((category) => _selectedCategoryIds.contains(category.id))
                .map((category) {
                  return Chip(
                    label: Text(category.name),
                    onDeleted: () {
                      setState(() {
                        _selectedCategoryIds.remove(category.id);
                      });
                    },
                  );
                })
                .toList(),
            ActionChip(
              avatar: Icon(Icons.edit),
              label: Text(AppLocalizations.of(context)!.add),
              onPressed: _showManageCategoriesDialog,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      final HabitRepository habitRepository = HabitRepository();

      final List<Category> selectedCategories = _allCategories
          .where((cat) => _selectedCategoryIds.contains(cat.id))
          .toList();

      final newHabit = Habit(
        id: widget.habit?.id,
        name: _nameController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        color: _currentColor,
        frequency: _selectedFrequency,
        createdAt: widget.habit?.createdAt ?? DateTime.now(),
        categories: selectedCategories,
        habitType: _selectedHabitType,
        numericUnit: _numericUnitController.text.isEmpty
            ? null
            : _numericUnitController.text,
        goalType: _selectedGoalType,
        goalValue: int.tryParse(_goalValueController.text),
        goalPeriod: _selectedGoalPeriod,
      );

      if (widget.habit == null) {
        await habitRepository.createHabit(newHabit);
      } else {
        await habitRepository.updateHabit(newHabit);
      }
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  String _getHabitTypeText(HabitType type, AppLocalizations l10n) {
    switch (type) {
      case HabitType.yesNo:
        return l10n.habitTypeYesNo;
      case HabitType.numeric:
        return l10n.habitTypeNumeric;
      case HabitType.timed:
        return l10n.habitTypeTimed;
    }
  }

  String _getGoalPeriodText(GoalPeriod period, AppLocalizations l10n) {
    switch (period) {
      case GoalPeriod.daily:
        return l10n.daily;
      case GoalPeriod.weekly:
        return l10n.goalPeriodWeekly;
      case GoalPeriod.monthly:
        return l10n.goalPeriodMonthly;
      case GoalPeriod.allTime:
        return l10n.goalPeriodAllTime;
    }
  }

  void _showHelpDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(body, style: const TextStyle(height: 1.5)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              AppLocalizations.of(context)!.select,
            ), // Using 'SELECT' (OK) or cancel? select implies choice.
            // Better use 'OK' if available in localization? Check arb.
            // arb has "cancel", "save", "delete". No "OK".
            // I'll use "OK" hardcoded or "save" (weird).
            // I'll use Text('OK').
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.habit == null ? l10n.createNewHabit : l10n.editHabit,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.habitName,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.enterHabitName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.descriptionOptional,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(l10n.color),
                trailing: GestureDetector(
                  onTap: _pickColor,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _currentColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.divider),
                    ),
                  ),
                ),
                onTap: _pickColor,
              ),
              const SizedBox(height: 16),
              // --- New Habit Type Section ---
              DropdownButtonFormField<HabitType>(
                key: const Key('habitTypeDropdown'),
                value: _selectedHabitType,
                decoration: InputDecoration(
                  labelText: l10n.habitType,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.help_outline),
                    tooltip: 'Help',
                    onPressed: () => _showHelpDialog(
                      context,
                      l10n.habitTypeHelpTitle,
                      l10n.habitTypeHelpBody,
                    ),
                  ),
                ),
                items: HabitType.values.map((HabitType type) {
                  return DropdownMenuItem<HabitType>(
                    value: type,
                    child: Text(_getHabitTypeText(type, l10n)),
                  );
                }).toList(),
                onChanged: (HabitType? newValue) {
                  setState(() {
                    _selectedHabitType = newValue!;
                  });
                },
              ),
              if (_selectedHabitType == HabitType.numeric)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextFormField(
                    controller: _numericUnitController,
                    decoration: InputDecoration(
                      labelText: l10n.numericUnit,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              if (_selectedHabitType == HabitType.timed)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Hours', // Localization later
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => _updateTotalMinutes(),
                          controller: _hoursController, // Need to define this
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          key: const Key('minutesTextField'),
                          decoration: InputDecoration(
                            labelText: 'Minutes', // Localization later
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => _updateTotalMinutes(),
                          controller: _minutesController, // Need to define this
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    l10n.frequencyHelpTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: () => _showHelpDialog(
                      context,
                      l10n.frequencyHelpTitle,
                      l10n.frequencyHelpBody,
                    ),
                  ),
                ],
              ),
              FrequencySelector(
                initialFrequency: _selectedFrequency,
                onFrequencyChanged: (newFrequency) {
                  setState(() {
                    _selectedFrequency = newFrequency;
                  });
                },
              ),
              _buildCategorySelector(),
              const SizedBox(height: 16),
              // --- New Goal Section ---
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.goal,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              IconButton(
                                icon: const Icon(Icons.help_outline),
                                onPressed: () => _showHelpDialog(
                                  context,
                                  l10n.goalHelpTitle,
                                  l10n.goalHelpBody,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _selectedGoalType != GoalType.off,
                            onChanged: (bool value) {
                              setState(() {
                                _selectedGoalType = value
                                    ? GoalType.targetCount
                                    : GoalType.off;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                      if (_selectedGoalType != GoalType.off)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: TextFormField(
                            controller: _goalValueController,
                            decoration: InputDecoration(
                              labelText: l10n.targetValue,
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      if (_selectedGoalType != GoalType.off)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: DropdownButtonFormField<GoalPeriod>(
                            value: _selectedGoalPeriod,
                            decoration: InputDecoration(
                              labelText: l10n.goalPeriod,
                              border: const OutlineInputBorder(),
                            ),
                            items: GoalPeriod.values.map((GoalPeriod period) {
                              return DropdownMenuItem<GoalPeriod>(
                                value: period,
                                child: Text(_getGoalPeriodText(period, l10n)),
                              );
                            }).toList(),
                            onChanged: (GoalPeriod? newValue) {
                              setState(() {
                                _selectedGoalPeriod = newValue!;
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  widget.habit == null ? l10n.createHabit : l10n.saveChanges,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

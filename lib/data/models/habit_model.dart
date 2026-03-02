import 'package:flutter/material.dart';
import 'package:loop_habit_tracker/data/models/category_model.dart';
import 'package:loop_habit_tracker/data/models/frequency_model.dart';
import 'package:loop_habit_tracker/data/models/reminder_model.dart';

enum HabitType { yesNo, numeric, timed }

enum GoalType { off, targetCount }

enum GoalPeriod { daily, weekly, monthly, allTime }

class Habit {
  final int? id;
  final String name;
  final String? description;
  final Color color;
  final Frequency frequency;
  final DateTime createdAt;
  final bool archived;
  final List<Category>? categories;

  // New fields for features 1 & 2
  final HabitType habitType;
  final String? numericUnit; // e.g., "pages", "glasses"
  final GoalType goalType;
  final int? goalValue;
  final GoalPeriod goalPeriod;
  final List<Reminder>? reminders;
  final int sortOrder;

  Habit({
    this.id,
    required this.name,
    this.description,
    required this.color,
    required this.frequency,
    required this.createdAt,
    this.archived = false,
    this.categories,
    this.habitType = HabitType.yesNo,
    this.numericUnit,
    this.goalType = GoalType.off,
    this.goalValue,
    this.goalPeriod = GoalPeriod.allTime,
    this.reminders,
    this.sortOrder = 0,
  });

  Habit copyWith({
    int? id,
    String? name,
    String? description,
    Color? color,
    Frequency? frequency,
    DateTime? createdAt,
    bool? archived,
    List<Category>? categories,
    HabitType? habitType,
    String? numericUnit,
    GoalType? goalType,
    int? goalValue,
    GoalPeriod? goalPeriod,
    List<Reminder>? reminders,
    int? sortOrder,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt ?? this.createdAt,
      archived: archived ?? this.archived,
      categories: categories ?? this.categories,
      habitType: habitType ?? this.habitType,
      numericUnit: numericUnit ?? this.numericUnit,
      goalType: goalType ?? this.goalType,
      goalValue: goalValue ?? this.goalValue,
      goalPeriod: goalPeriod ?? this.goalPeriod,
      reminders: reminders ?? this.reminders,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color.value,
      'frequency': frequency.toDatabaseString(),
      'created_at': createdAt.toIso8601String(),
      'archived': archived ? 1 : 0,
      'habit_type': habitType.toString(),
      'numeric_unit': numericUnit,
      'goal_type': goalType.toString(),
      'goal_value': goalValue,
      'goal_period': goalPeriod.toString(),
      'sort_order': sortOrder,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      color: Color(map['color']),
      frequency: Frequency.fromDatabaseString(map['frequency']),
      createdAt: DateTime.parse(map['created_at']),
      archived: map['archived'] == 1,
      categories: [], // Categories will be loaded separately
      reminders: [], // Reminders will be loaded separately
      habitType: HabitType.values.firstWhere(
        (e) => e.toString() == map['habit_type'],
        orElse: () => HabitType.yesNo,
      ),
      numericUnit: map['numeric_unit'],
      goalType: GoalType.values.firstWhere(
        (e) => e.toString() == map['goal_type'],
        orElse: () => GoalType.off,
      ),
      goalValue: map['goal_value'],
      goalPeriod: GoalPeriod.values.firstWhere(
        (e) => e.toString() == map['goal_period'],
        orElse: () => GoalPeriod.allTime,
      ),
      sortOrder: map['sort_order'] ?? 0,
    );
  }
}

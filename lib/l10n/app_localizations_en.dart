// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get myHabits => 'My Habits';

  @override
  String get settings => 'Settings';

  @override
  String get backupAndRestore => 'Backup & Restore';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get about => 'About';

  @override
  String get statistics => 'Statistics';

  @override
  String get archivedHabits => 'Archived Habits';

  @override
  String get habitName => 'Habit Name';

  @override
  String get enterHabitName => 'Please enter a habit name';

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String get color => 'Color';

  @override
  String get selectColor => 'Select a color';

  @override
  String get select => 'SELECT';

  @override
  String get everyday => 'Everyday';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get custom => 'Custom';

  @override
  String get createHabit => 'CREATE HABIT';

  @override
  String get createNewHabit => 'Create New Habit';

  @override
  String get editHabit => 'Edit Habit';

  @override
  String get saveChanges => 'SAVE CHANGES';

  @override
  String get deleteHabit => 'Delete Habit?';

  @override
  String deleteHabitConfirmation(String habitName) {
    return 'Are you sure you want to delete \"$habitName\"? This action cannot be undone.';
  }

  @override
  String get cancel => 'CANCEL';

  @override
  String get delete => 'DELETE';

  @override
  String createdOn(String date) {
    return 'Created on: $date';
  }

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get totalCompletions => 'Total Completions';

  @override
  String get progressCharts => 'Progress Charts:';

  @override
  String get statsDays => 'days';

  @override
  String get statsTimes => 'times';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';

  @override
  String get jan => 'Jan';

  @override
  String get feb => 'Feb';

  @override
  String get mar => 'Mar';

  @override
  String get apr => 'Apr';

  @override
  String get may => 'May';

  @override
  String get jun => 'Jun';

  @override
  String get jul => 'Jul';

  @override
  String get aug => 'Aug';

  @override
  String get sep => 'Sep';

  @override
  String get oct => 'Oct';

  @override
  String get nov => 'Nov';

  @override
  String get dec => 'Dec';

  @override
  String get weekdays => 'Weekdays';

  @override
  String get weekends => 'Weekends';

  @override
  String get successRate => 'Success Rate';

  @override
  String get frequencyLast7Days => 'Frequency (Last 7 Days)';

  @override
  String get habitStrengthLast30Days => 'Habit Strength (Last 30 Days)';

  @override
  String get cannotSkipCompleted => 'Cannot skip a completed day.';

  @override
  String get skipDay => 'Skip Day';

  @override
  String get unskipDay => 'Un-skip Day';

  @override
  String get confirmSkip =>
      'Are you sure you want to mark this day as skipped? This will not break your streak.';

  @override
  String get confirmUnskip =>
      'Are you sure you want to remove the skip for this day?';

  @override
  String get skip => 'Skip';

  @override
  String get unskip => 'Un-skip';

  @override
  String get addNewCategory => 'Add New Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get add => 'Add';

  @override
  String get categories => 'Categories';

  @override
  String get edit => 'Edit';

  @override
  String get archive => 'Archive';

  @override
  String get restoreHabit => 'Restore Habit';

  @override
  String get deletePermanently => 'Delete Permanently';

  @override
  String get habitType => 'Habit Type';

  @override
  String get habitTypeYesNo => 'Regular';

  @override
  String get habitTypeNumeric => 'Numeric';

  @override
  String get habitTypeTimed => 'Timed';

  @override
  String get numericUnit => 'Unit (e.g., pages, glasses)';

  @override
  String get goal => 'Goal';

  @override
  String get goalType => 'Goal Type';

  @override
  String get goalTypeOff => 'Off';

  @override
  String get goalTypeTargetCount => 'Target Count';

  @override
  String get targetValue => 'Target Amount';

  @override
  String get goalPeriod => 'Per Period';

  @override
  String get goalPeriodDaily => 'Daily';

  @override
  String get goalPeriodWeekly => 'Weekly';

  @override
  String get goalPeriodMonthly => 'Monthly';

  @override
  String get goalPeriodAllTime => 'All Time';

  @override
  String enterValueFor(String habitName) {
    return 'Enter Value for $habitName';
  }

  @override
  String get valueLabel => 'Value';

  @override
  String get timerDuration => 'Timer Duration (minutes)';

  @override
  String get noHabitsYet => 'No habits yet!';

  @override
  String get addFirstHabit => 'Tap the + button to add your first habit.';

  @override
  String get noArchivedHabits => 'You have no archived habits.';

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String timerTitle(String habitName) {
    return 'Timer: $habitName';
  }

  @override
  String get selectDuration => 'Select Duration (HH:MM)';

  @override
  String get save => 'SAVE';

  @override
  String get activityLog => 'Activity Log';

  @override
  String get maxStreak => 'Max Streak';

  @override
  String get success => 'Success';

  @override
  String get missed => 'Missed';

  @override
  String get repeatEvery => 'Repeat every';

  @override
  String get days => 'days';

  @override
  String get noCategories => 'No categories';

  @override
  String deleteCategoryConfirmation(String categoryName) {
    return 'Are you sure you want to delete \'$categoryName\'?';
  }

  @override
  String get showAll => 'Show All';

  @override
  String get showLess => 'Show Less';

  @override
  String get habitTypeHelpTitle => 'Habit Types';

  @override
  String get habitTypeHelpBody =>
      '1. **Regular:** Simple Yes/No check (e.g., Wake up early)\n2. **Numeric:** Track a number (e.g., Drink 8 glasses)\n3. **Timed:** Track duration (e.g., Meditate 15 mins)';

  @override
  String get goalHelpTitle => 'Goal Periods';

  @override
  String get goalHelpBody =>
      '1. **Daily:** Resets every day.\n2. **Weekly:** Resets every Monday.\n3. **Monthly:** Resets on the 1st of the month.\n4. **All Time:** Never resets (Accumulates forever).';

  @override
  String get frequencyHelpTitle => 'Frequency';

  @override
  String get frequencyHelpBody =>
      '1. **Daily:** Everyday, Weekdays, or Weekends.\n2. **Weekly:** specific days (Mon-Sun).\n3. **Monthly:** Once a month (Select specific months).\n4. **Custom:** Repeat every X days (e.g. Every 2 days = Every other day).';
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('th'),
  ];

  /// No description provided for @myHabits.
  ///
  /// In en, this message translates to:
  /// **'My Habits'**
  String get myHabits;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @backupAndRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupAndRestore;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @archivedHabits.
  ///
  /// In en, this message translates to:
  /// **'Archived Habits'**
  String get archivedHabits;

  /// No description provided for @habitName.
  ///
  /// In en, this message translates to:
  /// **'Habit Name'**
  String get habitName;

  /// No description provided for @enterHabitName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a habit name'**
  String get enterHabitName;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select a color'**
  String get selectColor;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'SELECT'**
  String get select;

  /// No description provided for @everyday.
  ///
  /// In en, this message translates to:
  /// **'Everyday'**
  String get everyday;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @createHabit.
  ///
  /// In en, this message translates to:
  /// **'CREATE HABIT'**
  String get createHabit;

  /// No description provided for @createNewHabit.
  ///
  /// In en, this message translates to:
  /// **'Create New Habit'**
  String get createNewHabit;

  /// No description provided for @editHabit.
  ///
  /// In en, this message translates to:
  /// **'Edit Habit'**
  String get editHabit;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get saveChanges;

  /// No description provided for @deleteHabit.
  ///
  /// In en, this message translates to:
  /// **'Delete Habit?'**
  String get deleteHabit;

  /// No description provided for @deleteHabitConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{habitName}\"? This action cannot be undone.'**
  String deleteHabitConfirmation(String habitName);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get delete;

  /// No description provided for @createdOn.
  ///
  /// In en, this message translates to:
  /// **'Created on: {date}'**
  String createdOn(String date);

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @totalCompletions.
  ///
  /// In en, this message translates to:
  /// **'Total Completions'**
  String get totalCompletions;

  /// No description provided for @progressCharts.
  ///
  /// In en, this message translates to:
  /// **'Progress Charts:'**
  String get progressCharts;

  /// No description provided for @statsDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get statsDays;

  /// No description provided for @statsTimes.
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get statsTimes;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @jan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get jan;

  /// No description provided for @feb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get feb;

  /// No description provided for @mar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get mar;

  /// No description provided for @apr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get apr;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @jun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get jun;

  /// No description provided for @jul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get jul;

  /// No description provided for @aug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get aug;

  /// No description provided for @sep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get sep;

  /// No description provided for @oct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get oct;

  /// No description provided for @nov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get nov;

  /// No description provided for @dec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get dec;

  /// No description provided for @weekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get weekdays;

  /// No description provided for @weekends.
  ///
  /// In en, this message translates to:
  /// **'Weekends'**
  String get weekends;

  /// No description provided for @successRate.
  ///
  /// In en, this message translates to:
  /// **'Success Rate'**
  String get successRate;

  /// No description provided for @frequencyLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Frequency (Last 7 Days)'**
  String get frequencyLast7Days;

  /// No description provided for @habitStrengthLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Frequency of doing the habit (Last 30 Days)'**
  String get habitStrengthLast30Days;

  /// No description provided for @cannotSkipCompleted.
  ///
  /// In en, this message translates to:
  /// **'Cannot skip a completed day.'**
  String get cannotSkipCompleted;

  /// No description provided for @skipDay.
  ///
  /// In en, this message translates to:
  /// **'Skip Day'**
  String get skipDay;

  /// No description provided for @unskipDay.
  ///
  /// In en, this message translates to:
  /// **'Un-skip Day'**
  String get unskipDay;

  /// No description provided for @confirmSkip.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to mark this day as skipped? This will not break your streak.'**
  String get confirmSkip;

  /// No description provided for @confirmUnskip.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove the skip for this day?'**
  String get confirmUnskip;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @unskip.
  ///
  /// In en, this message translates to:
  /// **'Un-skip'**
  String get unskip;

  /// No description provided for @addNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Add New Category'**
  String get addNewCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @restoreHabit.
  ///
  /// In en, this message translates to:
  /// **'Restore Habit'**
  String get restoreHabit;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get deletePermanently;

  /// No description provided for @habitType.
  ///
  /// In en, this message translates to:
  /// **'Habit Type'**
  String get habitType;

  /// No description provided for @habitTypeYesNo.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get habitTypeYesNo;

  /// No description provided for @habitTypeNumeric.
  ///
  /// In en, this message translates to:
  /// **'Numeric'**
  String get habitTypeNumeric;

  /// No description provided for @habitTypeTimed.
  ///
  /// In en, this message translates to:
  /// **'Timed'**
  String get habitTypeTimed;

  /// No description provided for @numericUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit (e.g., pages, glasses)'**
  String get numericUnit;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @goalType.
  ///
  /// In en, this message translates to:
  /// **'Goal Type'**
  String get goalType;

  /// No description provided for @goalTypeOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get goalTypeOff;

  /// No description provided for @goalTypeTargetCount.
  ///
  /// In en, this message translates to:
  /// **'Target Count'**
  String get goalTypeTargetCount;

  /// No description provided for @targetValue.
  ///
  /// In en, this message translates to:
  /// **'Target Amount'**
  String get targetValue;

  /// No description provided for @goalPeriod.
  ///
  /// In en, this message translates to:
  /// **'Per Period'**
  String get goalPeriod;

  /// No description provided for @goalPeriodDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get goalPeriodDaily;

  /// No description provided for @goalPeriodWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get goalPeriodWeekly;

  /// No description provided for @goalPeriodMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get goalPeriodMonthly;

  /// No description provided for @goalPeriodAllTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get goalPeriodAllTime;

  /// No description provided for @enterValueFor.
  ///
  /// In en, this message translates to:
  /// **'Enter Value for {habitName}'**
  String enterValueFor(String habitName);

  /// No description provided for @valueLabel.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get valueLabel;

  /// No description provided for @timerDuration.
  ///
  /// In en, this message translates to:
  /// **'Timer Duration (minutes)'**
  String get timerDuration;

  /// No description provided for @noHabitsYet.
  ///
  /// In en, this message translates to:
  /// **'No habits yet!'**
  String get noHabitsYet;

  /// No description provided for @addFirstHabit.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first habit.'**
  String get addFirstHabit;

  /// No description provided for @noArchivedHabits.
  ///
  /// In en, this message translates to:
  /// **'You have no archived habits.'**
  String get noArchivedHabits;

  /// No description provided for @uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// No description provided for @timerTitle.
  ///
  /// In en, this message translates to:
  /// **'Timer: {habitName}'**
  String timerTitle(String habitName);

  /// No description provided for @selectDuration.
  ///
  /// In en, this message translates to:
  /// **'Select Duration (HH:MM)'**
  String get selectDuration;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get save;

  /// No description provided for @activityLog.
  ///
  /// In en, this message translates to:
  /// **'Activity Log'**
  String get activityLog;

  /// No description provided for @maxStreak.
  ///
  /// In en, this message translates to:
  /// **'Max Streak'**
  String get maxStreak;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @missed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missed;

  /// No description provided for @repeatEvery.
  ///
  /// In en, this message translates to:
  /// **'Repeat every'**
  String get repeatEvery;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories'**
  String get noCategories;

  /// No description provided for @deleteCategoryConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \'{categoryName}\'?'**
  String deleteCategoryConfirmation(String categoryName);

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get showAll;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @habitTypeHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit Types'**
  String get habitTypeHelpTitle;

  /// No description provided for @habitTypeHelpBody.
  ///
  /// In en, this message translates to:
  /// **'1. Regular: Simple Yes/No check (e.g., Wake up early)\n2. Numeric: Track a number (e.g., Drink 8 glasses)\n3. Timed: Track duration (e.g., Meditate 15 mins)'**
  String get habitTypeHelpBody;

  /// No description provided for @goalHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal Periods'**
  String get goalHelpTitle;

  /// No description provided for @goalHelpBody.
  ///
  /// In en, this message translates to:
  /// **'1. Daily: Resets every day.\n2. Weekly: Resets every Monday.\n3. Monthly: Resets on the 1st of the month.\n4. All Time: Never resets (Accumulates forever).'**
  String get goalHelpBody;

  /// No description provided for @frequencyHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequencyHelpTitle;

  /// No description provided for @frequencyHelpBody.
  ///
  /// In en, this message translates to:
  /// **'1. Daily: Everyday, Weekdays, or Weekends.\n2. Weekly: specific days (Mon-Sun).\n3. Monthly: Once a month (Select specific months).\n4. Custom: Repeat every X days (e.g. Every 2 days = Every other day).'**
  String get frequencyHelpBody;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @completeGoal.
  ///
  /// In en, this message translates to:
  /// **'Complete Goal?'**
  String get completeGoal;

  /// No description provided for @completeGoalConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Mark remaining {count} times as done to finish the goal?'**
  String completeGoalConfirmation(String count);

  /// No description provided for @chooseAction.
  ///
  /// In en, this message translates to:
  /// **'Choose Action'**
  String get chooseAction;

  /// No description provided for @markAsDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as Done'**
  String get markAsDone;

  /// No description provided for @shareExportCSV.
  ///
  /// In en, this message translates to:
  /// **'Loop Habit Tracker Export (CSV)'**
  String get shareExportCSV;

  /// No description provided for @shareBackupSQLite.
  ///
  /// In en, this message translates to:
  /// **'Loop Habit Tracker Backup (SQLite)'**
  String get shareBackupSQLite;

  /// No description provided for @loopHabitTrackerBackup.
  ///
  /// In en, this message translates to:
  /// **'Loop Habit Tracker Backup'**
  String get loopHabitTrackerBackup;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @exportToCSV.
  ///
  /// In en, this message translates to:
  /// **'Export to CSV'**
  String get exportToCSV;

  /// No description provided for @exportToSQLite.
  ///
  /// In en, this message translates to:
  /// **'Export to SQLite'**
  String get exportToSQLite;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @importFromCSV.
  ///
  /// In en, this message translates to:
  /// **'Import from CSV'**
  String get importFromCSV;

  /// No description provided for @importFromSQLite.
  ///
  /// In en, this message translates to:
  /// **'Import from SQLite'**
  String get importFromSQLite;

  /// No description provided for @backupHistory.
  ///
  /// In en, this message translates to:
  /// **'Backup History'**
  String get backupHistory;

  /// No description provided for @noBackupFilesFound.
  ///
  /// In en, this message translates to:
  /// **'No backup files found.'**
  String get noBackupFilesFound;

  /// No description provided for @statisticsOverview.
  ///
  /// In en, this message translates to:
  /// **'Statistics Overview'**
  String get statisticsOverview;

  /// No description provided for @overallSummary.
  ///
  /// In en, this message translates to:
  /// **'Overall Summary'**
  String get overallSummary;

  /// No description provided for @totalHabits.
  ///
  /// In en, this message translates to:
  /// **'Total Habits'**
  String get totalHabits;

  /// No description provided for @noHabitsToRank.
  ///
  /// In en, this message translates to:
  /// **'No habits to rank.'**
  String get noHabitsToRank;

  /// No description provided for @habitLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Habit Leaderboard'**
  String get habitLeaderboard;

  /// No description provided for @savedToDownloads.
  ///
  /// In en, this message translates to:
  /// **'Saved to Downloads folder: {path}'**
  String savedToDownloads(String path);

  /// No description provided for @exportSuccessSharing.
  ///
  /// In en, this message translates to:
  /// **'Exported successfully. Sharing...'**
  String get exportSuccessSharing;

  /// No description provided for @errorExportingCSV.
  ///
  /// In en, this message translates to:
  /// **'Error exporting to CSV: {error}'**
  String errorExportingCSV(String error);

  /// No description provided for @errorExportingSQLite.
  ///
  /// In en, this message translates to:
  /// **'Error exporting to SQLite: {error}'**
  String errorExportingSQLite(String error);

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Import successful.'**
  String get importSuccess;

  /// No description provided for @errorImportingCSV.
  ///
  /// In en, this message translates to:
  /// **'Error importing from CSV: {error}'**
  String errorImportingCSV(String error);

  /// No description provided for @errorImportingSQLite.
  ///
  /// In en, this message translates to:
  /// **'Error importing from SQLite: {error}'**
  String errorImportingSQLite(String error);

  /// No description provided for @timeToCompleteHabit.
  ///
  /// In en, this message translates to:
  /// **'It\'s time to complete {habitName}'**
  String timeToCompleteHabit(String habitName);

  /// No description provided for @colorScheme.
  ///
  /// In en, this message translates to:
  /// **'Color Scheme'**
  String get colorScheme;

  /// No description provided for @selectColorScheme.
  ///
  /// In en, this message translates to:
  /// **'Select Color Scheme'**
  String get selectColorScheme;

  /// No description provided for @dailyRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders at 8 AM & 8 PM'**
  String get dailyRemindersSubtitle;

  /// No description provided for @dailyRemindersEnabledMessage.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders enabled for 8:00 AM & 8:00 PM'**
  String get dailyRemindersEnabledMessage;

  /// No description provided for @morningGreetingTitle.
  ///
  /// In en, this message translates to:
  /// **'Good Morning! ☀️'**
  String get morningGreetingTitle;

  /// No description provided for @morningGreetingBody.
  ///
  /// In en, this message translates to:
  /// **'Time to check your habits and start the day strong.'**
  String get morningGreetingBody;

  /// No description provided for @eveningGreetingTitle.
  ///
  /// In en, this message translates to:
  /// **'Good Evening! 🌙'**
  String get eveningGreetingTitle;

  /// No description provided for @eveningGreetingBody.
  ///
  /// In en, this message translates to:
  /// **'Have you completed your habits for today? Don\'t break the streak!'**
  String get eveningGreetingBody;

  /// No description provided for @statsExplanationTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics Explained'**
  String get statsExplanationTitle;

  /// No description provided for @statsExplanationBody.
  ///
  /// In en, this message translates to:
  /// **'1. Total Habits: The number of habits being tracked.\n2. Total Completions: The total number of days all habits have been completed.\n3. Habit Score: A score based on consistency and streaks.\n4. Leaderboard: Ranks your habits by their success score.'**
  String get statsExplanationBody;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @heatmap.
  ///
  /// In en, this message translates to:
  /// **'Heatmap'**
  String get heatmap;

  /// No description provided for @heatmapTimeRange.
  ///
  /// In en, this message translates to:
  /// **'Last 3 Months'**
  String get heatmapTimeRange;

  /// No description provided for @heatmapLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get heatmapLess;

  /// No description provided for @heatmapMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get heatmapMore;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @sortDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get sortDefault;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get sortOldest;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit Note'**
  String get editNote;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Enter note here...'**
  String get noteHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'th':
      return AppLocalizationsTh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

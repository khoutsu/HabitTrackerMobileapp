// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get myHabits => 'กิจวัตรของฉัน';

  @override
  String get settings => 'ตั้งค่า';

  @override
  String get backupAndRestore => 'สำรองและกู้คืนข้อมูล';

  @override
  String get theme => 'ธีม';

  @override
  String get language => 'ภาษา';

  @override
  String get notifications => 'การแจ้งเตือน';

  @override
  String get about => 'เกี่ยวกับ';

  @override
  String get statistics => 'สถิติ';

  @override
  String get archivedHabits => 'คลังกิจวัตร';

  @override
  String get habitName => 'ชื่อกิจวัตร';

  @override
  String get enterHabitName => 'กรุณากรอกชื่อกิจวัตร';

  @override
  String get descriptionOptional => 'รายละเอียด (ไม่บังคับ)';

  @override
  String get color => 'สี';

  @override
  String get selectColor => 'เลือกสี';

  @override
  String get select => 'เลือก';

  @override
  String get everyday => 'ทุกวัน';

  @override
  String get daily => 'รายวัน';

  @override
  String get weekly => 'รายสัปดาห์';

  @override
  String get monthly => 'รายเดือน';

  @override
  String get custom => 'กำหนดเอง';

  @override
  String get createHabit => 'สร้างกิจวัตร';

  @override
  String get createNewHabit => 'สร้างกิจวัตรใหม่';

  @override
  String get editHabit => 'แก้ไขกิจวัตร';

  @override
  String get saveChanges => 'บันทึกการเปลี่ยนแปลง';

  @override
  String get deleteHabit => 'ลบกิจวัตร?';

  @override
  String deleteHabitConfirmation(String habitName) {
    return 'คุณแน่ใจหรือไม่ว่าต้องการลบ \"$habitName\"? การกระทำนี้ไม่สามารถย้อนกลับได้';
  }

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get delete => 'ลบ';

  @override
  String createdOn(String date) {
    return 'สร้างเมื่อ: $date';
  }

  @override
  String get currentStreak => 'สถิติต่อเนื่องปัจจุบัน';

  @override
  String get totalCompletions => 'ทำสำเร็จทั้งหมด';

  @override
  String get progressCharts => 'กราฟความคืบหน้า:';

  @override
  String get statsDays => 'วัน';

  @override
  String get statsTimes => 'ครั้ง';

  @override
  String get mon => 'จ';

  @override
  String get tue => 'อ';

  @override
  String get wed => 'พ';

  @override
  String get thu => 'พฤ';

  @override
  String get fri => 'ศ';

  @override
  String get sat => 'ส';

  @override
  String get sun => 'อา';

  @override
  String get jan => 'ม.ค';

  @override
  String get feb => 'ก.พ';

  @override
  String get mar => 'มี.ค';

  @override
  String get apr => 'เม.ย';

  @override
  String get may => 'พ.ค';

  @override
  String get jun => 'มิ.ย';

  @override
  String get jul => 'ก.ค';

  @override
  String get aug => 'ส.ค';

  @override
  String get sep => 'ก.ย';

  @override
  String get oct => 'ต.ค';

  @override
  String get nov => 'พ.ย';

  @override
  String get dec => 'ธ.ค';

  @override
  String get weekdays => 'วันธรรมดา';

  @override
  String get weekends => 'วันหยุดสุดสัปดาห์';

  @override
  String get successRate => 'อัตราความสำเร็จ';

  @override
  String get frequencyLast7Days => 'ความถี่ (7 วันล่าสุด)';

  @override
  String get habitStrengthLast30Days => 'ความถี่ในการทำกิจวัตร (30 วันล่าสุด)';

  @override
  String get cannotSkipCompleted => 'ไม่สามารถข้ามวันที่ทำสำเร็จแล้ว';

  @override
  String get skipDay => 'ข้ามวัน';

  @override
  String get unskipDay => 'ยกเลิกการข้าม';

  @override
  String get confirmSkip =>
      'คุณแน่ใจหรือไม่ว่าต้องการข้ามวันนี้? การทำเช่นนี้จะไม่ส่งผลต่อสถิติของคุณ';

  @override
  String get confirmUnskip =>
      'คุณแน่ใจหรือไม่ว่าต้องการยกเลิกการข้ามสำหรับวันนี้?';

  @override
  String get skip => 'ข้าม';

  @override
  String get unskip => 'ยกเลิกการข้าม';

  @override
  String get addNewCategory => 'เพิ่มหมวดหมู่ใหม่';

  @override
  String get categoryName => 'ชื่อหมวดหมู่';

  @override
  String get add => 'เพิ่ม';

  @override
  String get categories => 'หมวดหมู่';

  @override
  String get edit => 'แก้ไข';

  @override
  String get archive => 'เก็บเข้าคลัง';

  @override
  String get restoreHabit => 'กู้คืนกิจวัตร';

  @override
  String get deletePermanently => 'ลบอย่างถาวร';

  @override
  String get habitType => 'ประเภทของกิจวัตร';

  @override
  String get habitTypeYesNo => 'ทั่วไป';

  @override
  String get habitTypeNumeric => 'ระบุจำนวน';

  @override
  String get habitTypeTimed => 'จับเวลา';

  @override
  String get numericUnit => 'หน่วย (เช่น หน้า, แก้ว)';

  @override
  String get goal => 'เป้าหมาย';

  @override
  String get goalType => 'ประเภทเป้าหมาย';

  @override
  String get goalTypeOff => 'ปิด';

  @override
  String get goalTypeTargetCount => 'จำนวนครั้ง';

  @override
  String get targetValue => 'จำนวนที่ต้องทำ';

  @override
  String get goalPeriod => 'ต่อระยะเวลา';

  @override
  String get goalPeriodDaily => 'รายวัน';

  @override
  String get goalPeriodWeekly => 'รายสัปดาห์';

  @override
  String get goalPeriodMonthly => 'รายเดือน';

  @override
  String get goalPeriodAllTime => 'ทั้งหมด';

  @override
  String enterValueFor(String habitName) {
    return 'ระบุจำนวนสำหรับ $habitName';
  }

  @override
  String get valueLabel => 'จำนวน';

  @override
  String get timerDuration => 'ระยะเวลาจับเวลา (นาที)';

  @override
  String get noHabitsYet => 'ยังไม่มีกิจวัตร!';

  @override
  String get addFirstHabit => 'แตะปุ่ม + เพื่อเพิ่มกิจวัตรแรกของคุณ';

  @override
  String get noArchivedHabits => 'คุณไม่มีกิจวัตรที่เก็บเข้าคลัง';

  @override
  String get uncategorized => 'ไม่มีหมวดหมู่';

  @override
  String timerTitle(String habitName) {
    return 'จับเวลา: $habitName';
  }

  @override
  String get selectDuration => 'เลือกระยะเวลา (ชม:นาที)';

  @override
  String get save => 'บันทึก';

  @override
  String get activityLog => 'บันทึกกิจกรรม';

  @override
  String get maxStreak => 'ทำต่อเนื่องสูงสุด';

  @override
  String get success => 'สำเร็จ';

  @override
  String get missed => 'พลาด';

  @override
  String get repeatEvery => 'ทำซ้ำทุกๆ';

  @override
  String get days => 'วัน';

  @override
  String get noCategories => 'ไม่มีหมวดหมู่';

  @override
  String deleteCategoryConfirmation(String categoryName) {
    return 'คุณแน่ใจหรือไม่ว่าต้องการลบ \'$categoryName\'?';
  }

  @override
  String get showAll => 'แสดงทั้งหมด';

  @override
  String get showLess => 'แสดงน้อยลง';

  @override
  String get habitTypeHelpTitle => 'ประเภทของกิจวัตร';

  @override
  String get habitTypeHelpBody =>
      '1. ทั่วไป (Regular): แค่เช็คว่าทำหรือไม่ทำ (เช่น ตื่นเช้า)\n2. ระบุจำนวน (Numeric): ใส่ค่าตัวเลข (เช่น ดื่มน้ำ 8 แก้ว)\n3. จับเวลา (Timed): จับเวลาที่ทำ (เช่น นั่งสมาธิ 15 นาที)';

  @override
  String get goalHelpTitle => 'ระยะเวลาของเป้าหมาย';

  @override
  String get goalHelpBody =>
      '1. รายวัน: รีเซ็ตยอดทุกวัน (เช่น ต้องทำทุกวัน)\n2. รายสัปดาห์: รีเซ็ตทุกวันจันทร์ (เหมาะสำหรับทำสะสมในวีค)\n3. รายเดือน: รีเซ็ตทุกต้นเดือน\n4. ทั้งหมด: ไม่มีการรีเซ็ต (สะสมยอดไปเรื่อยๆ จนครบ)';

  @override
  String get frequencyHelpTitle => 'ความถี่ (Frequency)';

  @override
  String get frequencyHelpBody =>
      '1. รายวัน: เลือกทำทุกวัน หรือ วันธรรมดา/เสาร์อาทิตย์\n2. รายสัปดาห์: เลือกวันเองระบุวัน (จันทร์ - อาทิตย์)\n3. รายเดือน: ทำเดือนละ 1 ครั้ง (ระบุเดือนที่จะทำได้)\n4. กำหนดเอง: ทำซ้ำทุกๆ X วัน (เช่น ทุก 2 วัน คือทำวันเว้นวัน)';

  @override
  String get all => 'ทั้งหมด';

  @override
  String get completeGoal => 'ทำเป้าหมายให้สำเร็จทันที?';

  @override
  String completeGoalConfirmation(String count) {
    return 'ต้องการบันทึกว่าทำอีก $count ครั้ง เพื่อให้ครบเป้าหมายเลยหรือไม่?';
  }

  @override
  String get chooseAction => 'เลือกการกระทำ';

  @override
  String get markAsDone => 'ทำเครื่องหมายว่าเสร็จ';

  @override
  String get shareExportCSV => 'ส่งออกข้อมูล Loop Habit Tracker (CSV)';

  @override
  String get shareBackupSQLite => 'สำรองข้อมูล Loop Habit Tracker (SQLite)';

  @override
  String get loopHabitTrackerBackup => 'การสำรองข้อมูล Loop Habit Tracker';

  @override
  String get reminders => 'การแจ้งเตือน';

  @override
  String get reminderTime => 'เวลาแจ้งเตือน';

  @override
  String get exportData => 'ส่งออกข้อมูล';

  @override
  String get exportToCSV => 'ส่งออกเป็น CSV';

  @override
  String get exportToSQLite => 'ส่งออกเป็น SQLite';

  @override
  String get importData => 'นำเข้าข้อมูล';

  @override
  String get importFromCSV => 'นำเข้าจาก CSV';

  @override
  String get importFromSQLite => 'นำเข้าจาก SQLite';

  @override
  String get backupHistory => 'ประวัติการสำรองข้อมูล';

  @override
  String get noBackupFilesFound => 'ไม่พบไฟล์สำรองข้อมูล';

  @override
  String get statisticsOverview => 'ภาพรวมสถิติ';

  @override
  String get overallSummary => 'สรุปผลรวม';

  @override
  String get totalHabits => 'กิจวัตรทั้งหมด';

  @override
  String get noHabitsToRank => 'ไม่มีข้อมูลกิจวัตรสำหรับจัดอันดับ';

  @override
  String get habitLeaderboard => 'อันดับทำสูงสุด';

  @override
  String savedToDownloads(String path) {
    return 'บันทึกไปยังโฟลเดอร์ดาวน์โหลด: $path';
  }

  @override
  String get exportSuccessSharing => 'ส่งออกสำเร็จ กำลังแชร์...';

  @override
  String errorExportingCSV(String error) {
    return 'เกิดข้อผิดพลาดในการส่งออก CSV: $error';
  }

  @override
  String errorExportingSQLite(String error) {
    return 'เกิดข้อผิดพลาดในการส่งออก SQLite: $error';
  }

  @override
  String get importSuccess => 'นำเข้าข้อมูลสำเร็จ';

  @override
  String errorImportingCSV(String error) {
    return 'เกิดข้อผิดพลาดในการนำเข้าจาก CSV: $error';
  }

  @override
  String errorImportingSQLite(String error) {
    return 'เกิดข้อผิดพลาดในการนำเข้าจาก SQLite: $error';
  }

  @override
  String timeToCompleteHabit(String habitName) {
    return 'ได้เวลาทำนิสัย $habitName แล้ว';
  }

  @override
  String get colorScheme => 'ชุดสี';

  @override
  String get selectColorScheme => 'เลือกชุดสี';

  @override
  String get dailyRemindersSubtitle => 'แจ้งเตือนรายวันเวลา 8:00 และ 20:00 น.';

  @override
  String get dailyRemindersEnabledMessage =>
      'เปิดการแจ้งเตือนรายวันแล้ว (08:00 และ 20:00 น.)';

  @override
  String get morningGreetingTitle => 'สวัสดีตอนเช้า! ☀️';

  @override
  String get morningGreetingBody =>
      'ได้เวลาตรวจสอบกิจวัตร และเริ่มต้นวันใหม่อย่างสดใส';

  @override
  String get eveningGreetingTitle => 'สวัสดีตอนค่ำ! 🌙';

  @override
  String get eveningGreetingBody =>
      'ทำกิจวัตรของวันนี้ครบหรือยัง? รักษาสถิติต่อไปนะ!';

  @override
  String get statsExplanationTitle => 'คำอธิบายสถิติ';

  @override
  String get statsExplanationBody =>
      'หน้านี้แสดงภาพรวมความก้าวหน้าของคุณ โดยเริ่มจากจำนวนกิจวัตรทั้งหมดที่คุณกำลังฝึกฝน และยอดรวมครั้งที่ทำสำเร็จทั้งหมด (Total Completions) ส่วนคะแนนความสำเร็จนั้นคำนวณเป็นเปอร์เซ็นต์จากความสม่ำเสมอของคุณ (วันที่ทำได้จริงหารด้วยวันที่ต้องทำทั้งหมด) และเราได้จัดอันดับ (Leaderboard) เพื่อให้คุณเห็นว่ากิจวัตรไหนที่คุณทำได้ดีที่สุด';

  @override
  String get close => 'ปิด';

  @override
  String get score => 'คะแนน';

  @override
  String get streak => 'ทำต่อเนื่อง';

  @override
  String get hours => 'ชั่วโมง';

  @override
  String get minutes => 'นาที';

  @override
  String get heatmap => 'ตารางความถี่';

  @override
  String get heatmapTimeRange => '3 เดือนล่าสุด';

  @override
  String get heatmapLess => 'น้อย';

  @override
  String get heatmapMore => 'มาก';

  @override
  String get sort => 'เรียงลำดับ';

  @override
  String get sortDefault => 'ค่าเริ่มต้น';

  @override
  String get sortNewest => 'ใหม่ล่าสุด';

  @override
  String get sortOldest => 'เก่าที่สุด';

  @override
  String get sortStreak => 'เรียงตาม Streak';

  @override
  String get addNote => 'เพิ่มโน้ต';

  @override
  String get editNote => 'แก้ไขโน้ต';

  @override
  String get noteHint => 'ใส่ข้อความ...';
}

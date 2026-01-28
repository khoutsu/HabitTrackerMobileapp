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
  String get archivedHabits => 'กิจวัตรที่เก็บถาวร';

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
  String get habitStrengthLast30Days =>
      'ความแข็งแกร่งของกิจวัตร (30 วันล่าสุด)';

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
  String get archive => 'เก็บถาวร';

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
  String get noArchivedHabits => 'คุณไม่มีกิจวัตรที่เก็บถาวร';

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
}

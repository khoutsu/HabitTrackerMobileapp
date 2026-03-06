# Report (ธันวาคม 2568 - กุมภาพันธ์ 2569)

## ธันวาคม 2568

**16 ธ.ค. 68**

- เริ่มต้นโปรเจกต์ (Project Initialization) และวางโครงสร้าง Clean Architecture (Domain, Data, Presentation)
- **องค์ความรู้:** โครงสร้าง Clean Architecture และการจัดระเบียบ Folder ใน Flutter

**17 ธ.ค. 68**

- ตั้งค่า Environment และ Dependencies หลัก (Flutter SDK, Provider, GetIt, GoRouter)
- **องค์ความรู้:** การใช้ Dependency Injection (GetIt) และ Routing (GoRouter)

**18 ธ.ค. 68**

- ออกแบบ UI/UX เบื้องต้น (Wireframe) ของหน้า Home และหน้าสร้างนิสัย
- **องค์ความรู้:** หลักการออกแบบ User Interface พื้นฐานสำหรับแอปมือถือ

**19 ธ.ค. 68**

- เริ่มต้นสร้าง Widget พื้นฐานและ Theme ของแอปพลิเคชัน
- **องค์ความรู้:** การจัดการ ThemeData และ Custom Widgets

**23 ธ.ค. 68**

- พัฒนาระบบฐานข้อมูล Local Storage ด้วย SQLite
- **องค์ความรู้:** การใช้งาน Library `sqflite` และคำสั่ง SQL เบื้องต้น

**24 ธ.ค. 68**

- สร้าง Entity และ Model สำหรับเก็บข้อมูลนิสัย (Habit)
- **องค์ความรู้:** การางแปลงข้อมูลระหว่ Dart Object และ Map (Serialization)

**25 ธ.ค. 68**

- สร้าง Entity และ Model สำหรับเก็บข้อมูลประวัติการทำ (Records)
- **องค์ความรู้:** การออกแบบ Database Schema และ Relationships

**26 ธ.ค. 68**

- เชื่อมต่อ Repository layer กับ Database ให้สมบูรณ์
- **องค์ความรู้:** การใช้ Repository Pattern เพื่อแยก Logic การเข้าถึงข้อมูล

**29 ธ.ค. 68**

- เริ่มออกแบบและพัฒนาหน้าแก้ไขนิสัย (Edit Habit Screen)
- **องค์ความรู้:** การส่งข้อมูลระหว่างหน้า (Data Passing) และการจัดการ Form State

**30 ธ.ค. 68**

- ทดสอบระบบและแก้ไขบั๊กเล็กน้อยก่อนหยุดปีใหม่
- **องค์ความรู้:** การ Debugging เบื้องต้นและการตรวจสอบ Log

## มกราคม 2569

**5 ม.ค. 69**

- พัฒนาหน้า Home Screen แสดงรายการนิสัยแบบ List
- **องค์ความรู้:** การใช้ ListView.builder และ StatelessWidget/StatefulWidget

**6 ม.ค. 69**

- Implement ฟังก์ชัน Check-in/Check-out นิสัยในแต่ละวัน
- **องค์ความรู้:** การจัดการ State เบื้องต้นเมื่อมีการกด Checkbox

**7 ม.ค. 69**

- เพิ่มระบบ CRUD (Create, Read, Update, Delete) สำหรับจัดการนิสัยพื้นฐาน
- **องค์ความรู้:** การส่งข้อมูลผ่าน Form, Validation และการจัดการ Dialog

**8 ม.ค. 69**

- เริ่มพัฒนาหน้าสถิติ (Statistics Screen) แสดงกราฟความถี่ (Frequency)
- **องค์ความรู้:** การใช้งาน Library กราฟ (เช่น fl_chart) แสดงข้อมูล

**9 ม.ค. 69**

- สร้าง Widget ปฏิทิน (Calendar) และปรับปรุง Logic การคำนวณ Streak
- **องค์ความรู้:** การคำนวณวันและเวลา (DateTime logic) เพื่อหา Streak

_(12-15 ม.ค. หยุดงาน)_

**16 ม.ค. 69**

- ติดตั้งและตั้งค่าระบบ Localization รองรับ 2 ภาษา (ไทย/อังกฤษ) และปรับปรุง Theme
- **องค์ความรู้:** การทำ Internationalization (.arb files) และ Dark Mode

_(19-20 ม.ค. หยุดงาน)_

**21 ม.ค. 69**

- Refactor Code ส่วนจัดการ State ให้มีประสิทธิภาพมากขึ้น
- **องค์ความรู้:** การใช้ Provider เพื่อจัดการ App State อย่างมีประสิทธิภาพ

**22 ม.ค. 69**

- แก้ไขบั๊กการแสดงผล UI บนหน้าจอขนาดเล็ก
- **องค์ความรู้:** Responsive Design และการใช้ LayoutBuilder

**23 ม.ค. 69**

- เตรียมความพร้อมระบบ Export ข้อมูลเบื้องต้น
- **องค์ความรู้:** การเข้าถึง File System บน Android/iOS (path_provider)

**26 ม.ค. 69**

- ตรวจสอบความถูกต้องของ Business Logic และ Unit Test เบื้องต้น
- **องค์ความรู้:** แนวทางการเขียน Unit Test พื้นฐานใน Flutter

**27 ม.ค. 69**

- แก้ไขปัญหา Dependency และตั้งค่า Emulator (LDPlayer)
- **องค์ความรู้:** การตั้งค่า Android Environment และการใช้ ADB

**28 ม.ค. 69**

- ปรับปรุง UI หน้าสร้างนิสัยให้เข้าใจง่ายขึ้น (Goal Period, Habit Type)
- **องค์ความรู้:** UX Writing เขียนข้อความให้ผู้ใช้เข้าใจง่าย

**29 ม.ค. 69**

- แก้ไขปัญหา Permission ในการ Push Code ขึ้น Git Repository
- **องค์ความรู้:** การจัดการ Git Permission และ SSH Keys

_(30 ม.ค. - 9 ก.พ. หยุดงาน)_

## กุมภาพันธ์ 2569

**10 ก.พ. 69**

- ปรับปรุงระบบ Export/Import CSV และแก้บั๊กกราฟ
- **องค์ความรู้:** การ Parsing CSV และการคำนวณ Data Visualization

**11 ก.พ. 69**

- ลบฟีเจอร์แจ้งเตือนและ Clean Code
- **องค์ความรู้:** เทคนิค Refactoring และการลบ Dead Code

**12 ก.พ. 69**

- เพิ่มปุ่ม Info และ Localization คำอธิบายสถิติ
- **องค์ความรู้:** การทำ UI/UX เพื่อให้ความรู้ผู้ใช้ (Onboarding elements)

**13 ก.พ. 69**

- Redesign หน้า Settings และปรับปรุง Heatmap
- **องค์ความรู้:** การออกแบบ UI สมัยใหม่ (Card/Glassmorphism) และการจัด Layout ขั้นสูง

**16 ก.พ. 69**

- เริ่มแผนงานพัฒนาฟีเจอร์การแจ้งเตือน (Notifications) และเตรียมการเชื่อมต่อ Firebase
- **องค์ความรู้:** การออกแบบระบบการแจ้งเตือนและการเชื่อมต่อแอปพลิเคชันภายนอก

**17 ก.พ. 69**

- กำหนดค่าคงที่ (Constants) สำหรับระบบแจ้งเตือน และโครงสร้างข้อมูลเบื้องต้น
- **องค์ความรู้:** การจัดการ Notification Channel และ Configuration Mapping

**18 ก.พ. 69**

- ติดตั้ง Dependencies สำคัญ (Firebase Core, Messaging, RxDart, ScreenUtil) และตั้งค่าโปรเจกต์
- **องค์ความรู้:** การตั้งค่า Firebase Messaging (FCM) และการใช้งาน ScreenUtil เพื่อรองรับหลายขนาดหน้าจอ

**19 ก.พ. 69**

- พัฒนาระบบจัดเรียงลำดับนิสัย (Sorting) และปรับปรุง Habit Model ให้รองรับการทำงาน
- **องค์ความรู้:** การจัดการข้อมูลลำดับ (Sort Order) ในฐานข้อมูลและการขยายขีดความสามารถของ Model

**20 ก.พ. 69**

- พัฒนาระบบบันทึกข้อความ (Note) และเปลี่ยน Habit List เป็นแบบ Reorderable (ลากวาง)
- **องค์ความรู้:** การใช้งาน ReorderableListView และการทำ Schema Migration สำหรับ SQLite

_(21-22 ก.พ. 69 หยุดงาน)_

**23 ก.พ. 69**

- พัฒนา FCM Service, การสลับภาษา (Localization), ระบบธีม และ Onboarding Screen
- **องค์ความรู้:** การจัดการ Background Message, ระบบ Internationalization และการออกแบบ User Onboarding Flow

# Flow การทำงานของระบบ Loop Habit Tracker

แผนภาพ Flowchart ด้านล่างแสดงกระบวนการทำงานหลักของแอปพลิเคชัน โดยแบ่งออกเป็น 2 ส่วนหลักที่สำคัญ คือ **การทำงานของผู้ใช้งาน (User Flow)** ในแอปพลิเคชัน และ **การทำงานของระบบแจ้งเตือน (Notification Flow)** ซึ่งสอดคล้องกับฟีเจอร์หลักที่เราพัฒนาไว้ครับ

## 1. การทำงานของผู้ใช้งานและแอปพลิเคชัน (User & Application Flow)

แสดงขั้นตอนตั้งแต่ผู้ใช้งานเปิดแอปพลิเคชัน การจัดการนิสัยประจำวัน และการบันทึกข้อมูล

```mermaid
graph TD
    classDef default fill:#f9f9f9,stroke:#333,stroke-width:1px;
    classDef startEnd fill:#fff,stroke:#333,stroke-width:1px;

    subgraph UserFlow ["ผู้ใช้งานแอปพลิเคชัน (User Flow)"]
        direction TB
        Start(((Start))) --> OpenApp[เปิดเข้าสู่แอปพลิเคชัน]
        OpenApp --> ViewHome[แสดงหน้ารายการนิสัยประจำวัน]

        ViewHome --> ActionDecision{"ประเภทการจัดการ\nที่ผู้ใช้งานต้องการ?"}

        %% Action 1: Create Habit
        ActionDecision -->|เพิ่มนิสัยใหม่| InputData[/กรอกข้อมูลการสร้างหัวข้อ\n(ชื่อ, เวลา, ความถี่)/]
        InputData --> SaveData[ระบบตรวจสอบและบันทึกข้อมูลนิสัย]
        SaveData --> BackToHome[กลับสู่หน้าจอหลัก]

        %% Action 2: Check-in Habit
        ActionDecision -->|บันทึกการทำกิจกรรม| CheckIn[/ผู้ใช้กด Check-in นิสัย/]
        CheckIn --> IsCompleted{"ทำสำเร็จตาม\nเป้าหมายหรือไม่?"}

        IsCompleted -->|ใช่| UpdateSuccess[ระบบอัปเดตจำนวนและคำนวณ Streak]
        IsCompleted -->|ไม่ใช่| UpdateFail[ผู้ใช้ยกเลิกการ Check-in]

        UpdateSuccess --> UpdateUI[ระบบอัปเดตและแสดงสถิติใหม่]
        UpdateFail --> UpdateUI
        UpdateUI --> BackToHome

        BackToHome --> Finish(((End)))
    end
```

## 2. การทำงานของระบบแจ้งเตือน (FCM Notification Flow)

แสดงขั้นตอนที่ระบบเกี่ยวข้องกับการแจ้งเตือน (สอดคล้องกับที่มีการตั้งค่า FCM)

```mermaid
graph TD
    classDef default fill:#f9f9f9,stroke:#333,stroke-width:1px;
    classDef startEnd fill:#fff,stroke:#333,stroke-width:1px;

    subgraph SystemFlow ["ระบบแจ้งเตือนและ FCM (System)"]
        direction TB
        SysStart(((Start))) --> Trigger[ระบบทำงาน/ตรวจสอบเวลา]

        Trigger --> CheckTime{"ถึงเวลาแจ้งเตือน\nตามที่ผู้ใช้ตั้งไว้หรือไม่?"}

        CheckTime -->|ยังไม่ถึงเวลา| LoopCheck[ระบบรอรอบตรวจสอบถัดไป]
        LoopCheck --> EndLoop[กลับไปทำงานเบื้องหลัง]

        CheckTime -->|ถึงเวลา| SendReq[ส่งข้อมูลไปยัง Firebase Cloud Messaging (FCM)]

        SendReq --> ReceiveFCM[แอปพลิเคชันรับสัญญาณ Notification]
        ReceiveFCM --> AppState{"ผู้ใช้เปิดแอปค้างไว้หรือไม่?"}

        AppState -->|ใช่ (Foreground)| ShowInApp[แสดง UI แจ้งเตือนแบบ In-app]
        AppState -->|ไม่ใช่ (Background)| ShowPush[เครื่องแสดง Push Notification]

        ShowInApp --> SysEnd(((End)))
        ShowPush --> SysEnd
        EndLoop --> SysEnd
    end
```

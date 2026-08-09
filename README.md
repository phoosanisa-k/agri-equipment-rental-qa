# ระบบเว็บศูนย์กลางให้บริการเช่าอุปกรณ์ทางการเกษตร - QA Automation

🚧 **สถานะ: อยู่ระหว่างพัฒนา**

โปรเจคทดสอบซอฟต์แวร์ (Software Testing) สำหรับระบบเว็บศูนย์กลางให้บริการเช่าอุปกรณ์ทางการเกษตร
โดยใช้ Robot Framework ร่วมกับ Playwright (Browser Library) ในการทำ Automated Testing

จัดทำโดยนักศึกษาสาขาวิชาเทคโนโลยีสารสนเทศ คณะวิทยาศาสตร์ มหาวิทยาลัยแม่โจ้

## ขอบเขตการทดสอบ (Scope)

- Black Box Testing ตามมาตรฐาน IEEE 829
- ออกแบบกรณีทดสอบด้วยตาราง ECTC (Equivalence Class Test Case)
  ร่วมกับเทคนิค Boundary Value Analysis (BVA)
- ทดสอบฟังก์ชันการทำงานหลักของระบบ จำนวน 10 ยูสเคส แบ่งตามบทบาทผู้ใช้งาน ดังนี้

### Farmer (เกษตรกรผู้เช่าอุปกรณ์)

| Test Case | ฟังก์ชันที่ทดสอบ |
| --------- | -------------------------------- |
| TC01      | Login                            |
| TC02      | Register                         |
| TC03      | Add Cart                         |
| TC04      | Booking Equipment                |
| TC05      | Return Equipment                 |

### Owner (เจ้าของอุปกรณ์)

| Test Case | ฟังก์ชันที่ทดสอบ |
| --------- | -------------------------------- |
| TC01      | Login                            |
| TC02      | Register                         |
| TC03      | Add Equipment                    |
| TC04      | Approve Booking                  |
| TC05      | Update Delivery and Pick Up      |

### การทดสอบแบบ End-to-End (จำนวน 1 Flow)

การทดสอบ User Journey ของผู้ใช้งานตั้งแต่ต้นกระบวนการจนจบกระบวนการ
เพื่อยืนยันว่าทุกฟังก์ชันของระบบสามารถทำงานร่วมกันได้อย่างถูกต้องต่อเนื่อง
ในสถานการณ์การใช้งานจริง ครอบคลุมการทำงานข้ามบทบาทระหว่าง
Farmer (ผู้เช่าอุปกรณ์) และ Owner (เจ้าของอุปกรณ์) ภายใน Flow เดียว
ตั้งแต่การเข้าสู่ระบบ การเลือกและจองอุปกรณ์ การอนุมัติการจอง
ไปจนถึงการส่งมอบและคืนอุปกรณ์ ซึ่งแตกต่างจากการทดสอบรายยูสเคส
ที่ตรวจสอบความถูกต้องของแต่ละฟังก์ชันแยกกัน

## เครื่องมือที่ใช้ (Tech Stack)

- Python
- Robot Framework
- Browser Library (Playwright)
- DataDriver (Data-Driven Testing จากไฟล์ Excel)
- Visual Studio Code
- Google Chrome
- Git / GitHub

## ระบบที่นำมาทดสอบ (System Under Test)

ระบบเว็บศูนย์กลางให้บริการเช่าอุปกรณ์ทางการเกษตร
พัฒนาโดย นายธนกฤต วัฒนะ (อ้างอิงจากเอกสาร SRS เวอร์ชัน 7.0)

## เอกสารประกอบ

- [Test Plan](Docs/TESTPLAN.pdf)
- [Test Design](Docs/TESTDESIGN.pdf)
- [Test Case](Docs/TESTCASE.pdf)

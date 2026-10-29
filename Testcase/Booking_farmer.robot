*** Settings ***
Documentation     TC04 - Booking Equipment Farmer | ตรวจข้อความแจ้งเตือนรายฟิลด์ (TC04_01-16)
...               อ่านข้อมูลทุกแถวของชีต BookingEQ_Farmer ด้วย FOR loop แล้วเทียบ ActualResult กับ ExpectedResult แบบตรงกัน 100% (Should Be Equal)
...               Flow การจองจริง (TC04_F01-F05) อยู่ที่ UseCase/Usecase_Booking_farmer.robot
...               ยกเว้น TC04_04 (จองซ้ำช่วงเวลาเดิม) ที่ต้องจองให้สำเร็จ 1 ครั้งก่อน จึงคงคีย์เวิร์ด "กรณี TC04_F05" ไว้ในไฟล์นี้
Metadata          Test Data   TestData/Data.xlsx (sheet: BookingEQ_Farmer)

Resource          ../Resources/keywords.robot
Library           ExcelLibrary
Library           Collections

Suite Setup       เปิดชุดทดสอบจาก Excel    Booking
Suite Teardown    ปิดชุดทดสอบ Excel

*** Variables ***
# ---------- ที่อยู่ของไฟล์และโฟลเดอร์ ----------
${DATA_FILE}          ${CURDIR}/../TestData/Data.xlsx
${SHEET}              BookingEQ_Farmer
${USECASE}            TC04_Booking_Farmer
${SCREENSHOT_DIR}     ${CURDIR}/../Screenshot/${USECASE}

# ---------- ตำแหน่งคอลัมน์ในชีต ----------
${COL_ID}         ${2}     # คอลัมน์ B : ${TestCase}
${COL_ACTUAL}     ${8}     # คอลัมน์ H : ${ActualResult}
${COL_PF}         ${9}     # คอลัมน์ I : ${Result}
${COL_COUNT}      ${7}     # อ่านคอลัมน์ A-G

# ---------- ข้อความที่ใช้ตรวจขั้นเตรียมข้อมูล ----------
# หัวข้อบน popup เมื่อจองสำเร็จ (ตรงตามระบบจริงทุกตัวอักษร) ใช้ยืนยันการจองรอบแรกของ TC04_04 (ผ่าน "กรณี TC04_F05" ในไฟล์นี้)
${BOOK_SUCCESS}       การจองสำเร็จ!
# หัวข้อของ popup ข้อกำหนดการเช่า (เป็น <h1> ในกล่องเดียวกับปุ่ม "ยอมรับ" ไม่ใช่ SweetAlert2) ใช้อ่าน ActualResult ของแถวที่ข้อมูลถูกต้อง
${Terms_Title}        xpath=//div[.//button[contains(text(),'ยอมรับ')]]//h1
# บัญชีที่ใช้ทุกกรณี ต้องเข้าสู่ระบบก่อนจึงจะเปิดตะกร้าและจองได้ (Inter-Case Dependency กับ TC01)
# wanidasukj4646 ใช้ไม่ได้ : login แล้ว backend error "Query did not return a unique result" (username ซ้ำหลายแถวใน DB
# เพราะ Register_farmer.robot ถูกรันซ้ำหลายรอบ และ backend ไม่ปฏิเสธ username ซ้ำตอนสมัคร — เป็นบั๊กจริงตรงเคส RF01-04)
# เกษตรกรล้าง DB แล้วรัน Register ใหม่เฉพาะ TC02_001 จึงได้บัญชีสะอาด ไม่ซ้ำ (somchaikaew เดิมที่เคยโดนล็อกถาวรจาก TC01_F06
# ก็หายล็อกไปด้วยเพราะ DB ถูกล้างทั้งตาราง)
${BOOK_USERNAME}      somchaikaew
${BOOK_PASSWORD}      Somc1442!
# บัญชีเกษตรกรคนที่ 2 ใช้เฉพาะ TC04_04 : จองช่วงเวลาเดียวกับที่ ${BOOK_USERNAME} จองไว้แล้ว
# ต้องเป็นคนละคน เพราะสถานการณ์จริงคือผู้เช่ารายอื่นมาจองชนกัน (ใช้ต่อใน AB01-01 ของ Approve Booking)
${BOOK_USERNAME_2}    ${TEST_FARMER_USER}
${BOOK_PASSWORD_2}    ${TEST_FARMER_PASS}

# ---------- อุปกรณ์ที่ใช้ทดสอบ ----------
# ตาราง Test Data ของ BK01 ในเอกสารมีแค่ Start Date / End Date / Address ไม่มีคอลัมน์อุปกรณ์
# ทุกกรณีจึงใช้อุปกรณ์ชิ้นเดียวกัน กำหนดไว้ที่เดียวตรงนี้ เปลี่ยนได้โดยไม่ต้องแก้ไฟล์ Excel
#
# หน้าค้นหากรองด้วยประเภท "และ" ชื่ออุปกรณ์พร้อมกัน ถ้า dropdown ค้างอยู่ที่ประเภทอื่น ผลการค้นหาจะว่างเปล่า
# ${BOOK_EQ_TYPE} รับได้ 3 แบบ
#   AUTO         : อ่านตัวเลือกใน dropdown แล้วเลือกประเภทที่เข้าคู่กับ ${BOOK_EQ_NAME} ให้เอง (ค่าเริ่มต้น)
#   <ชื่อประเภท> : ใช้ประเภทนั้นตรง ๆ ต้องเป็นประเภทของอุปกรณ์ชิ้นนั้นจริง ๆ
#   ค่าว่าง       : ไม่กรองประเภท (เลือก "ทุกประเภท")
${BOOK_EQ_TYPE}       AUTO
${BOOK_EQ_NAME}       รถไถเดินตาม

*** Test Cases ***
Booking Equipment Farmer : ทุกกรณีทดสอบในชีต BookingEQ_Farmer
    #วนอ่านทุกแถวจาก Excel (Run = Yes) ทดสอบทีละแถว เขียนผลกลับ Excel แล้วสรุปแถวที่ไม่ผ่านตอนท้าย
    ${Total}=    นับแถวใน Excel    ${SHEET}    ${COL_ID}
    @{Failed}=   Create List

    FOR    ${Row}    IN RANGE    2    ${Total} + 1
        ${Cells}=    อ่านแถวข้อมูลจาก Excel    ${SHEET}    ${Row}    ${COL_COUNT}
        ${Run}=         Set Variable    ${Cells}[0]
        ${TestCase}=    Set Variable    ${Cells}[1]
        # แถวสรุปท้ายชีตไม่มีรหัสกรณีทดสอบ และข้ามแถวที่ไม่ได้สั่งรัน
        IF    '${TestCase}' == '${EMPTY}' or '${Run}' != 'Yes'    CONTINUE

        ${Status}    ${Detail}=    Run Keyword And Ignore Error    ทดสอบหนึ่งแถว    ${Row}    ${Cells}
        IF    '${Status}' == 'FAIL'    Append To List    ${Failed}    ${TestCase} : ${Detail}
    END

    ${FailCount}=    Get Length    ${Failed}
    IF    ${FailCount} > 0
        ${Summary}=    Catenate    SEPARATOR=\n    @{Failed}
        Fail    ไม่ผ่าน ${FailCount} กรณี:\n${Summary}
    END

*** Keywords ***
# =====================================================================
# 1. ทดสอบหนึ่งแถว
# =====================================================================

ทดสอบหนึ่งแถว
    #กรอกฟอร์ม -> เก็บข้อความที่ระบบตอบ -> เทียบ Expected แบบตรงกัน 100% -> เขียนผลลง Excel -> ปิด context
    [Arguments]    ${Row}    ${Cells}
    ${TestCase}=            Set Variable    ${Cells}[1]
    ${TestScenario}=        Set Variable    ${Cells}[2]
    ${ExpectedResult}=      Set Variable    ${Cells}[6]

    ${Data}=    Create Dictionary
    ...    EquipmentType=${BOOK_EQ_TYPE}    EquipmentName=${BOOK_EQ_NAME}
    ...    StartDate=${Cells}[3]            EndDate=${Cells}[4]            Address=${Cells}[5]
    Log    ${TestCase} : ${TestScenario} | ข้อมูลที่ใช้ทดสอบ ${Data}    level=INFO

    # ขั้นที่ 1 : กรอกฟอร์มจอง กดสั่งจอง และเก็บสิ่งที่ระบบตอบ
    # ActualResult เก็บเฉพาะข้อความที่ get text ได้จากระบบ ถ้าสคริปต์ล้มกลางทางให้เป็นค่าว่าง (สาเหตุดูใน log/report)
    ${Status}    ${Out}=    Run Keyword And Ignore Error    ทำรายการจองและเก็บข้อความ    ${TestCase}    ${Data}
    # ขั้นที่ 2 : เทียบกับ Expected แบบตรงกัน 100% ถ่ายภาพเมื่อไม่ผ่าน และเขียนผลลง Excel (keyword กลางใน keywords.robot)
    ตัดสินผลและบันทึกลง Excel    ${Status}    ${Out}    ${ExpectedResult}    ${TestCase}    ${Row}

# =====================================================================
# 2. กรอกฟอร์มจองและเก็บข้อความที่ระบบตอบ
# =====================================================================

ทำรายการจองและเก็บข้อความ
    #แยกทางตามรหัส คืนข้อความที่ระบบตอบ (ActualResult)
    #TC04_04 (IVEc2.0) ต้องมีการจองค้างอยู่ในช่วงเวลาเดียวกันก่อน จึงใช้ขั้นตอนเดียวกับ TC04_F05
    #คือจองให้สำเร็จหนึ่งครั้งเพื่อสร้างช่วงเวลาที่ถูกจองไว้ แล้วค่อยจองซ้ำ ทำให้ไม่ต้องเตรียมข้อมูลในฐานข้อมูลเอง
    [Arguments]    ${TestCase}    ${Data}
    IF    $TestCase == 'TC04_04'
        ${ActualResult}=    กรณี TC04_F05    ${Data}
    ELSE
        ${ActualResult}=    ตรวจข้อความแจ้งเตือนรายฟิลด์    ${Data}
    END
    RETURN    ${ActualResult}

ตรวจข้อความแจ้งเตือนรายฟิลด์
    #กรอกฟอร์มจองแล้วกดปุ่ม "สั่งจอง" อ่านข้อความที่ระบบแจ้ง ถ้าข้อมูลผ่านจนขึ้น popup ข้อกำหนด จะติ๊กยอมรับแล้วจองจริง
    #คืนข้อความที่ระบบตอบ (ActualResult) เช่น หัวข้อ popup "การจองสำเร็จ!" ไม่มีข้อความหรือ popup ใหม่คืนค่าว่าง
    [Arguments]    ${Data}

    เตรียมฟอร์มจอง    ${Data}
    ${Filled}=    กรอกฟอร์มจอง    ${Data}

    ${Clicked}=    Click Booking Button
    ${Result}=     อ่านผลจากระบบ    ${Filled}    ${Clicked}

    # ข้อมูลผ่านการตรวจสอบถึงขั้นข้อกำหนดแล้ว ติ๊กยอมรับและกด "ยอมรับ" แล้วอ่านหัวข้อ popup ผลการจอง (${Popup_Title})
    ${Terms}=    Is Terms Popup Shown
    IF    ${Terms}
        ${Before}=      Get Popup Title
        ${Accepted}=    Accept Booking Terms
        IF    not ${Accepted}
            Log    ปุ่ม "ยอมรับ" ถูกปิดใช้งาน จึงไม่ได้ยืนยันการจอง    level=INFO
            RETURN    ${EMPTY}
        END
        ${Result}=      รอหัวข้อ popup ใหม่    ${Before}
    END
    RETURN    ${Result}

เตรียมฟอร์มจอง
    #เข้าสู่ระบบ เพิ่มอุปกรณ์ลงตะกร้า แล้วเปิดกล่องตะกร้าที่มีฟอร์มจองอยู่ (Pre-Condition ของเอกสาร)
    [Arguments]    ${Data}    ${Username}=${BOOK_USERNAME}    ${Password}=${BOOK_PASSWORD}

    Run Keyword And Ignore Error    Close Test Context
    Open Login Page
    Run Keyword And Ignore Error    Handle Future Dialogs    action=accept

    Input Username    ${Username}
    Input Password    ${Password}
    Keyboard Key      press    Tab
    ${Clicked}=    Click Button If Enabled    ${Btn_Login}
    Should Be True    ${Clicked}    msg=ปุ่มเข้าสู่ระบบถูกปิดใช้งาน จึงยังทดสอบการจองไม่ได้

    # popup เข้าสู่ระบบสำเร็จบางครั้งขึ้นช้ากว่า 2 วินาทีที่ Close Login Popup รอ จึงรอปุ่ม "ตกลง" ก่อน
    Run Keyword And Ignore Error    Wait For Elements State    ${Btn_Verify}    visible    10s
    Close Login Popup
    Open Search Equipment Page
    Clear Cart

    ${Cards}=    ค้นหาอุปกรณ์    ${Data}[EquipmentType]    ${Data}[EquipmentName]
    Should Be True    ${Cards} > 0
    ...    msg=ค้นหา "${Data}[EquipmentName]" แล้วไม่พบอุปกรณ์ จึงยังทดสอบการจองไม่ได้ — ตรวจว่ามีอุปกรณ์ชื่อนี้อยู่ในระบบจริง

    ${Added}=    Click Add To Cart
    Should Be True    ${Added}    msg=เพิ่มอุปกรณ์ลงตะกร้าไม่ได้ จึงยังทดสอบการจองไม่ได้

    ${Opened}=    Open Cart
    Should Be True    ${Opened}    msg=เปิดกล่องตะกร้าไม่ได้ จึงยังไม่เห็นฟอร์มจอง

    ${Displayed}=    Is Booking Form Displayed
    Should Be True    ${Displayed}    msg=เปิดตะกร้าแล้วแต่ไม่พบฟอร์มจอง (ไม่เจอช่องวันที่เริ่มเช่า)

    ${Status}=    อ่านสถานะอุปกรณ์ในตะกร้า
    ${Ready}=     Evaluate    $Status and $Status.startswith("พร้อมให้เช่า")

    IF    not ${Ready}
        IF    '${Status}' == '${EMPTY}'
            Log    ไม่พบสถานะอุปกรณ์ในตะกร้า (อาจโหลดไม่ทัน)    level=WARN
        ELSE
            Log    อุปกรณ์ "${Data}[EquipmentName]" สถานะ "${Status}" → มีการจองค้างอยู่    level=WARN
            Log    หน้าเว็บจะเลื่อนวันแรกที่จองได้ + ปิดวันที่ติดจองทั้งหมด    level=WARN
        END
    END

อ่านสถานะอุปกรณ์ในตะกร้า
    #อ่านข้อความ "สถานะ: ..." บนการ์ดอุปกรณ์ในตะกร้า คืนข้อความว่างเมื่ออ่านไม่ได้ (ถือว่าตรวจไม่ได้ ไม่ใช่สถานะผิด)
    ${Text}=      Get Cart Text
    ${Found}=     Evaluate    re.search(r"สถานะ\\s*[:：]\\s*([^\\r\\n]+)", $Text)    modules=re
    ${Status}=    Evaluate    $Found.group(1).strip() if $Found else ""

    ${Len}=    Get Length    ${Status}
    IF    ${Len} == 0
        Log    ไม่พบข้อความสถานะบนการ์ดอุปกรณ์ในตะกร้า จึงข้ามการตรวจสถานะ    level=INFO
        RETURN    ${EMPTY}
    END
    Log    สถานะของอุปกรณ์ในตะกร้าตอนนี้คือ "${Status}"    level=INFO
    RETURN    ${Status}

ค้นหาอุปกรณ์
    #เลือกประเภทอุปกรณ์แล้วค้นด้วยชื่อ คืนจำนวนการ์ดที่พบ (${Type}=AUTO ให้จับคู่ประเภทจากชื่อเอง)
    #เลือกประเภทแล้วยังไม่พบ จะล้างตัวกรองแล้วค้นใหม่ก่อนสรุปว่าไม่พบจริง
    [Arguments]    ${Type}    ${Name}

    IF    '${Type}' == 'AUTO'
        ${Filtered}=    Select Equipment Type Matching    ${Name}
    ELSE
        ${Filtered}=    Select Equipment Type    ${Type}
    END

    Input Search Equipment    ${Name}
    ${Cards}=    Get Equipment Card Count
    IF    ${Cards} > 0    RETURN    ${Cards}

    IF    ${Filtered}
        Log    ค้นหา "${Name}" ในประเภทที่เลือกไว้ไม่พบอุปกรณ์ จึงล้างตัวกรองประเภทแล้วค้นใหม่    level=WARN
        Select Equipment Type     ${EMPTY}
        Input Search Equipment    ${Name}
        ${Cards}=    Get Equipment Card Count
    END

    RETURN    ${Cards}

กรอกฟอร์มจอง
    #เลือกวันเริ่ม วันสิ้นสุด กรอกที่อยู่ คืนสรุปผลแต่ละช่อง (ช่องวันที่เป็น readonly เลือกจากปฏิทินเท่านั้น)
    [Arguments]    ${Data}

    ${Start}=    เลือกวันที่ลงช่อง    ${Text_StartDate}    ${Data}[StartDate]
    ${End}=      เลือกวันที่ลงช่อง    ${Text_EndDate}      ${Data}[EndDate]
    Input Booking Address    ${Data}[Address]

    # รวมทั้งวันที่ที่ระบบปิดไม่ให้เลือก และค่าวันที่ในชีตที่อ่านไม่ออก ทั้งสองอย่างแปลว่ายังไม่ได้เลือกวันที่จริง
    ${Blocked}=    Create List
    FOR    ${Text}    IN    ${Start}    ${End}
        ${Bad}=    Evaluate    "ระบบปิดวันที่" in $Text or "รูปแบบวันที่" in $Text
        IF    ${Bad}    Append To List    ${Blocked}    ${Text}
    END

    ${Summary}=    Create Dictionary    Start=${Start}    End=${End}    Blocked=${Blocked}
    Log    ผลการกรอกฟอร์ม : ${Summary}    level=INFO
    RETURN    ${Summary}

เลือกวันที่ลงช่อง
    #แปลงค่าในชีตเป็นวันที่จริงแล้วเลือกจากปฏิทิน คืนข้อความบอกผล (ค่าว่าง = ตั้งใจไม่เลือกวันที่)
    [Arguments]    ${Field}    ${Token}

    IF    '${Token}' == '${EMPTY}'    RETURN    ไม่ได้เลือกวันที่

    ${Base}    ${Offset}=    แยกคำวันที่    ${Token}
    IF    $Base == 'วันแรกที่จองได้'
        # ถามปฏิทินเองว่าวันแรกที่ระบบยอมให้เลือกคือวันไหน แล้วนับต่อจากวันนั้น จะได้ไม่พังเมื่อฐานข้อมูลมีการจองค้างอยู่
        ${First}=    หาวันแรกที่ระบบเปิดให้เลือก    ${Field}
        ${Len}=      Get Length    ${First}
        IF    ${Len} == 0    RETURN    ระบบไม่เปิดให้เลือกวันไหนเลยในช่วง 12 เดือนข้างหน้า
        ${Date}=     Evaluate    datetime.date.fromisoformat($First) + datetime.timedelta(days=${Offset})    modules=datetime
    ELSE IF    $Base == 'วันนี้'
        ${Date}=     Evaluate    datetime.date.today() + datetime.timedelta(days=${Offset})    modules=datetime
    ELSE
        ${Date}=     แปลงวันที่ตายตัว    ${Token}
        IF    $Date is None    RETURN    รูปแบบวันที่ "${Token}" ในไฟล์ทดสอบอ่านไม่ออก จึงเลือกจากปฏิทินไม่ได้
    END

    # ใช้ - คั่นแทน / เพราะข้อความนี้ถูกใช้เป็นชื่อไฟล์ภาพหน้าจอ (/ จะกลายเป็นโฟลเดอร์ย่อย)
    ${Display}=       Evaluate    "%02d-%02d-%d" % ($Date.day, $Date.month, $Date.year + ${THAI_YEAR_OFFSET})
    ${MonthIndex}=    Evaluate    $Date.year * 12 + $Date.month
    ${Result}=    Pick Date From Calendar    ${Field}    ${Date.day}    ${MonthIndex}    ${Display}
    Log    ${Token} -> ${Display} : ${Result}    level=INFO
    RETURN    ${Result}

แยกคำวันที่
    #แยกค่าวันที่ภาษาไทยในชีต คืน (จุดเริ่มนับ, จำนวนวันที่บวก/ลบ)
    #รองรับ: วันนี้ | วันนี้ + 3 วัน | วันนี้ - 3 วัน | วันแรกที่จองได้ | วันแรกที่จองได้ + 3 วัน
    #ค่าที่ไม่ตรงรูปแบบนี้ (เช่น 30/08/2569) คืนจุดเริ่มนับเป็น None
    [Arguments]    ${Token}
    ${Found}=     Evaluate    re.fullmatch(r"\\s*(วันนี้|วันแรกที่จองได้)\\s*(?:([+-])\\s*(\\d+)\\s*วัน)?\\s*", str($Token))    modules=re
    IF    $Found is None    RETURN    ${None}    ${0}
    ${Base}=      Evaluate    $Found.group(1)
    ${Offset}=    Evaluate    (-1 if $Found.group(2) == "-" else 1) * int($Found.group(3) or 0)
    RETURN    ${Base}    ${Offset}

แปลงวันที่ตายตัว
    #แปลงวันที่ตายตัวในชีต (วว/ดด/ปปปป เป็น พ.ศ. หรือ ค.ศ.) เป็นวันที่จริง คืน None เมื่ออ่านไม่ออกหรือไม่มีวันนี้จริง
    [Arguments]    ${Token}
    ${Text}=      Strip String    ${Token}
    ${IsSlash}=   Evaluate    re.fullmatch(r"\\d{1,2}/\\d{1,2}/\\d{4}", $Text) is not None    modules=re
    IF    not ${IsSlash}
        Log    อ่านค่าวันที่ "${Text}" ในไฟล์ทดสอบไม่ออก    level=WARN
        RETURN    ${None}
    END

    ${Parts}=    Split String          ${Text}    /
    ${Day}=      Convert To Integer    ${Parts}[0]
    ${Month}=    Convert To Integer    ${Parts}[1]
    # ปีในชีตเขียนเป็น พ.ศ. ส่งให้คีย์เวิร์ดกลางจัดการที่เดียว ไม่บวกลบปีตรงนี้
    ${Year}=     เทียบปีให้เป็น ค.ศ.    ${Parts}[2]

    ${Ok}    ${Date}=    Run Keyword And Ignore Error
    ...    Evaluate    datetime.date(${Year}, ${Month}, ${Day})    modules=datetime
    IF    '${Ok}' == 'PASS'    RETURN    ${Date}
    Log    วันที่ ${Text} ไม่มีอยู่จริงในปฏิทิน    level=WARN
    RETURN    ${None}

อ่านผลจากระบบ
    #อ่านข้อความที่ระบบแสดงหลังกดสั่งจอง ตามลำดับ : หัวข้อ popup SweetAlert2 -> ข้อความแจ้งเตือน (หลายข้อความคั่นด้วย " | ")
    #-> หัวข้อ popup ข้อกำหนดการเช่า (popup นี้เป็น <h1> ธรรมดา ไม่ใช่ SweetAlert2 จึงอ่านด้วย ${Terms_Title})
    #ไม่มีอะไรเลยคืนค่าว่าง ไม่ใส่ข้อความแทน (ผลการเลือกวันที่บนปฏิทิน/ปุ่มถูกปิด เก็บไว้ใน log เท่านั้น)
    [Arguments]    ${Filled}    ${Clicked}

    ${Blocked}=    Get Length    ${Filled}[Blocked]
    IF    ${Blocked} > 0    Log    เลือกวันที่บนปฏิทินไม่ได้ : ${Filled}[Blocked]    level=INFO
    IF    not ${Clicked}    Log    ปุ่ม "สั่งจอง" ถูกปิดใช้งาน จึงไม่ได้กดสั่งจอง    level=INFO

    ${Popup}=    Get Popup Title
    IF    '${Popup}' != '${EMPTY}'    RETURN    ${Popup}

    ${Messages}=    Get Validation Messages
    ${Count}=       Get Length    ${Messages}
    IF    ${Count} > 0
        ${Result}=    รวมข้อความหลายรายการ    ${Messages}    ${EMPTY}
        RETURN    ${Result}
    END

    # ข้อมูลผ่านการตรวจสอบ ระบบจะเปิด popup ข้อกำหนดการเช่า (ไม่ติ๊กยอมรับ จึงยังไม่เกิดการจองจริง)
    ${Terms}=    Is Terms Popup Shown
    IF    ${Terms}
        ${Ok}    ${Title}=    Run Keyword And Ignore Error    Get Text    ${Terms_Title}
        IF    '${Ok}' == 'PASS'
            ${Title}=    Strip String    ${Title}
            RETURN    ${Title}
        END
    END
    RETURN    ${EMPTY}


# 3. สำเนาที่จำเป็นสำหรับ TC04_04 (IVEc2.0) เท่านั้น
# ต้นฉบับของ flow นี้ (และเคสอื่น ๆ TC04_F01-F04) ย้ายไปอยู่ที่ Usecase/Usecase_Booking_farmer.robot แล้ว
# =====================================================================

กรณี TC04_F05
    #BK01-04 / IVEc2.0 : ${BOOK_USERNAME} จองให้สำเร็จก่อน (รอบ 1) แล้ว ${BOOK_USERNAME_2} จองวันเดียวกันซ้ำ (รอบ 2)
    #ระบบต้องไม่อนุญาต ถ้าผ่านถึงข้อกำหนดจะกดยอมรับต่อดูผลจริง (คำขอที่ชนกันใช้ทดสอบ AB01-01 ต่อได้) คืนข้อความที่ระบบตอบในรอบที่ 2
    [Arguments]    ${Data}

    # ---------- รอบที่ 1 : จองให้สำเร็จเพื่อสร้างช่วงเวลาที่ถูกจองไว้แล้ว ----------
    เตรียมฟอร์มจอง    ${Data}
    ${Fixed}=    แปลงวันที่จองได้เป็นวันที่จริง    ${Data}
    กรอกฟอร์มจอง    ${Fixed}
    ${Clicked}=    Click Booking Button
    Should Be True    ${Clicked}    msg=จองรอบแรกไม่ได้ จึงยังทดสอบการจองซ้ำไม่ได้

    ${Before}=      Get Popup Title
    ${Accepted}=    Accept Booking Terms
    ${First}=       รอหัวข้อ popup ใหม่    ${Before}
    Should Be Equal    ${First}    ${BOOK_SUCCESS}
    ...    msg=จองรอบแรกไม่สำเร็จ (${First}) จึงยังทดสอบการจองซ้ำไม่ได้
    Log    ${BOOK_USERNAME} จองสำเร็จ ${Fixed}[StartDate] - ${Fixed}[EndDate]    level=INFO

    # ---------- รอบที่ 2 : ผู้เช่าอีกคนจองช่วงเวลาเดิมซ้ำ ----------
    เตรียมฟอร์มจอง    ${Fixed}    ${BOOK_USERNAME_2}    ${BOOK_PASSWORD_2}
    ${Filled}=    กรอกฟอร์มจอง    ${Fixed}

    ${Clicked}=    Click Booking Button
    ${Result}=     อ่านผลจากระบบ    ${Filled}    ${Clicked}

    # ผ่านการตรวจสอบถึงขั้นข้อกำหนดแล้ว แปลว่าระบบยังไม่กัน จึงกดยอมรับต่อเพื่อดูผลสุดท้ายจากระบบ
    ${Terms}=    Is Terms Popup Shown
    IF    ${Terms}
        ${Before}=    Get Popup Title
        Accept Booking Terms
        ${Result}=    รอหัวข้อ popup ใหม่    ${Before}
    END

    Log    ${BOOK_USERNAME_2} จอง ${Fixed}[StartDate] - ${Fixed}[EndDate] ซ้ำกับ ${BOOK_USERNAME} : "${Result}"    level=INFO
    RETURN    ${Result}

แปลงวันที่จองได้เป็นวันที่จริง
    #แปลงค่า "วันแรกที่จองได้" / "วันแรกที่จองได้ + n วัน" ใน ${Data} เป็นวันที่ตายตัว (วว/ดด/ปปปป พ.ศ.) คืน Dictionary ใหม่
    #ต้องเรียกตอนฟอร์มจองเปิดอยู่ ใช้กับ TC04_04 เพื่อให้ผู้เช่าคนที่ 2 จองวันเดียวกับคนแรกได้ตรงกันทุกวัน
    [Arguments]    ${Data}
    ${Fixed}=    Copy Dictionary    ${Data}
    ${First}=    หาวันแรกที่ระบบเปิดให้เลือก    ${Text_StartDate}
    Should Not Be Empty    ${First}    msg=ปฏิทินไม่เปิดให้เลือกวันไหนเลยในช่วง 12 เดือนข้างหน้า จึงยังทดสอบการจองซ้ำไม่ได้
    # หาวันแรกเสร็จแล้วปฏิทินยังเปิดค้าง กด Escape ปิดก่อน ให้การเลือกวันที่ครั้งถัดไปเริ่มจากสภาพปกติ
    Run Keyword And Ignore Error    Keyboard Key    press    Escape

    FOR    ${Key}    IN    StartDate    EndDate
        ${Base}    ${Offset}=    แยกคำวันที่    ${Fixed}[${Key}]
        IF    $Base != 'วันแรกที่จองได้'    CONTINUE
        ${Date}=    Evaluate    datetime.date.fromisoformat($First) + datetime.timedelta(days=${Offset})    modules=datetime
        ${Text}=    Evaluate    "%02d/%02d/%d" % ($Date.day, $Date.month, $Date.year + ${THAI_YEAR_OFFSET})
        Set To Dictionary    ${Fixed}    ${Key}=${Text}
    END
    Log    แปลงวันที่เป็น ${Fixed}[StartDate] - ${Fixed}[EndDate]    level=INFO
    RETURN    ${Fixed}

รอหัวข้อ popup ใหม่
    #รอจน popup ขึ้นหัวข้อใหม่ที่ไม่ว่างและไม่ใช่ค่าเดิม (ราว 12 วินาที) ใช้หลังกดยอมรับข้อกำหนด ไม่พบคืนค่าว่าง
    [Arguments]    ${Previous}
    FOR    ${Round}    IN RANGE    40
        ${Now}=    Get Popup Title
        IF    $Now and $Now != $Previous    RETURN    ${Now}
        Sleep    0.3s
    END
    # ไม่มี popup ใหม่ภายในเวลาที่รอ คืนค่าว่าง ไม่ใส่ข้อความแทน
    RETURN    ${EMPTY}


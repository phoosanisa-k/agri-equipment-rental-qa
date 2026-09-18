*** Settings ***
Documentation     TC04 - Booking Equipment Farmer | ตรวจข้อความแจ้งเตือนรายฟิลด์ (TC04_01-17)
...               การทดสอบยูสเคสจองอุปกรณ์จริงระดับ Flow (TC04_F01-F05) แยกไปอยู่ที่ Usecase/Usecase_Booking_farmer.robot
...               ยกเว้น TC04_04 (IVEc2.0 จองซ้ำช่วงเวลาเดิม) ที่ยังต้องพึ่งขั้นตอน "จองให้สำเร็จ 1 ครั้งก่อน"
...               จึงคงคีย์เวิร์ด "กรณี TC04_F05" ไว้ในไฟล์นี้ด้วย (มีอยู่ทั้งที่นี่และที่ไฟล์ Usecase แยกกันคนละชุด)

Metadata          System      ระบบเว็บศูนย์กลางให้บริการเช่าอุปกรณ์ทางการเกษตร (SRS v7.0)
Metadata          Use Case    TC04 Booking Equipment Farmer (ทดสอบฟิลด์)
Metadata          Test Data   TestData/Data.xlsx (sheet: BookingEQ_Farmer)

Resource          ../Resources/keywords.robot
Library           DataDriver    file=${CURDIR}/../TestData/Data.xlsx    sheet_name=BookingEQ_Farmer
Library           ExcelLibrary
Library           OperatingSystem
Library           String
Library           Collections

Suite Setup       เปิดชุดทดสอบ
Suite Teardown    ปิดชุดทดสอบ
Test Teardown     เก็บผลท้ายกรณีทดสอบ
Test Template     ดำเนินการกรณีทดสอบ


*** Variables ***
# ---------- ที่อยู่ของไฟล์และโฟลเดอร์ ----------
${DATA_FILE}          ${CURDIR}/../TestData/Data.xlsx
${SHEET}               BookingEQ_Farmer
${SCREENSHOT_DIR}     ${CURDIR}/../Screenshot
${USECASE}            TC04_Booking_Farmer

# ---------- ตำแหน่งคอลัมน์ในชีต ----------
# ตรงกับ data validation ที่ตั้งไว้ในไฟล์ Excel : A2:A18 คือ ${Run} และ I2:I18 คือ ${Result}
${COL_ID}             ${2}    # คอลัมน์ B : ${TestCase}
${COL_ACTUAL}         ${8}    # คอลัมน์ H : ${ActualResult}
${COL_PF}             ${9}    # คอลัมน์ I : ${Result}

# ---------- ข้อความและตัวชี้วัดที่ใช้ตัดสินผล ----------
# ใช้แทนกรณี "ข้อมูลผ่านการตรวจสอบ ไม่มีข้อความแจ้งเตือน" ตามที่เอกสาร Test Case ระบุ
${PASS_MESSAGE}       ผ่านการตรวจสอบ
# ข้อความบน popup เมื่อจองสำเร็จ ใช้ยืนยันผลของ TC04_04 (ผ่าน "กรณี TC04_F05" ในไฟล์นี้)
${BOOK_SUCCESS}       การจองสำเร็จ
# บัญชีที่ใช้ทุกกรณี ต้องเข้าสู่ระบบก่อนจึงจะเปิดตะกร้าและจองได้ (Inter-Case Dependency กับ TC01)
${BOOK_USERNAME}      somchaikaew
${BOOK_PASSWORD}      Somc1442!

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

# ---------- ตัวแปรระดับกรณีทดสอบ ใช้ส่งข้อมูลให้ teardown ----------
${TC_ID}              UNKNOWN
${ROW_NUM}            ${0}
${ACTUAL_MESSAGE}     ${EMPTY}


*** Test Cases ***
Booking Equipment Farmer : ${TestCase}


*** Keywords ***
# =====================================================================
# 1. การเตรียมและปิดงาน
# =====================================================================

เปิดชุดทดสอบ
    [Documentation]    ล้างภาพของรอบก่อน เปิดไฟล์ Excel สำหรับเขียนผล และเปิดเบราว์เซอร์
    Create Directory    ${SCREENSHOT_DIR}
    ลบภาพของรอบก่อน    ${SCREENSHOT_DIR}

    Open Excel Document    ${DATA_FILE}    Booking
    Open Test Browser

ลบภาพของรอบก่อน
    [Documentation]    ลบเฉพาะภาพของยูสเคสนี้ ไม่แตะภาพของยูสเคสอื่นที่อยู่โฟลเดอร์เดียวกัน
    ...                และไม่ลบตัวโฟลเดอร์ เพราะ OneDrive มักคืน Access denied
    [Arguments]    ${Folder}
    ${Files}=    List Files In Directory    ${Folder}    ${USECASE}_*.png
    FOR    ${File}    IN    @{Files}
        ${Removed}=    Run Keyword And Return Status    Remove File    ${Folder}/${File}
        IF    not ${Removed}
            Log    ลบไฟล์ ${File} ไม่สำเร็จ ภาพอาจปนกับรอบก่อน    level=WARN
        END
    END

ปิดชุดทดสอบ
    [Documentation]    บันทึกไฟล์ Excel และปิดทรัพยากรทั้งหมด
    Run Keyword And Ignore Error    เซฟไฟล์ Excel อย่างปลอดภัย
    Run Keyword And Ignore Error    Close All Excel Documents
    Close All Test Browsers

เก็บผลท้ายกรณีทดสอบ
    [Documentation]    เก็บภาพเมื่อไม่ผ่าน เขียนผลกลับลง Excel แล้วปิด context
    ...                กรณีที่ถูกข้าม (${ROW_NUM} = 0) จะไม่เขียนทับผลเดิม
    ${Actual}=    Set Variable    ${ACTUAL_MESSAGE}

    IF    '${TEST STATUS}' == 'FAIL'
        Run Keyword And Ignore Error
        ...    Take Screenshot    ${SCREENSHOT_DIR}/${USECASE}_${TC_ID}_FAILED    fullPage=True

        # กรณีที่ล้มก่อนได้ข้อความจากระบบ ให้บันทึกสาเหตุที่ล้มแทน
        ${Length}=    Get Length    ${ACTUAL_MESSAGE}
        IF    ${Length} == 0
            ${Actual}=    Get Line         ${TEST MESSAGE}    0
            ${Actual}=    Get Substring    ${Actual}          0    250
        END
    END

    IF    ${ROW_NUM} > 0
        ${ResultPF}=    Set Variable If    '${TEST STATUS}' == 'PASS'    Pass    Fail
        Run Keyword And Ignore Error    บันทึกผลลง Excel    ${ROW_NUM}    ${Actual}    ${ResultPF}
    END

    # Ignore Error เพราะกรณีที่ถูกข้ามยังไม่มี context ถูกเปิด
    Run Keyword And Ignore Error    Close Test Context


# =====================================================================
# 2. การอ่านและเขียนไฟล์ Excel
# =====================================================================

หาแถวของกรณีทดสอบ
    [Documentation]    ค้นหมายเลขแถวจากรหัสกรณีทดสอบในคอลัมน์ B (index 0 คือหัวตาราง แถวจึงเป็น index + 1)
    ...                คืน 0 เมื่อไม่พบ เพื่อให้ teardown ข้ามการเขียนผลแทนที่จะล้ม
    [Arguments]    ${TestCaseID}
    ${Ids}=    Read Excel Column    ${COL_ID}    sheet_name=${SHEET}
    ${Ids}=    Evaluate    ["" if v is None else str(v).strip() for v in $Ids]

    ${Found}=    Run Keyword And Return Status    List Should Contain Value    ${Ids}    ${TestCaseID}
    IF    not ${Found}
        Log    ไม่พบ ${TestCaseID} ในคอลัมน์ B ของชีต ${SHEET} จึงไม่เขียนผลกลับ    level=WARN
        RETURN    ${0}
    END

    ${Index}=    Get Index From List    ${Ids}    ${TestCaseID}
    ${Row}=      Evaluate    ${Index} + 1
    RETURN    ${Row}

บันทึกผลลง Excel
    [Documentation]    เขียนผลที่ได้จริงและสถานะ Pass/Fail กลับลงไฟล์ Excel ตามแถวของกรณีทดสอบ
    [Arguments]    ${Row}    ${ActualResult}    ${ResultPF}
    Write Excel Cell       ${Row}    ${COL_ACTUAL}    ${ActualResult}    sheet_name=${SHEET}
    Write Excel Cell       ${Row}    ${COL_PF}        ${ResultPF}        sheet_name=${SHEET}
    เซฟไฟล์ Excel อย่างปลอดภัย

เซฟไฟล์ Excel อย่างปลอดภัย
    [Documentation]    เซฟลงไฟล์ชั่วคราวก่อน แล้วค่อยย้ายไปทับไฟล์จริง
    ...                ถ้ารันถูกตัดจบระหว่างเขียน ไฟล์ที่ค้างครึ่ง ๆ จะเป็นไฟล์ชั่วคราว ไฟล์จริงยังสมบูรณ์เสมอ
    ...                (เดิมเซฟทับไฟล์จริงตรง ๆ พอรันถูกตัดกลางคัน ไฟล์ .xlsx จะขาดท้ายจนเปิดไม่ขึ้น)
    ${Temp}=    Set Variable    ${DATA_FILE}.saving.xlsx
    Save Excel Document    ${Temp}
    Move File              ${Temp}    ${DATA_FILE}


# =====================================================================
# 3. จุดเริ่มของทุกกรณีทดสอบ
# =====================================================================

ดำเนินการกรณีทดสอบ
    [Documentation]    แยกทางตามรหัสกรณีทดสอบ
    ...                TC04_NN  -> ตรวจข้อความแจ้งเตือนรายฟิลด์ (หยุดที่ popup ข้อกำหนด ไม่จองจริง)
    ...                TC04_04  -> ต้องมีรายการจองค้างอยู่ก่อน จึงเรียก "กรณี TC04_F05" (สำเนาที่เก็บไว้ในไฟล์นี้)
    ...                TC04_FNN -> โค้ด flow อื่น ๆ ย้ายไปอยู่ที่ Usecase/Usecase_Booking_farmer.robot แล้ว
    ...                           (ถ้ายังมีแถว TC04_Fxx ที่ไม่ใช่ TC04_04 ถูกเลือกให้รันในไฟล์ Excel จะหา keyword ไม่เจอ)
    ...
    ...                ลำดับอาร์กิวเมนต์ต้องตรงกับหัวตารางคอลัมน์ A-G ของชีต ${SHEET}
    [Arguments]    ${Run}          ${TestCase}    ${TestScenario}
    ...            ${StartDate}    ${EndDate}     ${Address}    ${ExpectedResult}

    # แถวสรุปผลท้ายชีตไม่มีรหัสกรณีทดสอบ จึงไม่ใช่กรณีทดสอบ
    IF    '${TestCase}' == '${EMPTY}'
        Skip    ไม่ใช่กรณีทดสอบ (แถวสรุปผลในไฟล์ Excel)
    END
    IF    '${Run}' != 'Yes'
        Skip    ไม่ได้เลือกให้รัน (Run = ${Run})
    END

    Set Test Documentation    ${TestScenario}
    Set Test Variable         ${TC_ID}             ${TestCase}
    Set Test Variable         ${ACTUAL_MESSAGE}    ${EMPTY}

    ${Row}=    หาแถวของกรณีทดสอบ    ${TestCase}
    Set Test Variable    ${ROW_NUM}    ${Row}

    ${Data}=    Create Dictionary
    ...    EquipmentType=${BOOK_EQ_TYPE}    EquipmentName=${BOOK_EQ_NAME}
    ...    StartDate=${StartDate}           EndDate=${EndDate}            Address=${Address}
    Log    ${TestCase} : ${TestScenario} | ข้อมูลที่ใช้ทดสอบ ${Data}    level=INFO

    # TC04_04 (IVEc2.0) ต้องมีการจองค้างอยู่ในช่วงเวลาเดียวกันก่อน จึงใช้ขั้นตอนเดียวกับ TC04_F05
    # คือจองให้สำเร็จหนึ่งครั้งเพื่อสร้างช่วงเวลาที่ถูกจองไว้ แล้วค่อยจองซ้ำ ทำให้ไม่ต้องเตรียมข้อมูลในฐานข้อมูลเอง
    ${NeedBooked}=  Evaluate    "${TestCase}" == "TC04_04"

    IF    ${NeedBooked}
        กรณี TC04_F05    ${Data}    ${ExpectedResult}
    ELSE
        ตรวจข้อความแจ้งเตือนรายฟิลด์    ${Data}    ${ExpectedResult}
    END


# =====================================================================
# 4. ส่วนที่ 1 : ตรวจข้อความแจ้งเตือนรายฟิลด์ (TC04_01 - TC04_17)
# =====================================================================

ตรวจข้อความแจ้งเตือนรายฟิลด์
    [Documentation]    กรอกฟอร์มจองแล้วกดปุ่ม "สั่งจอง" เพื่ออ่านข้อความที่ระบบแจ้ง
    ...
    ...                ต่างจาก TC01/TC02 ที่ไม่กดปุ่ม submit เพราะหน้านี้ตรวจข้อมูลตอนกดสั่งจองเท่านั้น
    ...                และหยุดที่ popup ข้อกำหนด ไม่ติ๊กยอมรับ จึงไม่เกิดรายการจองจริงทุกครั้งที่รัน
    [Arguments]    ${Data}    ${ExpectedResult}

    เตรียมฟอร์มจอง    ${Data}
    ${Filled}=    กรอกฟอร์มจอง    ${Data}

    ${Clicked}=    Click Booking Button
    ${Result}=     อ่านผลจากระบบ    ${Filled}    ${Clicked}
    เก็บภาพหลักฐาน    ${TC_ID}

    บันทึกผลที่ได้จริง    ${Result}
    ผลตรงกับที่เอกสารกำหนด    ${Result}    ${ExpectedResult}

เตรียมฟอร์มจอง
    [Documentation]    เข้าสู่ระบบ เพิ่มอุปกรณ์ลงตะกร้า แล้วเปิดกล่องตะกร้าที่มีฟอร์มจองอยู่
    ...                เป็น Pre-Condition ของเอกสาร คือต้องเข้าสู่ระบบและมีอุปกรณ์ในตะกร้าก่อน
    [Arguments]    ${Data}

    Run Keyword And Ignore Error    Close Test Context
    Open Login Page
    Run Keyword And Ignore Error    Handle Future Dialogs    action=accept

    Input Username    ${BOOK_USERNAME}
    Input Password    ${BOOK_PASSWORD}
    Keyboard Key      press    Tab
    ${Clicked}=    Click Button If Enabled    ${Btn_Login}
    Should Be True    ${Clicked}    msg=ปุ่มเข้าสู่ระบบถูกปิดใช้งาน จึงยังทดสอบการจองไม่ได้

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
    [Documentation]    อ่านข้อความ "สถานะ: ..." บนการ์ดอุปกรณ์ในกล่องตะกร้า
    ...                คืนข้อความว่างเมื่ออ่านไม่ได้ ผู้เรียกจะได้ถือว่าตรวจไม่ได้ ไม่ใช่ว่าสถานะผิด
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
    [Documentation]    เลือกประเภทอุปกรณ์ให้เข้าคู่กับชื่อที่จะค้นหา แล้วพิมพ์ชื่อลงช่องค้นหา คืนจำนวนการ์ดที่พบ
    ...
    ...                ${Type} = AUTO ให้สคริปต์อ่าน dropdown แล้วจับคู่ประเภทจากชื่อที่ค้นหาเอง
    ...                ระบุประเภทมาก็ใช้ตามนั้น ค่าว่างคือไม่กรองประเภท
    ...                เลือกประเภทแล้วยังไม่พบ จะล้างตัวกรองแล้วค้นใหม่อีกครั้งก่อนสรุปว่าไม่พบจริง
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
    [Documentation]    เลือกวันเริ่ม วันสิ้นสุด และกรอกที่อยู่ คืนสรุปสิ่งที่เกิดขึ้นกับแต่ละช่อง
    ...                ช่องวันที่เป็น readonly จึงเลือกจากปฏิทินเท่านั้น ค่าว่างในชีตแปลว่าไม่ต้องแตะช่องนั้น
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
    [Documentation]    แปลงค่าในชีตเป็นวันที่จริงแล้วเลือกจากปฏิทิน คืนข้อความบอกผล
    ...                ค่าว่างแปลว่ากรณีทดสอบตั้งใจไม่เลือกวันที่ จึงไม่แตะช่องนั้นเลย
    [Arguments]    ${Field}    ${Token}

    IF    '${Token}' == '${EMPTY}'    RETURN    ไม่ได้เลือกวันที่

    # FIRST / FIRST+n = ให้สคริปต์ถามปฏิทินเองว่าวันแรกที่ระบบยอมให้เลือกคือวันไหน แล้วนับต่อจากวันนั้น
    # ใช้กับเคสที่ต้องการแค่ "วันที่ถูกต้องวันหนึ่ง" จะได้ไม่พังเมื่อฐานข้อมูลมีการจองค้างอยู่
    ${IsFirst}=    Evaluate    str($Token).strip().upper().startswith("FIRST")
    IF    ${IsFirst}
        ${Base}=    หาวันแรกที่ระบบเปิดให้เลือก    ${Field}
        ${Len}=     Get Length    ${Base}
        IF    ${Len} == 0    RETURN    ระบบไม่เปิดให้เลือกวันไหนเลยในช่วง 12 เดือนข้างหน้า

        ${Offset}=     Evaluate    int(str($Token).strip()[5:].strip() or 0)
        ${Date}=       Evaluate    datetime.date.fromisoformat($Base) + datetime.timedelta(days=${Offset})    modules=datetime
        ${Display}=    Evaluate    "%02d/%02d/%d" % ($Date.day, $Date.month, $Date.year + ${THAI_YEAR_OFFSET})
    ELSE
        ${Date}    ${Display}=    แปลงค่าวันที่    ${Token}
        IF    $Date is None    RETURN    รูปแบบวันที่ "${Token}" ในไฟล์ทดสอบอ่านไม่ออก จึงเลือกจากปฏิทินไม่ได้
    END

    ${MonthIndex}=    Evaluate    $Date.year * 12 + $Date.month
    ${Result}=    Pick Date From Calendar    ${Field}    ${Date.day}    ${MonthIndex}    ${Display}
    Log    ${Token} -> ${Display} : ${Result}    level=INFO
    RETURN    ${Result}

แปลงค่าวันที่
    [Documentation]    แปลงค่าวันที่ในชีตเป็นวันที่จริง คืน 2 ค่า คือ วันที่ และ ข้อความที่ใช้แสดงในรายงาน
    ...                คืน None เมื่ออ่านค่าไม่ออก
    ...
    ...                รองรับ 3 รูปแบบ
    ...                1) 30/08/2569 : วันที่ตายตัว วัน/เดือน/ปี ตามที่เขียนไว้ในชีต (ชีตยูสเคสนี้ใช้ พ.ศ.)
    ...                2) AUTO+3 / AUTO-2 / AUTO : นับจากวันที่รันจริง ใช้เมื่อไม่อยากให้วันที่หมดอายุ
    ...                3) Thu Jun 04 2026 07:00:00 GMT+0700 (...) : ค่าที่คัดลอกมาจากช่องวันที่ของหน้าเว็บ
    ...
    ...                ข้อความที่ใช้แสดงคงรูปแบบเดิมตามที่เขียนไว้ในชีต ไม่มีการแปลงปีเพื่อแสดงผลอีก
    [Arguments]    ${Token}
    ${Text}=    Strip String    ${Token}

    ${IsAuto}=    Evaluate    $Text.upper().startswith("AUTO")
    IF    ${IsAuto}
        ${Offset}=     Evaluate    int($Text[4:].strip() or 0)
        ${Date}=       Evaluate    datetime.date.today() + datetime.timedelta(days=${Offset})    modules=datetime
        # ใช้ ${Date.day} ของ Robot Framework แทน f-string เพราะ Evaluate ไม่แทนค่า $ตัวแปร ที่อยู่ในเครื่องหมายคำพูด
        ${Display}=    Set Variable    ${Date.day}/${Date.month}/${Date.year}
        RETURN    ${Date}    ${Display}
    END

    ${IsSlash}=    Evaluate    re.fullmatch(r"\\d{1,2}/\\d{1,2}/\\d{4}", $Text) is not None    modules=re
    IF    ${IsSlash}
        ${Parts}=    Split String          ${Text}    /
        ${Day}=      Convert To Integer    ${Parts}[0]
        ${Month}=    Convert To Integer    ${Parts}[1]
        # ปีในชีตเขียนเป็น พ.ศ. ส่งให้คีย์เวิร์ดกลางจัดการที่เดียว ไม่บวกลบปีตรงนี้
        ${Year}=     เทียบปีให้เป็น ค.ศ.    ${Parts}[2]

        ${Ok}    ${Date}=    Run Keyword And Ignore Error
        ...    Evaluate    datetime.date(${Year}, ${Month}, ${Day})    modules=datetime
        IF    '${Ok}' == 'PASS'    RETURN    ${Date}    ${Text}

        Log    วันที่ ${Text} ไม่มีอยู่จริงในปฏิทิน    level=WARN
        RETURN    ${None}    ${Text}
    END

    # รูปแบบของ JavaScript เช่น "Thu Jun 04 2026 07:00:00 GMT+0700 (Indochina Time)" อ่านแค่ 4 คำแรกก็พอ
    ${Ok}    ${Date}=    Run Keyword And Ignore Error
    ...    Evaluate    datetime.datetime.strptime(" ".join($Text.split()[:4]), "%a %b %d %Y").date()    modules=datetime
    IF    '${Ok}' == 'PASS'    RETURN    ${Date}    ${Text}

    Log    อ่านค่าวันที่ "${Text}" ในไฟล์ทดสอบไม่ออก    level=WARN
    RETURN    ${None}    ${Text}

อ่านผลจากระบบ
    [Documentation]    รวบรวมสิ่งที่ระบบตอบกลับหลังกดสั่งจอง เรียงตามความชัดเจนของหลักฐาน
    ...                1) วันที่ที่ระบบปิดไม่ให้เลือก  2) ข้อความบน popup  3) ข้อความแจ้งเตือนใต้ช่อง
    ...                4) popup ข้อกำหนดเด้ง = ข้อมูลผ่านการตรวจสอบ  5) ปุ่มสั่งจองถูกปิดใช้งาน
    [Arguments]    ${Filled}    ${Clicked}

    ${Blocked}=    Get Length    ${Filled}[Blocked]
    IF    ${Blocked} > 0
        ${Joined}=    Evaluate    " | ".join($Filled["Blocked"])
        RETURN    ${Joined}
    END

    ${Popup}=    Get Popup Title
    IF    '${Popup}' != '${EMPTY}'    RETURN    ${Popup}

    ${Messages}=    Get Validation Messages
    ${Count}=       Get Length    ${Messages}
    IF    ${Count} > 0
        ${Joined}=    Evaluate    " | ".join($Messages)
        RETURN    ${Joined}
    END

    ${Terms}=    Is Terms Popup Shown
    IF    ${Terms}    RETURN    ${PASS_MESSAGE}

    IF    not ${Clicked}    RETURN    ปุ่มสั่งจองถูกปิดใช้งาน ระบบไม่ให้ทำรายการ
    RETURN    ไม่พบทั้งข้อความแจ้งเตือนและ popup ข้อกำหนด

ผลตรงกับที่เอกสารกำหนด
    [Documentation]    เทียบผลที่ได้จริงกับ Expected Result ในชีต
    ...                กรณีที่ระบบปิดวันที่ไม่ให้เลือก ถือว่าป้องกันสำเร็จเช่นกัน แม้ข้อความจะไม่ตรงเอกสาร
    [Arguments]    ${Actual}    ${Expected}

    ${IsBlocked}=    Evaluate    "ระบบปิดวันที่" in $Actual or "รูปแบบวันที่" in $Actual
    IF    ${IsBlocked}
        Should Not Be Equal    ${Expected}    ${PASS_MESSAGE}
        ...    msg=เลือกวันที่ตามไฟล์ทดสอบไม่ได้ ทั้งที่เอกสารระบุว่าเป็นวันที่ถูกต้อง (${Actual}) — ตรวจว่าวันที่ในชีตยังไม่เลยวันปัจจุบัน
        Log    ระบบกันด้วยการปิดปุ่มวันที่แทนการแจ้งเตือนหลังกดสั่งจอง : ${Actual}    level=WARN
        RETURN
    END

    ${Matched}=    Evaluate    $Expected.strip() in $Actual or $Actual in $Expected.strip()
    Should Be True    ${Matched}
    ...    msg=ระบบตอบว่า "${Actual}" แต่เอกสารกำหนดไว้ว่า "${Expected}"


# =====================================================================
# 5. สำเนาที่จำเป็นสำหรับ TC04_04 (IVEc2.0) เท่านั้น
# ต้นฉบับของ flow นี้ (และเคสอื่น ๆ TC04_F01-F04) ย้ายไปอยู่ที่ Usecase/Usecase_Booking_farmer.robot แล้ว
# =====================================================================

กรณี TC04_F05
    [Documentation]    BK01-04 : จองซ้ำช่วงเวลาเดิมของอุปกรณ์ชิ้นเดิม ระบบต้องไม่อนุญาต
    ...                จองรอบแรกให้สำเร็จก่อน แล้วจองรอบสองด้วยช่วงเวลาเดียวกัน
    [Arguments]    ${Data}    ${ExpectedResult}

    # ---------- รอบที่ 1 : จองให้สำเร็จเพื่อสร้างช่วงเวลาที่ถูกจองไว้แล้ว ----------
    เตรียมฟอร์มจอง    ${Data}
    กรอกฟอร์มจอง    ${Data}
    ${Clicked}=    Click Booking Button
    Should Be True    ${Clicked}    msg=จองรอบแรกไม่ได้ จึงยังทดสอบการจองซ้ำไม่ได้

    ${Accepted}=    Accept Booking Terms
    ${First}=       Get Popup Title
    เก็บภาพหลักฐาน    ${TC_ID}_จองรอบแรก
    Should Contain    ${First}    ${BOOK_SUCCESS}
    ...    msg=จองรอบแรกไม่สำเร็จ (${First}) จึงยังทดสอบการจองซ้ำไม่ได้

    # ---------- รอบที่ 2 : จองช่วงเวลาเดิมซ้ำ ----------
    เตรียมฟอร์มจอง    ${Data}
    ${Filled}=    กรอกฟอร์มจอง    ${Data}

    ${Clicked}=    Click Booking Button
    ${Terms}=      Is Terms Popup Shown
    ${Result}=     อ่านผลจากระบบ    ${Filled}    ${Clicked}
    เก็บภาพหลักฐาน    ${TC_ID}_จองซ้ำ

    บันทึกผลที่ได้จริง    ${Result}
    ${Booked}=    Evaluate    "${BOOK_SUCCESS}" in $Result
    Should Not Be True    ${Booked}
    ...    msg=ระบบให้จองซ้ำช่วงเวลาที่ถูกจองไปแล้วได้ (${Result})

    ผลตรงกับที่เอกสารกำหนด    ${Result}    ${ExpectedResult}


# =====================================================================
# 6. คีย์เวิร์ดช่วยเหลือ
# =====================================================================

บันทึกผลที่ได้จริง
    [Documentation]    จำข้อความที่ระบบตอบกลับไว้ให้ teardown เขียนลงคอลัมน์ ActualResult
    [Arguments]    ${Text}
    Set Test Variable    ${ACTUAL_MESSAGE}    ${Text}

เก็บภาพหลักฐาน
    [Documentation]    บันทึกภาพหน้าจอไว้เป็นหลักฐานประกอบรายงาน
    [Arguments]    ${Name}
    Run Keyword And Ignore Error
    ...    Take Screenshot    ${SCREENSHOT_DIR}/${USECASE}_${Name}    fullPage=True

*** Settings ***
Documentation     TC04 - Booking Equipment Farmer (Usecase) | ทดสอบยูสเคส "จองอุปกรณ์" ของเกษตรกรระดับกระบวนการ (TC04_F01-F03)
...               ย้ายมาจาก Testcase/Booking_farmer.robot เฉพาะส่วนทดสอบ Flow เท่านั้น
...               ส่วนทดสอบฟิลด์ (TC04_01-17) ยังอยู่ที่ Testcase/Booking_farmer.robot ตามเดิม ไม่ใช้การอ่านจาก Excel
...               ใช้ข้อมูลคงที่ (fix ค่าตายตัวในสคริปต์) แทน
...               ทุกกรณีต้องเข้าสู่ระบบและมีอุปกรณ์ในตะกร้าก่อน จึงขึ้นกับยูสเคส TC01 Login และ TC03 Add Cart
...               อ้างอิงจากเอกสาร Test Case หน้า 69-78
...
...               ตัด BK01-03 (วันสิ้นสุด < วันเริ่มเช่า) และ BK01-04 (จองซ้ำช่วงเวลาเดิม) ออกจากไฟล์นี้แล้ว
...               เพราะซ้ำกับ TC04_08 และ TC04_04 ในไฟล์ฟิลด์ 100% (TC04_04 เรียก "กรณี TC04_F05"
...               ที่เก็บสำเนาไว้ในไฟล์ฟิลด์อยู่แล้ว จึงไม่ต้องมีเวอร์ชันแยกที่นี่อีก)
Metadata          System      ระบบเว็บศูนย์กลางให้บริการเช่าอุปกรณ์ทางการเกษตร (SRS v7.0)
Metadata          Use Case    TC04 Booking Equipment Farmer (ทดสอบยูสเคส)

Resource          ../Resources/keywords.robot
Library           OperatingSystem
Library           String
Library           Collections

Suite Setup       เปิดชุดทดสอบ
Suite Teardown    ปิดชุดทดสอบ
Test Teardown     เก็บผลท้ายกรณีทดสอบ


*** Variables ***
# ---------- ไฟล์และโฟลเดอร์ ----------
${SCREENSHOT_DIR}     ${CURDIR}/../Screenshot
${USECASE}            TC04_Usecase_Booking_Farmer

# ---------- ข้อความและตัวชี้วัดที่ใช้ตัดสินผล ----------
${PASS_MESSAGE}       ผ่านการตรวจสอบ
${BOOK_SUCCESS}       การจองสำเร็จ

# ---------- บัญชีคงที่ : ผู้ใช้สร้างไว้ล่วงหน้าในระบบจริงแล้ว (บัญชีเดียวกับ Usecase_Login_farmer) ----------
${LOGIN_USERNAME}     somchaikaew
${LOGIN_PASSWORD}     Somc1442!

# ---------- อุปกรณ์ที่ใช้ทดสอบ : ต้องมีอยู่จริงในระบบและว่างให้จองได้ ----------
${BOOK_EQ_TYPE}       AUTO
${BOOK_EQ_NAME}       รถไถเดินตาม

# ---------- วันที่และที่อยู่ที่ใช้ทดสอบ ----------
# ใช้ FIRST / FIRST+n แทน AUTO+n เพราะระบบจริงใส่ buffer 3 วันต่อท้ายทุกช่วงที่ถูกจองไว้
# (พบจากการรันจริง) ถ้าใช้วันที่ตายตัวแบบ AUTO+n มีโอกาสไปชนช่วงที่ถูกจอง/บัฟเฟอร์ไว้จากการรันครั้งก่อน
# FIRST จะให้สคริปต์ถามปฏิทินเองว่าวันแรกที่เลือกได้จริงคือวันไหน แล้วค่อยนับต่อ จึงไม่ชนกันไม่ว่าจะรันกี่ครั้ง
${VALID_START}        FIRST
${VALID_END}          FIRST+3
# ที่อยู่ต้องยาว 10-255 ตัวอักษร (เอกสารข้อ 7.4.5.3) — ใช้ที่อยู่เดียวกับที่เคยทดสอบผ่านจริงมาแล้ว
${VALID_ADDRESS}      123/45 หมู่ 5 ตำบลสุเทพ อำเภอเมือง จังหวัดเชียงใหม่ 50200

# ---------- ตัวแปรระดับกรณีทดสอบ ใช้ส่งข้อมูลให้ teardown ----------
${TC_ID}              UNKNOWN
${ACTUAL_MESSAGE}     ${EMPTY}


*** Test Cases ***
TC04_F01 - จองอุปกรณ์สำเร็จ (Basic Flow)
    [Documentation]    Basic Flow ของเอกสาร : กรอกครบถูกต้อง ยอมรับข้อกำหนด แล้วต้องจองสำเร็จจริง
    ...                กรณีนี้สร้างรายการจองจริงในระบบ 1 รายการทุกครั้งที่รัน
    Set Test Variable    ${TC_ID}    TC04_F01
    ${Data}=    สร้างข้อมูลทดสอบ    ${VALID_START}    ${VALID_END}    ${VALID_ADDRESS}
    กรณี TC04_F01    ${Data}

TC04_F02 - ไม่กรอกข้อมูลเลยแล้วกดสั่งจอง
    [Documentation]    BK01-01 : ไม่กรอกอะไรเลยแล้วกดสั่งจอง ระบบต้องไม่ให้ทำรายการ
    Set Test Variable    ${TC_ID}    TC04_F02
    ${Data}=    สร้างข้อมูลทดสอบ    ${VALID_START}    ${VALID_END}    ${VALID_ADDRESS}
    กรณี TC04_F02    ${Data}

TC04_F03 - ไม่ติ๊กยอมรับข้อกำหนด
    [Documentation]    ไม่ติ๊กยอมรับข้อกำหนด ระบบต้องไม่บันทึกการจอง
    ...                ตาม Post-Condition ของเอกสารที่ต้องผ่านหน้า Acceptance of the Terms of Use ก่อน
    Set Test Variable    ${TC_ID}    TC04_F03
    ${Data}=    สร้างข้อมูลทดสอบ    ${VALID_START}    ${VALID_END}    ${VALID_ADDRESS}
    กรณี TC04_F03    ${Data}


*** Keywords ***
# =====================================================================
# 1. การเตรียมและปิดชุดทดสอบ
# =====================================================================

เปิดชุดทดสอบ
    [Documentation]    ล้างภาพของรอบก่อน และเปิดเบราว์เซอร์ (ไม่ต้องเปิด Excel เพราะไฟล์นี้ fix ค่าตายตัว ไม่มีการเขียนผลกลับ)
    Create Directory    ${SCREENSHOT_DIR}
    ลบภาพของรอบก่อน    ${SCREENSHOT_DIR}
    Open Test Browser

ลบภาพของรอบก่อน
    [Documentation]    ลบเฉพาะภาพของยูสเคสนี้ ไม่แตะภาพของยูสเคสอื่นที่อยู่โฟลเดอร์เดียวกัน
    ...                และไม่ลบตัวโฟลเดอร์ เพราะ OneDrive มักคืน Access denied
    [Arguments]    ${Folder}
    ${Files}=    List Files In Directory    ${Folder}    ${USECASE}_*.png
    FOR    ${File}    IN    @{Files}
        ${Removed}=    Run Keyword And Return Status    Remove File    ${Folder}/${File}
        IF    not ${Removed}    Log    ลบไฟล์ ${File} ไม่สำเร็จ ภาพอาจปนกับรอบก่อน    level=WARN
    END

ปิดชุดทดสอบ
    [Documentation]    ปิดเบราว์เซอร์ทั้งหมด
    Close All Test Browsers

เก็บผลท้ายกรณีทดสอบ
    [Documentation]    เก็บภาพเมื่อไม่ผ่าน แล้วปิด context (ไม่มีการเขียนผลกลับ Excel เพราะไฟล์นี้ fix ค่าตายตัว)
    IF    '${TEST STATUS}' == 'FAIL'
        Run Keyword And Ignore Error
        ...    Take Screenshot    ${SCREENSHOT_DIR}/${USECASE}_${TC_ID}_FAILED    fullPage=True
    END
    # Ignore Error เพราะบางกรณีอาจยังไม่มี context ถูกเปิด
    Run Keyword And Ignore Error    Close Test Context


# =====================================================================
# 2. เตรียมข้อมูลทดสอบ
# =====================================================================

สร้างข้อมูลทดสอบ
    [Documentation]    สร้าง Dictionary ข้อมูลสำหรับกรณีทดสอบ ใช้อุปกรณ์คงที่ร่วมกับวันที่และที่อยู่ที่ระบุ
    [Arguments]    ${StartDate}    ${EndDate}    ${Address}
    ${Data}=    Create Dictionary
    ...    EquipmentType=${BOOK_EQ_TYPE}    EquipmentName=${BOOK_EQ_NAME}
    ...    StartDate=${StartDate}           EndDate=${EndDate}    Address=${Address}
    RETURN    ${Data}


# =====================================================================
# 3. กรณีทดสอบของยูสเคส (TC04_F01 - TC04_F03)
# =====================================================================

กรณี TC04_F01
    [Documentation]    Basic Flow ของเอกสาร : กรอกครบถูกต้อง ยอมรับข้อกำหนด แล้วต้องจองสำเร็จจริง
    ...                กรณีนี้สร้างรายการจองจริงในระบบ 1 รายการทุกครั้งที่รัน
    [Arguments]    ${Data}

    เตรียมฟอร์มจอง    ${Data}
    ${Filled}=    กรอกฟอร์มจอง    ${Data}

    ${Clicked}=    Click Booking Button
    Should Be True    ${Clicked}    msg=ปุ่มสั่งจองถูกปิดใช้งาน จึงยังทดสอบการจองไม่ได้

    ${Terms}=    Is Terms Popup Shown
    เก็บภาพหลักฐาน    ข้อกำหนดการเช่า
    Should Be True    ${Terms}    msg=กดสั่งจองแล้วแต่ popup ข้อกำหนดไม่เด้ง (${Filled})

    ${Accepted}=    Accept Booking Terms
    Should Be True    ${Accepted}    msg=ติ๊กยอมรับแล้วแต่กดปุ่ม "ยอมรับ" ไม่ได้

    ${Message}=    Get Popup Title
    เก็บภาพหลักฐาน    ผลการจอง
    บันทึกผลที่ได้จริง    ${Message}

    Should Contain    ${Message}    ${BOOK_SUCCESS}
    ...    msg=ยอมรับข้อกำหนดแล้ว แต่ระบบตอบว่า "${Message}" ไม่ใช่ "${BOOK_SUCCESS}"

    # Basic Flow ข้อ 6 ของเอกสาร : "ระบบแสดงผลให้ไปหน้าดูรายการจอง" — ตรวจแบบ WARN ไม่ Fail
    # เพราะยังไม่เคยเห็นพฤติกรรมจริงว่า redirect เกิดทันทีหรือต้องกด popup ปิดก่อน ถ้ารันแล้วเจอว่า
    # redirect ปกติทุกครั้ง ค่อยเปลี่ยนเป็น Should Be True (hard fail) ได้
    ${WentToBookingList}=    รอไปหน้ารายการจอง    ${10}
    IF    not ${WentToBookingList}
        ${Url}=    Get Url
        Log    จองสำเร็จแล้วแต่ยังไม่ไปหน้ารายการจอง (${MyBooking_farmerURL}) ภายใน 10 วิ อยู่ที่ ${Url} แทน    level=WARN
    END

กรณี TC04_F02
    [Documentation]    BK01-01 : ไม่กรอกอะไรเลยแล้วกดสั่งจอง ระบบต้องไม่ให้ทำรายการ
    [Arguments]    ${Data}

    เตรียมฟอร์มจอง    ${Data}
    Input Booking Address    ${EMPTY}

    ${Clicked}=    Click Booking Button
    ${Terms}=      Is Terms Popup Shown
    ${NoDate}=     Create List
    ${Empty}=      Create Dictionary    Blocked=${NoDate}
    ${Result}=     อ่านผลจากระบบ    ${Empty}    ${Clicked}
    เก็บภาพหลักฐาน    ผลการไม่กรอกข้อมูล

    บันทึกผลที่ได้จริง    ${Result}
    Should Not Be True    ${Terms}
    ...    msg=ไม่ได้กรอกข้อมูลเลย แต่ระบบเปิด popup ข้อกำหนดให้จองต่อได้

กรณี TC04_F03
    [Documentation]    ไม่ติ๊กยอมรับข้อกำหนด ระบบต้องไม่บันทึกการจอง
    ...                ตาม Post-Condition ของเอกสารที่ต้องผ่านหน้า Acceptance of the Terms of Use ก่อน
    [Arguments]    ${Data}

    เตรียมฟอร์มจอง    ${Data}
    กรอกฟอร์มจอง    ${Data}

    ${Clicked}=    Click Booking Button
    Should Be True    ${Clicked}    msg=ปุ่มสั่งจองถูกปิดใช้งาน จึงยังทดสอบข้อกำหนดไม่ได้

    ${Terms}=    Is Terms Popup Shown
    Should Be True    ${Terms}    msg=กดสั่งจองแล้วแต่ popup ข้อกำหนดไม่เด้ง

    # ไม่ติ๊ก checkbox แล้วกดยอมรับเลย ระบบควรปิดปุ่มไว้
    ${Accepted}=    Click Button If Enabled    ${Btn_AcceptTerms}
    ${Message}=     Get Popup Title
    เก็บภาพหลักฐาน    ไม่ติ๊กยอมรับข้อกำหนด

    ${Detail}=    Set Variable If    '${Message}' != '${EMPTY}'    ${Message}
    ...    กดปุ่มยอมรับได้ = ${Accepted} โดยยังไม่ติ๊กข้อกำหนด
    บันทึกผลที่ได้จริง    ${Detail}

    ${Booked}=    Evaluate    "${BOOK_SUCCESS}" in $Message
    Should Not Be True    ${Booked}
    ...    msg=ระบบจองให้ทั้งที่ยังไม่ได้ติ๊กยอมรับข้อกำหนด (${Detail})


# =====================================================================
# 4. ขั้นตอนย่อยของยูสเคส (ทำซ้ำจาก Testcase/Booking_farmer.robot เฉพาะส่วนที่ต้องใช้)
# =====================================================================

เตรียมฟอร์มจอง
    [Documentation]    เข้าสู่ระบบ เพิ่มอุปกรณ์ลงตะกร้า แล้วเปิดกล่องตะกร้าที่มีฟอร์มจองอยู่
    ...                เป็น Pre-Condition ของเอกสาร คือต้องเข้าสู่ระบบและมีอุปกรณ์ในตะกร้าก่อน
    [Arguments]    ${Data}

    Run Keyword And Ignore Error    Close Test Context
    Open Login Page
    Run Keyword And Ignore Error    Handle Future Dialogs    action=accept

    Input Username    ${LOGIN_USERNAME}
    Input Password    ${LOGIN_PASSWORD}
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
    ...                ช่องวันที่เป็น readonly จึงเลือกจากปฏิทินเท่านั้น ค่าว่างในข้อมูลทดสอบแปลว่าไม่ต้องแตะช่องนั้น
    [Arguments]    ${Data}

    ${Start}=    เลือกวันที่ลงช่อง    ${Text_StartDate}    ${Data}[StartDate]
    ${End}=      เลือกวันที่ลงช่อง    ${Text_EndDate}      ${Data}[EndDate]
    Input Booking Address    ${Data}[Address]

    # รวมทั้งวันที่ที่ระบบปิดไม่ให้เลือก และค่าวันที่ที่อ่านไม่ออก ทั้งสองอย่างแปลว่ายังไม่ได้เลือกวันที่จริง
    ${Blocked}=    Create List
    FOR    ${Text}    IN    ${Start}    ${End}
        ${Bad}=    Evaluate    "ระบบปิดวันที่" in $Text or "รูปแบบวันที่" in $Text
        IF    ${Bad}    Append To List    ${Blocked}    ${Text}
    END

    ${Summary}=    Create Dictionary    Start=${Start}    End=${End}    Blocked=${Blocked}
    Log    ผลการกรอกฟอร์ม : ${Summary}    level=INFO
    RETURN    ${Summary}

เลือกวันที่ลงช่อง
    [Documentation]    แปลงค่าที่กำหนดเป็นวันที่จริงแล้วเลือกจากปฏิทิน คืนข้อความบอกผล
    ...                ค่าว่างแปลว่ากรณีทดสอบตั้งใจไม่เลือกวันที่ จึงไม่แตะช่องนั้นเลย
    [Arguments]    ${Field}    ${Token}

    IF    '${Token}' == '${EMPTY}'    RETURN    ไม่ได้เลือกวันที่

    # FIRST / FIRST+n = ให้สคริปต์ถามปฏิทินเองว่าวันแรกที่ระบบยอมให้เลือกคือวันไหน แล้วนับต่อจากวันนั้น
    # ใช้เพราะระบบจริงใส่ buffer 3 วันต่อท้ายทุกช่วงที่ถูกจองไว้ วันที่ตายตัวจึงมีโอกาสชนกับรอบรันก่อนหน้า
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
        IF    $Date is None    RETURN    รูปแบบวันที่ "${Token}" อ่านไม่ออก จึงเลือกจากปฏิทินไม่ได้
    END

    ${MonthIndex}=    Evaluate    $Date.year * 12 + $Date.month
    ${Result}=    Pick Date From Calendar    ${Field}    ${Date.day}    ${MonthIndex}    ${Display}
    Log    ${Token} -> ${Display} : ${Result}    level=INFO
    RETURN    ${Result}

แปลงค่าวันที่
    [Documentation]    แปลงค่าวันที่ (AUTO+n หรือวันที่ตายตัว) เป็นวันที่จริง คืน 2 ค่า คือ วันที่ และ ข้อความที่ใช้แสดงในรายงาน
    ...                คืน None เมื่ออ่านค่าไม่ออก
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
        ${Year}=     เทียบปีให้เป็น ค.ศ.    ${Parts}[2]

        ${Ok}    ${Date}=    Run Keyword And Ignore Error
        ...    Evaluate    datetime.date(${Year}, ${Month}, ${Day})    modules=datetime
        IF    '${Ok}' == 'PASS'    RETURN    ${Date}    ${Text}

        Log    วันที่ ${Text} ไม่มีอยู่จริงในปฏิทิน    level=WARN
        RETURN    ${None}    ${Text}
    END

    Log    อ่านค่าวันที่ "${Text}" ไม่ออก    level=WARN
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


รอไปหน้ารายการจอง
    [Documentation]    รอจน URL เป็นหน้ารายการจองของเกษตรกร (${MyBooking_farmerURL}) ภายในเวลาที่กำหนด
    ...                ใช้แบบเดียวกับ "รอกลับหน้าหลัก" ใน Usecase_Login_farmer.robot
    [Arguments]    ${Rounds}=${10}
    FOR    ${Round}    IN RANGE    ${Rounds}
        ${Url}=    Get Url
        ${Now}=    Evaluate    $Url.rstrip('/') == '${MyBooking_farmerURL}'.rstrip('/')
        IF    ${Now}    RETURN    ${True}
        Sleep    0.5s
    END
    RETURN    ${False}


# =====================================================================
# 5. คีย์เวิร์ดช่วยเหลือ
# =====================================================================

บันทึกผลที่ได้จริง
    [Documentation]    จำข้อความที่ระบบตอบกลับไว้ ให้ teardown ใช้เขียน log เมื่อกรณีทดสอบไม่ผ่าน
    [Arguments]    ${Text}
    Set Test Variable    ${ACTUAL_MESSAGE}    ${Text}

เก็บภาพหลักฐาน
    [Documentation]    บันทึกภาพหน้าจอไว้เป็นหลักฐานประกอบรายงาน ตั้งชื่อเป็น <ยูสเคส>_<รหัส>_<คำอธิบาย>
    [Arguments]    ${Name}
    Run Keyword And Ignore Error
    ...    Take Screenshot    ${SCREENSHOT_DIR}/${USECASE}_${TC_ID}_${Name}    fullPage=True

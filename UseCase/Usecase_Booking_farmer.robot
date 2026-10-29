*** Settings ***
Documentation     TC04 - Booking Equipment Farmer (Usecase) | อ้างอิงเอกสาร Test Case หน้า 69-78 (TC04_F01-F03)
...               ทดสอบเฉพาะ Flow (ทดสอบฟิลด์ TC04_01-17 อยู่ที่ Testcase/Booking_farmer.robot) ใช้ข้อมูลคงที่ในสคริปต์
...               Pre-Condition: ต้อง login และมีอุปกรณ์ในตะกร้าก่อน (ขึ้นกับ TC01 Login, TC03 Add Cart)
...               ตัด BK01-03/BK01-04 ออก เพราะซ้ำกับ TC04_08/TC04_04 ในไฟล์ฟิลด์ 100% แล้ว
Metadata          Use Case    TC04 Booking Equipment Farmer (ทดสอบยูสเคส)

Resource          ../Resources/keywords.robot
Library           OperatingSystem
Library           String
Library           Collections

Suite Setup       เตรียมชุดทดสอบยูสเคส
Suite Teardown    ปิดชุดทดสอบ
Test Teardown     เก็บผลท้ายกรณีทดสอบ

*** Variables ***
# ---------- ไฟล์และโฟลเดอร์ ----------
${USECASE}            TC04_Usecase_Booking_Farmer
${SCREENSHOT_DIR}     ${CURDIR}/../Screenshot/${USECASE}

# ---------- ข้อความที่คาดหวังตามเอกสารเทสเคส (เทียบตรงกัน 100%) ----------
${EXP_LOGIN_SUCCESS}      เข้าสู่ระบบสำเร็จ     # BK01-03 / BK02-03 / BK03-03
${EXP_BOOK_SUCCESS}       การจองสำเร็จ!         # BK01-10
${POPUP_TIMEOUT}          10s

# ---------- บัญชีคงที่ : ผู้ใช้สร้างไว้ล่วงหน้าในระบบจริงแล้ว (บัญชีเดียวกับ Usecase_Login_farmer) ----------
${LOGIN_USERNAME}     somchaikaew
${LOGIN_PASSWORD}     Somc1442!

# ---------- อุปกรณ์ที่ใช้ทดสอบ : ต้องมีอยู่จริงในระบบและว่างให้จองได้ ----------
# หน้าค้นหาไม่มีตัวเลือก "ทุกประเภท" (ค่าเริ่มต้นคือแทรกเตอร์) จึงต้องเลือกประเภทให้ตรงกับอุปกรณ์ที่จะจอง
${BOOK_EQ_TYPE}       รถไถเดินตาม
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
    #TC04-BK01 : กรอกครบถูกต้อง ยอมรับข้อกำหนด ต้องได้ "การจองสำเร็จ!" และไปหน้ารายการจองของฉัน (สร้างรายการจองจริงทุกครั้งที่รัน)
    Set Test Variable    ${TC_ID}    TC04_F01
    ${Data}=    สร้างข้อมูลทดสอบ    ${VALID_START}    ${VALID_END}    ${VALID_ADDRESS}
    กรณี TC04_F01    ${Data}

TC04_F02 - ไม่กรอกข้อมูลเลยแล้วกดสั่งจอง
    #TC04-BK02 : ไม่กรอกอะไรเลย ปุ่มสั่งจองต้องถูกปิดใช้งาน และไม่เปิด popup ข้อกำหนด
    Set Test Variable    ${TC_ID}    TC04_F02
    ${Data}=    สร้างข้อมูลทดสอบ    ${VALID_START}    ${VALID_END}    ${VALID_ADDRESS}
    กรณี TC04_F02    ${Data}

TC04_F03 - ไม่ติ๊กยอมรับข้อกำหนด
    #TC04-BK03 : ไม่ติ๊กยอมรับข้อกำหนด ปุ่ม "ยอมรับ" ต้องถูกปิดใช้งาน ระบบไม่บันทึกการจอง
    Set Test Variable    ${TC_ID}    TC04_F03
    ${Data}=    สร้างข้อมูลทดสอบ    ${VALID_START}    ${VALID_END}    ${VALID_ADDRESS}
    กรณี TC04_F03    ${Data}

*** Keywords ***
# =====================================================================
# 1. เตรียมข้อมูลทดสอบ
# =====================================================================

สร้างข้อมูลทดสอบ
    #สร้าง Dictionary ข้อมูลสำหรับกรณีทดสอบ ใช้อุปกรณ์คงที่ร่วมกับวันที่และที่อยู่ที่ระบุ
    [Arguments]    ${StartDate}    ${EndDate}    ${Address}
    ${Data}=    Create Dictionary
    ...    EquipmentType=${BOOK_EQ_TYPE}    EquipmentName=${BOOK_EQ_NAME}
    ...    StartDate=${StartDate}           EndDate=${EndDate}    Address=${Address}
    RETURN    ${Data}

# =====================================================================
# 2. กรณีทดสอบของยูสเคส (TC04_F01 - TC04_F03)
# =====================================================================

กรณี TC04_F01
    #BK01-05 ถึง BK01-10 : popup ข้อกำหนดต้องเด้ง ยอมรับแล้วต้องได้ "การจองสำเร็จ!" และไปหน้ารายการจองของฉัน
    [Arguments]    ${Data}

    เตรียมฟอร์มจอง    ${Data}
    ${Filled}=    กรอกฟอร์มจอง    ${Data}

    ${Clicked}=    Click Booking Button
    Should Be True    ${Clicked}    msg=ปุ่มสั่งจองถูกปิดใช้งาน จึงยังทดสอบการจองไม่ได้ (${Filled})

    # BK01-09 : ต้องเด้ง popup ข้อกำหนดการใช้งาน
    ${Terms}=    Is Terms Popup Shown
    Should Be True    ${Terms}    msg=กดสั่งจองแล้วแต่ popup ข้อกำหนดไม่เด้ง (${Filled})

    # BK01-10 : ติ๊กยอมรับแล้วกด "ยอมรับ" หัวข้อ popup ต้องเป็น "การจองสำเร็จ!" ตรงตัว
    ${Accepted}=    Accept Booking Terms
    Should Be True    ${Accepted}    msg=ติ๊กยอมรับแล้วแต่กดปุ่ม "ยอมรับ" ไม่ได้
    ${HasPopup}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Popup_Title}    visible    ${POPUP_TIMEOUT}
    ${Message}=    Set Variable    ${EMPTY}
    IF    ${HasPopup}
        ${Message}=    Get Popup Title
    END
    บันทึกผลที่ได้จริง    ${Message}
    เทียบผลจริงกับที่คาดหวัง    ${Message}    ${EXP_BOOK_SUCCESS}

    # BK01-10 : ระบบพาไปหน้ารายการจองของฉันหลังผู้ใช้กด "ตกลง" บน popup เท่านั้น จึงต้องกดปุ่มก่อนรอเปลี่ยนหน้า
    ${Confirmed}=    Click Button If Enabled    ${Btn_PopupConfirm}
    Should Be True    ${Confirmed}    msg=ไม่พบปุ่ม "ตกลง" บน popup การจองสำเร็จ
    ${WentToBookingList}=    รอไปหน้ารายการจอง    ${20}
    ${Url}=    Get Url
    Should Be True    ${WentToBookingList}
    ...    msg=จองสำเร็จแล้วแต่ระบบไม่พาไปหน้ารายการจอง (${MyBooking_farmerURL}) อยู่ที่ ${Url}

กรณี TC04_F02
    #BK02-05 ถึง BK02-06 : ไม่กรอกข้อมูลใด ๆ ปุ่มสั่งจองต้องถูกปิดใช้งาน และไม่เปิด popup ข้อกำหนด
    [Arguments]    ${Data}

    เตรียมฟอร์มจอง    ${Data}
    Input Booking Address    ${EMPTY}

    ${Clicked}=    Click Booking Button
    ${Terms}=      Is Terms Popup Shown
    ${State}=      Set Variable If    ${Clicked}    ปุ่มสั่งจองกดได้    ปุ่มสั่งจองถูกปิดใช้งาน
    บันทึกผลที่ได้จริง    ${State}

    Should Not Be True    ${Clicked}    msg=ไม่ได้กรอกข้อมูลเลย แต่ปุ่มสั่งจองยังกดได้
    Should Not Be True    ${Terms}      msg=ไม่ได้กรอกข้อมูลเลย แต่ระบบเปิด popup ข้อกำหนดให้จองต่อได้

กรณี TC04_F03
    #BK03-06 ถึง BK03-07 : popup ข้อกำหนดต้องเด้ง และเมื่อไม่ติ๊กยอมรับ ปุ่ม "ยอมรับ" ต้องถูกปิดใช้งาน
    [Arguments]    ${Data}

    เตรียมฟอร์มจอง    ${Data}
    กรอกฟอร์มจอง    ${Data}

    ${Clicked}=    Click Booking Button
    Should Be True    ${Clicked}    msg=ปุ่มสั่งจองถูกปิดใช้งาน จึงยังทดสอบข้อกำหนดไม่ได้

    ${Terms}=    Is Terms Popup Shown
    Should Be True    ${Terms}    msg=กดสั่งจองแล้วแต่ popup ข้อกำหนดไม่เด้ง

    ${Accepted}=    Click Button If Enabled    ${Btn_AcceptTerms}
    ${State}=       Set Variable If    ${Accepted}    ปุ่มยอมรับกดได้    ปุ่มยอมรับถูกปิดใช้งาน
    บันทึกผลที่ได้จริง    ${State}
    Should Not Be True    ${Accepted}    msg=ยังไม่ได้ติ๊กยอมรับข้อกำหนด แต่ปุ่ม "ยอมรับ" ยังกดได้

# =====================================================================
# 3. ขั้นตอนย่อยของยูสเคส (ทำซ้ำจาก Testcase/Booking_farmer.robot เฉพาะส่วนที่ต้องใช้)
# =====================================================================

เตรียมฟอร์มจอง
    #เข้าสู่ระบบ เพิ่มอุปกรณ์ลงตะกร้า เปิดกล่องตะกร้าที่มีฟอร์มจอง (Pre-Condition ของเอกสาร)
    [Arguments]    ${Data}

    Run Keyword And Ignore Error    Close Test Context
    Open Login Page
    Run Keyword And Ignore Error    Handle Future Dialogs    action=accept

    Input Username    ${LOGIN_USERNAME}
    Input Password    ${LOGIN_PASSWORD}
    Keyboard Key      press    Tab
    ${Clicked}=    Click Button If Enabled    ${Btn_Login}
    Should Be True    ${Clicked}    msg=ปุ่มเข้าสู่ระบบถูกปิดใช้งาน จึงยังทดสอบการจองไม่ได้

    # BK01-03 : หัวข้อ popup ต้องเป็น "เข้าสู่ระบบสำเร็จ"
    ${HasPopup}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Popup_Title}    visible    ${POPUP_TIMEOUT}
    ${Message}=    Set Variable    ${EMPTY}
    IF    ${HasPopup}
        ${Message}=    Get Popup Title
    END
    บันทึกผลที่ได้จริง    ${Message}
    เทียบผลจริงกับที่คาดหวัง    ${Message}    ${EXP_LOGIN_SUCCESS}
    Close Login Popup
    Open Search Equipment Page
    Clear Cart

    ${Cards}=    ค้นหาอุปกรณ์    ${Data}[EquipmentType]    ${Data}[EquipmentName]
    Should Be True    ${Cards} > 0
    ...    msg=ค้นหา "${Data}[EquipmentName]" แล้วไม่พบอุปกรณ์ จึงยังทดสอบการจองไม่ได้ — ตรวจว่ามีอุปกรณ์ชื่อนี้อยู่ในระบบจริง

    # BK01-05 : เพิ่มลงตะกร้าแล้วปุ่มบนการ์ดต้องเป็น "อยู่ในตะกร้าแล้ว"
    ${Added}=    Click Add To Cart
    Should Be True    ${Added}    msg=เพิ่มอุปกรณ์ลงตะกร้าไม่ได้ จึงยังทดสอบการจองไม่ได้
    ${State}=    Get Equipment Button State
    เทียบผลจริงกับที่คาดหวัง    ${State}    ${State_InCart}

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
    #อ่านข้อความ "สถานะ: ..." บนการ์ดในตะกร้า คืนว่างเมื่ออ่านไม่ได้ (ไม่ใช่สถานะผิด)
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
    #BK01-04 : เลือกประเภท (ว่าง=ไม่กรอง) แล้วพิมพ์ชื่อค้นหา คืนจำนวนการ์ดที่พบ
    [Arguments]    ${Type}    ${Name}
    Select Equipment Type     ${Type}
    Input Search Equipment    ${Name}
    ${Cards}=    Get Equipment Card Count
    RETURN    ${Cards}

กรอกฟอร์มจอง
    #เลือกวันเริ่ม/สิ้นสุดจากปฏิทิน (ช่อง readonly) และกรอกที่อยู่ คืนสรุปผลแต่ละช่อง ค่าว่าง=ไม่แตะช่องนั้น
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
    #แปลงค่าที่กำหนดเป็นวันที่จริงแล้วเลือกจากปฏิทิน คืนข้อความบอกผล (ค่าว่าง=ตั้งใจไม่เลือกวันที่)
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
    #แปลงวันที่ตายตัว (วว/ดด/ปปปป) เป็นวันที่จริง คืน (วันที่, ข้อความแสดงผล) หรือ None เมื่ออ่านไม่ออก
    [Arguments]    ${Token}
    ${Text}=    Strip String    ${Token}

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

รอไปหน้ารายการจอง
    #รอจน URL เป็นหน้ารายการจอง (${MyBooking_farmerURL}) ภายในเวลาที่กำหนด
    [Arguments]    ${Rounds}=${10}
    FOR    ${Round}    IN RANGE    ${Rounds}
        ${Url}=    Get Url
        ${Now}=    Evaluate    $Url.rstrip('/') == '${MyBooking_farmerURL}'.rstrip('/')
        IF    ${Now}    RETURN    ${True}
        Sleep    0.5s
    END
    RETURN    ${False}

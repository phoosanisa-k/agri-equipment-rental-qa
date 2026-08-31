*** Settings ***
Documentation     TC04 - Approve Booking Owner | ทดสอบยูสเคส "อนุมัติการจอง" ของเจ้าของอุปกรณ์
...
...               *** ยังต้องตั้งค่าบัญชีทดสอบก่อนรัน ***
...               ดูรายการที่ต้องเติมได้จากคีย์เวิร์ด "ตรวจว่าตั้งค่าครบแล้วหรือยัง" ด้านล่าง
...               ทุกแถวในชีตจึงตั้ง ${Run} = No ไว้ก่อน เปลี่ยนเป็น Yes เมื่อเติมค่าครบแล้ว
...
...               หน้ารายการจองของเจ้าของอุปกรณ์ไม่ได้ใช้ปุ่ม "อนุมัติ/ปฏิเสธ" ตรง ๆ
...               แต่เป็นการเลื่อนสถานะไปทีละขั้นผ่านปุ่ม อัปเดตเป็น "<สถานะถัดไป>"
...               การ "อนุมัติการจอง" ตามเอกสารจึงหมายถึงการอัปเดตรายการที่อยู่ในแท็บ "รอดำเนินการ"
...               ไปยังสถานะถัดไป และการ "ปฏิเสธ" คือปุ่มยกเลิกการจองซึ่งมีกล่องยืนยันของตัวเอง
...
...               เอกสาร Test Case ข้อ 8.4 ไม่มีตาราง EC/BVA มีแต่ Flow ตามตาราง AB01
...               ครอบคลุม TC04_F01 - TC04_F05 คือ
...                 TC04_F01  อัปเดตสถานะการจองที่รอดำเนินการไปขั้นถัดไป (Basic Flow 1-7)
...                 TC04_F02  อัปเดตรายการที่ช่วงเวลาชนกับผู้จองรายอื่น   (AB01-01)
...                 TC04_F03  ยกเลิกการจอง                              (AB01-02)
...                 TC04_F04  กดอัปเดตซ้ำรายการที่อัปเดตไปแล้ว            (AB01-04)
...                 TC04_F05  กดยกเลิกซ้ำรายการที่ยกเลิกไปแล้ว            (AB01-05)
...
...               เอกสารมี AB01-03 "ไม่พบข้อมูลการจอง" ด้วย แต่สถานการณ์นั้นเกิดจริงผ่านหน้าเว็บไม่ได้
...               (ปุ่มอนุมัติแสดงเฉพาะรายการที่มีอยู่จริง) จึงไม่ได้ทำเป็นกรณีทดสอบอัตโนมัติ
...
...               Pre-Condition ของเอกสารคือต้องมีคำขอการจองเข้ามา ชุดทดสอบนี้จึงสร้างการจองเอง
...               ตอนเปิดชุดทดสอบ โดยใช้คีย์เวิร์ดฝั่งเกษตรกรที่มีอยู่แล้วใน keywords.robot
Metadata          System      ระบบเว็บศูนย์กลางให้บริการเช่าอุปกรณ์ทางการเกษตร (SRS v7.0)
Metadata          Use Case    TC04 Approve Booking Owner
Metadata          Test Data   TestData/Data.xlsx (sheet: ApproveBooking_Owner)
Metadata          Status      ต้องเติมบัญชีทดสอบใน variables.robot ก่อนรัน

Resource          ../Resources/keywords.robot
Library           DataDriver    file=${CURDIR}/../TestData/Data.xlsx    sheet_name=ApproveBooking_Owner
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
${DATA_FILE}      ${CURDIR}/../TestData/Data.xlsx
${SHEET}          ApproveBooking_Owner
${SCREENSHOT_DIR}    ${CURDIR}/../Screenshot
${USECASE}        TC04_ApproveBooking_Owner

# ---------- ตำแหน่งคอลัมน์ในชีต ----------
${COL_ID}         ${2}     # คอลัมน์ B : ${TestCase}
${COL_ACTUAL}     ${9}     # คอลัมน์ I : ${ActualResult}
${COL_PF}         ${10}    # คอลัมน์ J : ${Result}

# ---------- ข้อความและตัวชี้วัดที่ใช้ตัดสินผล ----------
${SUCCESS_KEYWORD}    สำเร็จ
${BOOK_SUCCESS}       การจองสำเร็จ
${NO_RESPONSE}        ไม่พบข้อความตอบกลับจากระบบ

# ---------- ตัวแปรระดับกรณีทดสอบ ใช้ส่งข้อมูลให้ teardown ----------
${TC_ID}             UNKNOWN
${ROW_NUM}           ${0}
${ACTUAL_MESSAGE}    ${EMPTY}

# สรุปข้อมูลตั้งต้นที่สร้างไว้ตอนเปิดชุดทดสอบ ใช้อธิบายในข้อความเมื่อกรณีทดสอบล้ม
${SETUP_SUMMARY}     ยังไม่ได้สร้างข้อมูลตั้งต้น


*** Test Cases ***
Approve Booking Owner : ${TestCase}


*** Keywords ***
# =====================================================================
# 1. การเตรียมและปิดชุดทดสอบ
# =====================================================================

เปิดชุดทดสอบ
    [Documentation]    ล้างภาพของรอบก่อน เปิดไฟล์ Excel เปิดเบราว์เซอร์
    ...                สร้างการจองตั้งต้น แล้วเข้าสู่ระบบเป็น Owner ค้างไว้ทั้งชุด
    Create Directory    ${SCREENSHOT_DIR}
    ลบภาพของรอบก่อน    ${SCREENSHOT_DIR}

    Open Excel Document    ${DATA_FILE}    ApproveBookingOwner
    Open Test Browser

    ตรวจว่าตั้งค่าครบแล้วหรือยัง
    สร้างการจองตั้งต้น
    เข้าสู่ระบบเป็นเจ้าของอุปกรณ์

ตรวจว่าตั้งค่าครบแล้วหรือยัง
    [Documentation]    ล้มทั้งชุดพร้อมบอกสิ่งที่ยังขาด ดีกว่าปล่อยให้ล้มทีละเคสโดยไม่รู้สาเหตุ
    ...                รายการนี้คือทุกอย่างที่ต้องเติมใน Resources/variables.robot ก่อนรันจริง
    ${Missing}=    Create List
    FOR    ${Name}    ${Value}    IN
    ...    \${OwnerUser}           ${OwnerUser}
    ...    \${OwnerPass}           ${OwnerPass}
    ...    \${AB_FARMER1_USER}     ${AB_FARMER1_USER}
    ...    \${AB_FARMER1_PASS}     ${AB_FARMER1_PASS}
    ...    \${AB_FARMER2_USER}     ${AB_FARMER2_USER}
    ...    \${AB_FARMER2_PASS}     ${AB_FARMER2_PASS}
    ...    \${AB_EQ_NAME}          ${AB_EQ_NAME}
        ${Length}=    Get Length    ${Value}
        IF    ${Length} == 0    Append To List    ${Missing}    ${Name}
    END

    ${Count}=    Get Length    ${Missing}
    IF    ${Count} > 0
        ${List}=    Evaluate    ", ".join($Missing)
        Fail    ยังตั้งค่าไม่ครบ กรุณาเติม ${List} ใน Resources/variables.robot ก่อนรันชุดทดสอบนี้
    END

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
    Run Keyword And Ignore Error    Save Excel Document    ${DATA_FILE}
    Run Keyword And Ignore Error    Close All Excel Documents
    Close All Test Browsers

เก็บผลท้ายกรณีทดสอบ
    [Documentation]    เก็บภาพเมื่อไม่ผ่าน แล้วเขียนผลกลับลง Excel
    ...                ไม่ปิด context เพราะต้องรักษาสถานะเข้าสู่ระบบของ Owner ไว้ให้กรณีถัดไป
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

    # ปิดกล่องโต้ตอบที่ค้างอยู่ ให้กรณีถัดไปเริ่มจากหน้ารายการจองตามปกติ
    Run Keyword And Ignore Error    Acknowledge Booking Dialog
    Run Keyword And Ignore Error    Dismiss Booking Dialog


# =====================================================================
# 2. การอ่านและเขียนไฟล์ Excel
# =====================================================================

หาแถวของกรณีทดสอบ
    [Documentation]    ค้นหมายเลขแถวจากรหัสกรณีทดสอบในคอลัมน์ B (index 0 คือหัวตาราง แถวจึงเป็น index + 1)
    ...                คืน 0 เมื่อไม่พบ เพื่อให้ teardown ข้ามการเขียนผลแทนที่จะล้ม
    [Arguments]    ${TestCase}
    ${Ids}=    Read Excel Column    ${COL_ID}    sheet_name=${SHEET}
    ${Ids}=    Evaluate    ["" if v is None else str(v).strip() for v in $Ids]

    ${Found}=    Run Keyword And Return Status    List Should Contain Value    ${Ids}    ${TestCase}
    IF    not ${Found}
        Log    ไม่พบ ${TestCase} ในคอลัมน์ B ของชีต ${SHEET} จึงไม่เขียนผลกลับ    level=WARN
        RETURN    ${0}
    END

    ${Index}=    Get Index From List    ${Ids}    ${TestCase}
    ${Row}=      Evaluate    ${Index} + 1
    RETURN    ${Row}

บันทึกผลลง Excel
    [Documentation]    เขียนผลที่ได้จริงและสถานะ Pass/Fail กลับลงไฟล์ Excel ตามแถวของกรณีทดสอบ
    [Arguments]    ${Row}    ${ActualResult}    ${ResultPF}
    Write Excel Cell       ${Row}    ${COL_ACTUAL}    ${ActualResult}    sheet_name=${SHEET}
    Write Excel Cell       ${Row}    ${COL_PF}        ${ResultPF}        sheet_name=${SHEET}
    Save Excel Document    ${DATA_FILE}


# =====================================================================
# 3. การเตรียมข้อมูลตั้งต้น (Pre-Condition : ต้องมีคำขอการจองเข้ามา)
# =====================================================================

สร้างการจองตั้งต้น
    [Documentation]    สร้างรายการจองสถานะ "รอดำเนินการ" ไว้ให้ชุดทดสอบใช้
    ...                จองด้วยเกษตรกร 2 บัญชี ในช่วงเวลาเดียวกันของอุปกรณ์ชิ้นเดียวกัน
    ...                รายการของบัญชีที่ 2 คือรายการที่ช่วงเวลาชนกัน ใช้ในเคส TC04_F02
    ${Start}    ${StartText}=    วันที่นับจากวันนี้    3
    ${End}      ${EndText}=      วันที่นับจากวันนี้    5

    ${First}=    จองอุปกรณ์ด้วยบัญชีเกษตรกร
    ...    ${AB_FARMER1_USER}    ${AB_FARMER1_PASS}    ${Start}    ${End}
    Log    การจองของ ${AB_FARMER1_USER} : ${First}    level=INFO

    ${Second}=    จองอุปกรณ์ด้วยบัญชีเกษตรกร
    ...    ${AB_FARMER2_USER}    ${AB_FARMER2_PASS}    ${Start}    ${End}
    Log    การจองของ ${AB_FARMER2_USER} (ช่วงเวลาชนกัน) : ${Second}    level=INFO

    Set Suite Variable    ${SETUP_SUMMARY}
    ...    ช่วงเวลา ${StartText} ถึง ${EndText} | ${AB_FARMER1_USER} : ${First} | ${AB_FARMER2_USER} : ${Second}

จองอุปกรณ์ด้วยบัญชีเกษตรกร
    [Documentation]    เข้าสู่ระบบเป็นเกษตรกร ค้นหาอุปกรณ์ เพิ่มลงตะกร้า แล้วสั่งจองตามช่วงเวลาที่ระบุ
    ...                คืนข้อความที่ระบบตอบกลับ ไม่ล้มเมื่อจองไม่สำเร็จ เพราะการจองซ้ำช่วงเวลาเดิม
    ...                อาจถูกระบบปฏิเสธตั้งแต่ตอนสร้างข้อมูล ซึ่งก็ยังใช้ทดสอบต่อได้
    [Arguments]    ${Username}    ${Password}    ${Start}    ${End}

    Run Keyword And Ignore Error    Close Test Context
    Open Login Page
    Run Keyword And Ignore Error    Handle Future Dialogs    action=accept

    Input Username    ${Username}
    Input Password    ${Password}
    Keyboard Key      press    Tab
    ${Clicked}=    Click Button If Enabled    ${Btn_Login}
    Should Be True    ${Clicked}
    ...    msg=เข้าสู่ระบบด้วยบัญชีเกษตรกร "${Username}" ไม่ได้ จึงสร้างข้อมูลตั้งต้นไม่ได้

    Close Login Popup
    Open Search Equipment Page
    Clear Cart

    Select Equipment Type     ${EMPTY}
    Input Search Equipment    ${AB_EQ_NAME}
    ${Cards}=    Get Equipment Card Count
    Should Be True    ${Cards} > 0
    ...    msg=ค้นหา "${AB_EQ_NAME}" แล้วไม่พบอุปกรณ์ จึงสร้างข้อมูลตั้งต้นไม่ได้

    ${Added}=    Click Add To Cart
    Should Be True    ${Added}    msg=เพิ่มอุปกรณ์ลงตะกร้าไม่ได้ จึงสร้างข้อมูลตั้งต้นไม่ได้

    ${Opened}=    Open Cart
    Should Be True    ${Opened}    msg=เปิดกล่องตะกร้าไม่ได้ จึงยังไม่เห็นฟอร์มจอง

    เลือกวันที่ลงช่อง    ${Text_StartDate}    ${Start}
    เลือกวันที่ลงช่อง    ${Text_EndDate}      ${End}
    Input Booking Address    99/12 หมู่ 5 ต.สุเทพ อ.เมือง เชียงใหม่

    ${Clicked}=    Click Booking Button
    IF    not ${Clicked}    RETURN    ปุ่มสั่งจองถูกปิดใช้งาน จึงไม่ได้สร้างรายการจอง

    ${Terms}=    Is Terms Popup Shown
    IF    not ${Terms}
        ${Message}=    Get Popup Title
        RETURN    ไม่ผ่านขั้นข้อกำหนดการเช่า (${Message})
    END

    Accept Booking Terms
    ${Message}=    Get Popup Title
    RETURN    ${Message}

เลือกวันที่ลงช่อง
    [Documentation]    เลือกวันที่จากปฏิทินลงช่องที่ระบุ ช่องวันที่เป็น readonly จึงพิมพ์ตรง ๆ ไม่ได้
    [Arguments]    ${Field}    ${Date}
    ${MonthIndex}=    Evaluate    $Date.year * 12 + $Date.month
    ${Display}=       Set Variable    ${Date.day}/${Date.month}/${Date.year}
    ${Result}=    Pick Date From Calendar    ${Field}    ${Date.day}    ${MonthIndex}    ${Display}
    Log    เลือกวันที่ ${Display} : ${Result}    level=INFO
    RETURN    ${Result}

วันที่นับจากวันนี้
    [Documentation]    คืนวันที่จริงและข้อความที่ใช้แสดงในรายงาน นับจากวันที่รันจริง
    ...                ใช้แทนวันที่ตายตัว เพื่อไม่ให้ข้อมูลตั้งต้นหมดอายุเมื่อเวลาผ่านไป
    [Arguments]    ${Offset}
    ${Date}=       Evaluate    datetime.date.today() + datetime.timedelta(days=${Offset})    modules=datetime
    ${Display}=    Set Variable    ${Date.day}/${Date.month}/${Date.year}
    RETURN    ${Date}    ${Display}

เข้าสู่ระบบเป็นเจ้าของอุปกรณ์
    [Documentation]    เข้าสู่ระบบด้วยบัญชีใน ${OwnerUser} / ${OwnerPass} แล้วคงสถานะไว้ตลอดชุดทดสอบ
    Run Keyword And Ignore Error    Close Test Context
    Open Login Owner Page
    Input Owner Username    ${OwnerUser}
    Input Owner Password    ${OwnerPass}
    Keyboard Key            press    Tab
    ${Clicked}=    Click Owner Login Button
    Should Be True    ${Clicked}    ปุ่มเข้าสู่ระบบถูกปิดใช้งาน จึงเข้าสู่ระบบไม่ได้

    ${HasButton}=    Is Element Visible    ${Btn_Verify}
    IF    ${HasButton}    Run Keyword And Ignore Error    Click Verify Button

    ${LoggedIn}=    รอให้ออกจากหน้าเข้าสู่ระบบ
    Should Be True    ${LoggedIn}
    ...    msg=เข้าสู่ระบบด้วยบัญชี Owner "${OwnerUser}" ไม่สำเร็จ จึงเริ่มทดสอบการอนุมัติไม่ได้
    Log    ข้อมูลตั้งต้นที่สร้างไว้ : ${SETUP_SUMMARY}    level=INFO

รอให้ออกจากหน้าเข้าสู่ระบบ
    [Documentation]    รอจน URL ออกจากหน้าเข้าสู่ระบบ คืน True เมื่อออกแล้ว
    FOR    ${Round}    IN RANGE    20
        ${Url}=     Get Url
        ${Left}=    Evaluate    "login-owner" not in $Url
        IF    ${Left}    RETURN    ${True}
        Sleep    0.5s
    END
    RETURN    ${False}


# =====================================================================
# 4. จุดเริ่มของทุกกรณีทดสอบ
# =====================================================================

ดำเนินการกรณีทดสอบ
    [Documentation]    ไฟล์นี้มีแต่กรณีทั้งกระบวนการ จึงส่งต่อให้คีย์เวิร์ด "กรณี <รหัส>" โดยตรง
    [Arguments]
    ...    ${Run}          ${TestCase}    ${TestScenario}
    ...    ${StartDate}    ${EndDate}     ${Address}
    ...    ${ExpectedResult}

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

    Run Keyword    กรณี ${TestCase}    ${ExpectedResult}


# =====================================================================
# 5. กรณีทดสอบตามตาราง AB01
# =====================================================================

กรณี TC04_F01
    [Documentation]    Basic Flow 1-7 : อัปเดตสถานะรายการจองที่อยู่ในแท็บ "รอดำเนินการ" ไปขั้นถัดไป
    ...                ระบบต้องอัปเดตสำเร็จและแสดงผลในกล่องโต้ตอบ
    [Arguments]    ${ExpectedResult}

    เปิดแท็บรอดำเนินการ
    ${Before}=    Get Updatable Booking Count
    Should Be True    ${Before} > 0
    ...    msg=ไม่พบรายการที่อัปเดตสถานะได้ จึงยังทดสอบไม่ได้ (ข้อมูลตั้งต้น : ${SETUP_SUMMARY})

    ${Next}=    Get Next Status Label
    Log    ปุ่มอัปเดตของรายการแรก : ${Next}    level=INFO

    ${Message}=    อัปเดตสถานะรายการแรก
    เก็บภาพหลักฐาน       อัปเดตสถานะ
    บันทึกผลที่ได้จริง    ${Next} -> ${Message}
    Acknowledge Booking Dialog

    ข้อความต้องกล่าวถึง    ${Message}    ${SUCCESS_KEYWORD}    เรียบร้อย    อัปเดต

กรณี TC04_F02
    [Documentation]    AB01-01 : อัปเดตรายการที่ช่วงเวลาชนกับผู้จองรายอื่น
    ...                ระบบต้องไม่ให้ดำเนินการ และแสดงเหตุผลในกล่องโต้ตอบ
    [Arguments]    ${ExpectedResult}

    เปิดแท็บรอดำเนินการ
    ${Count}=    Get Updatable Booking Count
    Should Be True    ${Count} > 0
    ...    msg=ไม่พบรายการที่อัปเดตสถานะได้ จึงยังทดสอบการจองชนกันไม่ได้ (ข้อมูลตั้งต้น : ${SETUP_SUMMARY})

    ${Message}=    อัปเดตสถานะรายการแรก
    เก็บภาพหลักฐาน       จองชนกัน
    บันทึกผลที่ได้จริง    ${Message}
    Acknowledge Booking Dialog

    ต้องไม่สำเร็จ           ${Message}
    ข้อความต้องกล่าวถึง    ${Message}    ไม่สามารถ    ดำเนินการ    ซ้ำ    ชน

กรณี TC04_F03
    [Documentation]    AB01-02 : กดยกเลิกการจอง ระบบต้องแจ้งว่ายกเลิกเรียบร้อย
    [Arguments]    ${ExpectedResult}

    เปิดแท็บรอดำเนินการ
    ${Message}=    ยกเลิกการจองรายการแรก
    เก็บภาพหลักฐาน       ยกเลิกการจอง
    บันทึกผลที่ได้จริง    ${Message}
    Acknowledge Booking Dialog

    ข้อความต้องกล่าวถึง    ${Message}    ยกเลิก    เรียบร้อย    ${SUCCESS_KEYWORD}

กรณี TC04_F04
    [Documentation]    AB01-04 : รายการที่อัปเดตไปแล้วต้องอัปเดตซ้ำจากแท็บเดิมไม่ได้อีก
    ...                อัปเดตรอบแรกให้สำเร็จก่อน แล้วกลับมาที่แท็บ "รอดำเนินการ" ตรวจว่ารายการหายไปจริง
    [Arguments]    ${ExpectedResult}

    # ---------- รอบที่ 1 : อัปเดตให้สำเร็จก่อน ----------
    เปิดแท็บรอดำเนินการ
    ${Before}=    Get Updatable Booking Count
    Should Be True    ${Before} > 0    msg=ไม่มีรายการให้อัปเดต จึงยังทดสอบการกดซ้ำไม่ได้

    ${First}=    อัปเดตสถานะรายการแรก
    เก็บภาพหลักฐาน    อัปเดตรอบแรก
    Acknowledge Booking Dialog

    # ---------- รอบที่ 2 : กลับมาแท็บเดิม รายการเดิมต้องไม่อยู่ให้กดซ้ำ ----------
    เปิดแท็บรอดำเนินการ
    ${After}=    Get Updatable Booking Count
    เก็บภาพหลักฐาน       ตรวจการกดซ้ำ
    บันทึกผลที่ได้จริง    รอบแรก : ${First} | รายการที่รอดำเนินการ ${Before} -> ${After}

    Should Be True    ${After} < ${Before}
    ...    msg=อัปเดตสถานะแล้ว แต่รายการยังค้างอยู่ในแท็บ "รอดำเนินการ" เท่าเดิม (${Before} -> ${After}) จึงกดอัปเดตซ้ำได้

กรณี TC04_F05
    [Documentation]    AB01-05 : รายการที่ยกเลิกไปแล้วต้องยกเลิกซ้ำไม่ได้อีก
    ...                ยกเลิกรอบแรกให้สำเร็จก่อน แล้วตรวจว่ารายการหายไปจากแท็บ "รอดำเนินการ" จริง
    [Arguments]    ${ExpectedResult}

    # ---------- รอบที่ 1 : ยกเลิกให้สำเร็จก่อน ----------
    เปิดแท็บรอดำเนินการ
    ${Before}=    Get Updatable Booking Count
    Should Be True    ${Before} > 0    msg=ไม่มีรายการให้ยกเลิก จึงยังทดสอบการกดซ้ำไม่ได้

    ${First}=    ยกเลิกการจองรายการแรก
    เก็บภาพหลักฐาน    ยกเลิกรอบแรก
    Acknowledge Booking Dialog

    # ---------- รอบที่ 2 : กลับมาแท็บเดิม รายการเดิมต้องไม่อยู่ให้กดซ้ำ ----------
    เปิดแท็บรอดำเนินการ
    ${After}=    Get Updatable Booking Count
    เก็บภาพหลักฐาน       ตรวจการยกเลิกซ้ำ
    บันทึกผลที่ได้จริง    รอบแรก : ${First} | รายการที่รอดำเนินการ ${Before} -> ${After}

    Should Be True    ${After} < ${Before}
    ...    msg=ยกเลิกการจองแล้ว แต่รายการยังค้างอยู่ในแท็บ "รอดำเนินการ" เท่าเดิม (${Before} -> ${After}) จึงกดยกเลิกซ้ำได้


# =====================================================================
# 6. ขั้นตอนย่อยบนหน้ารายการจอง
# =====================================================================

เปิดแท็บรอดำเนินการ
    [Documentation]    เปิดหน้ารายการจองแล้วเลือกแท็บ "รอดำเนินการ" ให้ทุกกรณีเริ่มจากมุมมองเดียวกัน
    Open Owner Booking Page
    Select Booking Tab    ${Tab_BookingPending}

อัปเดตสถานะรายการแรก
    [Documentation]    กดปุ่มอัปเดตของรายการแรก ยืนยันในกล่องโต้ตอบ แล้วคืนข้อความผลลัพธ์
    ...                กดปุ่มไม่ได้ก็เป็นผลลัพธ์อย่างหนึ่ง แปลว่าระบบกันไว้ด้วยการปิดปุ่ม
    ${Clicked}=    Click Update Booking Status
    IF    not ${Clicked}    RETURN    ปุ่มอัปเดตสถานะถูกปิดใช้งาน ระบบไม่ให้ทำรายการ

    ${Shown}=    Is Booking Dialog Shown
    IF    not ${Shown}    RETURN    กดปุ่มอัปเดตแล้วแต่ไม่มีกล่องยืนยันเด้งขึ้นมา

    ${Message}=    Confirm Booking Update
    ${Length}=     Get Length    ${Message}
    IF    ${Length} == 0    RETURN    ${NO_RESPONSE}
    RETURN    ${Message}

ยกเลิกการจองรายการแรก
    [Documentation]    กดปุ่มยกเลิกการจองของรายการแรก ยืนยันในกล่องโต้ตอบ แล้วคืนข้อความผลลัพธ์
    ${Clicked}=    Click Cancel Booking
    IF    not ${Clicked}    RETURN    ปุ่มยกเลิกการจองถูกปิดใช้งาน ระบบไม่ให้ทำรายการ

    ${Shown}=    Is Booking Dialog Shown
    IF    not ${Shown}    RETURN    กดปุ่มยกเลิกแล้วแต่ไม่มีกล่องยืนยันเด้งขึ้นมา

    ${Message}=    Confirm Booking Cancellation
    ${Length}=     Get Length    ${Message}
    IF    ${Length} == 0    RETURN    ${NO_RESPONSE}
    RETURN    ${Message}


# =====================================================================
# 7. คีย์เวิร์ดช่วยเหลือ : บันทึกผล ตรวจผล และเก็บหลักฐาน
# =====================================================================

ต้องไม่สำเร็จ
    [Documentation]    ยืนยันว่าระบบไม่ได้ทำรายการให้ คือไม่มีคำว่า "สำเร็จ" ในข้อความที่ตอบกลับ
    [Arguments]    ${Message}
    Should Not Contain    ${Message}    ${SUCCESS_KEYWORD}
    ...    msg=ระบบทำรายการสำเร็จ ทั้งที่ควรปฏิเสธ (ข้อความ "${Message}")

ข้อความต้องกล่าวถึง
    [Documentation]    ยืนยันว่าข้อความที่ระบบตอบกลับมีคำที่เอกสารระบุไว้อย่างน้อยหนึ่งคำ
    [Arguments]    ${Message}    @{Keywords}
    ${Lower}=    Convert To Lower Case    ${Message}
    # lambda รับค่าผ่าน default argument เพราะ RF มองไม่เห็น $ตัวแปร ใน comprehension
    ${Matched}=    Evaluate    any(map(lambda k, t=$Lower: k.lower() in t, $Keywords))
    Should Be True    ${Matched}
    ...    msg=ข้อความ "${Message}" ไม่ได้กล่าวถึง ${Keywords} จึงไม่แน่ใจว่าระบบตอบด้วยเหตุผลที่ถูกต้อง

บันทึกผลที่ได้จริง
    [Documentation]    จำข้อความที่ระบบตอบกลับไว้ ให้ teardown เขียนลงคอลัมน์ ActualResult
    [Arguments]    ${Text}
    Set Test Variable    ${ACTUAL_MESSAGE}    ${Text}

เก็บภาพหลักฐาน
    [Documentation]    บันทึกภาพหน้าจอไว้เป็นหลักฐานประกอบรายงาน ตั้งชื่อเป็น <ยูสเคส>_<รหัส>_<คำอธิบาย>
    [Arguments]    ${Name}
    Run Keyword And Ignore Error
    ...    Take Screenshot    ${SCREENSHOT_DIR}/${USECASE}_${TC_ID}_${Name}    fullPage=True

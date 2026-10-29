*** Settings ***
Documentation     TC01 - Login Farmer | ตรวจข้อความรายฟิลด์และเข้าสู่ระบบจริง (TC01_01-23)
...               อ่านข้อมูลทุกแถวของชีต Login_Farmer ด้วย FOR loop แล้วเทียบ ActualResult กับ ExpectedResult แบบตรงกัน 100% (Should Be Equal)
Metadata          Test Data   TestData/Data.xlsx (sheet: Login_Farmer)

Resource          ../Resources/keywords.robot
Library           ExcelLibrary
Library           Collections

Suite Setup       เปิดชุดทดสอบจาก Excel    Login
Suite Teardown    ปิดชุดทดสอบ Excel

*** Variables ***
# ---------- ที่อยู่ของไฟล์และโฟลเดอร์ ----------
${DATA_FILE}          ${CURDIR}/../TestData/Data.xlsx
${SHEET}              Login_Farmer
${USECASE}            TC01_Login_Farmer
${SCREENSHOT_DIR}     ${CURDIR}/../Screenshot/${USECASE}

# ---------- ตำแหน่งคอลัมน์ในชีต ----------
${COL_ID}         ${2}     # คอลัมน์ B : ${TestCase}
${COL_ACTUAL}     ${7}     # คอลัมน์ G : ${ActualResult}
${COL_PF}         ${8}     # คอลัมน์ H : ${Result}
${COL_COUNT}      ${6}     # อ่านคอลัมน์ A-F

# ---------- popup ผลการเข้าสู่ระบบ (SweetAlert2 ใช้ ${Popup_Title} จาก variables.robot) ----------
# รอสั้น ๆ เพราะกรณีที่ระบบไม่ตอบ จะไม่มี popup ขึ้นเลย
${POPUP_TIMEOUT}      5s

*** Test Cases ***
Login Farmer : ทุกกรณีทดสอบในชีต Login_Farmer
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
    ${ExpectedResult}=      Set Variable    ${Cells}[5]

    ${Data}=    Create Dictionary
    ...    Username=${Cells}[3]    Password=${Cells}[4]
    Log    ${TestCase} : ${TestScenario} | ข้อมูลที่ใช้ทดสอบ ${Data}    level=INFO

    # ขั้นที่ 1 : กรอกฟอร์ม กดเข้าสู่ระบบ และเก็บสิ่งที่ระบบตอบ
    # ActualResult เก็บเฉพาะข้อความที่ get text ได้จากระบบ ถ้าสคริปต์ล้มกลางทางให้เป็นค่าว่าง (สาเหตุดูใน log/report)
    ${Status}    ${Out}=    Run Keyword And Ignore Error    ทำรายการเข้าสู่ระบบและเก็บข้อความ    ${Data}
    # ขั้นที่ 2 : เทียบกับ Expected แบบตรงกัน 100% ถ่ายภาพเมื่อไม่ผ่าน และเขียนผลลง Excel (keyword กลางใน keywords.robot)
    ตัดสินผลและบันทึกลง Excel    ${Status}    ${Out}    ${ExpectedResult}    ${TestCase}    ${Row}

# =====================================================================
# 2. กรอกฟอร์มเข้าสู่ระบบและเก็บข้อความที่ระบบตอบ
# =====================================================================

ทำรายการเข้าสู่ระบบและเก็บข้อความ
    #กรอกชื่อผู้ใช้และรหัสผ่าน อ่านข้อความแจ้งเตือนรายฟิลด์ แล้วกดปุ่ม "เข้าสู่ระบบ" จริง คืนข้อความที่ระบบตอบ (ActualResult)
    [Arguments]    ${Data}

    Open Login Page
    Input Username    ${Data}[Username]
    Input Password    ${Data}[Password]
    # ช่องสุดท้ายไม่มีช่องถัดไปมา blur ให้ ต้อง Tab ออกเองระบบจึงจะตรวจสอบ
    Keyboard Key    press    Tab
    ${Messages}=    Get Validation Messages

    # กดปุ่มเข้าสู่ระบบจริง (Click Button If Enabled ข้ามการกดเมื่อปุ่มถูกปิดใช้งาน)
    ${Clicked}=    Click Button If Enabled    ${Btn_Login}
    ${Popup}=      Set Variable    ${EMPTY}
    IF    ${Clicked}
        ${Popup}=       รอข้อความบน popup หลังกดเข้าสู่ระบบ
        ${Messages}=    Get Validation Messages
    END

    ${ActualResult}=    สรุปข้อความที่ระบบตอบ    ${Messages}    ${Popup}
    RETURN    ${ActualResult}


รอข้อความบน popup หลังกดเข้าสู่ระบบ
    #รอ popup ผลการเข้าสู่ระบบ คืนข้อความหัวข้อบน popup ไม่มี popup คืนค่าว่าง
    ${Shown}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Popup_Title}    visible    ${POPUP_TIMEOUT}
    IF    not ${Shown}    RETURN    ${EMPTY}

    ${Text}=    Get Popup Title
    RETURN    ${Text}

*** Settings ***
Documentation     TC02 - Register Farmer | ตรวจข้อความแจ้งเตือนรายฟิลด์ (TC02_001-167)
...               อ่านข้อมูลทุกแถวของชีต Register_Farmer ด้วย FOR loop แล้วเทียบ ActualResult กับ ExpectedResult แบบตรงกัน 100% (Should Be Equal)
Metadata          Test Data   TestData/Data.xlsx (sheet: Register_Farmer)

Resource          ../Resources/keywords.robot
Library           ExcelLibrary
Library           Collections

Suite Setup       เปิดชุดทดสอบจาก Excel    Register
Suite Teardown    ปิดชุดทดสอบ Excel

*** Variables ***
# ---------- ที่อยู่ของไฟล์และโฟลเดอร์ ----------
${DATA_FILE}          ${CURDIR}/../TestData/Data.xlsx
${SHEET}              Register_Farmer
${USECASE}            TC02_Register_Farmer
${SCREENSHOT_DIR}     ${CURDIR}/../Screenshot/${USECASE}

# ---------- ตำแหน่งคอลัมน์ในชีต ----------
${COL_ID}         ${2}     # คอลัมน์ B : ${TestCase}
${COL_ACTUAL}     ${24}    # คอลัมน์ X : ${ActualResult}
${COL_PF}         ${25}    # คอลัมน์ Y : ${Result}
${COL_COUNT}      ${23}    # อ่านคอลัมน์ A-W

# ---------- popup ผลการสมัคร (SweetAlert2 ใช้ ${Popup_Title} จาก variables.robot) ----------
# รอสั้น ๆ เพราะกรณีที่ต้องไม่สำเร็จจะไม่มี popup ขึ้นเลย
${POPUP_TIMEOUT}      5s

*** Test Cases ***
Register Farmer : ทุกกรณีทดสอบในชีต Register_Farmer
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
    ${ExpectedResult}=      Set Variable    ${Cells}[22]

    ${Data}=    Create Dictionary
    ...    Picture=${Cells}[3]       UsernameR=${Cells}[4]     Email=${Cells}[5]
    ...    PasswordR=${Cells}[6]     Confirmpassword=${Cells}[7]
    ...    Firstname=${Cells}[8]     Surname=${Cells}[9]       Gender=${Cells}[10]
    ...    Daybirth=${Cells}[11]     Monthbirth=${Cells}[12]   Yearbirth=${Cells}[13]
    ...    Tel=${Cells}[14]          Hnum=${Cells}[15]         Alley=${Cells}[16]
    ...    Group=${Cells}[17]        District=${Cells}[18]     Canton=${Cells}[19]
    ...    Province=${Cells}[20]     Postcode=${Cells}[21]
    Log    ${TestCase} : ${TestScenario} | ข้อมูลที่ใช้ทดสอบ ${Data}    level=INFO

    # ขั้นที่ 1 : กรอกฟอร์ม กดสมัครสมาชิก และเก็บสิ่งที่ระบบตอบ
    # ActualResult เก็บเฉพาะข้อความที่ get text ได้จากระบบ ถ้าสคริปต์ล้มกลางทางให้เป็นค่าว่าง (สาเหตุดูใน log/report)
    ${Status}    ${Out}=    Run Keyword And Ignore Error    ทำรายการสมัครและเก็บข้อความ    ${Data}
    # ขั้นที่ 2 : เทียบกับ Expected แบบตรงกัน 100% ถ่ายภาพเมื่อไม่ผ่าน และเขียนผลลง Excel (keyword กลางใน keywords.robot)
    ตัดสินผลและบันทึกลง Excel    ${Status}    ${Out}    ${ExpectedResult}    ${TestCase}    ${Row}

# =====================================================================
# 2. กรอกฟอร์มสมัครสมาชิกและเก็บข้อความที่ระบบตอบ
# =====================================================================

ทำรายการสมัครและเก็บข้อความ
    #กรอกทั้ง 2 ขั้นตอนแล้วกดปุ่มจริง คืนข้อความที่ระบบตอบ (ActualResult)
    [Arguments]    ${Data}

    Open Register Page

    # ---------- ขั้นตอนที่ 1 : ข้อมูลบัญชีผู้ใช้ ----------
    กรอกข้อมูลบัญชีผู้ใช้    ${Data}
    Click Next Button
    ${Messages}=       Get Validation Messages
    ${OnStep2}=        Is Register Step2 Displayed
    ${Registered}=     Set Variable    ${EMPTY}

    # ---------- ขั้นตอนที่ 2 : ข้อมูลส่วนตัวและที่อยู่ ----------
    IF    ${OnStep2}
        กรอกข้อมูลส่วนตัว    ${Data}
        ${RegisterClicked}=    Click Register Button
        ${Messages}=           Get Validation Messages
        IF    ${RegisterClicked}
            ${Registered}=    รอผลการสมัคร
        END
    END

    ${ActualResult}=    สรุปข้อความที่ระบบตอบ    ${Messages}    ${Registered}
    RETURN    ${ActualResult}


# =====================================================================
# 3. ขั้นตอนย่อยของการสมัครสมาชิก (ใช้ร่วมกับ UseCase/Usecase_Register_farmer.robot)
# =====================================================================

กรอกข้อมูลบัญชีผู้ใช้
    #กรอกข้อมูลขั้นตอนที่ 1 (รูปโปรไฟล์ ชื่อผู้ใช้ อีเมล รหัสผ่าน)
    [Arguments]    ${Data}
    Upload Picture           ${Data}[Picture]
    Input UsernameR          ${Data}[UsernameR]
    Input Email              ${Data}[Email]
    Input PasswordR          ${Data}[PasswordR]
    Input Confirmpassword    ${Data}[Confirmpassword]

    # ช่องสุดท้ายไม่มีช่องถัดไปมา blur ให้ ต้อง Tab ออกเองระบบจึงจะตรวจสอบ
    Keyboard Key    press    Tab

กรอกข้อมูลส่วนตัว
    #กรอกข้อมูลขั้นตอนที่ 2 (ข้อมูลส่วนตัวและที่อยู่)
    [Arguments]    ${Data}
    Input Firstname    ${Data}[Firstname]
    Input Surname      ${Data}[Surname]
    Select Gender      ${Data}[Gender]
    Input Birthdate    ${Data}[Daybirth]    ${Data}[Monthbirth]    ${Data}[Yearbirth]
    Input Tel          ${Data}[Tel]
    Input Hnum         ${Data}[Hnum]
    Input Alley        ${Data}[Alley]
    Input Group        ${Data}[Group]
    Input District     ${Data}[District]
    Input Canton       ${Data}[Canton]
    Input Province     ${Data}[Province]
    Input Postcode     ${Data}[Postcode]
    Keyboard Key       press    Tab

รอผลการสมัคร
    #รอ popup แจ้งสมัครสำเร็จ คืนข้อความบน popup ไม่พบให้คืนค่าว่าง (รอสั้นเพราะเคสที่ต้องไม่สำเร็จจะไม่มี popup)
    ${Success}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Popup_Title}    visible    ${POPUP_TIMEOUT}
    IF    not ${Success}    RETURN    ${EMPTY}

    ${Text}=    Get Popup Title
    RETURN    ${Text}

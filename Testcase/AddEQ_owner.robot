*** Settings ***
Documentation     TC03 - Add Equipment Owner | ตรวจข้อความแจ้งเตือนรายฟิลด์ (TC03_01-73) กรอกฟอร์มแล้วกด "บันทึก" จริง
...               อ่านข้อมูลทุกแถวของชีต AddEQ_Owner ด้วย FOR loop แล้วเทียบ ActualResult กับ ExpectedResult แบบตรงกัน 100% (Should Be Equal)
...               Pre-Condition: เข้าสู่ระบบเป็น Owner ครั้งเดียวตอนเริ่มชุด ใช้ session เดิมทั้งชุด
Metadata          Test Data   TestData/Data.xlsx (sheet: AddEQ_Owner)

Resource          ../Resources/keywords.robot
Library           ExcelLibrary
Library           Collections

Suite Setup       เปิดชุดทดสอบ
Suite Teardown    ปิดชุดทดสอบ Excel

*** Variables ***
# ---------- ที่อยู่ของไฟล์และโฟลเดอร์ ----------
${DATA_FILE}          ${CURDIR}/../TestData/Data.xlsx
${SHEET}              AddEQ_Owner
${USECASE}            TC03_AddEQ_Owner
${SCREENSHOT_DIR}     ${CURDIR}/../Screenshot/${USECASE}

# ---------- ตำแหน่งคอลัมน์ในชีต ----------
${COL_ID}         ${2}     # คอลัมน์ B : ${TestCase}
${COL_ACTUAL}     ${13}    # คอลัมน์ M : ${ActualResult}
${COL_PF}         ${14}    # คอลัมน์ N : ${Result}
${COL_COUNT}      ${12}    # อ่านคอลัมน์ A-L

# ---------- ข้อความผลการบันทึก ----------
# ระบบแสดงผลการบันทึกเป็นกล่องแจ้งเตือนมุมขวาบน (role="status") ไม่ใช่ SweetAlert2 และกล่องหายเองภายใน 2.5 วินาที
${Toast_Text}         //div[@role='status' and contains(@class,'fixed')]//div[contains(@class,'text-sm')]
# รอสั้น ๆ เพราะกรณีที่ต้องไม่สำเร็จจะไม่มี popup ขึ้นเลย
${POPUP_TIMEOUT}      5s

*** Test Cases ***
Add Equipment Owner : ทุกกรณีทดสอบในชีต AddEQ_Owner
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
# 1. การเตรียมและปิดชุดทดสอบ
# =====================================================================

เปิดชุดทดสอบ
    #เปิดชุดทดสอบตามโครงกลาง แล้วเข้าสู่ระบบ Owner ครั้งเดียว ใช้ session เดิมทั้งชุด
    เปิดชุดทดสอบจาก Excel    AddEquipmentOwner
    เข้าสู่ระบบเป็นเจ้าของอุปกรณ์

# =====================================================================
# 2. ทดสอบหนึ่งแถว
# =====================================================================

ทดสอบหนึ่งแถว
    #กรอกฟอร์ม -> เก็บข้อความที่ระบบตอบ -> เทียบ Expected แบบตรงกัน 100% -> เขียนผลลง Excel -> ปิดฟอร์มที่ค้าง
    [Arguments]    ${Row}    ${Cells}
    ${TestCase}=            Set Variable    ${Cells}[1]
    ${TestScenario}=        Set Variable    ${Cells}[2]
    ${ExpectedResult}=      Set Variable    ${Cells}[11]

    ${Data}=    Create Dictionary
    ...    EquipmentName=${Cells}[3]       EquipmentType=${Cells}[4]
    ...    EquipmentDetail=${Cells}[5]     Price=${Cells}[6]
    ...    Status=${Cells}[7]              EquipmentFeature=${Cells}[8]
    ...    EquipmentAddress=${Cells}[9]    EquipmentImage=${Cells}[10]
    Log    ${TestCase} : ${TestScenario} | ข้อมูลที่ใช้ทดสอบ ${Data}    level=INFO

    # ขั้นที่ 1 : กรอกฟอร์ม กดบันทึก และเก็บสิ่งที่ระบบตอบ
    # ActualResult เก็บเฉพาะข้อความที่ get text ได้จากระบบ ถ้าสคริปต์ล้มกลางทางให้เป็นค่าว่าง (สาเหตุดูใน log/report)
    ${Status}    ${Out}=    Run Keyword And Ignore Error    ทำรายการเพิ่มอุปกรณ์และเก็บข้อความ    ${Data}
    # ขั้นที่ 2 : เทียบกับ Expected แบบตรงกัน 100% ถ่ายภาพเมื่อไม่ผ่าน และเขียนผลลง Excel (keyword กลางใน keywords.robot)
    ตัดสินผลและบันทึกลง Excel    ${Status}    ${Out}    ${ExpectedResult}    ${TestCase}    ${Row}
    ...    Cleanup=Click Cancel Equipment Button

# =====================================================================
# 3. กรอกฟอร์มเพิ่มอุปกรณ์และเก็บข้อความที่ระบบตอบ
# =====================================================================

ทำรายการเพิ่มอุปกรณ์และเก็บข้อความ
    #กรอกฟอร์มครบทุกช่องแล้วกดปุ่ม "บันทึก" จริง คืนข้อความที่ระบบตอบ (ActualResult)
    [Arguments]    ${Data}

    # ชุดนี้ยาว 73 เคส session ของเว็บหมดอายุกลางทาง จึงเช็คและเข้าสู่ระบบใหม่ก่อนทุกแถว
    เข้าสู่ระบบใหม่ถ้า session หมดอายุ

    # ต้องเลือกประเภทบนหน้ารายการอุปกรณ์ก่อน ปุ่ม "เพิ่มอุปกรณ์" จึงจะกดเข้าฟอร์มได้
    Open Add Equipment Page    ${Data}[EquipmentType]
    กรอกข้อมูลอุปกรณ์    ${Data}

    ${Clicked}=     Click Save Equipment Button

    # อ่านกล่องแจ้งผลการบันทึกก่อนอย่างอื่น เพราะกล่องหายเองภายใน 2.5 วินาที
    ${Saved}=       Set Variable    ${EMPTY}
    IF    ${Clicked}
        ${Saved}=    รอผลการบันทึก
    ELSE
        Log    ปุ่ม "บันทึก" ถูกปิดใช้งาน จึงไม่ได้กดบันทึก    level=INFO
    END

    # อ่านเฉพาะข้อความแจ้งเตือนภาษาไทยที่เว็บแสดง ไม่อ่านข้อความภาษาอังกฤษของเบราว์เซอร์
    # (เช่น "Please fill out this field.") เพราะเอกสาร dev ไม่ได้ระบุไว้
    ${Messages}=    Get Validation Messages

    ${ActualResult}=    สรุปข้อความที่ระบบตอบ    ${Messages}    ${Saved}
    RETURN    ${ActualResult}

กรอกข้อมูลอุปกรณ์
    #กรอกทั้ง 7 ช่องตามลำดับบนหน้าจอ (ประเภทอุปกรณ์เลือกไว้แล้วตอนเปิดฟอร์ม)
    [Arguments]    ${Data}
    Input Equipment Name       ${Data}[EquipmentName]
    Input Equipment Detail     ${Data}[EquipmentDetail]
    กรอกราคา                   ${Data}[Price]
    Select Equipment Status    ${Data}[Status]
    Input Equipment Feature    ${Data}[EquipmentFeature]
    Input Equipment Address    ${Data}[EquipmentAddress]
    Upload Equipment Picture   ${Data}[EquipmentImage]

    # ช่องสุดท้ายไม่มีช่องถัดไปมา blur ให้ ต้อง Tab ออกเองระบบจึงจะตรวจสอบ
    Keyboard Key    press    Tab

กรอกราคา
    #ช่องราคาเป็น input type=number พิมพ์ตัวอักษรไม่ได้ ถ้า Fill Text ใช้ไม่ได้จึงพิมพ์ทีละตัวแทน
    #ให้เบราว์เซอร์กรองตัวที่พิมพ์ไม่ได้เอง (ไม่บันทึกหมายเหตุใดลง ActualResult)
    [Arguments]    ${Price}
    ${Ok}=    Run Keyword And Return Status    Input Equipment Price    ${Price}
    IF    ${Ok}    RETURN
    Type Text    ${Text_EQPrice}    ${Price}    clear=True

รอผลการบันทึก
    #รอกล่องแจ้งผลการบันทึก (${Toast_Text}) คืนข้อความที่อ่านได้จากกล่อง ไม่มีกล่องหรืออ่านไม่ทันคืนค่าว่าง
    ${Shown}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Toast_Text}    visible    ${POPUP_TIMEOUT}

    # ระหว่างระบบกำลังบันทึก ปุ่ม "ยกเลิก" จะถูกปิดใช้งาน ไฟล์รูปใหญ่ (เช่น 5MB ใน TC03_71) อัปโหลดนานกว่า
    # ${POPUP_TIMEOUT} ถ้ายังบันทึกอยู่ให้รอกล่องแจ้งผลต่อจนครบ ${DEFAULT_TIMEOUT}
    IF    not ${Shown}
        ${CancelEnabled}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${Btn_CancelEQ}    enabled    ${SHORT_TIMEOUT}
        IF    not ${CancelEnabled}
            ${Shown}=    Run Keyword And Return Status
            ...    Wait For Elements State    ${Toast_Text}    visible    ${DEFAULT_TIMEOUT}
        END
    END
    IF    not ${Shown}    RETURN    ${EMPTY}

    # กล่องปิดเองเร็ว อ่านด้วย timeout สั้น อ่านไม่ทันคืนค่าว่าง
    Set Browser Timeout    ${SHORT_TIMEOUT}
    ${Ok}    ${Text}=    Run Keyword And Ignore Error    Get Text    ${Toast_Text}
    Set Browser Timeout    ${DEFAULT_TIMEOUT}
    IF    '${Ok}' == 'FAIL'    RETURN    ${EMPTY}
    ${Text}=    Strip String    ${Text}
    RETURN    ${Text}


# =====================================================================
# 4. คีย์เวิร์ดเข้าสู่ระบบ Owner (ใช้ session เดียวทั้งชุด)
# =====================================================================

เข้าสู่ระบบเป็นเจ้าของอุปกรณ์
    #เข้าสู่ระบบด้วยบัญชี ${OwnerUser} / ${OwnerPass} จาก variables.robot ล้มทั้งชุดถ้าเข้าไม่ได้
    ${UserLen}=    Get Length    ${OwnerUser}
    ${PassLen}=    Get Length    ${OwnerPass}
    IF    ${UserLen} == 0 or ${PassLen} == 0
        Fail    ยังไม่ได้ตั้งค่าบัญชี Owner กรุณาเติม \${OwnerUser} และ \${OwnerPass} ใน Resources/variables.robot
    END

    Open Login Owner Page
    กรอกบัญชีแล้วกดเข้าสู่ระบบ

กรอกบัญชีแล้วกดเข้าสู่ระบบ
    #กรอกบัญชี Owner แล้วกดเข้าสู่ระบบ ใช้ซ้ำได้ตอน session หมดอายุ โดยไม่ต้องเปิด context ใหม่
    Input Owner Username    ${OwnerUser}
    Input Owner Password    ${OwnerPass}
    Keyboard Key            press    Tab
    ${Clicked}=    Click Owner Login Button
    Should Be True    ${Clicked}    ปุ่มเข้าสู่ระบบถูกปิดใช้งาน จึงเข้าสู่ระบบไม่ได้

    # popup แจ้งเข้าสู่ระบบสำเร็จของฝั่ง Owner ใช้ปุ่ม "ไปหน้าแรก" ไม่ใช่ "ตกลง" เหมือนฝั่ง Farmer
    # ต้องกดปุ่มนี้ระบบจึงจะพาออกจากหน้าเข้าสู่ระบบ ไม่กดแล้ว popup จะค้างจนเข้าหน้าอื่นไม่ได้
    Run Keyword And Ignore Error
    ...    Wait For Elements State    ${Popup_Title}    visible    ${POPUP_TIMEOUT}
    ${HasButton}=    Is Element Visible    ${Btn_OGoHome}
    IF    ${HasButton}    Run Keyword And Ignore Error    Click    ${Btn_OGoHome}

    ${LoggedIn}=    รอให้ออกจากหน้าเข้าสู่ระบบ
    Should Be True    ${LoggedIn}
    ...    msg=เข้าสู่ระบบด้วยบัญชี "${OwnerUser}" ไม่สำเร็จ จึงเริ่มทดสอบการเพิ่มอุปกรณ์ไม่ได้
    Log    เข้าสู่ระบบเป็น Owner "${OwnerUser}" สำเร็จ ใช้ session นี้ตลอดทั้งชุดทดสอบ    level=INFO

เข้าสู่ระบบใหม่ถ้า session หมดอายุ
    #เช็ค session ก่อนทุกเคส (ใช้ session เดียวทั้งชุด) ถ้าหมดอายุให้เข้าสู่ระบบใหม่บนหน้าเดิม
    #ห้ามเปิด context ใหม่ เพราะ Browser library จะปิด context อัตโนมัติเมื่อจบเคส
    Go To                  ${AddEQ_ownerURL}
    Wait For Load State    domcontentloaded    ${DEFAULT_TIMEOUT}

    # การเด้งกลับหน้าเข้าสู่ระบบอาจเกิดหลังโหลดหน้าเสร็จ จึงรอดูสั้น ๆ
    ${Expired}=    Set Variable    ${False}
    FOR    ${Round}    IN RANGE    6
        ${Url}=    Get Url
        ${Expired}=    Evaluate    "login" in $Url
        IF    ${Expired}    BREAK
        ${Ready}=    Is Element Visible    ${Btn_AddEQ}
        IF    ${Ready}    BREAK
        Sleep    0.5s
    END

    IF    ${Expired}
        Log    session หมดอายุ (ถูกพาไปที่ ${Url}) จึงเข้าสู่ระบบใหม่ก่อนทำกรณีถัดไป    level=WARN
        Go To                      ${Login_ownerURL}
        Wait For Elements State    ${Text_OUsername}    visible    ${DEFAULT_TIMEOUT}
        กรอกบัญชีแล้วกดเข้าสู่ระบบ
    END

รอให้ออกจากหน้าเข้าสู่ระบบ
    #รอจน URL ออกจากหน้าเข้าสู่ระบบ คืน True เมื่อออกแล้ว
    FOR    ${Round}    IN RANGE    20
        ${Url}=     Get Url
        ${Left}=    Evaluate    "login-owner" not in $Url
        IF    ${Left}    RETURN    ${True}
        Sleep    0.5s
    END
    RETURN    ${False}

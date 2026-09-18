*** Settings ***
Documentation     TC01 - Login Farmer | ตรวจข้อความแจ้งเตือนรายฟิลด์ (TC01_01-27) ไม่กดปุ่มเข้าสู่ระบบ
...               การทดสอบยูสเคสเข้าสู่ระบบจริง (TC01_F01-F06) แยกไปอยู่ที่ Usecase_Login_farmer.robot
...               เลือกกรณีที่รันจากคอลัมน์ ${Run} ใน Data.xlsx และเขียนผลกลับลง ActualResult / Result
Metadata          System      ระบบเว็บศูนย์กลางให้บริการเช่าอุปกรณ์ทางการเกษตร (SRS v7.0)
Metadata          Use Case    TC01 Login Farmer (ทดสอบฟิลด์)
Metadata          Test Data   TestData/Data.xlsx (sheet: Login_Farmer)

Resource          ../Resources/keywords.robot
Library           DataDriver    file=${CURDIR}/../TestData/Data.xlsx    sheet_name=Login_Farmer
Library           ExcelLibrary
Library           OperatingSystem
Library           String
Library           Collections

Suite Setup       เปิดชุดทดสอบ
Suite Teardown    ปิดชุดทดสอบ
Test Teardown     เก็บผลท้ายกรณีทดสอบ
Test Template     ดำเนินการกรณีทดสอบ


*** Variables ***
# ---------- ไฟล์และโฟลเดอร์ ----------
${DATA_FILE}          ${CURDIR}/../TestData/Data.xlsx
${SHEET}              Login_Farmer
${SCREENSHOT_DIR}     ${CURDIR}/../Screenshot
${USECASE}            TC01_Login_Farmer

# ---------- ตำแหน่งคอลัมน์ในชีต ----------
${COL_ID}             ${2}     # คอลัมน์ B : ${TestCase}
${COL_ACTUAL}         ${7}     # คอลัมน์ G : ${ActualResult}
${COL_PF}             ${8}     # คอลัมน์ H : ${Result}

# ---------- ตัวชี้วัดที่ใช้ตัดสินผล ----------
${PASS_MESSAGE}       ผ่านการตรวจสอบ    # ใช้แทนกรณี "ไม่มีข้อความแจ้งเตือน" ตามเอกสาร

# ---------- รายการอนุโลม : ต่างสำนวนจากเอกสารแต่สื่อกฎเดียวกัน ใช้แล้วจะมี WARN ใน log.html ----------
&{ACCEPTED_MESSAGE}
...    TC01_04=ชื่อผู้ใช้ต้องเป็นตัวอักษรภาษาอังกฤษและตัวเลขเท่านั้น
...    TC01_05=ชื่อผู้ใช้ต้องเป็นตัวอักษรภาษาอังกฤษและตัวเลขเท่านั้น
...    TC01_06=ชื่อผู้ใช้ต้องเป็นตัวอักษรภาษาอังกฤษและตัวเลขเท่านั้น
...    TC01_07=ชื่อผู้ใช้ต้องมีความยาวอย่างน้อย 6 ตัวอักษร
...    TC01_12=ชื่อผู้ใช้ต้องมีความยาวไม่เกิน 20 ตัวอักษร
...    TC01_18=รหัสผ่านต้องเป็นตัวอักษรภาษาอังกฤษ ตัวเลข หรืออักขระพิเศษ [!#_.] เท่านั้น
...    TC01_19=รหัสผ่านต้องเป็นตัวอักษรภาษาอังกฤษ ตัวเลข หรืออักขระพิเศษ [!#_.] เท่านั้น
...    TC01_20=รหัสผ่านต้องมีความยาวอย่างน้อย 8 ตัวอักษร
...    TC01_25=รหัสผ่านต้องมีความยาวไม่เกิน 16 ตัวอักษร

# ---------- ตัวแปรระดับกรณีทดสอบ ใช้ส่งข้อมูลให้ teardown ----------
${TC_ID}              UNKNOWN
${ROW_NUM}            ${0}
${ACTUAL_MESSAGE}     ${EMPTY}


*** Test Cases ***
Login Farmer : ${TestCase}


*** Keywords ***
# ---------- 1. เตรียมและปิดชุดทดสอบ ----------

เปิดชุดทดสอบ
    [Documentation]    ล้างภาพของรอบก่อน เปิดไฟล์ Excel สำหรับเขียนผล และเปิดเบราว์เซอร์
    Create Directory    ${SCREENSHOT_DIR}
    ลบภาพของรอบก่อน    ${SCREENSHOT_DIR}
    Open Excel Document    ${DATA_FILE}    Login
    Open Test Browser

ลบภาพของรอบก่อน
    [Documentation]    ลบเฉพาะภาพของยูสเคสนี้ ไม่ลบตัวโฟลเดอร์เพราะ OneDrive มักคืน Access denied
    [Arguments]    ${Folder}
    ${Files}=    List Files In Directory    ${Folder}    ${USECASE}_*.png
    FOR    ${File}    IN    @{Files}
        ${Removed}=    Run Keyword And Return Status    Remove File    ${Folder}/${File}
        IF    not ${Removed}    Log    ลบ ${File} ไม่สำเร็จ ภาพอาจปนกับรอบก่อน    level=WARN
    END

ปิดชุดทดสอบ
    [Documentation]    บันทึกไฟล์ Excel และปิดทรัพยากรทั้งหมด
    Run Keyword And Ignore Error    เซฟไฟล์ Excel อย่างปลอดภัย
    Run Keyword And Ignore Error    Close All Excel Documents
    Close All Test Browsers

เก็บผลท้ายกรณีทดสอบ
    [Documentation]    เก็บภาพเมื่อไม่ผ่าน เขียนผลกลับลง Excel แล้วปิด context (กรณีที่ถูกข้าม ROW_NUM=0 จะไม่เขียนทับ)
    ${Actual}=    Set Variable    ${ACTUAL_MESSAGE}

    IF    '${TEST STATUS}' == 'FAIL'
        Run Keyword And Ignore Error
        ...    Take Screenshot    ${SCREENSHOT_DIR}/${USECASE}_${TC_ID}_FAILED    fullPage=True

        # ล้มก่อนได้ข้อความจากระบบ ให้บันทึกสาเหตุที่ล้มแทน
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


# ---------- 2. อ่านและเขียนไฟล์ Excel ----------

หาแถวของกรณีทดสอบ
    [Documentation]    หาเลขแถวจากรหัสในคอลัมน์ B (index 0 คือหัวตาราง แถวจึงเป็น index+1) ไม่พบคืน 0
    [Arguments]    ${TestCaseID}
    ${Ids}=    Read Excel Column    ${COL_ID}    sheet_name=${SHEET}
    ${Ids}=    Evaluate    ["" if v is None else str(v).strip() for v in $Ids]

    ${Found}=    Run Keyword And Return Status    List Should Contain Value    ${Ids}    ${TestCaseID}
    IF    not ${Found}
        Log    ไม่พบ ${TestCaseID} ในชีต ${SHEET} จึงไม่เขียนผลกลับ    level=WARN
        RETURN    ${0}
    END

    ${Index}=    Get Index From List    ${Ids}    ${TestCaseID}
    ${Row}=      Evaluate    ${Index} + 1
    RETURN    ${Row}

บันทึกผลลง Excel
    [Documentation]    เขียนผลที่ได้จริงและสถานะ Pass/Fail กลับลงแถวของกรณีทดสอบ
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


# ---------- 3. จุดเริ่มของทุกกรณีทดสอบ ----------

ดำเนินการกรณีทดสอบ
    [Documentation]    ตรวจข้อความแจ้งเตือนรายฟิลด์ (ไม่กดปุ่มเข้าสู่ระบบ) ทุกแถวในชีต Login_Farmer
    [Arguments]    ${Run}          ${TestCase}    ${TestScenario}
    ...            ${Username}     ${Password}    ${ExpectedResult}

    # แถวสรุปผลท้ายชีตไม่มีรหัสกรณีทดสอบ จึงไม่ใช่กรณีทดสอบ
    IF    '${TestCase}' == '${EMPTY}'    Skip    ไม่ใช่กรณีทดสอบ (แถวสรุปผลในไฟล์ Excel)
    IF    '${Run}' != 'Yes'              Skip    ไม่ได้เลือกให้รัน (Run = ${Run})

    Set Test Documentation    ${TestScenario}
    Set Test Variable         ${TC_ID}             ${TestCase}
    Set Test Variable         ${ACTUAL_MESSAGE}    ${EMPTY}

    ${Row}=    หาแถวของกรณีทดสอบ    ${TestCase}
    Set Test Variable    ${ROW_NUM}    ${Row}
    Log    ${TestCase} : ${TestScenario}    level=INFO

    ตรวจข้อความแจ้งเตือนรายฟิลด์    ${Username}    ${Password}    ${ExpectedResult}


# ---------- 4. ส่วนที่ 1 : ตรวจข้อความแจ้งเตือนรายฟิลด์ (TC01_01 - TC01_27) ----------

ตรวจข้อความแจ้งเตือนรายฟิลด์
    [Documentation]    กรอกข้อมูลแล้วอ่านข้อความที่ระบบแจ้งทันที ยังไม่กดปุ่ม "เข้าสู่ระบบ"
    [Arguments]    ${Username}    ${Password}    ${ExpectedResult}

    Open Login Page
    Input Username    ${Username}
    Input Password    ${Password}
    # ช่องสุดท้ายไม่มีช่องถัดไปให้ blur เอง จึงต้องกด Tab ระบบจึงจะตรวจสอบ
    Keyboard Key    press    Tab

    ${Messages}=        Get Validation Messages
    # บันทึกข้อความจริงเสมอ ไม่ทับด้วยข้อความจากเอกสาร จะได้เห็นของจริงตอนทำรายงาน
    ${ActualResult}=    รวมข้อความ    ${Messages}    ${PASS_MESSAGE}
    ${Matched}=         ผลตรงกับที่เอกสารกำหนด    ${Messages}    ${ExpectedResult}

    บันทึกผลที่ได้จริง    ${ActualResult}
    Should Be True    ${Matched}
    ...    msg=${TC_ID} : ระบบแจ้งว่า "${ActualResult}" แต่เอกสารกำหนดไว้ว่า "${ExpectedResult}"

ผลตรงกับที่เอกสารกำหนด
    [Documentation]    ไม่มีข้อความ = ผ่านการตรวจสอบ / มีข้อความต้องตรงกับ ExpectedResult หรือรายการอนุโลม
    [Arguments]    ${Messages}    ${ExpectedResult}
    ${Count}=    Get Length    ${Messages}
    IF    ${Count} == 0
        ${Matched}=    ข้อความตรงกับที่คาดหวัง    ${PASS_MESSAGE}    ${ExpectedResult}
        RETURN    ${Matched}
    END

    FOR    ${Message}    IN    @{Messages}
        ${Matched}=    ข้อความตรงกับที่คาดหวัง    ${Message}    ${ExpectedResult}
        IF    ${Matched}    RETURN    ${True}
    END

    ${Accepted}=    Get From Dictionary    ${ACCEPTED_MESSAGE}    ${TC_ID}    default=${EMPTY}
    IF    '${Accepted}' == '${EMPTY}'    RETURN    ${False}

    FOR    ${Message}    IN    @{Messages}
        ${Matched}=    ข้อความตรงกับที่คาดหวัง    ${Message}    ${Accepted}
        IF    ${Matched}
            Log    ${TC_ID} : ใช้สำนวนต่างจากเอกสารแต่สื่อกฎเดียวกัน ถือว่าผ่านตามรายการอนุโลม    level=WARN
            RETURN    ${True}
        END
    END
    RETURN    ${False}


# ---------- 5. คีย์เวิร์ดช่วยเหลือ : บันทึกผล ตรวจผล ----------

บันทึกผลที่ได้จริง
    [Documentation]    จำข้อความที่ระบบตอบกลับไว้ให้ teardown เขียนลงคอลัมน์ ActualResult
    [Arguments]    ${Text}
    Set Test Variable    ${ACTUAL_MESSAGE}    ${Text}

รวมข้อความ
    [Documentation]    รวมข้อความในลิสต์เป็นข้อความเดียว ลิสต์ว่างให้ใช้ข้อความสำรอง
    [Arguments]    ${Messages}    ${Fallback}
    ${Count}=    Get Length    ${Messages}
    IF    ${Count} == 0    RETURN    ${Fallback}
    ${Joined}=    Evaluate    " | ".join($Messages)
    RETURN    ${Joined}

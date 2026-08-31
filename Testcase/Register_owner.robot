*** Settings ***
Documentation     TC02 - Register Owner | ทดสอบยูสเคส "สมัครสมาชิก" ของเจ้าของอุปกรณ์
...
...               เอกสาร Test Case ข้อ 8.2.5 ระบุว่า การตรวจสอบความถูกต้องของข้อมูลรายฟิลด์
...               (รูปแบบ ความยาว ค่าว่าง) ใช้เงื่อนไขเดียวกับฝั่ง Farmer จึงไม่ทดสอบซ้ำในไฟล์นี้
...               ไฟล์นี้จึงครอบคลุมเฉพาะ Functional Flow ตามตาราง 8.2.6 (RO02-01 ถึง RO02-09)
...
...               เลือกกรณีที่รันจากคอลัมน์ ${Run} (Yes/No) ใน Data.xlsx และเขียนผลกลับลง ActualResult / ResultPF
...               หมายเหตุ : กรณีที่ข้อมูลถูกต้องจะสร้างบัญชีจริงในฐานข้อมูลทดสอบ
Metadata          System      ระบบเว็บศูนย์กลางให้บริการเช่าอุปกรณ์ทางการเกษตร (SRS v7.0)
Metadata          Use Case    TC02 Register Owner
Metadata          Test Data   TestData/Data.xlsx (sheet: Register_Owner)

Resource          ../Resources/keywords.robot
Library           DataDriver    file=${CURDIR}/../TestData/Data.xlsx    sheet_name=Register_Owner
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
${SHEET}          Register_Owner
${SCREENSHOT_DIR}    ${CURDIR}/../Screenshot
${USECASE}        TC02_Register_Owner

# ---------- ตำแหน่งคอลัมน์ในชีต ----------
# ใช้หัวตารางชุดเดียวกับชีต Register_Farmer ตำแหน่งคอลัมน์จึงตรงกัน
${COL_ID}         ${2}     # คอลัมน์ B : ${TestCaseID}
${COL_ACTUAL}     ${24}    # คอลัมน์ X : ${ActualResult}
${COL_PF}         ${25}    # คอลัมน์ Y : ${ResultPF}

# ---------- ข้อความและตัวชี้วัดที่ใช้ตัดสินผล ----------
${SUCCESS_KEYWORD}    สำเร็จ
${Popup_Success}      text=${SUCCESS_KEYWORD}
# รอสั้น ๆ เพราะกรณีที่ต้องไม่สำเร็จจะไม่มี popup ขึ้นเลย
${POPUP_TIMEOUT}      5s

# ---------- ตัวแปรระดับกรณีทดสอบ ใช้ส่งข้อมูลให้ teardown ----------
${TC_ID}             UNKNOWN
${ROW_NUM}           ${0}
${ACTUAL_MESSAGE}    ${EMPTY}


*** Test Cases ***
Register Owner : ${TestCaseID}


*** Keywords ***
# =====================================================================
# 1. การเตรียมและปิดชุดทดสอบ
# =====================================================================

เปิดชุดทดสอบ
    [Documentation]    ล้างภาพของรอบก่อน เปิดไฟล์ Excel สำหรับเขียนผล และเปิดเบราว์เซอร์
    Create Directory    ${SCREENSHOT_DIR}
    ลบภาพของรอบก่อน    ${SCREENSHOT_DIR}

    Open Excel Document    ${DATA_FILE}    RegisterOwner
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
    Run Keyword And Ignore Error    Save Excel Document    ${DATA_FILE}
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
    Save Excel Document    ${DATA_FILE}


# =====================================================================
# 3. จุดเริ่มของทุกกรณีทดสอบ
# =====================================================================

ดำเนินการกรณีทดสอบ
    [Documentation]    ไฟล์นี้มีแต่กรณีทั้งกระบวนการ จึงส่งต่อให้คีย์เวิร์ด "กรณี <รหัส>" โดยตรง
    [Arguments]
    ...    ${Run}          ${TestCaseID}      ${TestScanario}      ${Picture}       ${UsernameR}
    ...    ${Email}        ${PasswordR}       ${Confirmpassword}
    ...    ${Firstname}    ${Surname}         ${Gender}
    ...    ${Daybirth}     ${Monthbirth}      ${Yearbirth}         ${Tel}
    ...    ${Hnum}         ${Alley}           ${Group}             ${District}
    ...    ${Canton}       ${province}        ${Postcode}
    ...    ${ExpectedResult}

    # แถวสรุปผลท้ายชีตไม่มีรหัสกรณีทดสอบ จึงไม่ใช่กรณีทดสอบ
    IF    '${TestCaseID}' == '${EMPTY}'
        Skip    ไม่ใช่กรณีทดสอบ (แถวสรุปผลในไฟล์ Excel)
    END
    IF    '${Run}' != 'Yes'
        Skip    ไม่ได้เลือกให้รัน (Run = ${Run})
    END

    Set Test Documentation    ${TestScanario}
    Set Test Variable         ${TC_ID}             ${TestCaseID}
    Set Test Variable         ${ACTUAL_MESSAGE}    ${EMPTY}

    ${Row}=    หาแถวของกรณีทดสอบ    ${TestCaseID}
    Set Test Variable    ${ROW_NUM}    ${Row}

    ${Data}=    Create Dictionary
    ...    Picture=${Picture}              UsernameR=${UsernameR}              Email=${Email}
    ...    PasswordR=${PasswordR}          Confirmpassword=${Confirmpassword}
    ...    Firstname=${Firstname}          Surname=${Surname}                  Gender=${Gender}
    ...    Daybirth=${Daybirth}            Monthbirth=${Monthbirth}            Yearbirth=${Yearbirth}
    ...    Tel=${Tel}                      Hnum=${Hnum}                        Alley=${Alley}
    ...    Group=${Group}                  District=${District}                Canton=${Canton}
    ...    Province=${province}            Postcode=${Postcode}

    ${Data}=    แทนค่า AUTO ด้วยค่าที่ไม่ซ้ำ    ${Data}
    Log    ${TestCaseID} : ${TestScanario} | ข้อมูลที่ใช้ทดสอบ ${Data}    level=INFO

    Run Keyword    กรณี ${TestCaseID}    ${Data}    ${ExpectedResult}

แทนค่า AUTO ด้วยค่าที่ไม่ซ้ำ
    [Documentation]    ช่องที่เขียนว่า AUTO ใน Excel จะถูกสุ่มค่าใหม่ทุกครั้งที่รัน
    ...                จึงรันซ้ำได้แม้ระบบจะตรวจชื่อผู้ใช้/อีเมล/เบอร์โทรซ้ำ
    [Arguments]    ${Data}
    ${Username}    ${Email}    ${Tel}=    สร้างข้อมูลบัญชีที่ไม่ซ้ำ

    # เทียบผ่านตัวแปร $Data ไม่แทนค่าลงใน expression เพราะข้อมูลทดสอบอาจมีอัญประกาศหรือขึ้นบรรทัดใหม่
    ${AutoUsername}=    Evaluate    $Data["UsernameR"] == "AUTO"
    ${AutoEmail}=       Evaluate    $Data["Email"] == "AUTO"
    ${AutoTel}=         Evaluate    $Data["Tel"] == "AUTO"
    ${AutoConfirm}=     Evaluate    $Data["Confirmpassword"] == "AUTO"

    IF    ${AutoUsername}    Set To Dictionary    ${Data}    UsernameR=${Username}
    IF    ${AutoEmail}       Set To Dictionary    ${Data}    Email=${Email}
    IF    ${AutoTel}         Set To Dictionary    ${Data}    Tel=${Tel}
    IF    ${AutoConfirm}     Set To Dictionary    ${Data}    Confirmpassword=${Data}[PasswordR]
    RETURN    ${Data}

สร้างข้อมูลบัญชีที่ไม่ซ้ำ
    [Documentation]    สร้างชื่อผู้ใช้ / อีเมล / เบอร์โทรที่ไม่ซ้ำ เพื่อรันซ้ำได้โดยไม่ต้องล้างฐานข้อมูล
    ...                ใช้คำนำหน้า pkowner เพื่อแยกจากบัญชีทดสอบของฝั่ง Farmer
    # 8 หลักท้ายของเลขเวลา + สุ่ม 3 หลัก ให้ชื่อไม่เกิน 20 ตัวอักษรตามกฎของระบบ
    ${Stamp}=       Get Time    epoch
    ${Suffix}=      Evaluate    str($Stamp)[-8:] + str(random.randint(100, 999))    modules=random
    ${Username}=    Set Variable    pkowner${Suffix}
    ${Email}=       Set Variable    ${Username}@mail.com

    # เบอร์โทร 10 หลัก ขึ้นต้น 09 ตามกฎของระบบ
    ${Tel}=    Evaluate    "09" + "".join(str(random.randint(0, 9)) for _ in range(8))    modules=random
    RETURN    ${Username}    ${Email}    ${Tel}


# =====================================================================
# 4. กรณีทดสอบตามตาราง 8.2.6 (RO02-01 ถึง RO02-09)
# =====================================================================

กรณี TC02_F00
    [Documentation]    สร้างบัญชีตั้งต้น PKOwner01 ไว้อ้างอิงในกรณีข้อมูลซ้ำ (F02 / F03)
    ...                รันครั้งแรกจะสมัครใหม่ ครั้งต่อไปถ้าระบบแจ้งว่าข้อมูลซ้ำถือว่าปกติ
    [Arguments]    ${Data}    ${ExpectedResult}

    ${Message}=    ดำเนินการสมัครสมาชิก Owner    ${Data}
    บันทึกผลที่ได้จริง    ${Message}
    เก็บภาพหลักฐาน       สร้างบัญชีตั้งต้น

    ข้อความต้องกล่าวถึง    ${Message}    ${SUCCESS_KEYWORD}    ถูกใช้งานแล้ว    ซ้ำ

กรณี TC02_F01
    [Documentation]    RO02-01, RO02-02, RO02-03 : สมัครด้วยข้อมูลที่ถูกต้องครบถ้วน
    ...                ระบบต้องสร้างบัญชี Owner และแสดงข้อความ "สมัครสมาชิกสำเร็จ"
    [Arguments]    ${Data}    ${ExpectedResult}

    ${Message}=    ดำเนินการสมัครสมาชิก Owner    ${Data}
    บันทึกผลที่ได้จริง    ${Message}
    เก็บภาพหลักฐาน       สมัครสำเร็จ

    Should Contain    ${Message}    ${SUCCESS_KEYWORD}
    ...    msg=สมัครสมาชิกไม่สำเร็จ ระบบตอบกลับว่า "${Message}"

กรณี TC02_F02
    [Documentation]    RO02-04, RO02-05 : ชื่อผู้ใช้ของบัญชีตั้งต้น + อีเมลใหม่
    ...                ระบบต้องไม่อนุญาตให้สมัคร เนื่องจาก username ซ้ำ
    [Arguments]    ${Data}    ${ExpectedResult}

    ${Message}=    ดำเนินการสมัครสมาชิก Owner    ${Data}
    บันทึกผลที่ได้จริง    ${Message}
    เก็บภาพหลักฐาน       ชื่อผู้ใช้ซ้ำ

    ต้องสมัครไม่สำเร็จ     ${Message}
    ข้อความต้องกล่าวถึง    ${Message}    ชื่อผู้ใช้    username

กรณี TC02_F03
    [Documentation]    RO02-06 : อีเมลของบัญชีตั้งต้น + ชื่อผู้ใช้ใหม่
    ...                ระบบต้องแสดงข้อความว่าอีเมลนี้ถูกใช้งานแล้ว
    [Arguments]    ${Data}    ${ExpectedResult}

    ${Message}=    ดำเนินการสมัครสมาชิก Owner    ${Data}
    บันทึกผลที่ได้จริง    ${Message}
    เก็บภาพหลักฐาน       อีเมลซ้ำ

    ต้องสมัครไม่สำเร็จ     ${Message}
    ข้อความต้องกล่าวถึง    ${Message}    อีเมล    email

กรณี TC02_F04
    [Documentation]    RO02-07 : อีเมลไม่มีเครื่องหมาย @ ระบบต้องแจ้งว่ารูปแบบอีเมลไม่ถูกต้อง
    ...                และไม่ให้ผ่านไปขั้นตอนถัดไป
    [Arguments]    ${Data}    ${ExpectedResult}

    ${Message}=    ดำเนินการสมัครสมาชิก Owner    ${Data}
    บันทึกผลที่ได้จริง    ${Message}
    เก็บภาพหลักฐาน       อีเมลผิดรูปแบบ

    ต้องสมัครไม่สำเร็จ     ${Message}
    ข้อความต้องกล่าวถึง    ${Message}    อีเมล    email

กรณี TC02_F05
    [Documentation]    RO02-08, RO02-09 : เว้นว่างทุกช่องที่จำเป็นแล้วกดปุ่ม
    ...                ระบบต้องแจ้งเตือนและไม่สร้างบัญชีให้
    [Arguments]    ${Data}    ${ExpectedResult}

    Open Register Owner Page
    กรอกข้อมูลบัญชีผู้ใช้ Owner    ${Data}

    ${Clicked}=     Click Next Button
    ${Messages}=    Get Validation Messages
    ${Count}=       Get Length    ${Messages}
    ${Summary}=     รวมข้อความ    ${Messages}    ระบบไม่แสดงข้อความแจ้งเตือน

    บันทึกผลที่ได้จริง    ${Summary}
    เก็บภาพหลักฐาน       ไม่กรอกข้อมูล

    Should Not Be True    ${Clicked}
    ...    msg=ระบบยอมให้ไปขั้นตอนถัดไปทั้งที่ไม่ได้กรอกข้อมูล
    Should Be True    ${Count} > 0
    ...    msg=ระบบไม่แสดงข้อความแจ้งเตือนเมื่อไม่กรอกข้อมูล


# =====================================================================
# 5. ขั้นตอนย่อยของการสมัครสมาชิก
# =====================================================================

กรอกข้อมูลบัญชีผู้ใช้ Owner
    [Documentation]    กรอกข้อมูลขั้นตอนที่ 1 (รูปเจ้าของอุปกรณ์ ชื่อผู้ใช้ อีเมล รหัสผ่าน)
    [Arguments]    ${Data}
    Upload Owner Picture           ${Data}[Picture]
    Input Owner UsernameR          ${Data}[UsernameR]
    Input Owner Email              ${Data}[Email]
    Input Owner PasswordR          ${Data}[PasswordR]
    Input Owner Confirmpassword    ${Data}[Confirmpassword]

    # ช่องสุดท้ายไม่มีช่องถัดไปมา blur ให้ ต้อง Tab ออกเองระบบจึงจะตรวจสอบ
    Keyboard Key    press    Tab

กรอกข้อมูลส่วนตัว Owner
    [Documentation]    กรอกข้อมูลขั้นตอนที่ 2 (ข้อมูลส่วนตัวและที่อยู่)
    [Arguments]    ${Data}
    Input Owner Firstname    ${Data}[Firstname]
    Input Owner Surname      ${Data}[Surname]
    Select Owner Gender      ${Data}[Gender]
    Input Owner Birthdate    ${Data}[Daybirth]    ${Data}[Monthbirth]    ${Data}[Yearbirth]
    Input Owner Tel          ${Data}[Tel]
    Input Owner Hnum         ${Data}[Hnum]
    Input Owner Alley        ${Data}[Alley]
    Input Owner Group        ${Data}[Group]
    Input Owner District     ${Data}[District]
    Input Owner Canton       ${Data}[Canton]
    Input Owner Province     ${Data}[Province]
    Input Owner Postcode     ${Data}[Postcode]
    Keyboard Key             press    Tab

ดำเนินการสมัครสมาชิก Owner
    [Documentation]    หน้าสมัครมี 2 ขั้นตอน กรอกครบแล้วกดสมัคร คืนข้อความที่ระบบตอบกลับ
    ...                ถ้าติดตั้งแต่ขั้นตอนที่ 1 จะคืนข้อความแจ้งเตือนที่พบแทน
    [Arguments]    ${Data}

    Open Register Owner Page
    กรอกข้อมูลบัญชีผู้ใช้ Owner    ${Data}

    ${Clicked}=    Click Next Button
    IF    not ${Clicked}
        ${Messages}=    Get Validation Messages
        ${Result}=      รวมข้อความ    ${Messages}    ไม่ผ่านขั้นตอนที่ 1 และไม่พบข้อความแจ้งเตือน
        RETURN    ${Result}
    END

    ${OnStep2}=    Is Register Owner Step2 Displayed
    IF    not ${OnStep2}
        ${Messages}=    Get Validation Messages
        ${Result}=      รวมข้อความ    ${Messages}    ไม่สามารถไปยังขั้นตอนที่ 2 ได้
        RETURN    ${Result}
    END

    กรอกข้อมูลส่วนตัว Owner    ${Data}

    ${Clicked}=    Click Register Button
    IF    not ${Clicked}
        ${Messages}=    Get Validation Messages
        ${Result}=      รวมข้อความ    ${Messages}    ปุ่มสมัครสมาชิกถูกปิดใช้งาน
        RETURN    ${Result}
    END

    ${Registered}=    รอผลการสมัคร
    ${RegLen}=        Get Length    ${Registered}
    IF    ${RegLen} > 0
        Log    ข้อความที่ระบบตอบกลับ : ${Registered}    level=INFO
        RETURN    ${Registered}
    END

    ${Messages}=    Get Validation Messages
    ${Result}=      รวมข้อความ    ${Messages}    ไม่พบทั้งข้อความแจ้งสำเร็จและข้อความแจ้งเตือน
    Log    ข้อความที่ระบบตอบกลับ : ${Result}    level=INFO
    RETURN    ${Result}

รอผลการสมัคร
    [Documentation]    รอ popup แจ้งสมัครสำเร็จสั้น ๆ คืนข้อความบน popup ถ้าไม่พบให้คืนข้อความว่าง
    ...                รอสั้นเพราะกรณีที่ต้องไม่สำเร็จจะไม่มี popup ขึ้นเลย
    ${Success}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Popup_Success}    visible    ${POPUP_TIMEOUT}
    IF    not ${Success}    RETURN    ${EMPTY}

    ${Text}=    Get Text        ${Popup_Success}
    ${Text}=    Strip String    ${Text}
    RETURN    ${Text}


# =====================================================================
# 6. คีย์เวิร์ดช่วยเหลือ : บันทึกผล ตรวจผล และเก็บหลักฐาน
# =====================================================================

บันทึกผลที่ได้จริง
    [Documentation]    จำข้อความที่ระบบตอบกลับไว้ ให้ teardown เขียนลงคอลัมน์ ActualResult
    [Arguments]    ${Text}
    Set Test Variable    ${ACTUAL_MESSAGE}    ${Text}

รวมข้อความ
    [Documentation]    รวมข้อความในลิสต์เป็นข้อความเดียว ถ้าลิสต์ว่างให้ใช้ข้อความสำรอง
    [Arguments]    ${Messages}    ${Fallback}
    ${Count}=    Get Length    ${Messages}
    IF    ${Count} == 0    RETURN    ${Fallback}
    ${Joined}=    Evaluate    " | ".join($Messages)
    RETURN    ${Joined}

ต้องสมัครไม่สำเร็จ
    [Documentation]    ยืนยันว่าระบบไม่ได้สมัครสมาชิกให้
    [Arguments]    ${Message}
    Should Not Contain    ${Message}    ${SUCCESS_KEYWORD}
    ...    msg=ระบบสมัครสมาชิกสำเร็จ ทั้งที่ควรปฏิเสธ (ข้อความ "${Message}")

ข้อความต้องกล่าวถึง
    [Documentation]    ยืนยันว่าข้อความที่ระบบตอบกลับมีคำที่เอกสารระบุไว้อย่างน้อยหนึ่งคำ
    [Arguments]    ${Message}    @{Keywords}
    ${Lower}=    Convert To Lower Case    ${Message}
    # lambda รับค่าผ่าน default argument เพราะ RF มองไม่เห็น $ตัวแปร ใน comprehension
    ${Matched}=    Evaluate    any(map(lambda k, t=$Lower: k.lower() in t, $Keywords))
    Should Be True    ${Matched}
    ...    msg=ข้อความ "${Message}" ไม่ได้กล่าวถึง ${Keywords} จึงไม่แน่ใจว่าระบบตอบด้วยเหตุผลที่ถูกต้อง

เก็บภาพหลักฐาน
    [Documentation]    บันทึกภาพหน้าจอไว้เป็นหลักฐานประกอบรายงาน ตั้งชื่อเป็น <ยูสเคส>_<รหัส>_<คำอธิบาย>
    [Arguments]    ${Name}
    Run Keyword And Ignore Error
    ...    Take Screenshot    ${SCREENSHOT_DIR}/${USECASE}_${TC_ID}_${Name}    fullPage=True

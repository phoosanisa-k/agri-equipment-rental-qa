*** Settings ***
Library           Browser
Library           Collections
Library           String
Library           OperatingSystem
Library           ExcelLibrary
Resource          variables.robot


*** Keywords ***
#-------------------------------------------------------------------------
# Login Farmer
Open Login Page
    [Documentation]    เปิด context และหน้าเข้าสู่ระบบใหม่ (ต้องเรียก Open Test Browser ก่อน)
    New Context
    New Page                   ${Login_farmerURL}
    Set Viewport Size          ${VIEWPORT_WIDTH}    ${VIEWPORT_HEIGHT}
    Wait For Elements State    ${Text_Username}    visible    ${DEFAULT_TIMEOUT}

Input Username
    [Arguments]    ${Username}
    Fill Text    ${Text_Username}    ${Username}

Input Password
    [Arguments]    ${Password}
    Fill Text    ${Text_Password}    ${Password}

Click Verify Button
    Click    ${Btn_Verify}

#-------------------------------------------------------------------------
# คีย์เวิร์ดช่วยเหลือทั่วไป
Open Test Browser
    [Documentation]    เปิด browser process เดียวต่อชุดทดสอบ แล้วใช้ context ใหม่ในแต่ละกรณีทดสอบ
    New Browser            ${browser}    headless=${headless}
    Set Browser Timeout    ${DEFAULT_TIMEOUT}
    # ปิดภาพหน้าจออัตโนมัติ เพราะสคริปต์ถ่ายเองเมื่อเคสไม่ผ่าน และเคสที่ตั้งใจให้ล้มจะได้ภาพเปล่า ๆ ทั้งรันช้าลง
    Register Keyword To Run On Failure    None

Close Test Context
    [Documentation]    ปิด context ของกรณีทดสอบที่เพิ่งจบ ให้กรณีถัดไปเริ่มจากสถานะสะอาด
    Close Context

Close All Test Browsers
    [Documentation]    ปิดเบราว์เซอร์ทั้งหมดตอนจบชุดทดสอบ
    Close Browser    ALL

Is Element Visible
    [Documentation]    ตรวจว่า element แสดงอยู่ไหม ลด timeout ชั่วคราวไม่ให้รอครบ 30 วินาทีตอนไม่พบ
    [Arguments]    ${Selector}
    Set Browser Timeout    ${SHORT_TIMEOUT}
    ${Visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Selector}    visible
    Set Browser Timeout    ${DEFAULT_TIMEOUT}
    RETURN    ${Visible}

Click Button If Enabled
    [Documentation]    กดปุ่มเมื่อไม่ถูก disable คืน True เมื่อกดได้ (ลด timeout ไม่ให้รอครบ 30 วินาที)
    [Arguments]    ${Selector}
    Set Browser Timeout    ${SHORT_TIMEOUT}
    ${Enabled}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Selector}    enabled
    Set Browser Timeout    ${DEFAULT_TIMEOUT}

    IF    ${Enabled}
        Click    ${Selector}
    ELSE
        Log    ปุ่มถูกปิดใช้งานอยู่ (ข้อมูลยังไม่ผ่านการตรวจสอบ) จึงไม่กดปุ่ม    level=INFO
    END
    RETURN    ${Enabled}

#-------------------------------------------------------------------------
# Register Farmer
# page1
Open Register Page
    New Context
    New Page                   ${Register_farmerURL}
    Set Viewport Size          ${VIEWPORT_WIDTH}    ${VIEWPORT_HEIGHT}
    Wait For Elements State    ${Text_RUsername}    visible    ${DEFAULT_TIMEOUT}

Upload Picture
    [Arguments]    ${Picture}
    IF    '${Picture}' != '${EMPTY}'
        Upload File By Selector    ${Img}    ${TestDataDir}/${Picture}
    END

Input UsernameR
    [Arguments]    ${UsernameR}
    Fill Text    ${Text_RUsername}    ${UsernameR}

Input Email
    [Arguments]    ${Email}
    Fill Text    ${Text_REmail}    ${Email}

Input PasswordR
    [Arguments]    ${PasswordR}
    Fill Text    ${Text_RPassword}    ${PasswordR}

Input Confirmpassword
    [Arguments]    ${Confirmpassword}
    Fill Text    ${Text_RConfirmPassword}    ${Confirmpassword}

Click Next Button
    [Documentation]    กดปุ่ม "ถัดไป" คืน True เมื่อกดได้ / False เมื่อปุ่มถูกปิดใช้งาน
    ${Clicked}=    Click Button If Enabled    ${Btn_Next}
    RETURN    ${Clicked}

# page2
Click Register Button
    [Documentation]    กดปุ่ม "สมัครสมาชิก" คืน True เมื่อกดได้ / False เมื่อปุ่มถูกปิดใช้งาน
    ${Clicked}=    Click Button If Enabled    ${Btn_Register}
    RETURN    ${Clicked}

Click Back Button
    [Documentation]    กดปุ่ม "ย้อนกลับ" เพื่อกลับไปขั้นตอนที่ 1
    Click    ${Btn_Back}

Is Register Step2 Displayed
    [Documentation]    ตรวจว่าถึงหน้าที่ 2 (ข้อมูลส่วนตัว) หรือยัง ดูจากช่อง "ชื่อจริง"
    ${Displayed}=    Is Element Visible    ${Text_Name}
    RETURN    ${Displayed}

Input Firstname
    [Arguments]    ${Firstname}
    Fill Text    ${Text_Name}    ${Firstname}

Input Surname
    [Arguments]    ${Surname}
    Fill Text    ${Text_LName}    ${Surname}

Select Gender
    [Arguments]    ${Gender}
    IF    '${Gender}' == 'ชาย'
        Select Options By    ${Select_Gender}    value    male
    ELSE IF    '${Gender}' == 'หญิง'
        Select Options By    ${Select_Gender}    value    female
    ELSE
        # ไม่เลือกเพศ : ต้องเข้าช่องแล้วออกเอง ระบบจึงเตือน (select ไม่ถูกแตะอัตโนมัติเหมือน Fill Text)
        Focus    ${Select_Gender}
        Focus    ${Text_Phone}
    END

Input Birthdate
    [Arguments]    ${Daybirth}    ${Monthbirth}    ${Yearbirth}
    # กรอกทุกช่องแม้ค่าว่างเพื่อให้ระบบเตือน ปีในไฟล์ทดสอบเป็น พ.ศ. อยู่แล้วจึงกรอกตรง ๆ
    # ใช้ Type Text แทน Fill Text เพราะช่องเป็น input type="number" ถ้าค่าทดสอบมีอักขระที่ไม่ใช่ตัวเลข
    # (เช่นกรณี Invalid Format ที่ยัดวันที่ทั้งก้อนมาในช่องเดียว) Fill Text จะ error ทันทีตั้งแต่ระดับ Playwright
    # ก่อนถึงขั้นให้เว็บตรวจสอบ Type Text จำลองการพิมพ์ทีละตัวอักษรจริง ให้ browser กรองตัวที่พิมพ์ไม่ได้เองแทน
    Type Text    ${Date_Birth}    ${Daybirth}
    Type Text    ${Date_Month}    ${Monthbirth}
    Type Text    ${Date_Year}     ${Yearbirth}

Input Tel
    [Arguments]    ${Tel}
    Fill Text    ${Text_Phone}    ${Tel}

Input Hnum
    [Arguments]    ${Hnum}
    Fill Text    ${Text_Num}    ${Hnum}

Input Alley
    [Arguments]    ${Alley}
    Fill Text    ${Text_Alley}    ${Alley}

Input Group
    [Arguments]    ${Group}
    Fill Text    ${Text_Moo}    ${Group}

Input District
    [Arguments]    ${District}
    Fill Text    ${Text_Subdistric}    ${District}

Input Canton
    [Arguments]    ${Canton}
    Fill Text    ${Text_Distric}    ${Canton}

Input Province
    [Arguments]    ${province}
    Fill Text    ${Text_Province}    ${province}

Input Postcode
    [Arguments]    ${Postcode}
    Fill Text    ${Text_Postcode}    ${Postcode}

Get Validation Messages
    [Documentation]    คืน list ข้อความแจ้งเตือน (ไม่มีก็คืน list ว่าง) ลด timeout ชั่วคราวไม่ให้รอครบ 30 วินาทีตอนไม่พบ
    ${Messages}=    Create List

    Set Browser Timeout    ${SHORT_TIMEOUT}
    ${Status}    ${Elements}=    Run Keyword And Ignore Error    Get Elements    ${Error_Message}
    Set Browser Timeout    ${DEFAULT_TIMEOUT}

    IF    '${Status}' == 'FAIL'    RETURN    ${Messages}

    # หน้าเว็บอาจเปลี่ยนระหว่างวนอ่าน (เช่น ฟอร์มปิดหลังบันทึกสำเร็จ) element ที่นับไว้จึงหายไปได้
    # อ่านแต่ละตัวด้วย timeout สั้นและข้ามตัวที่อ่านไม่ได้ ไม่ให้ค้างรอ 30 วินาทีแล้วทั้งเคสล้ม
    Set Browser Timeout    ${SHORT_TIMEOUT}
    FOR    ${Element}    IN    @{Elements}
        ${Ok}    ${Text}=    Run Keyword And Ignore Error    Get Text    ${Element}
        IF    '${Ok}' == 'FAIL'    CONTINUE
        ${Text}=    Strip String    ${Text}

        # locator อาจจับได้ทั้ง element แม่และลูกที่ข้อความเดียวกัน จึงกรองข้อความซ้ำออก
        ${IsDuplicate}=    Evaluate    $Text in $Messages
        # เทียบด้วยความยาว ไม่เอาข้อความไปแทรกใน expression เพราะข้อความที่ขึ้นบรรทัดใหม่จะทำให้ IF พัง
        ${Length}=    Get Length    ${Text}
        IF    ${Length} > 0 and not ${IsDuplicate}
            Append To List    ${Messages}    ${Text}
        END
    END
    Set Browser Timeout    ${DEFAULT_TIMEOUT}
    RETURN    ${Messages}

#-------------------------------------------------------------------------
# เทียบผลจริงกับที่คาดหวังแบบตรงกัน 100% (Exact Match) : ไม่ตัดช่องว่าง ไม่อนุโลม ไม่แทนที่คำ
เทียบผลจริงกับที่คาดหวัง
    [Arguments]    ${Actual}    ${Expected}
    Should Be Equal    ${Actual}    ${Expected}
    ...    msg=ระบบตอบ "${Actual}" แต่เอกสารกำหนด "${Expected}"    values=False

#-------------------------------------------------------------------------
# Excel : คีย์เวิร์ดกลางสำหรับสวีทที่อ่านข้อมูลทดสอบและเขียนผลกลับ (ต้อง Open Excel Document ก่อน)
นับแถวใน Excel
    [Documentation]    จำนวนแถวทั้งหมดของชีต (รวมหัวตาราง) นับจากคอลัมน์รหัสกรณีทดสอบ
    [Arguments]    ${Sheet}    ${ColId}
    ${Ids}=      Read Excel Column    ${ColId}    sheet_name=${Sheet}
    ${Total}=    Get Length    ${Ids}
    RETURN    ${Total}

อ่านแถวข้อมูลจาก Excel
    [Documentation]    อ่านทั้งแถวเป็นลิสต์ข้อความ ช่องว่างเป็น "" ตัวเลขเต็มเป็นข้อความเลขจำนวนเต็ม
    [Arguments]    ${Sheet}    ${Row}    ${ColumnCount}
    ${Cells}=    Read Excel Row    ${Row}    max_num=${ColumnCount}    sheet_name=${Sheet}
    ${Cells}=    Evaluate
    ...    ["" if v is None else (str(int(v)) if isinstance(v, float) and v.is_integer() else str(v)) for v in $Cells]
    RETURN    ${Cells}

บันทึกผลทดสอบลง Excel
    [Documentation]    เขียนผลที่ได้จริงและ Pass/Fail ลงแถวที่ระบุ แล้วเซฟผ่านไฟล์ชั่วคราว (ถ้ารันถูกตัดกลางคัน ไฟล์จริงยังสมบูรณ์)
    [Arguments]    ${DataFile}    ${Sheet}    ${Row}    ${ColActual}    ${ColResult}    ${Actual}    ${Result}
    Write Excel Cell    ${Row}    ${ColActual}    ${Actual}    sheet_name=${Sheet}
    Write Excel Cell    ${Row}    ${ColResult}    ${Result}    sheet_name=${Sheet}
    เซฟ Excel อย่างปลอดภัย    ${DataFile}

เซฟ Excel อย่างปลอดภัย
    [Arguments]    ${DataFile}
    ${Temp}=    Set Variable    ${DataFile}.saving.xlsx
    Save Excel Document    ${Temp}
    Move File    ${Temp}    ${DataFile}

ลบภาพทั้งหมดในโฟลเดอร์
    [Documentation]    ลบ *.png ในโฟลเดอร์ของยูสเคส ไม่ลบตัวโฟลเดอร์ เพราะ OneDrive มักคืน Access denied
    [Arguments]    ${Folder}
    Create Directory    ${Folder}
    ${Files}=    List Files In Directory    ${Folder}    *.png
    FOR    ${File}    IN    @{Files}
        ${Removed}=    Run Keyword And Return Status    Remove File    ${Folder}/${File}
        IF    not ${Removed}    Log    ลบไฟล์ ${File} ไม่สำเร็จ    level=WARN
    END

รวมข้อความหลายรายการ
    [Documentation]    รวมลิสต์ข้อความเป็นข้อความเดียวคั่นด้วย " | " ถ้าลิสต์ว่างคืนข้อความที่ส่งมาเป็น ${WhenEmpty}
    [Arguments]    ${Messages}    ${WhenEmpty}
    ${Count}=    Get Length    ${Messages}
    IF    ${Count} == 0    RETURN    ${WhenEmpty}
    ${Joined}=    Evaluate    " | ".join($Messages)
    RETURN    ${Joined}

สรุปข้อความที่ระบบตอบ
    [Documentation]    ข้อความที่บันทึกลง ActualResult : ข้อความบน popup ถ้ามี ไม่มีให้ใช้ข้อความแจ้งเตือนที่ระบบแสดง
    ...                (หลายข้อความคั่นด้วย " | ") ถ้าระบบไม่แสดงอะไรเลยเป็นค่าว่าง ไม่ใส่ข้อความแทน
    [Arguments]    ${Messages}    ${Popup}
    ${PopupLen}=    Get Length    ${Popup}
    IF    ${PopupLen} > 0    RETURN    ${Popup}
    ${Result}=    รวมข้อความหลายรายการ    ${Messages}    ${EMPTY}
    RETURN    ${Result}

#-------------------------------------------------------------------------
# โครงกลางของไฟล์ใน UseCase : ใช้ร่วมกันทั้ง 10 ไฟล์
# ไฟล์ที่เรียกใช้ต้องประกาศตัวแปร ${USECASE} ${SCREENSHOT_DIR} ${TC_ID} ${ACTUAL_MESSAGE}
เตรียมชุดทดสอบยูสเคส
    [Documentation]    ล้างภาพของรอบก่อนในโฟลเดอร์ของยูสเคส แล้วเปิดเบราว์เซอร์
    ลบภาพทั้งหมดในโฟลเดอร์    ${SCREENSHOT_DIR}
    Open Test Browser

ปิดชุดทดสอบ
    [Documentation]    ปิดเบราว์เซอร์ทั้งหมด
    Close All Test Browsers

บันทึกผลที่ได้จริง
    [Documentation]    จำข้อความที่ระบบตอบไว้ ให้ "เก็บผลท้ายกรณีทดสอบ" เขียนลง log และ report
    [Arguments]    ${Text}
    Set Test Variable    ${ACTUAL_MESSAGE}    ${Text}

เก็บผลท้ายกรณีทดสอบ
    [Documentation]    ใช้เป็น Test Teardown : เขียนผลจริงลง log และ report ถ่ายภาพเมื่อไม่ผ่าน แล้วเก็บกวาด
    ...                ${Cleanup} คือคีย์เวิร์ดที่ใช้เก็บกวาดตอนจบเคส (ค่าเริ่มต้นปิด context)
    [Arguments]    ${Cleanup}=Close Test Context
    Log    ${TC_ID} ข้อความที่ระบบตอบ : "${ACTUAL_MESSAGE}"    level=INFO
    IF    $ACTUAL_MESSAGE != ''
        Set Test Message    \nผลที่ได้จริง : ${ACTUAL_MESSAGE}    append=True
    END
    IF    '${TEST STATUS}' == 'FAIL'
        Run Keyword And Ignore Error
        ...    Take Screenshot    ${SCREENSHOT_DIR}/${USECASE}_${TC_ID}_FAILED    fullPage=True
    END
    # Ignore Error เพราะบางกรณีอาจไม่มี context หรือไม่มีฟอร์ม/กล่องโต้ตอบค้างอยู่
    Run Keyword And Ignore Error    ${Cleanup}

#-------------------------------------------------------------------------
# โครงกลางของไฟล์ใน Testcase : อ่าน Excel ด้วย FOR loop ทดสอบทีละแถว เทียบผลตรงกัน 100% แล้วเขียนผลกลับ
# ไฟล์ที่เรียกใช้ต้องประกาศตัวแปร ${DATA_FILE} ${SHEET} ${USECASE} ${SCREENSHOT_DIR}
# ${COL_ACTUAL} ${COL_PF} (ตัว FOR loop อ่านทุกแถวเขียนไว้ในแต่ละไฟล์เอง)
เปิดชุดทดสอบจาก Excel
    [Documentation]    ล้างภาพของรอบก่อน เปิดไฟล์ Excel สำหรับเขียนผล และเปิดเบราว์เซอร์
    [Arguments]    ${Alias}
    ลบภาพทั้งหมดในโฟลเดอร์    ${SCREENSHOT_DIR}
    Open Excel Document    ${DATA_FILE}    ${Alias}
    Open Test Browser

ปิดชุดทดสอบ Excel
    [Documentation]    บันทึกไฟล์ Excel แล้วปิดทุกอย่าง
    Run Keyword And Ignore Error    เซฟ Excel อย่างปลอดภัย    ${DATA_FILE}
    Run Keyword And Ignore Error    Close All Excel Documents
    Close All Test Browsers

ตัดสินผลและบันทึกลง Excel
    [Documentation]    รับผลจาก "Run Keyword And Ignore Error ทำรายการ..." ของแถวนั้น
    ...                -> เทียบ Actual กับ Expected แบบตรงกัน 100% -> ถ่ายภาพเมื่อไม่ผ่าน -> เขียนผลลง Excel -> เก็บกวาด -> Fail ถ้าไม่ผ่าน
    ...                ActualResult เก็บเฉพาะข้อความที่ get text ได้จากระบบ ถ้าสคริปต์ล้มกลางทางให้เป็นค่าว่าง (สาเหตุดูใน log/report)
    ...                ${Cleanup} คือคีย์เวิร์ดที่ใช้เก็บกวาดตอนจบแถว (ค่าเริ่มต้นปิด context)
    [Arguments]    ${Status}    ${Out}    ${ExpectedResult}    ${TestCase}    ${Row}    ${Cleanup}=Close Test Context
    IF    '${Status}' == 'FAIL'
        ${Actual}=     Set Variable    ${EMPTY}
        ${Verdict}=    Set Variable    FAIL
        ${Reason}=     Set Variable    ${Out}
    ELSE
        ${Actual}=    Set Variable    ${Out}
        ${Verdict}    ${Reason}=    Run Keyword And Ignore Error    เทียบผลจริงกับที่คาดหวัง    ${Actual}    ${ExpectedResult}
    END

    IF    '${Verdict}' == 'FAIL'
        Run Keyword And Ignore Error    Take Screenshot    ${SCREENSHOT_DIR}/${USECASE}_${TestCase}_FAILED    fullPage=True
    END
    ${Result}=    Set Variable If    '${Verdict}' == 'PASS'    Pass    Fail
    Run Keyword And Ignore Error    บันทึกผลทดสอบลง Excel
    ...    ${DATA_FILE}    ${SHEET}    ${Row}    ${COL_ACTUAL}    ${COL_PF}    ${Actual}    ${Result}
    Run Keyword And Ignore Error    ${Cleanup}
    IF    '${Verdict}' == 'FAIL'    Fail    ${Reason}

#-------------------------------------------------------------------------
# Add Cart Farmer : ไม่มีการกรอกฟอร์ม เป็นคีย์เวิร์ด "ค้นหา - กดปุ่ม - ดูตะกร้า" ล้วน ๆ
Close Login Popup
    [Documentation]    ปิด popup เข้าสู่ระบบสำเร็จ ระบบจะพาเข้าหน้าหลักเมื่อกด "ตกลง" เท่านั้น
    ${HasButton}=    Is Element Visible    ${Btn_Verify}
    IF    ${HasButton}    Run Keyword And Ignore Error    Click Verify Button

Open Search Equipment Page
    [Documentation]    เข้าหน้าค้นหาอุปกรณ์ (ต้องล็อกอินก่อน) ไม่พบปุ่มบนหน้าหลักใช้เมนูบนหัวเว็บแทน เผื่อหน้าหลักถูกปรับดีไซน์
    ${Found}=    Is Element Visible    ${Link_SearchEQ}
    IF    ${Found}
        Click    ${Link_SearchEQ}
    ELSE
        Log    ไม่พบปุ่มเข้าหน้าค้นหาบนหน้าหลัก จึงกดเมนูบนหัวเว็บแทน    level=WARN
        Wait For Elements State    ${Link_SearchEQMenu}    visible    ${DEFAULT_TIMEOUT}
        Click                      ${Link_SearchEQMenu}
    END
    Wait For Elements State    ${Text_SearchEQ}     visible    ${DEFAULT_TIMEOUT}

Select Equipment Type
    [Documentation]    เลือกประเภทอุปกรณ์จาก dropdown คืน True เมื่อกรองด้วยประเภทที่ระบุจริง ๆ
    ...                ค่าว่างจะเลือกตัวเลือก "ทุกประเภท" เพื่อล้างตัวกรองรอบก่อน (dropdown ค้างจะบังผลค้นหา)
    ...                หาประเภทไม่เจอจะ log warning แทนการล้ม test
    [Arguments]    ${Type}

    ${Ok}    ${Options}=    Run Keyword And Ignore Error    Get Select Options    ${Select_EQType}
    IF    '${Ok}' == 'FAIL'
        Log    ไม่พบ dropdown ประเภทอุปกรณ์ จึงข้ามการเลือกประเภท    level=WARN
        RETURN    ${False}
    END

    ${Labels}=    Evaluate    [str(o.get("label", "")).strip() for o in $Options]

    IF    '${Type}' == '${EMPTY}'
        ล้างตัวกรองประเภทอุปกรณ์    ${Labels}
        RETURN    ${False}
    END

    # lambda รับค่าผ่าน default argument เพราะ RF มองไม่เห็น $ตัวแปร ในเงื่อนไขของ comprehension
    ${Matched}=    Evaluate    next(filter(lambda l, t=$Type: l == t or t in l, $Labels), "")

    IF    '${Matched}' == '${EMPTY}'
        Log    ไม่มีประเภท "${Type}" ใน dropdown (มี ${Labels}) จึงล้างตัวกรองแล้วค้นหาจากชื่ออุปกรณ์อย่างเดียว    level=WARN
        ล้างตัวกรองประเภทอุปกรณ์    ${Labels}
        RETURN    ${False}
    END

    Select Options By    ${Select_EQType}    label    ${Matched}
    RETURN    ${True}

ล้างตัวกรองประเภทอุปกรณ์
    [Documentation]    เลือกตัวเลือกที่หมายถึง "ทุกประเภท" ใน dropdown เพื่อไม่ให้ตัวกรองบังผลการค้นหา
    ...                ไม่มีตัวเลือกแบบนั้นก็ปล่อยไว้ตามค่าเริ่มต้นของหน้า แล้วบันทึกไว้ใน log
    [Arguments]    ${Labels}
    ${All}=    Evaluate    next((l for l in $Labels if "ทั้งหมด" in l or "ทุกประเภท" in l or l == ""), None)

    IF    $All is None
        Log    ไม่มีตัวเลือก "ทุกประเภท" ใน dropdown (มี ${Labels}) จึงปล่อยตัวกรองไว้ตามค่าเริ่มต้น    level=INFO
        RETURN    ${False}
    END

    Select Options By    ${Select_EQType}    label    ${All}
    RETURN    ${True}

Select Equipment Type Matching
    [Documentation]    เลือกประเภทใน dropdown ให้เข้าคู่กับชื่ออุปกรณ์ที่กำลังค้นหา คืน True เมื่อได้เลือกประเภทเจาะจงจริง
    ...                ไม่มีตัวเลือกเข้าคู่จะเลือก "ทุกประเภท" แทน (ไม่กรองยังดีกว่ากรองผิดประเภท)
    [Arguments]    ${Name}

    ${Len}=    Get Length    ${Name}
    IF    ${Len} == 0
        ${Cleared}=    Select Equipment Type    ${EMPTY}
        RETURN    ${False}
    END

    ${Ok}    ${Options}=    Run Keyword And Ignore Error    Get Select Options    ${Select_EQType}
    IF    '${Ok}' == 'FAIL'
        Log    ไม่พบ dropdown ประเภทอุปกรณ์ จึงข้ามการเลือกประเภท    level=WARN
        RETURN    ${False}
    END

    ${Labels}=     Evaluate    [str(o.get("label", "")).strip() for o in $Options]
    ${Matched}=    จับคู่ประเภทกับคำค้นหา    ${Labels}    ${Name}

    IF    '${Matched}' == '${EMPTY}'
        Log    ไม่มีประเภทที่เข้าคู่กับ "${Name}" ใน dropdown (มี ${Labels}) จึงเลือกทุกประเภทแทน    level=INFO
        ล้างตัวกรองประเภทอุปกรณ์    ${Labels}
        RETURN    ${False}
    END

    Select Options By    ${Select_EQType}    label    ${Matched}
    Log    เลือกประเภท "${Matched}" ให้ตรงกับคำค้นหา "${Name}"    level=INFO
    RETURN    ${True}

จับคู่ประเภทกับคำค้นหา
    [Documentation]    หาตัวเลือกใน dropdown ที่เข้าคู่กับคำค้นหามากที่สุด ไม่พบคืนค่าว่าง
    ...                จับคู่ตามลำดับ ตรงตัว > เป็นส่วนของกัน > คำร่วมกันยาวสุดตั้งแต่ 3 ตัวอักษร
    ...                ข้ามตัวเลือกที่หมายถึง "ทุกประเภท" เพราะไม่ได้เจาะจงประเภทใด
    [Arguments]    ${Labels}    ${Name}
    # lambda รับค่าผ่าน default argument เพราะ RF มองไม่เห็น $ตัวแปร ในเงื่อนไขของ comprehension
    ${Exact}=    Evaluate    next(filter(lambda l, n=$Name.strip(): l == n, $Labels), "")
    IF    '${Exact}' != '${EMPTY}'    RETURN    ${Exact}

    ${Types}=    Evaluate    [l for l in $Labels if l and "ทั้งหมด" not in l and "ทุกประเภท" not in l]
    ${Part}=     Evaluate    next(filter(lambda l, n=$Name.strip(): l in n or n in l, $Types), "")
    IF    '${Part}' != '${EMPTY}'    RETURN    ${Part}

    # คำร่วมที่ยาวที่สุด เช่น คำค้น "รถไถเดินตาม" กับประเภท "รถไถนา" มีคำร่วมกันคือ "รถไถ"
    ${Best}=     Evaluate
    ...    max($Types, key=lambda l, n=$Name.strip(): max((j - i for i in range(len(n)) for j in range(i + 3, len(n) + 1) if n[i:j] in l), default=0), default="")
    ${Score}=    Evaluate
    ...    max((j - i for i in range(len($Name.strip())) for j in range(i + 3, len($Name.strip()) + 1) if $Name.strip()[i:j] in $Best), default=0) if $Best else 0
    IF    ${Score} >= 3    RETURN    ${Best}

    RETURN    ${EMPTY}

Input Search Equipment
    [Documentation]    พิมพ์ชื่ออุปกรณ์ลงช่องค้นหา แล้วรอให้รายการอัปเดตตามคำค้น
    [Arguments]    ${Keyword}
    Fill Text    ${Text_SearchEQ}    ${Keyword}
    # หน้าเว็บกรองรายการหลังหยุดพิมพ์ จึงต้องรอสั้น ๆ ก่อนนับผล
    Sleep    1s

Get Equipment Card Count
    [Documentation]    นับการ์ดอุปกรณ์ ต้องรอการ์ดใบแรกก่อน เพราะ Get Element Count ไม่รอ element จะได้ 0 ถ้าหน้ายังวาดไม่เสร็จ
    ${Found}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Card_EQButtons} >> nth=0    visible    ${CARD_TIMEOUT}
    IF    not ${Found}    RETURN    ${0}

    ${Count}=    Get Element Count    ${Card_EQButtons}
    RETURN    ${Count}

Get Found Count Text
    [Documentation]    อ่านข้อความสรุปผลการค้นหา เช่น "พบอุปกรณ์ทั้งหมด 1 รายการ" ใช้บันทึกลง ActualResult
    ${Found}=    Is Element Visible    ${Text_FoundCount}
    IF    not ${Found}    RETURN    ไม่พบข้อความสรุปผลการค้นหา
    ${Text}=    Get Text        ${Text_FoundCount}
    ${Text}=    Strip String    ${Text}
    RETURN    ${Text}

Get Popup Title
    [Documentation]    อ่านหัวข้อบนกล่องแจ้งเตือน SweetAlert2 ที่ระบบขึ้นมา ถ้าไม่มี popup คืนข้อความว่าง
    ${Found}=    Is Element Visible    ${Popup_Title}
    IF    not ${Found}    RETURN    ${EMPTY}

    ${Text}=    Get Text        ${Popup_Title}
    ${Text}=    Strip String    ${Text}
    RETURN    ${Text}

Get Equipment Button State
    [Documentation]    อ่านข้อความบนปุ่มการ์ดใบแรก (3 สถานะ: เพิ่มในตะกร้า / อยู่ในตะกร้าแล้ว / ไม่พร้อมให้เช่า) ไม่ตรงสถานะใดเลยคืนข้อความดิบ
    ${Found}=    Is Element Visible    ${Card_EQButtons} >> nth=0
    IF    not ${Found}    RETURN    ${EMPTY}

    ${Raw}=    Get Text        ${Card_EQButtons} >> nth=0
    ${Raw}=    Strip String    ${Raw}
    # ปุ่มมีไอคอนนำหน้า จึงมีช่องว่าง/ขึ้นบรรทัดใหม่ติดมาด้วย
    ${Raw}=    Evaluate    " ".join($Raw.split())

    # lambda รับค่าผ่าน default argument เพราะ RF มองไม่เห็น $ตัวแปร ที่อยู่ในเงื่อนไข
    ${State}=    Evaluate    next(filter(lambda s, t=$Raw: s in t, $EQ_BUTTON_STATES), $Raw)
    RETURN    ${State}

Click Add To Cart
    [Documentation]    กดปุ่ม "เพิ่มในตะกร้า" ของการ์ดใบแรก คืน True เมื่อกดได้
    ${Clicked}=    Click Button If Enabled    ${Btn_AddToCart} >> nth=0
    IF    ${Clicked}    Sleep    0.5s
    RETURN    ${Clicked}

Open Cart
    [Documentation]    กดปุ่มตะกร้ามุมขวาล่าง คืน True เมื่อกล่องเปิดขึ้นจริง
    ${HasButton}=    Is Element Visible    ${Btn_OpenCart}
    IF    not ${HasButton}    RETURN    ${False}

    Click    ${Btn_OpenCart}
    ${Opened}=    Is Element Visible    ${Cart_Modal}
    RETURN    ${Opened}

Close Cart
    [Documentation]    ปิดกล่องตะกร้า ใช้ Ignore Error เพราะบางกรณีกล่องไม่ได้เปิดอยู่
    Run Keyword And Ignore Error    Click    ${Btn_CloseCart}

Get Cart Item Count
    [Documentation]    นับรายการในตะกร้าจากปุ่มถังขยะ (หนึ่งรายการหนึ่งปุ่ม) ต้องเปิดกล่องไว้ก่อน
    ${Count}=    Get Element Count    ${Btn_RemoveFromCart}
    RETURN    ${Count}

Get Available Equipment Count
    [Documentation]    นับอุปกรณ์ที่ยังกด "เพิ่มในตะกร้า" ได้ ไม่นับชิ้นที่อยู่ในตะกร้าแล้วหรือไม่พร้อมให้เช่า
    ${Found}=    Is Element Visible    ${Btn_AddToCart} >> nth=0
    IF    not ${Found}    RETURN    ${0}
    ${Count}=    Get Element Count    ${Btn_AddToCart}
    RETURN    ${Count}

Remove First Cart Item
    [Documentation]    กดถังขยะของรายการแรกในตะกร้า ต้องเปิดกล่องตะกร้าไว้ก่อน คืน True เมื่อกดได้
    ${Clicked}=    Click Button If Enabled    ${Btn_RemoveFromCart} >> nth=0
    IF    ${Clicked}    Sleep    0.3s
    RETURN    ${Clicked}

Click Clear Cart Button
    [Documentation]    กดปุ่ม "ล้างตะกร้า" ในกล่องตะกร้า ต้องเปิดกล่องไว้ก่อน คืน True เมื่อกดได้
    ...                ตอบกล่องยืนยันของเบราว์เซอร์ไว้ล่วงหน้า เผื่อหน้าเว็บเรียก confirm ก่อนล้าง
    Run Keyword And Ignore Error    Handle Future Dialogs    action=accept
    ${Clicked}=    Click Button If Enabled    ${Btn_ClearCart}
    IF    ${Clicked}    Sleep    0.5s
    RETURN    ${Clicked}

Get Cart Text
    [Documentation]    อ่านข้อความในกล่องตะกร้า (ไม่อ่านทั้งหน้า เพราะการ์ดใต้กล่องมีชื่ออุปกรณ์เดียวกัน)
    ${Opened}=    Is Element Visible    ${Cart_Modal}
    IF    not ${Opened}    RETURN    ${EMPTY}
    ${Text}=    Get Text    ${Cart_Modal}
    RETURN    ${Text}

Clear Cart
    [Documentation]    ล้างตะกร้าให้ทุกเคสเริ่มจากว่าง ลบทีละรายการ ไม่ใช้ปุ่ม "ล้างตะกร้า" เพราะอาจมีกล่องยืนยันของเบราว์เซอร์ทำให้ค้าง
    ${Opened}=    Open Cart
    IF    not ${Opened}
        Log    เปิดกล่องตะกร้าไม่ได้ ถือว่าตะกร้าว่างอยู่แล้ว    level=INFO
        RETURN    ${0}
    END

    ${Removed}=    Set Variable    ${0}
    FOR    ${Round}    IN RANGE    20
        ${Count}=    Get Cart Item Count
        IF    ${Count} == 0    BREAK
        Click      ${Btn_RemoveFromCart} >> nth=0
        Sleep      0.3s
        ${Removed}=    Evaluate    ${Removed} + 1
    END

    Close Cart
    Log    ล้างของเดิมออกจากตะกร้า ${Removed} รายการ    level=INFO
    RETURN    ${Removed}

#-------------------------------------------------------------------------
# Booking Equipment Farmer : ฟอร์มจองอยู่ในกล่องตะกร้า ต้องเปิดกล่องไว้ก่อนจึงจะกรอกได้
Is Booking Form Displayed
    [Documentation]    ตรวจว่ากล่องตะกร้าแสดงฟอร์มจองแล้วหรือยัง ดูจากช่องวันที่เริ่มเช่า
    ${Displayed}=    Is Element Visible    ${Text_StartDate}
    RETURN    ${Displayed}

เทียบปีให้เป็น ค.ศ.
    [Documentation]    แปลงปีให้เป็น ค.ศ. ก่อนนำไปเทียบ (ปีที่มากกว่า 2400 ถือว่าเป็น พ.ศ.) รองรับหัวปฏิทินทั้งสองระบบ
    [Arguments]    ${Year}
    ${Year}=      Convert To Integer    ${Year}
    ${Result}=    Evaluate    ${Year} - ${THAI_YEAR_OFFSET} if ${Year} > 2400 else ${Year}
    RETURN    ${Result}

หากล่องปฏิทินของช่องที่ระบุ
    [Documentation]    คืน selector ของกล่อง .date-picker-container ที่ครอบช่องวันที่นั้น
    ...                ต้องอ้างจากกล่องนี้เสมอ ไม่งั้นจะไปโดนปฏิทินของอีกช่องเมื่อเปิดพร้อมกัน 2 กล่อง
    [Arguments]    ${Field}
    RETURN    xpath=(${Field}/ancestor::div[contains(@class,'date-picker-container')])[last()]

อ่านเดือนบนหัวปฏิทิน
    [Documentation]    อ่านหัวปฏิทินของกล่องที่ระบุ (เช่น "กันยายน 2026") คืนเลขเดือนรวมปี (ปี*12+เดือน)
    ...                คืน 0 เมื่ออ่านไม่ได้ ให้ผู้เรียกตัดสินใจเองว่าจะเลิกเลื่อน
    [Arguments]    ${Picker}
    ${Ok}    ${Header}=    Run Keyword And Ignore Error    Get Text    ${Picker} >> xpath=.//h3
    IF    '${Ok}' == 'FAIL'    RETURN    ${0}

    ${Header}=    Strip String    ${Header}
    ${Parts}=     Split String    ${Header}
    ${Count}=     Get Length      ${Parts}
    IF    ${Count} < 2
        Log    อ่านหัวปฏิทินไม่ได้ (ได้ "${Header}")    level=WARN
        RETURN    ${0}
    END

    ${Month}=    Get From Dictionary    ${THAI_MONTHS}    ${Parts}[0]    default=${0}
    IF    ${Month} == 0
        Log    ไม่รู้จักชื่อเดือน "${Parts}[0]" บนหัวปฏิทิน    level=WARN
        RETURN    ${0}
    END

    ${Year}=    เทียบปีให้เป็น ค.ศ.    ${Parts}[1]
    ${Index}=   Evaluate    ${Year} * 12 + ${Month}
    RETURN    ${Index}

เลื่อนปฏิทินไปยังเดือน
    [Documentation]    เลื่อนปฏิทินของกล่องที่ระบุไปยังเดือนเป้าหมาย โดยอ่านหัวเดือนใหม่ทุกครั้งแทนการนับจำนวนคลิก
    ...                ปฏิทินอาจเปิดที่เดือนของค่าเดิมในช่อง ไม่ใช่เดือนปัจจุบันเสมอไป
    [Arguments]    ${Picker}    ${TargetIndex}
    ${Prev}=    Set Variable    ${Picker} >> xpath=.//button[.//*[name()='path'][@d='M15 19l-7-7 7-7']]
    ${Next}=    Set Variable    ${Picker} >> xpath=.//button[.//*[name()='path'][@d='M9 5l7 7-7 7']]

    FOR    ${Round}    IN RANGE    24
        ${Now}=    อ่านเดือนบนหัวปฏิทิน    ${Picker}
        IF    ${Now} == 0                 RETURN    ${False}
        IF    ${Now} == ${TargetIndex}    RETURN    ${True}

        ${Button}=    Set Variable If    ${Now} < ${TargetIndex}    ${Next}    ${Prev}
        Click    ${Button}
        Sleep    0.2s
    END
    Log    เลื่อนปฏิทินครบ 24 ครั้งแล้วยังไม่ถึงเดือนเป้าหมาย    level=WARN
    RETURN    ${False}

หาวันแรกที่ระบบเปิดให้เลือก
    [Documentation]    ไล่หาวันแรกที่ระบบยังเปิดให้เลือก (มองไปข้างหน้าไม่เกิน 12 เดือน) คืน "ปปปป-ดด-วว" หรือค่าว่างถ้าไม่พบ
    ...                ใช้เมื่อกรณีทดสอบต้องการแค่วันที่ถูกต้องวันหนึ่ง ไม่ต้องพึ่งสภาพข้อมูลในฐานข้อมูล
    [Arguments]    ${Field}
    ${Picker}=    หากล่องปฏิทินของช่องที่ระบุ    ${Field}
    ${Opened}=    เปิดปฏิทินให้ได้    ${Field}    ${Picker}
    IF    not ${Opened}    RETURN    ${EMPTY}

    ${Next}=    Set Variable    ${Picker} >> xpath=.//button[.//*[name()='path'][@d='M9 5l7 7-7 7']]

    FOR    ${Round}    IN RANGE    12
        ${Index}=    อ่านเดือนบนหัวปฏิทิน    ${Picker}
        IF    ${Index} == 0    BREAK

        ${Days}=    วันที่ที่ระบบเปิดให้เลือก    ${Picker}
        ${Day}=     Evaluate    int($Days.split(",")[0].strip()) if $Days[:1].isdigit() else 0

        IF    ${Day} > 0
            ${Month}=    Evaluate    (${Index} - 1) % 12 + 1
            ${Year}=     Evaluate    (${Index} - ${Month}) // 12
            ${Found}=    Evaluate    "%04d-%02d-%02d" % (${Year}, ${Month}, ${Day})
            Log    วันแรกที่ระบบเปิดให้เลือกของช่องนี้คือ ${Found}    level=INFO
            RETURN    ${Found}
        END

        Click    ${Next}
        Sleep    0.2s
    END

    Log    ไล่ดูปฏิทิน 12 เดือนแล้วไม่พบวันที่ระบบเปิดให้เลือกเลย    level=WARN
    RETURN    ${EMPTY}

Pick Date From Calendar
    [Documentation]    เปิดปฏิทินของช่องที่ระบุแล้วกดเลือกวันที่เป้าหมาย คืนค่าที่อ่านได้เมื่อสำเร็จ / คืนข้อความบอกเหตุเมื่อเลือกไม่ได้
    ...                ช่องวันที่เป็นปุ่มสลับเปิด-ปิด ต้องเช็คว่าเปิดอยู่หรือยังก่อนกด (กดซ้ำจะปิด) หลังเลือกวันแล้วปฏิทินปิดให้เอง
    [Arguments]    ${Field}    ${Day}    ${MonthIndex}    ${Display}

    ${Picker}=    หากล่องปฏิทินของช่องที่ระบุ    ${Field}
    ${Opened}=    เปิดปฏิทินให้ได้    ${Field}    ${Picker}
    IF    not ${Opened}    RETURN    เปิดปฏิทินของช่องนี้ไม่ได้

    เลื่อนปฏิทินไปยังเดือน    ${Picker}    ${MonthIndex}

    # เอาเฉพาะวันของเดือนที่แสดงอยู่ (วันของเดือนข้างเคียงมีคลาส text-gray-300) และเฉพาะปุ่มที่ยังกดได้
    ${Cell}=     Set Variable    ${Picker} >> xpath=.//button[not(@disabled)][not(contains(@class,'text-gray-300'))][.//span[normalize-space(text())='${Day}']]
    ${Count}=    Get Element Count    ${Cell}

    IF    ${Count} == 0
        ${Why}=    เหตุผลที่วันที่นี้เลือกไม่ได้    ${Picker}    ${Day}
        Run Keyword And Ignore Error
        ...    Take Screenshot    ${SCREENSHOT_DIR}/${USECASE}_${TC_ID}_ปฏิทิน${Display}    fullPage=True
        RETURN    ระบบปิดวันที่ ${Display} ไม่ให้เลือก (${Why})
    END

    Click    ${Cell} >> nth=0
    Sleep    0.3s

    # ช่องนี้เป็น controlled input ของ React ค่าจริงอยู่ที่ property ไม่ใช่ attribute
    ${Value}=      Get Property    ${Field}    value
    ${Matched}=    ค่าวันที่ตรงกับเป้าหมาย    ${Value}    ${Day}    ${MonthIndex}
    IF    not ${Matched}
        Log    กดวันที่ ${Display} แล้วช่องได้ค่า "${Value}" ซึ่งไม่ตรงกับที่ตั้งใจ    level=WARN
    END
    RETURN    ${Value}

เปิดปฏิทินให้ได้
    [Documentation]    ทำให้ปฏิทินของช่องนี้อยู่ในสถานะ "เปิด" คืน True เมื่อเปิดได้ (เปิดอยู่แล้วไม่กดซ้ำ เพราะกดซ้ำจะปิด)
    ...                ถ้าปฏิทินของอีกช่องเปิดค้างอยู่ ต้องปิดก่อนเพราะมันลอยทับช่องนี้
    [Arguments]    ${Field}    ${Picker}
    ${Today}=     Set Variable    ${Picker} >> xpath=.//button[normalize-space(text())='วันนี้']

    ${Opened}=    Is Element Visible    ${Today}
    IF    ${Opened}    RETURN    ${True}

    ${Other}=    Is Element Visible    ${Cal_AnyToday}
    IF    ${Other}
        Run Keyword And Ignore Error    Click    ${Text_BookAddress}
        Sleep    0.2s
    END

    Click    ${Field}
    ${Opened}=    Is Element Visible    ${Today}
    RETURN    ${Opened}

เหตุผลที่วันที่นี้เลือกไม่ได้
    [Documentation]    แยกสาเหตุว่าวันนั้นถูกปิดเพราะติดจองไว้แล้ว หรือเพราะยังไม่ถึงวันแรกที่ระบบยอมให้เช่า
    ...                หน้าเว็บใส่ title="วันที่นี้มีการจองแล้ว" ไว้เฉพาะวันที่ติดจอง จึงใช้แยกได้
    [Arguments]    ${Picker}    ${Day}
    ${Booked}=    Get Element Count
    ...    ${Picker} >> xpath=.//button[not(contains(@class,'text-gray-300'))][@title='วันที่นี้มีการจองแล้ว'][.//span[normalize-space(text())='${Day}']]
    ${Selectable}=    วันที่ที่ระบบเปิดให้เลือก    ${Picker}

    IF    ${Booked} > 0
        RETURN    วันนี้ติดจองไว้แล้ว | เดือนนี้เลือกได้เฉพาะวันที่ ${Selectable}
    END
    RETURN    เป็นวันในอดีต หรือยังไม่ถึงวันแรกที่ระบบยอมให้เช่า | เดือนนี้เลือกได้เฉพาะวันที่ ${Selectable}

วันที่ที่ระบบเปิดให้เลือก
    [Documentation]    อ่านเลขวันทั้งหมดที่ยังกดได้ในเดือนที่ปฏิทินแสดงอยู่ (นับเฉพาะวันของเดือนนั้น)
    [Arguments]    ${Picker}
    ${Ok}    ${Elements}=    Run Keyword And Ignore Error
    ...    Get Elements    ${Picker} >> xpath=.//button[not(@disabled)][not(contains(@class,'text-gray-300'))][.//span]
    IF    '${Ok}' == 'FAIL'    RETURN    อ่านรายชื่อวันที่ไม่ได้

    ${Texts}=    Create List
    FOR    ${El}    IN    @{Elements}
        ${Text}=    Get Text    ${El}
        Append To List    ${Texts}    ${Text}
    END
    ${Joined}=    Evaluate    ", ".join([t.strip() for t in $Texts if t.strip().isdigit()]) or "ไม่มีวันไหนกดได้เลย"
    RETURN    ${Joined}

ค่าวันที่ตรงกับเป้าหมาย
    [Documentation]    ตรวจว่าค่าที่ระบบใส่ลงช่อง (เช่น "6/11/2569") เป็นวันที่ที่ตั้งใจเลือกจริงไหม
    ...                รองรับทั้ง วัน/เดือน/ปี และ ปี-เดือน-วัน ทั้งปี พ.ศ. และ ค.ศ. และมี/ไม่มีศูนย์นำหน้า
    [Arguments]    ${Value}    ${Day}    ${MonthIndex}
    # แยกตัวเลขด้วยเมธอดของสตริง ไม่ใช้ regex เพราะ Robot Framework จะกินเครื่องหมาย \ ในอาร์กิวเมนต์ทิ้ง
    ${Parts}=    Evaluate    [int(g) for g in "".join(c if c.isdigit() else " " for c in str($Value)).split()]
    ${Count}=    Get Length    ${Parts}
    IF    ${Count} < 3    RETURN    ${False}

    ${Month}=    Evaluate    (${MonthIndex} - 1) % 12 + 1
    ${Year}=     Evaluate    (${MonthIndex} - ${Month}) // 12

    # ตัวเลขก้อนแรกมากกว่า 31 แปลว่าเขียนปีขึ้นก่อน
    ${GotDay}=      Evaluate    $Parts[2] if $Parts[0] > 31 else $Parts[0]
    ${GotMonth}=    Evaluate    $Parts[1]
    ${RawYear}=     Evaluate    $Parts[0] if $Parts[0] > 31 else $Parts[2]
    ${GotYear}=     เทียบปีให้เป็น ค.ศ.    ${RawYear}
    ${Matched}=     Evaluate    ${GotDay} == ${Day} and ${GotMonth} == ${Month} and ${GotYear} == ${Year}
    RETURN    ${Matched}

Input Booking Address
    [Documentation]    กรอกที่อยู่จัดส่ง กรอกทุกครั้งแม้เป็นค่าว่างเพื่อให้ระบบตรวจสอบช่องนี้
    [Arguments]    ${Address}
    Fill Text    ${Text_BookAddress}    ${Address}

Click Booking Button
    [Documentation]    กดปุ่ม "สั่งจอง" คืน True เมื่อกดได้ / False เมื่อปุ่มถูกปิดใช้งาน
    ${Clicked}=    Click Button If Enabled    ${Btn_Booking}
    IF    ${Clicked}    Sleep    0.5s
    RETURN    ${Clicked}

Is Terms Popup Shown
    [Documentation]    ตรวจว่า popup ข้อกำหนดการเช่าเด้งขึ้นมาแล้วหรือยัง ดูจากปุ่ม "ยอมรับ"
    ...                popup นี้เด้งเฉพาะตอนข้อมูลผ่านการตรวจสอบ จึงใช้เป็นตัวชี้วัดว่าฟอร์มถูกต้อง
    ${Shown}=    Is Element Visible    ${Btn_AcceptTerms}
    RETURN    ${Shown}

Accept Booking Terms
    [Documentation]    ติ๊กยอมรับข้อกำหนดแล้วกดปุ่ม "ยอมรับ" คืน True เมื่อกดปุ่มได้
    Check Checkbox    ${Check_Terms}
    ${Clicked}=    Click Button If Enabled    ${Btn_AcceptTerms}
    IF    ${Clicked}    Sleep    0.5s
    RETURN    ${Clicked}

#-------------------------------------------------------------------------
# Return Equipment Farmer : ไม่มีการกรอกฟอร์ม เป็นคีย์เวิร์ด "เปิดหน้า - กดปุ่ม - ยืนยัน - อ่าน popup" ล้วน ๆ
Open Return Equipment Page
    [Documentation]    เปิดหน้ารายการส่งคืนอุปกรณ์ ต้องเข้าสู่ระบบไว้ก่อนจึงจะเห็นรายการของตนเอง
    ...                ใช้ Go To แทนการเปิด context ใหม่ เพื่อไม่ให้เสียสถานะเข้าสู่ระบบที่เพิ่งทำไว้
    Go To                  ${Return_farmerURL}
    Wait For Load State    domcontentloaded    ${DEFAULT_TIMEOUT}
    # หน้านี้ดึงรายการจองมาแสดงหลังโหลดหน้าเสร็จ จึงรอสั้น ๆ ก่อนเริ่มนับปุ่ม
    Sleep    1s

Get Returnable Item Count
    [Documentation]    นับรายการที่อยู่ในสถานะพร้อมส่งคืน จากจำนวนปุ่ม "ส่งคืนอุปกรณ์" (หนึ่งรายการหนึ่งปุ่ม)
    ...                ต้องรอปุ่มใบแรกก่อน เพราะ Get Element Count ไม่รอ element จะได้ 0 ถ้าหน้ายังวาดไม่เสร็จ
    ${Found}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Btn_ReturnEQ} >> nth=0    visible    ${CARD_TIMEOUT}
    IF    not ${Found}    RETURN    ${0}

    ${Count}=    Get Element Count    ${Btn_ReturnEQ}
    RETURN    ${Count}

Click Return Equipment
    [Documentation]    กดปุ่ม "ส่งคืนอุปกรณ์" ของรายการแรก คืน True เมื่อกดได้
    ${Clicked}=    Click Button If Enabled    ${Btn_ReturnEQ} >> nth=0
    IF    ${Clicked}    Sleep    0.5s
    RETURN    ${Clicked}

Is Return Confirm Popup Shown
    [Documentation]    ตรวจว่า popup ยืนยันการส่งคืนเด้งขึ้นมาแล้วหรือยัง ดูจากปุ่ม "ยืนยัน"
    ...                popup นี้เด้งเฉพาะตอนรายการอยู่ในสถานะที่ส่งคืนได้ จึงใช้เป็นตัวชี้วัดว่าระบบยอมให้คืน
    ${Shown}=    Is Element Visible    ${Btn_ConfirmReturn}
    RETURN    ${Shown}

Confirm Return Equipment
    [Documentation]    กดปุ่ม "ยืนยัน" บน popup แล้วรอ popup ผลลัพธ์ คืนข้อความที่ระบบตอบกลับ
    ...                ต้องรอหัวข้อเปลี่ยนก่อน เพราะ popup ยืนยันกับ popup ผลลัพธ์ใช้ id เดียวกัน จะอ่านได้หัวข้อเดิม
    ${Before}=     Get Popup Title
    ${Clicked}=    Click Button If Enabled    ${Btn_ConfirmReturn}
    IF    not ${Clicked}    RETURN    ปุ่มยืนยันการส่งคืนถูกปิดใช้งาน ระบบไม่ให้ทำรายการ

    ${After}=    Wait For Popup Title Change    ${Before}
    RETURN    ${After}

Wait For Popup Title Change
    [Documentation]    รอจนหัวข้อบน popup เปลี่ยนไปจากค่าเดิม คืนหัวข้อใหม่
    ...                รอครบแล้วยังไม่เปลี่ยนคืนค่าเดิม ให้ผู้เรียกตัดสินเองว่าถือเป็นผลลัพธ์หรือข้อผิดพลาด
    [Arguments]    ${Previous}
    FOR    ${Round}    IN RANGE    20
        Sleep    0.3s
        ${Now}=    Get Popup Title
        IF    '${Now}' != '${Previous}'    RETURN    ${Now}
    END
    Log    รอครบ 20 รอบแล้วหัวข้อบน popup ยังเป็น "${Previous}" เหมือนเดิม    level=WARN
    RETURN    ${Previous}

Dismiss Popup
    [Documentation]    ปิด popup ด้วยปุ่ม Escape ใช้แทนการกดยกเลิก เพราะข้อความบนปุ่มยกเลิกต่างกันในแต่ละ popup
    Run Keyword And Ignore Error    Keyboard Key    press    Escape
    Sleep    0.5s

#-------------------------------------------------------------------------
# Register Owner : โครงเหมือนฝั่ง Farmer ต่างที่ selector จึงแยกคีย์เวิร์ดไว้คนละชุด
# ยกเว้นช่องวันเกิดที่ใช้ element ชุดเดียวกัน จึงเรียก "Input Birthdate" ร่วมกับฝั่ง Farmer
# page1
Open Register Owner Page
    New Context
    New Page                   ${Register_ownerURL}
    Set Viewport Size          ${VIEWPORT_WIDTH}    ${VIEWPORT_HEIGHT}
    Wait For Elements State    ${Text_ROUsername}    visible    ${DEFAULT_TIMEOUT}

Upload Owner Picture
    [Arguments]    ${Picture}
    IF    '${Picture}' != '${EMPTY}'
        Upload File By Selector    ${Img_Owner}    ${TestDataDir}/${Picture}
    END

Input Owner UsernameR
    [Arguments]    ${UsernameR}
    Fill Text    ${Text_ROUsername}    ${UsernameR}

Input Owner Email
    [Arguments]    ${Email}
    Fill Text    ${Text_ROEmail}    ${Email}

Input Owner PasswordR
    [Arguments]    ${PasswordR}
    Fill Text    ${Text_ROPassword}    ${PasswordR}

Input Owner Confirmpassword
    [Arguments]    ${Confirmpassword}
    Fill Text    ${Text_ROConfirmPassword}    ${Confirmpassword}

# page2
Is Register Owner Step2 Displayed
    [Documentation]    ตรวจว่าถึงขั้นตอนที่ 2 (ข้อมูลส่วนตัว) หรือยัง ดูจากช่อง "ชื่อจริง" ของฝั่ง Owner
    ${Displayed}=    Is Element Visible    ${Text_OName}
    RETURN    ${Displayed}

Input Owner Firstname
    [Arguments]    ${Firstname}
    Fill Text    ${Text_OName}    ${Firstname}

Input Owner Surname
    [Arguments]    ${Surname}
    Fill Text    ${Text_OLName}    ${Surname}

Select Owner Gender
    [Arguments]    ${Gender}
    IF    '${Gender}' == 'ชาย'
        Select Options By    ${Select_OGender}    value    male
    ELSE IF    '${Gender}' == 'หญิง'
        Select Options By    ${Select_OGender}    value    female
    ELSE
        # ไม่เลือกเพศ : ต้องเข้าช่องแล้วออกเอง ระบบจึงเตือน (select ไม่ถูกแตะอัตโนมัติเหมือน Fill Text)
        Focus    ${Select_OGender}
        Focus    ${Text_OPhone}
    END

Input Owner Tel
    [Arguments]    ${Tel}
    Fill Text    ${Text_OPhone}    ${Tel}

Input Owner Hnum
    [Arguments]    ${Hnum}
    Fill Text    ${Text_ONum}    ${Hnum}

Input Owner Alley
    [Arguments]    ${Alley}
    Fill Text    ${Text_OAlley}    ${Alley}

Input Owner Group
    [Arguments]    ${Group}
    Fill Text    ${Text_OMoo}    ${Group}

Input Owner District
    [Arguments]    ${District}
    Fill Text    ${Text_OSubdistric}    ${District}

Input Owner Canton
    [Arguments]    ${Canton}
    Fill Text    ${Text_ODistric}    ${Canton}

Input Owner Province
    [Arguments]    ${province}
    Fill Text    ${Text_OProvince}    ${province}

Input Owner Postcode
    [Arguments]    ${Postcode}
    Fill Text    ${Text_OPostcode}    ${Postcode}

#-------------------------------------------------------------------------
# Login Owner
Open Login Owner Page
    [Documentation]    เปิด context และหน้าเข้าสู่ระบบของเจ้าของอุปกรณ์ใหม่ (ต้องเรียก Open Test Browser ก่อน)
    New Context
    New Page                   ${Login_ownerURL}
    Set Viewport Size          ${VIEWPORT_WIDTH}    ${VIEWPORT_HEIGHT}
    Wait For Elements State    ${Text_OUsername}    visible    ${DEFAULT_TIMEOUT}

Input Owner Username
    [Arguments]    ${Username}
    Fill Text    ${Text_OUsername}    ${Username}

Input Owner Password
    [Arguments]    ${Password}
    Fill Text    ${Text_OPassword}    ${Password}

Click Owner Login Button
    [Documentation]    กดปุ่ม "เข้าสู่ระบบ" คืน True เมื่อกดได้ / False เมื่อปุ่มถูกปิดใช้งาน
    ${Clicked}=    Click Button If Enabled    ${Btn_OLogin}
    RETURN    ${Clicked}

#-------------------------------------------------------------------------
# Add Equipment Owner : ฟอร์มเปิดจากปุ่มบนหน้ารายการอุปกรณ์ ไม่ได้เข้าจาก URL ตรง ๆ
Open Add Equipment Page
    [Documentation]    เปิดหน้ารายการอุปกรณ์ เลือกประเภทอุปกรณ์ แล้วกดปุ่ม "เพิ่มอุปกรณ์" ให้ฟอร์มแสดงขึ้นมา
    ...                ปุ่มถูกปิดใช้งานจนกว่าจะเลือกประเภทก่อน ${EquipmentType} ต้องตรงกับข้อมูลที่จะกรอกในฟอร์ม
    [Arguments]    ${EquipmentType}=${EMPTY}
    Go To                      ${AddEQ_ownerURL}
    Wait For Load State        domcontentloaded    ${DEFAULT_TIMEOUT}

    Select Add Equipment Type    ${EquipmentType}
    ${Enabled}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Btn_AddEQ}    enabled    ${DEFAULT_TIMEOUT}
    Should Be True    ${Enabled}
    ...    msg=ปุ่ม "เพิ่มอุปกรณ์" ยังถูกปิดใช้งานหลังเลือกประเภท "${EquipmentType}" จึงเปิดฟอร์มไม่ได้

    Click                      ${Btn_AddEQ}
    Wait For Elements State    ${Text_EQName}      visible    ${DEFAULT_TIMEOUT}

Is Equipment Form Displayed
    [Documentation]    ตรวจว่าฟอร์มเพิ่มอุปกรณ์ยังเปิดอยู่ไหม ดูจากช่อง "ชื่ออุปกรณ์"
    ...                ฟอร์มปิดลงหลังบันทึกสำเร็จ จึงใช้เป็นตัวชี้วัดว่าระบบรับข้อมูลแล้ว
    ${Displayed}=    Is Element Visible    ${Text_EQName}
    RETURN    ${Displayed}

Get Native Validation Messages
    [Documentation]    อ่านข้อความตรวจสอบของเบราว์เซอร์จากทุกช่องในฟอร์มเพิ่มอุปกรณ์ คืนเป็นลิสต์
    ...                ฟอร์มใช้ HTML required เบราว์เซอร์กันไว้ด้วย bubble เอง (ไม่ใช่ element ใน DOM) จึงอ่านจาก property validationMessage แทน
    ...                ฟอร์มปิดไปแล้วคืนลิสต์ว่างทันที และลด timeout ระหว่างอ่านเพื่อไม่ให้เสียเวลารอ
    ${Messages}=    Create List
    ${FormOpen}=    Is Equipment Form Displayed
    IF    not ${FormOpen}    RETURN    ${Messages}

    Set Browser Timeout    ${SHORT_TIMEOUT}
    FOR    ${Selector}    IN
    ...    ${Text_EQName}       ${Text_EQDetail}      ${Text_EQPrice}    ${Select_EQStatus}
    ...    ${Text_EQFeature}    ${Text_EQAddress}     ${Img_EQ}
        ${Ok}    ${Msg}=    Run Keyword And Ignore Error
        ...    Get Property    ${Selector}    validationMessage
        IF    '${Ok}' == 'FAIL'    CONTINUE
        ${Len}=    Get Length    ${Msg}
        IF    ${Len} > 0    Append To List    ${Messages}    ${Msg}
    END
    Set Browser Timeout    ${DEFAULT_TIMEOUT}
    RETURN    ${Messages}

Select Add Equipment Type
    [Documentation]    เลือกประเภทอุปกรณ์จาก dropdown บน "หน้ารายการอุปกรณ์" ของเจ้าของ (คนละตัวกับ dropdown หน้าค้นหาฝั่ง Farmer)
    ...                ค่าว่างหมายถึงเลือกตัวเลือกเริ่มต้น "${EQTYPE_NONE}" (ปุ่ม "เพิ่มอุปกรณ์" จะยังถูกปิดใช้งานอยู่)
    [Arguments]    ${EquipmentType}

    ${Ok}    ${Options}=    Run Keyword And Ignore Error    Get Select Options    ${Select_AddEQType}
    IF    '${Ok}' == 'FAIL'
        Log    ไม่พบ dropdown ประเภทอุปกรณ์ด้วย locator ${Select_AddEQType} จึงข้ามการเลือกประเภท    level=WARN
        RETURN
    END

    # ค่าว่างแปลว่าไม่เลือกประเภท คือเลือกตัวเลือก "${EQTYPE_NONE}" (ค่าเริ่มต้นของ dropdown)
    # เลือกให้ชัดเจนแทนการปล่อยผ่าน เพื่อล้างประเภทที่อาจค้างจากกรณีทดสอบก่อนหน้า
    IF    '${EquipmentType}' == '${EMPTY}'
        Run Keyword And Ignore Error
        ...    Select Options By    ${Select_AddEQType}    label    ${EQTYPE_NONE}
        RETURN
    END

    ${Labels}=    Evaluate    [str(o.get("label", "")).strip() for o in $Options]
    # lambda รับค่าผ่าน default argument เพราะ RF มองไม่เห็น $ตัวแปร ในเงื่อนไขของ comprehension
    ${Matched}=    Evaluate    next(filter(lambda l, s=$EquipmentType: l == s, $Labels), "")
    IF    '${Matched}' == '${EMPTY}'
        Log    ไม่มีประเภท "${EquipmentType}" ใน dropdown (มี ${Labels}) จึงไม่เลือกประเภท    level=WARN
        RETURN
    END
    Select Options By    ${Select_AddEQType}    label    ${Matched}

Input Equipment Name
    [Arguments]    ${EquipmentName}
    Fill Text    ${Text_EQName}    ${EquipmentName}

Input Equipment Detail
    [Arguments]    ${EquipmentDetail}
    Fill Text    ${Text_EQDetail}    ${EquipmentDetail}

Input Equipment Price
    [Arguments]    ${Price}
    Fill Text    ${Text_EQPrice}    ${Price}

Select Equipment Status
    [Documentation]    เลือกสถานะจากข้อความที่ผู้ใช้เห็นบนหน้าจอ (พร้อมให้เช่า / ไม่พร้อมให้เช่า / ถูกจอง)
    ...                ค่าว่างหมายถึงไม่เลือกสถานะ ต้องเข้าช่องแล้วออกเอง ระบบจึงจะเตือน
    [Arguments]    ${Status}
    IF    '${Status}' == '${EMPTY}'
        Focus    ${Select_EQStatus}
        Focus    ${Text_EQFeature}
        RETURN
    END

    ${Ok}    ${Options}=    Run Keyword And Ignore Error    Get Select Options    ${Select_EQStatus}
    IF    '${Ok}' == 'FAIL'
        Log    ไม่พบ dropdown สถานะอุปกรณ์ จึงข้ามการเลือกสถานะ    level=WARN
        RETURN
    END

    ${Labels}=    Evaluate    [str(o.get("label", "")).strip() for o in $Options]
    # lambda รับค่าผ่าน default argument เพราะ RF มองไม่เห็น $ตัวแปร ในเงื่อนไขของ comprehension
    ${Matched}=    Evaluate    next(filter(lambda l, s=$Status: l == s, $Labels), "")
    IF    '${Matched}' == '${EMPTY}'
        Log    ไม่มีสถานะ "${Status}" ใน dropdown (มี ${Labels}) จึงไม่เลือกสถานะ    level=WARN
        RETURN
    END
    Select Options By    ${Select_EQStatus}    label    ${Matched}

Input Equipment Feature
    [Arguments]    ${EquipmentFeature}
    Fill Text    ${Text_EQFeature}    ${EquipmentFeature}

Input Equipment Address
    [Arguments]    ${EquipmentAddress}
    Fill Text    ${Text_EQAddress}    ${EquipmentAddress}

Upload Equipment Picture
    [Arguments]    ${Picture}
    IF    '${Picture}' != '${EMPTY}'
        Upload File By Selector    ${Img_EQ}    ${TestDataDir}/${Picture}
    END

Click Save Equipment Button
    [Documentation]    กดปุ่ม "บันทึก" คืน True เมื่อกดได้ / False เมื่อปุ่มถูกปิดใช้งาน
    ${Clicked}=    Click Button If Enabled    ${Btn_SaveEQ}
    RETURN    ${Clicked}

Click Cancel Equipment Button
    [Documentation]    กดปุ่ม "ยกเลิก" เพื่อปิดฟอร์ม ข้ามไปเลยถ้าฟอร์มปิดไปแล้ว
    ...                (เดิมกดตรง ๆ แล้วรอ 30 วินาทีทุกครั้งที่ฟอร์มปิดไปแล้วหลังบันทึกสำเร็จ)
    ${HasButton}=    Is Element Visible    ${Btn_CancelEQ}
    IF    ${HasButton}    Run Keyword And Ignore Error    Click    ${Btn_CancelEQ}

#-------------------------------------------------------------------------
# Approve Booking Owner : หน้ารายการจองของเจ้าของอุปกรณ์
# กลไกของหน้าคือ "เลือกแท็บสถานะ - กดปุ่มอัปเดตหรือยกเลิก - ยืนยันในกล่องโต้ตอบ - อ่านผล - กดตกลง"
Open Owner Booking Page
    [Documentation]    เปิดหน้ารายการจองที่เข้ามา ต้องเข้าสู่ระบบเป็น Owner ไว้ก่อน
    ...                ใช้ Go To ไม่ใช่ New Context เพื่อไม่ให้เสียสถานะเข้าสู่ระบบ
    Go To                  ${ApproveBooking_ownerURL}
    Wait For Load State    domcontentloaded    ${DEFAULT_TIMEOUT}
    # หน้านี้ดึงรายการจองมาแสดงหลังโหลดหน้าเสร็จ จึงรอสั้น ๆ ก่อนเริ่มนับรายการ
    Sleep    1s

Select Booking Tab
    [Documentation]    กดแท็บกรองตามสถานะ คืน True เมื่อกดได้
    ...                ไม่พบแท็บไม่ถือว่าล้ม เพราะบางหน้าจออาจไม่มีแท็บนั้นเมื่อไม่มีรายการในสถานะนั้น
    [Arguments]    ${Tab}
    ${Found}=    Is Element Visible    ${Tab}
    IF    not ${Found}
        Log    ไม่พบแท็บ ${Tab} บนหน้ารายการจอง    level=WARN
        RETURN    ${False}
    END
    Click    ${Tab}
    Sleep    1s
    RETURN    ${True}

Get Updatable Booking Count
    [Documentation]    นับรายการที่ยังอัปเดตสถานะได้ จากจำนวนปุ่ม "อัปเดตเป็น ..." (หนึ่งรายการหนึ่งปุ่ม)
    ...                ต้องรอปุ่มใบแรกก่อน เพราะ Get Element Count ไม่รอ element จะได้ 0 ถ้าหน้ายังวาดไม่เสร็จ
    ${Found}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Btn_UpdateBookingStatus} >> nth=0    visible    ${CARD_TIMEOUT}
    IF    not ${Found}    RETURN    ${0}

    ${Count}=    Get Element Count    ${Btn_UpdateBookingStatus}
    RETURN    ${Count}

Get Next Status Label
    [Documentation]    อ่านข้อความบนปุ่มอัปเดตของรายการแรก เช่น อัปเดตเป็น "รอการชำระเงิน"
    ...                ใช้บันทึกลงรายงานว่าระบบกำลังจะเลื่อนไปสถานะใด
    ${Found}=    Is Element Visible    ${Btn_UpdateBookingStatus} >> nth=0
    IF    not ${Found}    RETURN    ${EMPTY}
    ${Text}=    Get Text        ${Btn_UpdateBookingStatus} >> nth=0
    ${Text}=    Strip String    ${Text}
    ${Text}=    Evaluate    " ".join($Text.split())
    RETURN    ${Text}

Click Update Booking Status
    [Documentation]    กดปุ่มอัปเดตสถานะของรายการแรก คืน True เมื่อกดได้
    ${Clicked}=    Click Button If Enabled    ${Btn_UpdateBookingStatus} >> nth=0
    IF    ${Clicked}    Sleep    0.5s
    RETURN    ${Clicked}

Click Cancel Booking
    [Documentation]    กดปุ่ม "ยกเลิกการจอง" ของรายการแรก คืน True เมื่อกดได้
    ${Clicked}=    Click Button If Enabled    ${Btn_CancelBooking} >> nth=0
    IF    ${Clicked}    Sleep    0.5s
    RETURN    ${Clicked}

Is Booking Dialog Shown
    [Documentation]    ตรวจว่ากล่องโต้ตอบเด้งขึ้นมาแล้วหรือยัง ดูจากเนื้อความในกล่อง
    ${Shown}=    Is Element Visible    ${Popup_DialogText}
    RETURN    ${Shown}

Get Booking Dialog Text
    [Documentation]    อ่านเนื้อความบนกล่องโต้ตอบ ใช้เป็น ActualResult
    ...                กล่องยืนยันกับกล่องผลลัพธ์ใช้ id เดียวกัน จึงต้องอ่านหลังกดยืนยันแล้วเท่านั้น
    ${Found}=    Is Element Visible    ${Popup_DialogText}
    IF    not ${Found}    RETURN    ${EMPTY}
    ${Text}=    Get Text        ${Popup_DialogText}
    ${Text}=    Strip String    ${Text}
    ${Text}=    Evaluate    " ".join($Text.split())
    RETURN    ${Text}

Confirm Booking Update
    [Documentation]    กดปุ่ม "ยืนยัน" ในกล่องโต้ตอบ แล้วรอเนื้อความเปลี่ยนเป็นผลลัพธ์ คืนข้อความที่อ่านได้
    ${Before}=    Get Booking Dialog Text
    ${Clicked}=    Click Button If Enabled    ${Btn_ConfirmUpdate}
    IF    not ${Clicked}    RETURN    ปุ่มยืนยันถูกปิดใช้งาน ระบบไม่ให้ทำรายการ

    ${After}=    Wait For Booking Dialog Change    ${Before}
    RETURN    ${After}

Confirm Booking Cancellation
    [Documentation]    กดปุ่ม "ยืนยันยกเลิก" ในกล่องโต้ตอบ แล้วรอเนื้อความเปลี่ยนเป็นผลลัพธ์
    ${Before}=    Get Booking Dialog Text
    ${Clicked}=    Click Button If Enabled    ${Btn_ConfirmCancelBooking}
    IF    not ${Clicked}    RETURN    ปุ่มยืนยันยกเลิกถูกปิดใช้งาน ระบบไม่ให้ทำรายการ

    ${After}=    Wait For Booking Dialog Change    ${Before}
    RETURN    ${After}

Wait For Booking Dialog Change
    [Documentation]    รอจนเนื้อความในกล่องโต้ตอบเปลี่ยนไปจากค่าเดิม คืนเนื้อความใหม่
    ...                รอครบแล้วยังไม่เปลี่ยนคืนค่าเดิม ให้ผู้เรียกตัดสินเองว่าถือเป็นผลลัพธ์หรือข้อผิดพลาด
    [Arguments]    ${Previous}
    FOR    ${Round}    IN RANGE    20
        Sleep    0.3s
        ${Now}=    Get Booking Dialog Text
        IF    '${Now}' != '${Previous}'    RETURN    ${Now}
    END
    Log    รอครบ 20 รอบแล้วเนื้อความในกล่องโต้ตอบยังเป็น "${Previous}" เหมือนเดิม    level=WARN
    RETURN    ${Previous}

Dismiss Booking Dialog
    [Documentation]    ปิดกล่องโต้ตอบด้วยปุ่มยกเลิกของกล่อง ใช้เมื่อไม่ต้องการทำรายการต่อ
    Run Keyword And Ignore Error    Click Button If Enabled    ${Btn_DismissDialog}
    Sleep    0.3s

Acknowledge Booking Dialog
    [Documentation]    กดปุ่ม "ตกลง" ปิดกล่องผลลัพธ์ ให้กรณีถัดไปเริ่มจากหน้าที่ไม่มีกล่องค้าง
    Run Keyword And Ignore Error    Click Button If Enabled    ${Btn_AcknowledgeDialog}
    Sleep    0.3s

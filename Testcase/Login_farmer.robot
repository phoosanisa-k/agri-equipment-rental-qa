*** Settings ***
Documentation     TC01 - Login Farmer | รวมการทดสอบยูสเคส "เข้าสู่ระบบ" ของเกษตรกรไว้ในไฟล์เดียว
...
...               ส่วนที่ 1 (TC01_01 - TC01_27) : ตรวจข้อความแจ้งเตือนรายฟิลด์ โดยยังไม่กดปุ่ม "เข้าสู่ระบบ"
...               ส่วนที่ 2 (TC01_F01 - TC01_F06) : ทดสอบการเข้าสู่ระบบจริง โดยกดปุ่ม "เข้าสู่ระบบ"
...
...               เลือกกรณีที่รันจากคอลัมน์ ${Run} (Yes/No) ใน Data.xlsx และเขียนผลกลับลง ActualResult / Result
Metadata          System      ระบบเว็บศูนย์กลางให้บริการเช่าอุปกรณ์ทางการเกษตร (SRS v7.0)
Metadata          Use Case    TC01 Login Farmer
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
# ---------- ที่อยู่ของไฟล์และโฟลเดอร์ ----------
${DATA_FILE}          ${CURDIR}/../TestData/Data.xlsx
${SHEET}              Login_Farmer
${ERROR_DIR}          ${CURDIR}/../Error IMG
${EVIDENCE_DIR}       ${CURDIR}/../Flow IMG
${USECASE}            TC01_Login_Farmer

# ---------- ตำแหน่งคอลัมน์ในชีต ----------
${COL_ID}             ${2}     # คอลัมน์ B : ${TestCase}
${COL_ACTUAL}         ${7}     # คอลัมน์ G : ${ActualResult}
${COL_PF}             ${8}     # คอลัมน์ H : ${Result}

# ---------- ข้อความและตัวชี้วัดที่ใช้ตัดสินผล ----------
# ใช้แทนกรณี "ไม่มีข้อความแจ้งเตือน" ตามที่เอกสาร Test Case ระบุ
${PASS_MESSAGE}       ผ่านการตรวจสอบ
${SUCCESS_KEYWORD}    สำเร็จ
${Popup_Success}      text=${SUCCESS_KEYWORD}
# ส่วนของ URL ที่บอกว่ายังอยู่หน้าเข้าสู่ระบบ
${LOGIN_URL_PART}     login-farmer
# รอสั้น ๆ เพราะกรณีที่ต้องไม่สำเร็จจะไม่มี popup ขึ้นเลย
${POPUP_TIMEOUT}      5s

# ---------- บัญชีชั่วคราวสำหรับกรณีที่ทำให้บัญชีเสียหาย ----------
# Username = AUTO ในไฟล์ทดสอบ หมายถึงให้สมัครบัญชีใหม่ก่อนเริ่มกรณีนั้น
${AUTO_ACCOUNT}       AUTO
${REG_PASSWORD}       PK01010101
${REG_PICTURE}        farmer.jpg
# รหัสผ่านผิด 3 ชุดตามเอกสาร (LF01-02 ถึง LF01-07) กรอกเรียงกันจนระบบล็อกบัญชี
@{WRONG_PASSWORDS}    wrong123    wrong456    wrong789

# ---------- รายการอนุโลม : ข้อความต่างสำนวนจากเอกสาร แต่สื่อกฎเดียวกัน ----------
# ผู้ทดสอบพิจารณาแล้วว่ายอมรับได้ กรณีที่ไม่อยู่ในรายการนี้ต้องตรงกับเอกสารเท่านั้น
# ทุกครั้งที่ใช้ข้อยกเว้นจะมีบรรทัด WARN ใน log.html ให้ตรวจย้อนหลังได้
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
# =====================================================================
# 1. การเตรียมและปิดชุดทดสอบ
# =====================================================================

เปิดชุดทดสอบ
    [Documentation]    ล้างภาพของรอบก่อน เปิดไฟล์ Excel สำหรับเขียนผล และเปิดเบราว์เซอร์
    Create Directory    ${ERROR_DIR}
    Create Directory    ${EVIDENCE_DIR}
    ลบภาพของรอบก่อน    ${ERROR_DIR}
    ลบภาพของรอบก่อน    ${EVIDENCE_DIR}

    Open Excel Document    ${DATA_FILE}    Login
    Open Login Browser

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
    Close All Login Browsers

เก็บผลท้ายกรณีทดสอบ
    [Documentation]    เก็บภาพเมื่อไม่ผ่าน เขียนผลกลับลง Excel แล้วปิด context
    ...                กรณีที่ถูกข้าม (${ROW_NUM} = 0) จะไม่เขียนทับผลเดิม
    ${Actual}=    Set Variable    ${ACTUAL_MESSAGE}

    IF    '${TEST STATUS}' == 'FAIL'
        Run Keyword And Ignore Error
        ...    Take Screenshot    ${ERROR_DIR}/${USECASE}_${TC_ID}    fullPage=True

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
    Run Keyword And Ignore Error    Close Login Context


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
    [Documentation]    แยกทางตามรหัสกรณีทดสอบ
    ...                TC01_NN  -> ตรวจข้อความแจ้งเตือนรายฟิลด์ (ไม่กดปุ่ม)
    ...                TC01_FNN -> ทดสอบการเข้าสู่ระบบจริง (กดปุ่ม) โดยเรียกคีย์เวิร์ด "กรณี <รหัส>"
    [Arguments]    ${Run}          ${TestCase}    ${TestScenario}
    ...            ${Username}     ${Password}    ${ExpectedResult}

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
    Log    ${TestCase} : ${TestScenario}    level=INFO

    ${IsLoginAction}=    Evaluate    "_F" in "${TestCase}"
    IF    ${IsLoginAction}
        Run Keyword    กรณี ${TestCase}    ${Username}    ${Password}    ${ExpectedResult}
    ELSE
        ตรวจข้อความแจ้งเตือนรายฟิลด์    ${Username}    ${Password}    ${ExpectedResult}
    END


# =====================================================================
# 4. ส่วนที่ 1 : ตรวจข้อความแจ้งเตือนรายฟิลด์ (TC01_01 - TC01_27)
# =====================================================================

ตรวจข้อความแจ้งเตือนรายฟิลด์
    [Documentation]    กรอกชื่อผู้ใช้และรหัสผ่าน แล้วอ่านข้อความที่ระบบแจ้งทันที
    ...                ยังไม่กดปุ่ม "เข้าสู่ระบบ" เพราะกรณีเหล่านี้ตรวจการตรวจสอบข้อมูลรายฟิลด์
    [Arguments]    ${Username}    ${Password}    ${ExpectedResult}

    Open Login Page
    Input Username    ${Username}
    Input Password    ${Password}
    # ช่องสุดท้ายไม่มีช่องถัดไปให้ blur เอง จึงต้องกด Tab ออกจากช่อง ระบบจึงจะตรวจสอบ
    Keyboard Key    press    Tab

    ${Messages}=        Get Validation Messages
    # บันทึกข้อความจริงที่ระบบแจ้งเสมอ ไม่ทับด้วยข้อความจากเอกสาร จะได้เห็นของจริงตอนทำรายงาน
    ${ActualResult}=    รวมข้อความ    ${Messages}    ${PASS_MESSAGE}
    ${Matched}=         ผลตรงกับที่เอกสารกำหนด    ${Messages}    ${ExpectedResult}

    บันทึกผลที่ได้จริง    ${ActualResult}
    Should Be True    ${Matched}
    ...    msg=${TC_ID} : ระบบแจ้งว่า "${ActualResult}" แต่เอกสารกำหนดไว้ว่า "${ExpectedResult}"

ผลตรงกับที่เอกสารกำหนด
    [Documentation]    ตัดสินว่าผลที่ระบบแสดงตรงกับที่เอกสารกำหนดหรือไม่ โดยไล่เทียบ 3 ชั้น
    ...                1) ไม่มีข้อความแจ้งเตือน = "ผ่านการตรวจสอบ"
    ...                2) มีข้อความที่ตรงกับ ExpectedResult
    ...                3) มีข้อความที่ตรงกับรายการอนุโลมของกรณีนั้น (ต่างสำนวนแต่กฎเดียวกัน)
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
            Log    ${TC_ID} : ระบบใช้สำนวนต่างจากเอกสาร แต่สื่อกฎเดียวกัน จึงถือว่าผ่านตามรายการอนุโลม    level=WARN
            RETURN    ${True}
        END
    END
    RETURN    ${False}

ข้อความตรงกับที่คาดหวัง
    [Documentation]    เทียบข้อความหลังปรับรูปมาตรฐานแล้ว : ตรงกันทั้งประโยค หรือเป็นส่วนหนึ่งของกัน
    [Arguments]    ${Message}    ${ExpectedResult}
    ${Actual}=      ปรับข้อความเป็นรูปมาตรฐาน    ${Message}
    ${Expected}=    ปรับข้อความเป็นรูปมาตรฐาน    ${ExpectedResult}
    ${Matched}=     Evaluate    $Actual == $Expected or $Expected in $Actual or $Actual in $Expected
    RETURN    ${Matched}

ปรับข้อความเป็นรูปมาตรฐาน
    [Documentation]    รวมขีดกลางทุกแบบให้เป็นตัวเดียว ตัดช่องว่างทั้งหมด และไม่แยกตัวพิมพ์ใหญ่เล็ก
    [Arguments]    ${Text}
    ${Text}=    Evaluate    unicodedata.normalize("NFC", str($Text))    modules=unicodedata
    ${Text}=    Evaluate    "".join("-" if 0x2010 <= ord(c) <= 0x2015 or ord(c) == 0x2212 else c for c in $Text)
    ${Text}=    Evaluate    "".join($Text.split()).lower()
    RETURN    ${Text}


# =====================================================================
# 5. ส่วนที่ 2 : ทดสอบการเข้าสู่ระบบจริง (TC01_F01 - TC01_F06)
# =====================================================================

กรณี TC01_F01
    [Documentation]    เข้าสู่ระบบด้วยบัญชีที่ถูกต้อง
    ...                ต้องมีข้อความแจ้งสำเร็จ และต้องออกจากหน้าเข้าสู่ระบบจริง
    [Arguments]    ${Username}    ${Password}    ${ExpectedResult}

    ${Message}=    เข้าสู่ระบบ    ${Username}    ${Password}
    ${Left}=       รอให้ออกจากหน้าเข้าสู่ระบบ
    ${Url}=        Get Url

    บันทึกผลที่ได้จริง    ${Message} (หน้าปัจจุบัน ${Url})
    เก็บภาพหลักฐาน       เข้าสู่ระบบสำเร็จ

    Should Contain    ${Message}    ${SUCCESS_KEYWORD}
    ...    msg=เข้าสู่ระบบไม่สำเร็จ ระบบตอบกลับว่า "${Message}"
    Should Be True    ${Left}
    ...    msg=ระบบแจ้งว่าสำเร็จ แต่ยังคงอยู่ที่หน้าเข้าสู่ระบบ (${Url})

กรณี TC01_F02
    [Documentation]    เข้าสู่ระบบด้วยรหัสผ่านที่ไม่ถูกต้อง
    ...                ใช้บัญชีที่สมัครใหม่ กันไม่ให้บัญชีหลักสะสมจำนวนครั้งที่กรอกผิดจนถูกล็อก
    [Arguments]    ${Username}    ${Password}    ${ExpectedResult}

    ${Account}=    เตรียมชื่อผู้ใช้    ${Username}    ${REG_PASSWORD}
    ${Message}=    เข้าสู่ระบบ        ${Account}     ${Password}

    บันทึกผลที่ได้จริง    ${Message}
    เก็บภาพหลักฐาน       รหัสผ่านไม่ถูกต้อง

    ต้องเข้าสู่ระบบไม่สำเร็จ    ${Message}
    ข้อความต้องตรงกับที่คาดหวัง    ${Message}    ${ExpectedResult}

กรณี TC01_F03
    [Documentation]    เข้าสู่ระบบด้วยชื่อผู้ใช้ที่ไม่มีในระบบ
    ...                ระบบต้องปฏิเสธ และต้องไม่พาออกจากหน้าเข้าสู่ระบบ
    [Arguments]    ${Username}    ${Password}    ${ExpectedResult}

    ${Message}=    เข้าสู่ระบบ    ${Username}    ${Password}

    บันทึกผลที่ได้จริง    ${Message}
    เก็บภาพหลักฐาน       ไม่มีชื่อผู้ใช้นี้

    ต้องเข้าสู่ระบบไม่สำเร็จ    ${Message}
    ข้อความต้องตรงกับที่คาดหวัง    ${Message}    ${ExpectedResult}

กรณี TC01_F04
    [Documentation]    ไม่กรอกข้อมูลแล้วกดปุ่ม "เข้าสู่ระบบ"
    ...                ระบบต้องกันไว้ ไม่ว่าจะด้วยการแจ้งเตือนหรือปิดปุ่มไว้ ถือว่าป้องกันได้ทั้งสองทาง
    [Arguments]    ${Username}    ${Password}    ${ExpectedResult}

    Open Login Page
    Input Username    ${Username}
    Input Password    ${Password}
    Keyboard Key      press    Tab

    ${Clicked}=     Click Button If Enabled    ${Btn_Login}
    ${Messages}=    Get Validation Messages
    ${Count}=       Get Length    ${Messages}
    ${Summary}=     รวมข้อความ    ${Messages}    ปุ่มเข้าสู่ระบบถูกปิดใช้งาน ระบบไม่ให้เข้าสู่ระบบ
    ${Left}=        รอให้ออกจากหน้าเข้าสู่ระบบ

    บันทึกผลที่ได้จริง    ${Summary}
    เก็บภาพหลักฐาน       ไม่กรอกข้อมูล

    Should Not Be True    ${Left}
    ...    msg=ระบบยอมให้เข้าสู่ระบบทั้งที่ไม่ได้กรอกข้อมูล
    ${Prevented}=    Evaluate    (not ${Clicked}) or ${Count} > 0
    Should Be True    ${Prevented}
    ...    msg=ระบบไม่ได้แจ้งเตือนและไม่ได้ปิดปุ่มไว้เมื่อไม่กรอกข้อมูล

กรณี TC01_F05
    [Documentation]    ออกจากระบบแล้วต้องกลับมาหน้าเข้าสู่ระบบ
    ...                ถ้าไม่พบปุ่มออกจากระบบ จะบันทึกรายชื่อปุ่มบนหน้าไว้ใน log.html เพื่อใช้แก้ locator
    [Arguments]    ${Username}    ${Password}    ${ExpectedResult}

    ${Message}=    เข้าสู่ระบบ    ${Username}    ${Password}
    ${Left}=       รอให้ออกจากหน้าเข้าสู่ระบบ
    Should Be True    ${Left}
    ...    msg=เข้าสู่ระบบไม่สำเร็จ จึงยังทดสอบการออกจากระบบไม่ได้ (${Message})

    ${Found}=    Is Element Visible    ${Btn_Logout}
    IF    not ${Found}
        บันทึกรายชื่อปุ่มบนหน้า
        เก็บภาพหลักฐาน       ไม่พบปุ่มออกจากระบบ
        บันทึกผลที่ได้จริง    ไม่พบปุ่มออกจากระบบบนหน้าหลัก (ดูรายชื่อปุ่มใน log.html)
        Fail    ไม่พบปุ่มออกจากระบบด้วย locator ${Btn_Logout}
    END

    Click    ${Btn_Logout}
    ${BackToLogin}=    รอให้กลับมาหน้าเข้าสู่ระบบ
    ${Url}=            Get Url

    บันทึกผลที่ได้จริง    ออกจากระบบแล้วไปที่หน้า ${Url}
    เก็บภาพหลักฐาน       ออกจากระบบ

    Should Be True    ${BackToLogin}
    ...    msg=กดออกจากระบบแล้วไม่ได้กลับมาหน้าเข้าสู่ระบบ (อยู่ที่ ${Url})

กรณี TC01_F06
    [Documentation]    กรอกรหัสผ่านผิด 3 ครั้งติดกัน ระบบต้องระงับบัญชี (LF01-01 ถึง LF01-09)
    ...                ใช้บัญชีที่สมัครใหม่ เพราะบัญชีที่ถูกล็อกแล้วใช้ซ้ำในรอบถัดไปไม่ได้
    [Arguments]    ${Username}    ${Password}    ${ExpectedResult}

    ${Account}=    เตรียมชื่อผู้ใช้    ${Username}    ${Password}
    ${Records}=    Create List

    # ---------- LF01-02 ถึง LF01-07 : กรอกรหัสผ่านผิด 3 ครั้ง ----------
    FOR    ${Index}    ${Wrong}    IN ENUMERATE    @{WRONG_PASSWORDS}    start=1
        ${Message}=    เข้าสู่ระบบ    ${Account}    ${Wrong}
        Append To List    ${Records}    ครั้งที่ ${Index} (${Wrong}) : ${Message}
        เก็บภาพหลักฐาน    ผิดครั้งที่ ${Index}
        ต้องเข้าสู่ระบบไม่สำเร็จ    ${Message}
    END

    # ---------- LF01-08 ถึง LF01-09 : รหัสผ่านถูกต้อง แต่บัญชีถูกระงับไปแล้ว ----------
    ${Final}=    เข้าสู่ระบบ    ${Account}    ${Password}
    Append To List    ${Records}    รหัสผ่านถูกต้องหลังถูกล็อก : ${Final}
    เก็บภาพหลักฐาน    บัญชีถูกระงับ

    ${Summary}=    Evaluate    " | ".join($Records)
    บันทึกผลที่ได้จริง    ${Summary}

    ต้องเข้าสู่ระบบไม่สำเร็จ    ${Final}
    ข้อความต้องกล่าวถึง        ${Final}    ระงับ    ล็อก    ล็อค    lock    suspend


# =====================================================================
# 6. ขั้นตอนย่อยของการเข้าสู่ระบบ
# =====================================================================

เข้าสู่ระบบ
    [Documentation]    เปิดหน้าเข้าสู่ระบบใหม่ กรอกข้อมูล แล้วกดปุ่ม "เข้าสู่ระบบ" คืนข้อความที่ระบบตอบกลับ
    ...                เปิด context ใหม่ทุกครั้ง ให้การลองหลายรอบเริ่มจากสถานะสะอาดเสมอ
    [Arguments]    ${Username}    ${Password}

    Run Keyword And Ignore Error    Close Login Context
    Open Login Page
    Input Username    ${Username}
    Input Password    ${Password}
    Keyboard Key      press    Tab

    ${Clicked}=    Click Button If Enabled    ${Btn_Login}
    IF    not ${Clicked}
        ${Messages}=    Get Validation Messages
        ${Blocked}=     รวมข้อความ    ${Messages}    ปุ่มเข้าสู่ระบบถูกปิดใช้งาน
        RETURN    ${Blocked}
    END

    ${Message}=    รอผลลัพธ์หลังกดเข้าสู่ระบบ
    Log    ข้อความที่ระบบตอบกลับ : ${Message}    level=INFO
    RETURN    ${Message}

รอผลลัพธ์หลังกดเข้าสู่ระบบ
    [Documentation]    รอ popup แจ้งสำเร็จก่อน (รอสั้น ๆ เพราะกรณีที่ต้องไม่สำเร็จจะไม่มี popup)
    ...                ถ้าไม่มีจึงดูว่าเปลี่ยนหน้าไปแล้วหรือมีข้อความแจ้งเตือนอะไรขึ้นมา
    ${Success}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Popup_Success}    visible    ${POPUP_TIMEOUT}

    IF    ${Success}
        ${Text}=    Get Text    ${Popup_Success}
        ปิด popup ถ้ามีปุ่มตกลง
        RETURN    ${Text}
    END

    # บางหน้าไม่มี popup แต่เด้งไปหน้าถัดไปเลย ถือว่าสำเร็จเช่นกัน
    ${Left}=    รอให้ออกจากหน้าเข้าสู่ระบบ
    IF    ${Left}
        ${Url}=    Get Url
        RETURN    เข้าสู่ระบบสำเร็จ (เปลี่ยนไปหน้า ${Url})
    END

    ${Messages}=    Get Validation Messages
    ${Result}=      รวมข้อความ    ${Messages}    ไม่พบทั้งข้อความแจ้งสำเร็จและข้อความแจ้งเตือน
    RETURN    ${Result}

ปิด popup ถ้ามีปุ่มตกลง
    [Documentation]    บาง popup ต้องกด "ตกลง" ก่อน ระบบจึงจะพาไปหน้าถัดไป
    ${HasButton}=    Is Element Visible    ${Btn_Verify}
    IF    ${HasButton}    Run Keyword And Ignore Error    Click Verify Button

รอให้ออกจากหน้าเข้าสู่ระบบ
    [Documentation]    รอจน URL ออกจากหน้าเข้าสู่ระบบ คืน True เมื่อออกแล้ว
    ...                รอเป็นรอบสั้น ๆ เพื่อไม่ให้กรณีที่ต้องไม่สำเร็จเสียเวลารอนาน
    FOR    ${Round}    IN RANGE    10
        ${Url}=     Get Url
        ${Left}=    Evaluate    '${LOGIN_URL_PART}' not in $Url
        IF    ${Left}    RETURN    ${True}
        Sleep    0.5s
    END
    RETURN    ${False}

รอให้กลับมาหน้าเข้าสู่ระบบ
    [Documentation]    รอจน URL กลับมาที่หน้าเข้าสู่ระบบ ใช้ตรวจผลการออกจากระบบ
    FOR    ${Round}    IN RANGE    20
        ${Url}=     Get Url
        ${Back}=    Evaluate    '${LOGIN_URL_PART}' in $Url
        IF    ${Back}    RETURN    ${True}
        Sleep    0.5s
    END
    RETURN    ${False}

เตรียมชื่อผู้ใช้
    [Documentation]    ถ้าไฟล์ทดสอบระบุ AUTO ให้สมัครบัญชีใหม่ก่อนแล้วคืนชื่อผู้ใช้นั้น
    ...                ใช้กับกรณีที่ทำให้บัญชีเสียหาย (เช่น ถูกระงับ) จะได้ไม่แตะบัญชีหลัก
    [Arguments]    ${Username}    ${RegisterPassword}
    IF    '${Username}' != '${AUTO_ACCOUNT}'    RETURN    ${Username}
    ${NewAccount}=    สมัครบัญชีสำหรับทดสอบ    ${RegisterPassword}
    RETURN    ${NewAccount}

สมัครบัญชีสำหรับทดสอบ
    [Documentation]    สมัครบัญชีเกษตรกรใหม่ผ่านหน้าสมัครสมาชิกจริง แล้วคืนชื่อผู้ใช้ที่ได้
    [Arguments]    ${Password}

    # ชื่อผู้ใช้ยาว 19 ตัว (ระบบจำกัด 20) และไม่ซ้ำเพราะอิงเลขเวลา
    ${Stamp}=       Get Time    epoch
    ${Suffix}=      Evaluate    str($Stamp)[-8:] + str(random.randint(100, 999))    modules=random
    ${Username}=    Set Variable    locktest${Suffix}
    ${Tel}=         Evaluate    "09" + "".join(str(random.randint(0, 9)) for _ in range(8))    modules=random

    Run Keyword And Ignore Error    Close Login Context
    Open Register Page

    # ---------- ขั้นตอนที่ 1 : บัญชีและรหัสผ่าน ----------
    Upload Picture           ${REG_PICTURE}
    Input UsernameR          ${Username}
    Input Email              ${Username}@mail.com
    Input PasswordR          ${Password}
    Input Confirmpassword    ${Password}
    Keyboard Key    press    Tab

    ${Clicked}=    Click Next Button
    Should Be True    ${Clicked}    สมัครบัญชีสำหรับทดสอบไม่สำเร็จ (ไม่ผ่านขั้นตอนที่ 1)

    # ---------- ขั้นตอนที่ 2 : ข้อมูลส่วนตัวและที่อยู่ ----------
    Input Firstname    ภูษณิศา
    Input Surname      คำมา ศรีสุข
    Select Gender      หญิง
    Input Birthdate    12    6    2546
    Input Tel          ${Tel}
    Input Hnum         10/3ก
    Input Alley        สุขุมวิท 11/2
    Input Group        หมู่ 5
    Input District     บางนา
    Input Canton       บางรัก
    Input Province     สุราษฎร์ธานี
    Input Postcode     12345
    Keyboard Key       press    Tab

    ${Clicked}=    Click Register Button
    Should Be True    ${Clicked}    สมัครบัญชีสำหรับทดสอบไม่สำเร็จ (ปุ่มสมัครสมาชิกถูกปิดใช้งาน)

    ${Registered}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Popup_Success}    visible    ${DEFAULT_TIMEOUT}
    Should Be True    ${Registered}    สมัครบัญชีสำหรับทดสอบไม่สำเร็จ (ไม่พบข้อความแจ้งสำเร็จ)

    Log    บัญชีที่สมัครขึ้นเพื่อทดสอบ : ${Username}    level=INFO
    Run Keyword And Ignore Error    Close Login Context
    RETURN    ${Username}


# =====================================================================
# 7. คีย์เวิร์ดช่วยเหลือ : บันทึกผล ตรวจผล และเก็บหลักฐาน
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

ต้องเข้าสู่ระบบไม่สำเร็จ
    [Documentation]    ยืนยันว่าระบบไม่ให้เข้าสู่ระบบ คือไม่มีข้อความแจ้งสำเร็จ และยังอยู่หน้าเดิม
    [Arguments]    ${Message}
    ${Url}=    Get Url
    Should Not Contain    ${Message}    ${SUCCESS_KEYWORD}
    ...    msg=ระบบให้เข้าสู่ระบบสำเร็จ ทั้งที่ควรปฏิเสธ (ข้อความ "${Message}")
    Should Contain    ${Url}    ${LOGIN_URL_PART}
    ...    msg=ระบบพาออกจากหน้าเข้าสู่ระบบ ทั้งที่ควรปฏิเสธ (ไปที่ ${Url})

ข้อความต้องตรงกับที่คาดหวัง
    [Documentation]    ยืนยันว่าข้อความที่ระบบตอบกลับตรงกับที่เอกสารกำหนดไว้ในคอลัมน์ ExpectedResult
    [Arguments]    ${Message}    ${ExpectedResult}
    ${Matched}=    ข้อความตรงกับที่คาดหวัง    ${Message}    ${ExpectedResult}
    Should Be True    ${Matched}
    ...    msg=ระบบตอบว่า "${Message}" แต่เอกสารกำหนดไว้ว่า "${ExpectedResult}"

ข้อความต้องกล่าวถึง
    [Documentation]    ยืนยันว่าข้อความที่ระบบตอบกลับมีคำที่เอกสารระบุไว้อย่างน้อยหนึ่งคำ
    ...                ใช้กับกรณีที่เอกสารอธิบายพฤติกรรมเป็นประโยคยาว จึงเทียบทั้งประโยคไม่ได้
    [Arguments]    ${Message}    @{Keywords}
    ${Lower}=    Convert To Lower Case    ${Message}
    # lambda รับค่าผ่าน default argument เพราะ RF มองไม่เห็น $ตัวแปร ใน comprehension
    ${Matched}=    Evaluate    any(map(lambda k, t=$Lower: k.lower() in t, $Keywords))
    Should Be True    ${Matched}
    ...    msg=ข้อความ "${Message}" ไม่มีคำว่า ${Keywords} จึงไม่ตรงกับที่เอกสารกำหนดไว้

เก็บภาพหลักฐาน
    [Documentation]    บันทึกภาพหน้าจอไว้เป็นหลักฐานประกอบรายงาน ตั้งชื่อเป็น <ยูสเคส>_<รหัส>_<คำอธิบาย>
    [Arguments]    ${Name}
    Run Keyword And Ignore Error
    ...    Take Screenshot    ${EVIDENCE_DIR}/${USECASE}_${TC_ID}_${Name}    fullPage=True

บันทึกรายชื่อปุ่มบนหน้า
    [Documentation]    บันทึกข้อความของปุ่มและลิงก์ทั้งหมดบนหน้า ใช้ตอนหา locator ที่ยังไม่ทราบ
    ${Texts}=    Create List
    Set Browser Timeout    ${SHORT_TIMEOUT}
    ${Status}    ${Elements}=    Run Keyword And Ignore Error    Get Elements    css=button, a
    Set Browser Timeout    ${DEFAULT_TIMEOUT}

    IF    '${Status}' == 'FAIL'
        Log    อ่านรายชื่อปุ่มบนหน้าไม่สำเร็จ    level=WARN
        RETURN
    END

    FOR    ${Element}    IN    @{Elements}
        ${Ok}    ${Text}=    Run Keyword And Ignore Error    Get Text    ${Element}
        IF    '${Ok}' == 'PASS'
            ${Text}=    Strip String    ${Text}
            # เทียบด้วยความยาว ไม่เอาข้อความไปแทรกใน expression เพราะข้อความบนปุ่มที่ขึ้นบรรทัดใหม่จะทำให้ IF พัง
            ${Length}=    Get Length    ${Text}
            IF    ${Length} > 0    Append To List    ${Texts}    ${Text}
        END
    END
    Log    ปุ่มและลิงก์ที่พบบนหน้า : ${Texts}    level=WARN

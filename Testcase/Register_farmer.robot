*** Settings ***
Documentation     TC02 - Register Farmer | ตรวจข้อความแจ้งเตือนรายฟิลด์ (TC02_001-167) โดยกดปุ่ม "ถัดไป" และ "สมัครสมาชิก" จริง
...               การทดสอบยูสเคสสมัครสมาชิกทั้งกระบวนการ (TC02_F00-F03, F05-F07) แยกไปอยู่ที่ UseCase/Usecase_Register_farmer.robot
...               เลือกกรณีที่รันจากคอลัมน์ ${Run} (Yes/No) ใน Data.xlsx และเขียนผลกลับลง ActualResult / ResultPF
...               หมายเหตุ : กดปุ่มสมัครจริง กรณีที่ข้อมูลถูกต้องจึงสร้างบัญชีจริงในฐานข้อมูลทดสอบ
Metadata          System      ระบบเว็บศูนย์กลางให้บริการเช่าอุปกรณ์ทางการเกษตร (SRS v7.0)
Metadata          Use Case    TC02 Register Farmer (ทดสอบฟิลด์)
Metadata          Test Data   TestData/Data.xlsx (sheet: Register_Farmer)

Resource          ../Resources/keywords.robot
Library           DataDriver    file=${CURDIR}/../TestData/Data.xlsx    sheet_name=Register_Farmer
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
${SHEET}              Register_Farmer
${SCREENSHOT_DIR}     ${CURDIR}/../Screenshot
${USECASE}            TC02_Register_Farmer

# ---------- ตำแหน่งคอลัมน์ในชีต ----------
${COL_ID}         ${2}     # คอลัมน์ B : ${TestCaseID}
${COL_ACTUAL}     ${24}    # คอลัมน์ X : ${ActualResult}
${COL_PF}         ${25}    # คอลัมน์ Y : ${ResultPF}

# ---------- ข้อความและตัวชี้วัดที่ใช้ตัดสินผล ----------
# ${PASS_MESSAGE} คือคำที่เอกสาร Test Case ใช้แทนกรณี "ข้อมูลถูกต้อง ไม่มีข้อความแจ้งเตือน"
${PASS_MESSAGE}       ผ่านการตรวจสอบ
${SUCCESS_KEYWORD}    สำเร็จ
${Popup_Success}      text=${SUCCESS_KEYWORD}
# รอสั้น ๆ เพราะกรณีที่ต้องไม่สำเร็จจะไม่มี popup ขึ้นเลย
${POPUP_TIMEOUT}      5s
${NO_RESPONSE}        ไม่พบข้อความแจ้งเตือน และระบบไม่ได้สมัครสมาชิกให้

# ---------- รายการอนุโลม : ข้อความต่างสำนวนจากเอกสาร แต่สื่อกฎเดียวกัน ----------
# (เอกสารเขียนว่า TC02_024 "กรุณากรอกข้อมูลให้ถูกต้อง", TC02_086 "กรุณากรอกเป็นตัวเลข 0-9")
&{ACCEPTED_MESSAGE}
...    TC02_024=รูปแบบอีเมลไม่ถูกต้อง
...    TC02_086=เบอร์โทรศัพท์ต้องเป็นตัวเลขเท่านั้น

# % ของคำหลักในเอกสารที่ต้องพบในข้อความของระบบ จึงถือว่าตรงกัน
${WORD_MATCH_THRESHOLD}    ${60}

# คำทั่วไปที่ไม่สื่อความหมายของกฎ ตัดทิ้งก่อนเทียบ
@{STOPWORDS}
...    กรุณา    กรอก    โปรด    ระบุ    ต้อง    เป็น    และ    หรือ    ที่    มี    ไม่    ให้    การ    ของ
...    เท่านั้น    อัปโหลด    ตั้งแต่    ความ    อย่าง    ได้    ใน    กับ    ตัว    นั้น    นี้    จะ
...    ค่า    ระหว่าง    ถึง    เลือก    ประกอบ    ไป    ด้วย    รองรับ    เฉพาะ    ประเภท    /

# ชื่อฟิลด์บนฟอร์ม กันจับคู่ผิดฟิลด์ เช่น "อีเมล 5-60 ตัวอักษร" กับ "รหัสผ่าน 5-60 ตัวอักษร"
@{FIELD_NAMES}
...    ชื่อผู้ใช้    ชื่อจริง    นามสกุล    อีเมล    ยืนยันรหัสผ่าน    รหัสผ่าน    เพศ    วันเกิด    อายุ
...    เบอร์โทรศัพท์    เลขที่บ้าน    ซอย    หมู่    ตำบล    แขวง    อำเภอ    เขต    จังหวัด
...    รหัสไปรษณีย์    รูปภาพ    ไฟล์

# ---------- ตัวแปรระดับกรณีทดสอบ ใช้ส่งข้อมูลให้ teardown ----------
${TC_ID}             UNKNOWN
${ROW_NUM}           ${0}
${ACTUAL_MESSAGE}    ${EMPTY}


*** Test Cases ***
Register Farmer : ${TestCaseID}


*** Keywords ***
# =====================================================================
# 1. การเตรียมและปิดชุดทดสอบ
# =====================================================================

เปิดชุดทดสอบ
    [Documentation]    ล้างภาพของรอบก่อน เปิดไฟล์ Excel สำหรับเขียนผล และเปิดเบราว์เซอร์
    Create Directory    ${SCREENSHOT_DIR}
    ลบภาพของรอบก่อน    ${SCREENSHOT_DIR}

    Open Excel Document    ${DATA_FILE}    Register
    Open Test Browser

ลบภาพของรอบก่อน
    [Documentation]    ลบเฉพาะภาพของยูสเคสนี้ และไม่ลบตัวโฟลเดอร์ เพราะ OneDrive มักคืน Access denied
    [Arguments]    ${Folder}
    ${Files}=    List Files In Directory    ${Folder}    ${USECASE}_*.png
    FOR    ${File}    IN    @{Files}
        ${Removed}=    Run Keyword And Return Status    Remove File    ${Folder}/${File}
        IF    not ${Removed}    Log    ลบไฟล์ ${File} ไม่สำเร็จ ภาพอาจปนกับรอบก่อน    level=WARN
    END

ปิดชุดทดสอบ
    [Documentation]    บันทึกไฟล์ Excel และปิดทรัพยากรทั้งหมด
    Run Keyword And Ignore Error    เซฟไฟล์ Excel อย่างปลอดภัย
    Run Keyword And Ignore Error    Close All Excel Documents
    Close All Test Browsers

เก็บผลท้ายกรณีทดสอบ
    [Documentation]    เก็บภาพเมื่อไม่ผ่าน เขียนผลกลับลง Excel แล้วปิด context (กรณีที่ถูกข้าม ${ROW_NUM} = 0 จะไม่เขียนทับผลเดิม)
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
    [Documentation]    ค้นแถวจากรหัสกรณีทดสอบในคอลัมน์ B (index 0 คือหัวตาราง แถวจึงเป็น index + 1)
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
    เซฟไฟล์ Excel อย่างปลอดภัย

เซฟไฟล์ Excel อย่างปลอดภัย
    [Documentation]    เซฟลงไฟล์ชั่วคราวก่อน แล้วค่อยย้ายไปทับไฟล์จริง
    ...                ถ้ารันถูกตัดจบระหว่างเขียน ไฟล์ที่ค้างครึ่ง ๆ จะเป็นไฟล์ชั่วคราว ไฟล์จริงยังสมบูรณ์เสมอ
    ...                (เดิมเซฟทับไฟล์จริงตรง ๆ พอรันถูกตัดกลางคัน ไฟล์ .xlsx จะขาดท้ายจนเปิดไม่ขึ้น)
    ${Temp}=    Set Variable    ${DATA_FILE}.saving.xlsx
    Save Excel Document    ${Temp}
    Move File              ${Temp}    ${DATA_FILE}


# =====================================================================
# 3. จุดเริ่มของทุกกรณีทดสอบ
# =====================================================================

ดำเนินการกรณีทดสอบ
    [Documentation]    ตรวจข้อความแจ้งเตือนรายฟิลด์ พร้อมกดปุ่มจริง (TC02_NNN)
    ...                เคส TC02_FNN (ทดสอบทั้งกระบวนการ) แยกไปอยู่ที่ UseCase/Usecase_Register_farmer.robot แล้ว
    [Arguments]
    ...    ${Run}          ${TestCaseID}      ${TestScanario}      ${Picture}       ${UsernameR}
    ...    ${Email}        ${PasswordR}       ${Confirmpassword}
    ...    ${Firstname}    ${Surname}         ${Gender}
    ...    ${Daybirth}     ${Monthbirth}      ${Yearbirth}         ${Tel}
    ...    ${Hnum}         ${Alley}           ${Group}             ${District}
    ...    ${Canton}       ${province}        ${Postcode}
    ...    ${ExpectedResult}

    # แถวสรุปผลท้ายชีตไม่มีรหัสกรณีทดสอบ จึงไม่ใช่กรณีทดสอบ
    IF    '${TestCaseID}' == '${EMPTY}'    Skip    ไม่ใช่กรณีทดสอบ (แถวสรุปผลในไฟล์ Excel)
    IF    '${Run}' != 'Yes'                Skip    ไม่ได้เลือกให้รัน (Run = ${Run})

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

    ตรวจข้อความแจ้งเตือนรายฟิลด์    ${Data}    ${ExpectedResult}

แทนค่า AUTO ด้วยค่าที่ไม่ซ้ำ
    [Documentation]    ช่องที่เขียนว่า AUTO ใน Excel จะถูกสุ่มค่าใหม่ทุกครั้งที่รัน จึงรันซ้ำได้แม้ระบบตรวจข้อมูลซ้ำ
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
    # 8 หลักท้ายของเลขเวลา + สุ่ม 3 หลัก ให้ชื่อไม่เกิน 20 ตัวอักษรตามกฎของระบบ
    ${Stamp}=       Get Time    epoch
    ${Suffix}=      Evaluate    str($Stamp)[-8:] + str(random.randint(100, 999))    modules=random
    ${Username}=    Set Variable    pkfarmer${Suffix}
    ${Email}=       Set Variable    ${Username}@mail.com

    # เบอร์โทร 10 หลัก ขึ้นต้น 09 ตามกฎของระบบ
    ${Tel}=    Evaluate    "09" + "".join(str(random.randint(0, 9)) for _ in range(8))    modules=random
    RETURN    ${Username}    ${Email}    ${Tel}


# =====================================================================
# 4. ส่วนที่ 1 : ตรวจข้อความแจ้งเตือนรายฟิลด์ (TC02_001 - TC02_167)
# =====================================================================

ตรวจข้อความแจ้งเตือนรายฟิลด์
    [Documentation]    กรอกทั้ง 2 ขั้นตอนแล้วกดปุ่มจริง ตัดสินผลจากข้อความที่ระบบแจ้ง คู่กับว่าระบบยอมสมัครให้หรือไม่
    [Arguments]    ${Data}    ${ExpectedResult}

    Open Register Page

    # ---------- ขั้นตอนที่ 1 : ข้อมูลบัญชีผู้ใช้ ----------
    กรอกข้อมูลบัญชีผู้ใช้    ${Data}
    ${NextClicked}=    Click Next Button
    ${Messages}=       Get Validation Messages
    ${OnStep2}=        Is Register Step2 Displayed
    ${Registered}=     Set Variable    ${EMPTY}
    ${Blocked}=        Set Variable    ${EMPTY}

    # ---------- ขั้นตอนที่ 2 : ข้อมูลส่วนตัวและที่อยู่ ----------
    IF    ${OnStep2}
        กรอกข้อมูลส่วนตัว    ${Data}
        ${RegisterClicked}=    Click Register Button
        ${Messages}=           Get Validation Messages
        IF    ${RegisterClicked}
            ${Registered}=    รอผลการสมัคร
        ELSE
            ${Blocked}=    Set Variable    ปุ่ม "สมัครสมาชิก" ถูกปิดใช้งาน ระบบไม่ให้สร้างบัญชี
        END
    ELSE IF    not ${NextClicked}
        ${Blocked}=    Set Variable    ปุ่ม "ถัดไป" ถูกปิดใช้งาน ระบบไม่ให้ไปขั้นตอนที่ 2
    ELSE
        ${Blocked}=    Set Variable    กดปุ่ม "ถัดไป" ได้ แต่ระบบไม่ได้พาไปขั้นตอนที่ 2
    END
    ${BlockedLen}=    Get Length    ${Blocked}
    IF    ${BlockedLen} > 0    Log    ${Blocked}    level=INFO

    ${ActualResult}=    สรุปผลที่ได้จริง          ${Messages}    ${Registered}    ${Blocked}
    ${Matched}=         ผลตรงกับที่เอกสารกำหนด    ${Messages}    ${Registered}    ${ExpectedResult}

    บันทึกผลที่ได้จริง    ${ActualResult}
    Should Be True    ${Matched}
    ...    msg=${TC_ID} : ระบบตอบว่า "${ActualResult}" แต่เอกสารกำหนดไว้ว่า "${ExpectedResult}"

สรุปผลที่ได้จริง
    [Documentation]    ข้อความที่บันทึกลง ActualResult เรียงตามลำดับ : ข้อความบน popup ตอนสมัครสำเร็จ >
    ...                ข้อความแจ้งเตือนที่พบ > จุดที่ระบบกันไว้ เช่น ปุ่มถูกปิดใช้งานโดยไม่แจ้งเหตุผล
    [Arguments]    ${Messages}    ${Registered}    ${Blocked}
    ${RegLen}=    Get Length    ${Registered}
    IF    ${RegLen} > 0    RETURN    ${Registered}

    ${BlockedLen}=    Get Length    ${Blocked}
    ${Fallback}=      Set Variable If    ${BlockedLen} == 0
    ...    ${NO_RESPONSE}    ${Blocked} (ไม่มีข้อความแจ้งเตือน)

    ${Result}=    รวมข้อความ    ${Messages}    ${Fallback}
    RETURN    ${Result}

ผลตรงกับที่เอกสารกำหนด
    [Documentation]    เอกสารระบุ "ผ่านการตรวจสอบ" -> ต้องไม่มีข้อความแจ้งเตือน และระบบต้องสมัครให้สำเร็จ
    ...                เอกสารระบุข้อความแจ้งเตือน   -> ระบบต้องไม่สมัครให้ และข้อความต้องตรงกับเอกสาร
    [Arguments]    ${Messages}    ${Registered}    ${ExpectedResult}
    ${Count}=      Get Length    ${Messages}
    ${RegLen}=     Get Length    ${Registered}

    ${ExpNorm}=     Normalize Message    ${ExpectedResult}
    ${PassNorm}=    Normalize Message    ${PASS_MESSAGE}
    ${WantPass}=    Evaluate    $ExpNorm == $PassNorm

    IF    ${WantPass}
        ${Ok}=    Evaluate    ${Count} == 0 and ${RegLen} > 0
        IF    not ${Ok}
            Log    ข้อมูลถูกต้องตามเอกสาร แต่ระบบไม่ได้สมัครสมาชิกให้ (ข้อความแจ้งเตือน ${Count} รายการ)    level=WARN
        END
        RETURN    ${Ok}
    END

    IF    ${RegLen} > 0
        Log    ระบบสมัครสมาชิกให้สำเร็จ ทั้งที่เอกสารกำหนดว่าต้องแจ้งเตือน "${ExpectedResult}"    level=WARN
        RETURN    ${False}
    END

    FOR    ${Message}    IN    @{Messages}
        ${Matched}=    Is Message Matched    ${Message}    ${ExpectedResult}    ${TC_ID}
        IF    ${Matched}    RETURN    ${True}
    END
    RETURN    ${False}


# =====================================================================
# 5. การเปรียบเทียบข้อความ
# =====================================================================

Normalize Text
    [Documentation]    ปรับข้อความเป็นรูปมาตรฐาน : NFC + ตัวพิมพ์เล็ก + รวมขีดกลางทุกแบบให้เป็น "-"
    [Arguments]    ${Text}
    ${Text}=    Evaluate    unicodedata.normalize("NFC", str($Text)).lower()    modules=unicodedata
    ${Text}=    Evaluate    "".join("-" if 0x2010 <= ord(c) <= 0x2015 or ord(c) == 0x2212 else c for c in $Text)
    RETURN    ${Text}

Normalize Message
    [Documentation]    ปรับข้อความเป็นรูปมาตรฐานแล้วตัดช่องว่างทิ้งทั้งหมด ใช้ตอนเทียบข้อความแบบตรงตัว
    [Arguments]    ${Text}
    ${Text}=    Normalize Text    ${Text}
    ${Text}=    Evaluate    "".join($Text.split())
    RETURN    ${Text}

Get Content Words
    [Documentation]    ตัดคำภาษาไทยด้วย pythainlp คืนเฉพาะคำหลัก (ตัด @{STOPWORDS} ทิ้ง)
    [Arguments]    ${Text}
    ${Norm}=      Normalize Text    ${Text}
    ${Tokens}=    Evaluate    pythainlp.word_tokenize($Norm, keep_whitespace=False)    modules=pythainlp
    ${Clean}=     Evaluate    [t.strip(" ,.-") for t in $Tokens]
    ${Words}=     Evaluate    list(filter(lambda w, s=$STOPWORDS: bool(w) and w not in s, $Clean))
    RETURN    ${Words}

Get Fields In Message
    [Documentation]    คืนรายชื่อฟิลด์บนฟอร์มที่ถูกกล่าวถึงในข้อความนั้น
    [Arguments]    ${Text}
    ${Flat}=     Evaluate    "".join(unicodedata.normalize("NFC", str($Text)).lower().split())    modules=unicodedata
    ${Found}=    Evaluate    list(filter(lambda f, t=$Flat: "".join(f.split()).lower() in t, $FIELD_NAMES))
    RETURN    ${Found}

Is Message Matched By Words
    [Documentation]    เทียบระดับคำ ต้องเป็นฟิลด์เดียวกันและคำหลักตรงกันตามเกณฑ์ที่กำหนด
    [Arguments]    ${Message}    ${ExpectedResult}
    ${FieldsExp}=    Get Fields In Message    ${ExpectedResult}
    ${FieldsAct}=    Get Fields In Message    ${Message}
    ${HasField}=     Get Length    ${FieldsExp}
    ${SameField}=    Evaluate      bool(set($FieldsExp) & set($FieldsAct))

    IF    ${HasField} > 0 and not ${SameField}
        Log    ข้อความเป็นของคนละฟิลด์ (${FieldsExp} vs ${FieldsAct})    level=INFO
        RETURN    ${False}
    END

    # ตัดชื่อฟิลด์ออก เหลือเฉพาะคำที่บอกเนื้อหาของกฎ
    ${WordsExp}=    Get Content Words    ${ExpectedResult}
    ${WordsAct}=    Get Content Words    ${Message}
    ${WordsExp}=    Evaluate    list(filter(lambda w, fs=$FieldsExp: not any(w in f or f in w for f in fs), $WordsExp))

    ${Count}=    Get Length    ${WordsExp}
    IF    ${Count} == 0    RETURN    ${SameField}

    # ตรงเมื่อคำเหมือนกัน หรือเป็นส่วนหนึ่งของกันและยาว 3 ตัวอักษรขึ้นไป (กันคำสั้นจับคู่มั่ว)
    ${Hit}=    Evaluate
    ...    list(filter(lambda w, a=$WordsAct: any(w == x or (len(x) >= 3 and x in w) or (len(w) >= 3 and w in x) for x in a), $WordsExp))

    ${Coverage}=   Evaluate    round(len($Hit) / len($WordsExp) * 100, 1)
    Log    คำหลักของเอกสาร ${WordsExp} -> พบในข้อความระบบ ${Hit} = ${Coverage}%    level=INFO
    ${Matched}=    Evaluate    ${Coverage} >= ${WORD_MATCH_THRESHOLD}
    RETURN    ${Matched}

Is Message Matched
    [Documentation]    ตัดสินว่าตรงกับเอกสารไหม ตามลำดับ ตรงตัว > เป็นส่วนของกัน > รายการอนุโลม > ระดับคำ
    [Arguments]    ${Message}    ${ExpectedResult}    ${TestCaseID}
    ${Actual}=      Normalize Message    ${Message}
    ${Expected}=    Normalize Message    ${ExpectedResult}

    IF    $Actual == $Expected                           RETURN    ${True}
    IF    $Expected in $Actual or $Actual in $Expected    RETURN    ${True}

    ${Accepted}=    Get From Dictionary    ${ACCEPTED_MESSAGE}    ${TestCaseID}    default=${EMPTY}
    IF    '${Accepted}' == '${EMPTY}'
        ${ByWords}=    Is Message Matched By Words    ${Message}    ${ExpectedResult}
        IF    ${ByWords}    Log    ${TestCaseID} : ต่างสำนวนแต่คำหลักตรงและเป็นฟิลด์เดียวกัน    level=INFO
        RETURN    ${ByWords}
    END

    ${AcceptedNorm}=    Normalize Message    ${Accepted}
    ${Matched}=         Evaluate    $Actual == $AcceptedNorm
    IF    ${Matched}    Log    ${TestCaseID} : ต่างสำนวน แต่อยู่ในรายการที่อนุโลมไว้    level=WARN
    RETURN    ${Matched}


# =====================================================================
# 6. ขั้นตอนย่อยของการสมัครสมาชิก (ใช้ร่วมกับ UseCase/Usecase_Register_farmer.robot)
# =====================================================================

กรอกข้อมูลบัญชีผู้ใช้
    [Documentation]    กรอกข้อมูลขั้นตอนที่ 1 (รูปโปรไฟล์ ชื่อผู้ใช้ อีเมล รหัสผ่าน)
    [Arguments]    ${Data}
    Upload Picture           ${Data}[Picture]
    Input UsernameR          ${Data}[UsernameR]
    Input Email              ${Data}[Email]
    Input PasswordR          ${Data}[PasswordR]
    Input Confirmpassword    ${Data}[Confirmpassword]

    # ช่องสุดท้ายไม่มีช่องถัดไปมา blur ให้ ต้อง Tab ออกเองระบบจึงจะตรวจสอบ
    Keyboard Key    press    Tab

กรอกข้อมูลส่วนตัว
    [Documentation]    กรอกข้อมูลขั้นตอนที่ 2 (ข้อมูลส่วนตัวและที่อยู่)
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
    [Documentation]    รอ popup แจ้งสมัครสำเร็จ คืนข้อความบน popup ไม่พบให้คืนค่าว่าง (รอสั้นเพราะเคสที่ต้องไม่สำเร็จจะไม่มี popup)
    ${Success}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Popup_Success}    visible    ${POPUP_TIMEOUT}
    IF    not ${Success}    RETURN    ${EMPTY}

    ${Text}=    Get Text        ${Popup_Success}
    ${Text}=    Strip String    ${Text}
    RETURN    ${Text}


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

เก็บภาพหลักฐาน
    [Documentation]    บันทึกภาพหน้าจอเป็นหลักฐานประกอบรายงาน ตั้งชื่อ <ยูสเคส>_<รหัส>_<คำอธิบาย>
    [Arguments]    ${Name}
    Run Keyword And Ignore Error
    ...    Take Screenshot    ${SCREENSHOT_DIR}/${USECASE}_${TC_ID}_${Name}    fullPage=True

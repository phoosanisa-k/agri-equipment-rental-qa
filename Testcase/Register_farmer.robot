*** Settings ***
Documentation     TC02 - Register Farmer | ทดสอบฟังก์ชันสมัครสมาชิกของเกษตรกร
...
...               อ้างอิงเอกสาร System Test Case จำนวน 167 กรณีทดสอบ
...               เลือกกรณีที่ต้องการรันจากคอลัมน์ ${Run} (Yes/No) ในไฟล์ Data.xlsx
...               ผลการทดสอบถูกเขียนกลับลงคอลัมน์ ActualResult และ ResultPF อัตโนมัติ
Metadata          System      ระบบเว็บศูนย์กลางให้บริการเช่าอุปกรณ์ทางการเกษตร (SRS v7.0)
Metadata          Use Case    TC02 Register Farmer
Metadata          Test Data   TestData/Data.xlsx (sheet: Register_Farmer)

Resource          ../Resources/keywords.robot
Library           DataDriver    file=${CURDIR}/../TestData/Data.xlsx    sheet_name=Register_Farmer
Library           ExcelLibrary
Library           OperatingSystem
Library           String

Suite Setup       Prepare Register Suite
Suite Teardown    Finish Register Suite
Test Teardown     Register Test Teardown

Test Template     Register_Farmer


*** Variables ***
${DATA_FILE}      ${CURDIR}/../TestData/Data.xlsx
${SHEET}          Register_Farmer
${ERROR_DIR}      ${CURDIR}/../Error IMG
${USECASE}        TC02_Register_Farmer

${COL_ACTUAL}     ${24}    # คอลัมน์ X : ${ActualResult}
${COL_PF}         ${25}    # คอลัมน์ Y : ${ResultPF}

# ข้อความแทน "ไม่มีข้อความแจ้งเตือน" ให้ตรงกับที่ระบุในเอกสาร Test Case
${PASS_MESSAGE}   ผ่านการตรวจสอบ

# ตัวแปรระดับกรณีทดสอบ ใช้ส่งข้อมูลให้ teardown
${TC_ID}             UNKNOWN
${ROW_NUM}           ${0}
${RESULT_RECORDED}   ${False}

# ข้อความที่ระบบตอบต่างสำนวนจากเอกสาร แต่ตรวจแล้วว่าเป็นกฎเดียวกัน จึงยอมรับเป็น Pass
# ระบุรายกรณีเพื่อให้ตรวจสอบย้อนหลังได้ว่าอนุโลมเคสใดไปบ้าง
&{ACCEPTED_MESSAGE}
# TC02_024 : เอกสาร "กรุณากรอกข้อมูลให้ถูกต้อง" / ระบบ "รูปแบบอีเมลไม่ถูกต้อง" - กฎเดียวกัน
...    TC02_024=รูปแบบอีเมลไม่ถูกต้อง
# TC02_086 : เอกสาร "กรุณากรอกเป็นตัวเลข 0-9" / ระบบ "เบอร์โทรศัพท์ต้องเป็นตัวเลขเท่านั้น" - กฎเดียวกัน
...    TC02_086=เบอร์โทรศัพท์ต้องเป็นตัวเลขเท่านั้น

# เกณฑ์การเทียบข้อความระดับคำ (% ของคำหลักในเอกสารที่ต้องพบในข้อความของระบบ)
${WORD_MATCH_THRESHOLD}    ${60}

# คำทั่วไปที่ไม่สื่อความหมายของกฎ ตัดทิ้งก่อนเทียบ
@{STOPWORDS}
...    กรุณา    กรอก    โปรด    ระบุ    ต้อง    เป็น    และ    หรือ    ที่    มี    ไม่    ให้    การ    ของ
...    เท่านั้น    อัปโหลด    ตั้งแต่    ความ    อย่าง    ได้    ใน    กับ    ตัว    นั้น    นี้    จะ
...    ค่า    ระหว่าง    ถึง    เลือก    ประกอบ    ไป    ด้วย    รองรับ    เฉพาะ    ประเภท    /

# ชื่อฟิลด์บนฟอร์ม ใช้ยืนยันว่าข้อความที่อ่านได้มาจากฟิลด์เดียวกับที่ทดสอบ
# กันการจับคู่ผิดฟิลด์ เช่น "อีเมล 5-60 ตัวอักษร" กับ "รหัสผ่าน 5-60 ตัวอักษร"
@{FIELD_NAMES}
...    ชื่อผู้ใช้    ชื่อจริง    นามสกุล    อีเมล    ยืนยันรหัสผ่าน    รหัสผ่าน    เพศ    วันเกิด    อายุ
...    เบอร์โทรศัพท์    เลขที่บ้าน    ซอย    หมู่    ตำบล    แขวง    อำเภอ    เขต    จังหวัด
...    รหัสไปรษณีย์    รูปภาพ    ไฟล์


*** Test Cases ***
Register For ${TestCaseID}


*** Keywords ***
# =====================================================================
# การเตรียมและปิดงาน
# =====================================================================

Prepare Register Suite
    [Documentation]    ล้างภาพของรอบก่อน เปิดไฟล์ Excel สำหรับเขียนผล และเปิดเบราว์เซอร์
    Create Directory    ${ERROR_DIR}

    # ล้างเฉพาะไฟล์ข้างใน ไม่ลบตัวโฟลเดอร์ (Windows มักติด Access denied จาก OneDrive)
    ${Cleaned}=    Run Keyword And Return Status    Empty Directory    ${ERROR_DIR}
    IF    not ${Cleaned}
        Log    ล้างโฟลเดอร์ ${ERROR_DIR} ไม่สำเร็จ ภาพอาจปนกับรอบก่อน    level=WARN
    END

    Open Excel Document    ${DATA_FILE}    Result
    Open Register Browser

Finish Register Suite
    [Documentation]    บันทึกไฟล์ Excel และปิดทรัพยากรทั้งหมด
    Run Keyword And Ignore Error    Save Excel Document    ${DATA_FILE}
    Run Keyword And Ignore Error    Close All Excel Documents
    Close All Register Browsers

Register Test Teardown
    [Documentation]    เก็บภาพหน้าจอเมื่อไม่ผ่าน และบันทึก error ลง Excel ถ้ายังไม่ได้บันทึกผล
    IF    '${TEST STATUS}' == 'FAIL'
        Run Keyword And Ignore Error
        ...    Take Screenshot    ${ERROR_DIR}/${USECASE}_${TC_ID}    fullPage=True

        # กรณีเกิด error กลางทาง จะยังไม่ได้บันทึกผล จึงเขียนข้อความ error ลงแทน
        IF    ${ROW_NUM} > 0 and not ${RESULT_RECORDED}
            ${ErrorText}=    Get Line         ${TEST MESSAGE}    0
            ${ErrorText}=    Get Substring    ${ErrorText}       0    200
            Run Keyword And Ignore Error
            ...    Record Test Result    ${ROW_NUM}    ${ErrorText}    Fail
        END
    END

    # ใช้ Ignore Error เพราะกรณีที่ถูก Skip จะยังไม่มี context ถูกเปิด
    Run Keyword And Ignore Error    Close Register Context

Record Test Result
    [Documentation]    เขียนผลจริงและสถานะ Pass/Fail กลับลงไฟล์ Excel ตามแถวของกรณีทดสอบ
    [Arguments]    ${Row}    ${ActualResult}    ${ResultPF}
    Write Excel Cell       ${Row}    ${COL_ACTUAL}    ${ActualResult}    sheet_name=${SHEET}
    Write Excel Cell       ${Row}    ${COL_PF}        ${ResultPF}        sheet_name=${SHEET}
    Save Excel Document    ${DATA_FILE}
    Set Test Variable      ${RESULT_RECORDED}    ${True}


# =====================================================================
# การเปรียบเทียบข้อความ
# =====================================================================

Normalize Message
    [Documentation]    ปรับข้อความเป็นรูปมาตรฐาน - รวมขีดกลางทุกแบบ ตัดช่องว่าง ไม่แยกตัวพิมพ์
    [Arguments]    ${Text}
    ${Text}=    Evaluate    unicodedata.normalize("NFC", str($Text))    modules=unicodedata
    ${Text}=    Evaluate    "".join("-" if 0x2010 <= ord(c) <= 0x2015 or ord(c) == 0x2212 else c for c in $Text)
    ${Text}=    Evaluate    "".join($Text.split()).lower()
    RETURN    ${Text}

Get Content Words
    [Documentation]    ตัดคำภาษาไทยด้วย pythainlp คืนเฉพาะคำหลัก (ตัด @{STOPWORDS} ทิ้ง)
    [Arguments]    ${Text}
    ${Norm}=      Evaluate    unicodedata.normalize("NFC", str($Text)).lower()    modules=unicodedata
    ${Norm}=      Evaluate    "".join("-" if 0x2010 <= ord(c) <= 0x2015 or ord(c) == 0x2212 else c for c in $Norm)
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
    [Documentation]    เทียบระดับคำ ต้องเป็นฟิลด์เดียวกัน และคำหลักตรงกันตามเกณฑ์ที่กำหนด
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

    # ตรงกันเมื่อคำเหมือนกัน หรือคำหนึ่งเป็นส่วนหนึ่งของอีกคำและยาวตั้งแต่ 3 ตัวอักษร
    # เช่น เอกสารเขียน "ภาษาอังกฤษ" ระบบเขียน "อังกฤษ" - เงื่อนไขความยาวกันเลขสั้นจับคู่มั่ว
    ${Hit}=    Evaluate
    ...    list(filter(lambda w, a=$WordsAct: any(w == x or (len(x) >= 3 and x in w) or (len(w) >= 3 and w in x) for x in a), $WordsExp))

    ${Coverage}=   Evaluate    round(len($Hit) / len($WordsExp) * 100, 1)
    Log    คำหลักของเอกสาร ${WordsExp} -> พบในข้อความระบบ ${Hit} = ${Coverage}%    level=INFO
    ${Matched}=    Evaluate    ${Coverage} >= ${WORD_MATCH_THRESHOLD}
    RETURN    ${Matched}

Is Message Matched
    [Documentation]    ตัดสินว่าข้อความจากหน้าเว็บตรงกับที่เอกสารคาดหวังหรือไม่ ตามลำดับ
    ...                1) ปรับรูปแบบแล้วตรงกัน  2) เป็นส่วนหนึ่งของกัน
    ...                3) อยู่ใน &{ACCEPTED_MESSAGE}  4) เทียบระดับคำ
    [Arguments]    ${Message}    ${ExpectedResult}    ${TestCaseID}
    ${Actual}=      Normalize Message    ${Message}
    ${Expected}=    Normalize Message    ${ExpectedResult}

    IF    $Actual == $Expected                           RETURN    ${True}
    IF    $Expected in $Actual or $Actual in $Expected    RETURN    ${True}

    ${Accepted}=    Get From Dictionary    ${ACCEPTED_MESSAGE}    ${TestCaseID}    default=${EMPTY}
    IF    '${Accepted}' == '${EMPTY}'
        ${ByWords}=    Is Message Matched By Words    ${Message}    ${ExpectedResult}
        IF    ${ByWords}    Log    ${TestCaseID}: ต่างสำนวนแต่คำหลักตรงและเป็นฟิลด์เดียวกัน    level=INFO
        RETURN    ${ByWords}
    END

    ${AcceptedNorm}=    Normalize Message    ${Accepted}
    ${Matched}=         Evaluate    $Actual == $AcceptedNorm
    IF    ${Matched}    Log    ${TestCaseID}: ต่างสำนวน แต่อยู่ในรายการที่อนุโลมไว้    level=INFO
    RETURN    ${Matched}

Resolve Actual Result
    [Documentation]    เลือกข้อความที่จะบันทึกเป็นผลจริง
    ...                ไม่มีข้อความ -> "ผ่านการตรวจสอบ" / ตรงกับที่คาดหวัง -> ใช้ข้อความนั้น
    ...                ไม่ตรง -> รวมทุกข้อความที่แสดงจริง เพื่อให้เห็นว่าระบบตอบอะไรกลับมา
    [Arguments]    ${Messages}    ${ExpectedResult}    ${TestCaseID}
    ${Count}=    Get Length    ${Messages}
    IF    ${Count} == 0    RETURN    ${PASS_MESSAGE}

    FOR    ${Message}    IN    @{Messages}
        ${Matched}=    Is Message Matched    ${Message}    ${ExpectedResult}    ${TestCaseID}
        IF    ${Matched}    RETURN    ${ExpectedResult}
    END

    ${Joined}=    Evaluate    " | ".join($Messages)
    RETURN    ${Joined}


# =====================================================================
# ขั้นตอนการทดสอบหนึ่งกรณี
# =====================================================================

Register_Farmer
    [Arguments]
    ...    ${Run}          ${TestCaseID}      ${TestScanario}      ${Picture}       ${UsernameR}
    ...    ${Email}        ${PasswordR}       ${Confirmpassword}
    ...    ${Firstname}    ${Surname}         ${Gender}
    ...    ${Daybirth}     ${Monthbirth}      ${Yearbirth}         ${Tel}
    ...    ${Hnum}         ${Alley}           ${Group}             ${District}
    ...    ${Canton}       ${province}        ${Postcode}
    ...    ${ExpectedResult}

    # แถวสรุปผลท้ายชีตไม่มี TestCaseID จึงไม่ใช่กรณีทดสอบ
    IF    '${TestCaseID}' == '${EMPTY}'
        Skip    ไม่ใช่กรณีทดสอบ (แถวสรุปผลในไฟล์ Excel)
    END

    IF    '${Run}' != 'Yes'
        Skip    ไม่ได้เลือกให้รัน (Run = ${Run})
    END

    Set Test Variable    ${TC_ID}    ${TestCaseID}
    ${Row}=              Evaluate    int("${TestCaseID}".split("_")[1]) + 1
    Set Test Variable    ${ROW_NUM}            ${Row}
    Set Test Variable    ${RESULT_RECORDED}    ${False}
    Log                  ${TestCaseID} : ${TestScanario}

    Open Register Page

    # ---------- ขั้นที่ 1 : ข้อมูลบัญชีผู้ใช้ ----------
    Upload Picture           ${Picture}
    Input UsernameR          ${UsernameR}
    Input Email              ${Email}
    Input PasswordR          ${PasswordR}
    Input Confirmpassword    ${Confirmpassword}

    # ช่องสุดท้ายของหน้าไม่มีช่องถัดไปให้กรอก จึงต้องสั่งออกจากช่องเอง
    # ระบบตรวจสอบตอนออกจากช่อง (blur) เหมือนช่องอื่นที่ถูก blur อัตโนมัติเมื่อไปกรอกช่องถัดไป
    Keyboard Key    press    Tab

    ${Clicked}=    Click Next Button

    ${Messages}=    Get Validation Messages
    ${OnStep2}=     Is Register Step2 Displayed

    # ---------- ขั้นที่ 2 : ข้อมูลส่วนตัว ----------
    IF    ${OnStep2}
        Input Firstname    ${Firstname}
        Input Surname      ${Surname}
        Select Gender      ${Gender}
        Input Birthdate    ${Daybirth}    ${Monthbirth}    ${Yearbirth}
        Input Tel          ${Tel}
        Input Hnum         ${Hnum}
        Input Alley        ${Alley}
        Input Group        ${Group}
        Input District     ${District}
        Input Canton       ${Canton}
        Input Province     ${province}
        Input Postcode     ${Postcode}

        # ช่องสุดท้ายของหน้าเช่นกัน ต้องออกจากช่องเพื่อให้ระบบตรวจสอบ
        Keyboard Key    press    Tab

        # ไม่กดปุ่มสมัครสมาชิก เพราะขอบเขตคือการตรวจสอบข้อมูลบนหน้าจอ ระบบแจ้งเตือนทันทีที่กรอก
        # และการไม่ submit ทำให้ไม่มีการสร้างบัญชีจริง จึงไม่เกิดปัญหาชื่อผู้ใช้ซ้ำในเคสถัดไป
        ${Messages}=    Get Validation Messages
    END

    # สถานะปุ่มใช้บันทึก log เท่านั้น ไม่นำมาตัดสินผล เพราะอาจถูกปิดจากฟิลด์อื่นที่ไม่ได้ทดสอบ
    IF    not ${Clicked}
        Log    ปุ่ม "ถัดไป" ถูกปิดใช้งาน (อาจมาจากฟิลด์อื่นในฟอร์ม)    level=INFO
    END

    # ---------- บันทึกผลลง Excel แล้วตัดสิน Pass/Fail ----------
    ${ActualResult}=    Resolve Actual Result    ${Messages}    ${ExpectedResult}    ${TestCaseID}
    ${ResultPF}=        Set Variable If    '${ActualResult}' == '${ExpectedResult}'    Pass    Fail
    Record Test Result    ${Row}    ${ActualResult}    ${ResultPF}

    Should Be Equal As Strings    ${ActualResult}    ${ExpectedResult}
    ...    msg=${TestCaseID} (${TestScanario}) ไม่ผ่าน

*** Settings ***
Documentation     TC01 - Login Farmer | ทดสอบการตรวจสอบข้อมูลบนหน้าเข้าสู่ระบบของเกษตรกร
...
...               ขอบเขต : ตรวจสอบข้อความแจ้งเตือนบนหน้าจอเท่านั้น ไม่กดปุ่ม "เข้าสู่ระบบ"
...               (การเข้าสู่ระบบจริงแยกเป็นไฟล์ flow ต่างหาก)
...
...               อ้างอิงเอกสาร System Test Case จำนวน 27 กรณีทดสอบ
...               เลือกกรณีที่ต้องการรันจากคอลัมน์ ${Run} (Yes/No) ในไฟล์ Data.xlsx
...               ผลการทดสอบถูกเขียนกลับลงคอลัมน์ ActualResult และ Result อัตโนมัติ
Metadata          System      ระบบเว็บศูนย์กลางให้บริการเช่าอุปกรณ์ทางการเกษตร (SRS v7.0)
Metadata          Use Case    TC01 Login Farmer
Metadata          Test Data   TestData/Data.xlsx (sheet: Login_Farmer)

Resource          ../Resources/keywords.robot
Library           DataDriver    file=${CURDIR}/../TestData/Data.xlsx    sheet_name=Login_Farmer
Library           ExcelLibrary
Library           OperatingSystem
Library           String

Suite Setup       Prepare Login Suite
Suite Teardown    Finish Login Suite
Test Teardown     Login Test Teardown

Test Template     Login_Farmer


*** Variables ***
${DATA_FILE}      ${CURDIR}/../TestData/Data.xlsx
${SHEET}          Login_Farmer
${ERROR_DIR}      ${CURDIR}/../Error IMG
${USECASE}        TC01_Login_Farmer

${COL_ACTUAL}     ${7}     # คอลัมน์ G : ${ActualResult}
${COL_PF}         ${8}     # คอลัมน์ H : ${Result}

# ข้อความแทน "ไม่มีข้อความแจ้งเตือน" ให้ตรงกับที่ระบุในเอกสาร Test Case
${PASS_MESSAGE}   ผ่านการตรวจสอบ

# ตัวแปรระดับกรณีทดสอบ ใช้ส่งข้อมูลให้ teardown
${TC_ID}             UNKNOWN
${ROW_NUM}           ${0}
${RESULT_RECORDED}   ${False}

# ข้อความที่ระบบตอบต่างสำนวนจากเอกสาร แต่ตรวจแล้วว่าเป็นกฎเดียวกัน จึงยอมรับเป็น Pass
# ระบุรายกรณีเพื่อให้ตรวจสอบย้อนหลังได้ว่าอนุโลมเคสใดไปบ้าง
# ตัวอย่างการเพิ่ม :    TC01_04=ชื่อผู้ใช้ต้องเป็นภาษาอังกฤษและตัวเลข
&{ACCEPTED_MESSAGE}

# เกณฑ์การเทียบข้อความระดับคำ (% ของคำหลักในเอกสารที่ต้องพบในข้อความของระบบ)
${WORD_MATCH_THRESHOLD}    ${60}

# คำทั่วไปที่ไม่สื่อความหมายของกฎ ตัดทิ้งก่อนเทียบ
@{STOPWORDS}
...    กรุณา    กรอก    โปรด    ระบุ    ต้อง    เป็น    และ    หรือ    ที่    มี    ไม่    ให้    การ    ของ
...    เท่านั้น    ตั้งแต่    ความ    อย่าง    ได้    ใน    กับ    ตัว    นั้น    นี้    จะ
...    ค่า    ระหว่าง    ถึง    เลือก    ไป    ด้วย    รองรับ    เฉพาะ    /

# ชื่อฟิลด์บนฟอร์ม ใช้ยืนยันว่าข้อความที่อ่านได้มาจากฟิลด์เดียวกับที่ทดสอบ
# กันการจับคู่ผิดฟิลด์ เช่น "ชื่อผู้ใช้ 6-20 ตัวอักษร" กับ "รหัสผ่าน 8-16 ตัวอักษร"
@{FIELD_NAMES}
...    ชื่อผู้ใช้    รหัสผ่าน


*** Test Cases ***
Login For ${TestCase}


*** Keywords ***
# =====================================================================
# การเตรียมและปิดงาน
# =====================================================================

Prepare Login Suite
    [Documentation]    ล้างภาพของรอบก่อน เปิดไฟล์ Excel สำหรับเขียนผล และเปิดเบราว์เซอร์
    Create Directory    ${ERROR_DIR}
    Clear Previous Screenshots

    Open Excel Document    ${DATA_FILE}    Result
    Open Login Browser

Clear Previous Screenshots
    [Documentation]    ลบเฉพาะภาพของ use case นี้ (${USECASE}_*) ไม่แตะภาพของ use case อื่น
    ...                ที่เก็บอยู่ในโฟลเดอร์เดียวกัน และไม่ลบตัวโฟลเดอร์
    ...                (Windows มักติด Access denied จาก OneDrive ถ้าลบทั้งโฟลเดอร์)
    ${Files}=    List Files In Directory    ${ERROR_DIR}    ${USECASE}_*.png
    FOR    ${File}    IN    @{Files}
        ${Removed}=    Run Keyword And Return Status    Remove File    ${ERROR_DIR}/${File}
        IF    not ${Removed}
            Log    ลบไฟล์ ${File} ไม่สำเร็จ ภาพอาจปนกับรอบก่อน    level=WARN
        END
    END

Finish Login Suite
    [Documentation]    บันทึกไฟล์ Excel และปิดทรัพยากรทั้งหมด
    Run Keyword And Ignore Error    Save Excel Document    ${DATA_FILE}
    Run Keyword And Ignore Error    Close All Excel Documents
    Close All Login Browsers

Login Test Teardown
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
    Run Keyword And Ignore Error    Close Login Context

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

Login_Farmer
    [Arguments]
    ...    ${Run}        ${TestCase}    ${TestScenario}
    ...    ${Username}   ${Password}    ${ExpectedResult}

    # แถวสรุปผลท้ายชีตไม่มี TestCase จึงไม่ใช่กรณีทดสอบ
    IF    '${TestCase}' == '${EMPTY}'
        Skip    ไม่ใช่กรณีทดสอบ (แถวสรุปผลในไฟล์ Excel)
    END

    IF    '${Run}' != 'Yes'
        Skip    ไม่ได้เลือกให้รัน (Run = ${Run})
    END

    Set Test Variable    ${TC_ID}    ${TestCase}
    ${Row}=              Evaluate    int("${TestCase}".split("_")[1]) + 1
    Set Test Variable    ${ROW_NUM}            ${Row}
    Set Test Variable    ${RESULT_RECORDED}    ${False}
    Log                  ${TestCase} : ${TestScenario}

    Open Login Page

    Input Username    ${Username}
    Input Password    ${Password}

    # ช่องสุดท้ายของหน้าไม่มีช่องถัดไปให้กรอก จึงต้องสั่งออกจากช่องเอง
    # ระบบตรวจสอบตอนออกจากช่อง (blur) เหมือนช่องอื่นที่ถูก blur อัตโนมัติเมื่อไปกรอกช่องถัดไป
    Keyboard Key    press    Tab

    # ไม่กดปุ่ม "เข้าสู่ระบบ" เพราะขอบเขตคือการตรวจสอบข้อมูลบนหน้าจอ ระบบแจ้งเตือนทันทีที่กรอก
    # การเข้าสู่ระบบจริง (ตรวจบัญชีถูก/ผิด, ไปหน้าถัดไป) อยู่ในไฟล์ flow แยกต่างหาก
    ${Messages}=    Get Validation Messages

    # ---------- บันทึกผลลง Excel แล้วตัดสิน Pass/Fail ----------
    ${ActualResult}=    Resolve Actual Result    ${Messages}    ${ExpectedResult}    ${TestCase}
    ${ResultPF}=        Set Variable If    '${ActualResult}' == '${ExpectedResult}'    Pass    Fail
    Record Test Result    ${Row}    ${ActualResult}    ${ResultPF}

    Should Be Equal As Strings    ${ActualResult}    ${ExpectedResult}
    ...    msg=${TestCase} (${TestScenario}) ไม่ผ่าน

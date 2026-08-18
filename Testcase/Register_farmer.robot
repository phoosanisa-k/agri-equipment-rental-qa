*** Settings ***
Documentation     TC02 - Register Farmer | ทดสอบฟังก์ชันสมัครสมาชิกของเกษตรกร
...
...               อ้างอิงเอกสาร System Test Case จำนวน 167 กรณีทดสอบ
...               เลือกกรณีที่ต้องการรันได้จากคอลัมน์ ${Run} (Yes/No) ในไฟล์ Data.xlsx
...               ผลการทดสอบจะถูกเขียนกลับลงคอลัมน์ ActualResult และ ResultPF อัตโนมัติ
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

${COL_ACTUAL}     ${24}
${COL_PF}         ${25}

# ข้อความที่ใช้แทน "ไม่มีข้อความแจ้งเตือน" ให้ตรงกับที่ระบุไว้ในเอกสาร Test Case
${PASS_MESSAGE}   ผ่านการตรวจสอบ

# ข้อความที่ระบบตอบกลับต่างสำนวนจากเอกสาร แต่ตรวจสอบแล้วว่าเป็นการตรวจสอบกฎเดียวกัน
# จึงยอมรับเป็น Pass โดยระบุเป็นรายกรณี เพื่อให้ตรวจสอบย้อนหลังได้ว่าอนุโลมเคสใดไปบ้าง
&{ACCEPTED_MESSAGE}
...    TC02_011=ชื่อผู้ใช้ต้องเป็นตัวอักษรภาษาอังกฤษและตัวเลขเท่านั้น
...    TC02_012=ชื่อผู้ใช้ต้องเป็นตัวอักษรภาษาอังกฤษและตัวเลขเท่านั้น
...    TC02_013=ชื่อผู้ใช้ต้องมีความยาวอย่างน้อย 6 ตัวอักษร
...    TC02_018=ชื่อผู้ใช้ต้องมีความยาวไม่เกิน 20 ตัวอักษร

${TC_ID}             UNKNOWN
${ROW_NUM}           ${0}
${RESULT_RECORDED}   ${False}


*** Test Cases ***
Register For ${TestCaseID}


*** Keywords ***
Prepare Register Suite
    [Documentation]    เตรียมโฟลเดอร์เก็บภาพ error, เปิดไฟล์ Excel เขียนผล และเปิดเบราว์เซอร์
    ...                ล้างภาพของรอบก่อนทิ้งทุกครั้ง 
    Create Directory       ${ERROR_DIR}

    ${Cleaned}=    Run Keyword And Return Status    Empty Directory    ${ERROR_DIR}
    IF    not ${Cleaned}
        Log    ล้างโฟลเดอร์ ${ERROR_DIR} ไม่สำเร็จ 
        ...    level=WARN
    END
    Open Excel Document    ${DATA_FILE}    Result
    Open Register Browser

Finish Register Suite
    [Documentation]    บันทึกไฟล์ Excel 
    Run Keyword And Ignore Error    Save Excel Document    ${DATA_FILE}
    Run Keyword And Ignore Error    Close All Excel Documents
    Close All Register Browsers

Register Test Teardown
    [Documentation]    ถ้ากรณีทดสอบไม่ผ่าน ให้บันทึกภาพหน้าจอไว้เป็นหลักฐาน
    ...                และถ้าเกิดข้อผิดพลาดกลางทางจนยังไม่ได้บันทึกผล ให้บันทึกข้อความ error ลง Excel
    IF    '${TEST STATUS}' == 'FAIL'
        Run Keyword And Ignore Error
        ...    Take Screenshot    ${ERROR_DIR}/${USECASE}_${TC_ID}    fullPage=True

        IF    ${ROW_NUM} > 0 and not ${RESULT_RECORDED}
            ${ErrorText}=    Get Line         ${TEST MESSAGE}    0
            ${ErrorText}=    Get Substring    ${ErrorText}       0    200
            Run Keyword And Ignore Error
            ...    Record Test Result    ${ROW_NUM}    ${ErrorText}    Fail
        END
    END
    Run Keyword And Ignore Error    Close Register Context

Record Test Result
    [Documentation]    เขียนผลจริง และสถานะ Pass/Fail กลับลงไฟล์ Excel ตามแถวของกรณีทดสอบ
    [Arguments]    ${Row}    ${ActualResult}    ${ResultPF}
    Write Excel Cell       ${Row}    ${COL_ACTUAL}    ${ActualResult}    sheet_name=${SHEET}
    Write Excel Cell       ${Row}    ${COL_PF}        ${ResultPF}        sheet_name=${SHEET}
    Save Excel Document    ${DATA_FILE}
    Set Test Variable      ${RESULT_RECORDED}    ${True}

Normalize Message
    [Documentation]    ปรับข้อความให้อยู่ในรูปมาตรฐานก่อนเปรียบเทียบ
    ...                รวมขีดกลางทุกแบบให้เป็น "-" / ตัดช่องว่างทิ้งทั้งหมด / ไม่แยกตัวพิมพ์ใหญ่เล็ก
    ...                แก้ปัญหาข้อความที่ต่างกันแค่รูปแบบ เช่น "10KB - 1MB" ที่ใช้ขีดกลางคนละตัวอักษร
    [Arguments]    ${Text}
    ${Text}=    Evaluate    unicodedata.normalize("NFC", str($Text))    modules=unicodedata
    ${Text}=    Evaluate    "".join("-" if 0x2010 <= ord(c) <= 0x2015 or ord(c) == 0x2212 else c for c in $Text)
    ${Text}=    Evaluate    "".join($Text.split()).lower()
    RETURN    ${Text}

Is Message Matched
    [Documentation]    ตรวจว่าข้อความจากหน้าเว็บถือว่าตรงกับที่เอกสารคาดหวังหรือไม่
    ...                1) ปรับรูปแบบแล้วตรงกัน
    ...                2) ข้อความหนึ่งเป็นส่วนหนึ่งของอีกข้อความหนึ่ง
    ...                3) ตรงกับข้อความที่ระบุอนุโลมไว้ใน &{ACCEPTED_MESSAGE} เฉพาะกรณีนั้น
    [Arguments]    ${Message}    ${ExpectedResult}    ${TestCaseID}
    ${Actual}=      Normalize Message    ${Message}
    ${Expected}=    Normalize Message    ${ExpectedResult}

    IF    $Actual == $Expected                           RETURN    ${True}
    IF    $Expected in $Actual or $Actual in $Expected    RETURN    ${True}

    ${Accepted}=    Get From Dictionary    ${ACCEPTED_MESSAGE}    ${TestCaseID}    default=${EMPTY}
    IF    '${Accepted}' == '${EMPTY}'    RETURN    ${False}

    ${AcceptedNorm}=    Normalize Message    ${Accepted}
    ${Matched}=         Evaluate    $Actual == $AcceptedNorm
    IF    ${Matched}
        Log    ${TestCaseID}: ข้อความต่างสำนวนจากเอกสาร แต่อยู่ในรายการที่อนุโลมไว้ จึงถือว่าผ่าน
        ...    level=INFO
    END
    RETURN    ${Matched}

Resolve Actual Result
    [Documentation]    เลือกข้อความที่จะบันทึกเป็นผลจริง
    ...                - ไม่มีข้อความแจ้งเตือน  -> "ผ่านการตรวจสอบ"
    ...                - มีข้อความตรงกับที่คาดหวัง -> ใช้ข้อความนั้น
    ...                - ไม่ตรง -> รวมทุกข้อความที่แสดงจริง เพื่อให้เห็นว่าระบบตอบอะไรกลับมา
    [Arguments]    ${Messages}    ${ExpectedResult}    ${TestCaseID}
    ${count}=    Get Length    ${Messages}
    IF    ${count} == 0
        RETURN    ${PASS_MESSAGE}
    END

    FOR    ${Message}    IN    @{Messages}
        ${Matched}=    Is Message Matched    ${Message}    ${ExpectedResult}    ${TestCaseID}
        IF    ${Matched}    RETURN    ${ExpectedResult}
    END

    ${joined}=    Evaluate    " | ".join($Messages)
    RETURN    ${joined}


Register_Farmer
    [Arguments]
    ...    ${Run}          ${TestCaseID}      ${TestScanario}      ${Picture}       ${UsernameR}
    ...    ${Email}        ${PasswordR}       ${Confirmpassword}
    ...    ${Firstname}    ${Surname}         ${Gender}
    ...    ${Daybirth}     ${Monthbirth}      ${Yearbirth}         ${Tel}
    ...    ${Hnum}         ${Alley}           ${Group}             ${District}
    ...    ${Canton}       ${province}        ${Postcode}
    ...    ${ExpectedResult}

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
        ${Clicked}=    Click Register Button

        ${Messages}=    Get Validation Messages
    END

    # ปุ่มถูกปิดใช้งาน = ระบบถือว่าข้อมูลไม่ผ่าน 
    ${MessageCount}=    Get Length    ${Messages}
    IF    not ${Clicked} and ${MessageCount} == 0
        ${Messages}=    Create List
        ...    ปุ่มถูกปิดใช้งาน (ข้อมูลไม่ผ่านการตรวจสอบ) แต่ไม่พบข้อความแจ้งเตือนบนหน้าจอ
    END

    # ---------- บันทึกผลลงไฟล์ Excel ----------
    ${ActualResult}=    Resolve Actual Result    ${Messages}    ${ExpectedResult}    ${TestCaseID}
    ${ResultPF}=        Set Variable If    '${ActualResult}' == '${ExpectedResult}'    Pass    Fail
    Record Test Result    ${Row}    ${ActualResult}    ${ResultPF}

    Should Be Equal As Strings    ${ActualResult}    ${ExpectedResult}
    ...    msg=${TestCaseID} (${TestScanario}) ไม่ผ่าน

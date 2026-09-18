*** Settings ***
Documentation     TC03 - Add Equipment Owner | ทดสอบยูสเคส "เพิ่มอุปกรณ์" ของเจ้าของอุปกรณ์
...
...               ครอบคลุมกรณีทดสอบ TC03_01 - TC03_73 ตามตาราง TD01 - TD07 ในเอกสาร
...               แบ่งตามฟิลด์ที่ทดสอบ 7 ฟิลด์ คือ
...                 TC03_01 - TC03_12  ชื่ออุปกรณ์   (2 - 100 ตัวอักษร)
...                 TC03_13 - TC03_24  รายละเอียด    (2 - 500 ตัวอักษร)
...                 TC03_25 - TC03_38  ราคาเช่า      (ตัวเลข 500 - 100000)
...                 TC03_39 - TC03_42  สถานะ         (dropdown 3 ค่า ห้ามว่าง)
...                 TC03_43 - TC03_53  คุณสมบัติ     (2 - 500 ตัวอักษร)
...                 TC03_54 - TC03_64  ที่อยู่อุปกรณ์ (2 - 255 ตัวอักษร)
...                 TC03_65 - TC03_73  รูปอุปกรณ์    (jpg/jpeg/png ขนาด 10KB - 5MB)
...
...               ยูสเคสนี้ต้องเข้าสู่ระบบเป็น Owner ก่อน (Inter-Case Dependency กับ TC01 และ TC02)
...               จึงเข้าสู่ระบบครั้งเดียวตอนเปิดชุดทดสอบ แล้วใช้ session เดิมตลอดทั้งชุด
...
...               เลือกกรณีที่รันจากคอลัมน์ ${Run} (Yes/No) ใน Data.xlsx และเขียนผลกลับลง ActualResult / Result
...               หมายเหตุ : สคริปต์กดปุ่ม "บันทึก" จริง กรณีที่ข้อมูลถูกต้องจึงสร้างอุปกรณ์จริงในฐานข้อมูลทดสอบ
Metadata          System      ระบบเว็บศูนย์กลางให้บริการเช่าอุปกรณ์ทางการเกษตร (SRS v7.0)
Metadata          Use Case    TC03 Add Equipment Owner
Metadata          Test Data   TestData/Data.xlsx (sheet: AddEQ_Owner)

Resource          ../Resources/keywords.robot
Library           DataDriver    file=${CURDIR}/../TestData/Data.xlsx    sheet_name=AddEQ_Owner
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
${SHEET}          AddEQ_Owner
${SCREENSHOT_DIR}    ${CURDIR}/../Screenshot
${USECASE}        TC03_AddEQ_Owner

# ---------- ตำแหน่งคอลัมน์ในชีต ----------
${COL_ID}         ${2}     # คอลัมน์ B : ${TestCase}
${COL_ACTUAL}     ${12}    # คอลัมน์ L : ${ActualResult}
${COL_PF}         ${13}    # คอลัมน์ M : ${Result}

# ---------- ข้อความและตัวชี้วัดที่ใช้ตัดสินผล ----------
# ใช้แทนกรณี "ข้อมูลถูกต้อง ไม่มีข้อความแจ้งเตือน" ตามคำที่เอกสาร Test Case ระบุ
${PASS_MESSAGE}       ผ่านการตรวจสอบ
${SUCCESS_KEYWORD}    สำเร็จ
${Popup_Success}      text=${SUCCESS_KEYWORD}
# รอสั้น ๆ เพราะกรณีที่ต้องไม่สำเร็จจะไม่มี popup ขึ้นเลย
${POPUP_TIMEOUT}      5s
${NO_RESPONSE}        ไม่พบข้อความแจ้งเตือน และระบบไม่ได้บันทึกอุปกรณ์ให้

# ---------- รายการอนุโลม : ข้อความต่างสำนวนจากเอกสาร แต่สื่อกฎเดียวกัน ----------
# ใส่รหัสกรณีทดสอบกับข้อความที่ระบบตอบจริง เมื่อผู้ทดสอบพิจารณาแล้วว่ายอมรับได้
# ทุกครั้งที่ใช้ข้อยกเว้นจะมีบรรทัด WARN ใน log.html ให้ตรวจย้อนหลังได้
&{ACCEPTED_MESSAGE}

# % ของคำหลักในเอกสารที่ต้องพบในข้อความของระบบ จึงถือว่าตรงกัน
${WORD_MATCH_THRESHOLD}    ${60}

# คำทั่วไปที่ไม่สื่อความหมายของกฎ ตัดทิ้งก่อนเทียบ
@{STOPWORDS}
...    กรุณา    กรอก    โปรด    ระบุ    ต้อง    เป็น    และ    หรือ    ที่    มี    ไม่    ให้    การ    ของ
...    เท่านั้น    อัปโหลด    ตั้งแต่    ความ    อย่าง    ได้    ใน    กับ    ตัว    นั้น    นี้    จะ
...    ค่า    ระหว่าง    ถึง    เลือก    ประกอบ    ไป    ด้วย    รองรับ    เฉพาะ    ประเภท    /

# ชื่อฟิลด์บนฟอร์ม กันจับคู่ผิดฟิลด์ เช่น "ความยาว 2-500" ของรายละเอียด กับของคุณสมบัติ
@{FIELD_NAMES}
...    ชื่ออุปกรณ์    รายละเอียด    ราคา    สถานะ    คุณสมบัติ    ที่อยู่
...    รูปภาพ    ไฟล์    ขนาด    ความยาว

# ---------- ตัวแปรระดับกรณีทดสอบ ใช้ส่งข้อมูลให้ teardown ----------
${TC_ID}             UNKNOWN
${ROW_NUM}           ${0}
${ACTUAL_MESSAGE}    ${EMPTY}


*** Test Cases ***
Add Equipment Owner : ${TestCase}


*** Keywords ***
# =====================================================================
# 1. การเตรียมและปิดชุดทดสอบ
# =====================================================================

เปิดชุดทดสอบ
    [Documentation]    ล้างภาพของรอบก่อน เปิดไฟล์ Excel เปิดเบราว์เซอร์ แล้วเข้าสู่ระบบเป็น Owner
    ...                เข้าสู่ระบบครั้งเดียวแล้วใช้ session เดิมทั้งชุด เพราะทุกกรณีทดสอบต้องล็อกอินอยู่แล้ว
    Create Directory    ${SCREENSHOT_DIR}
    ลบภาพของรอบก่อน    ${SCREENSHOT_DIR}

    Open Excel Document    ${DATA_FILE}    AddEquipmentOwner
    Open Test Browser
    เข้าสู่ระบบเป็นเจ้าของอุปกรณ์

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

เข้าสู่ระบบเป็นเจ้าของอุปกรณ์
    [Documentation]    เข้าสู่ระบบด้วยบัญชีใน ${OwnerUser} / ${OwnerPass} ของ variables.robot
    ...                ล้มทั้งชุดทันทีเมื่อเข้าไม่ได้ เพราะทุกกรณีทดสอบต้องอยู่ในสถานะเข้าสู่ระบบ
    ${UserLen}=    Get Length    ${OwnerUser}
    ${PassLen}=    Get Length    ${OwnerPass}
    IF    ${UserLen} == 0 or ${PassLen} == 0
        Fail    ยังไม่ได้ตั้งค่าบัญชี Owner กรุณาเติม \${OwnerUser} และ \${OwnerPass} ใน Resources/variables.robot
    END

    Open Login Owner Page
    Input Owner Username    ${OwnerUser}
    Input Owner Password    ${OwnerPass}
    Keyboard Key            press    Tab
    ${Clicked}=    Click Owner Login Button
    Should Be True    ${Clicked}    ปุ่มเข้าสู่ระบบถูกปิดใช้งาน จึงเข้าสู่ระบบไม่ได้

    # popup แจ้งสำเร็จของระบบต้องกด "ตกลง" ก่อน จึงจะเข้าหน้าหลัก
    Run Keyword And Ignore Error
    ...    Wait For Elements State    ${Popup_Success}    visible    ${POPUP_TIMEOUT}
    ${HasButton}=    Is Element Visible    ${Btn_Verify}
    IF    ${HasButton}    Run Keyword And Ignore Error    Click Verify Button

    ${LoggedIn}=    รอให้ออกจากหน้าเข้าสู่ระบบ
    Should Be True    ${LoggedIn}
    ...    msg=เข้าสู่ระบบด้วยบัญชี "${OwnerUser}" ไม่สำเร็จ จึงเริ่มทดสอบการเพิ่มอุปกรณ์ไม่ได้
    Log    เข้าสู่ระบบเป็น Owner "${OwnerUser}" สำเร็จ ใช้ session นี้ตลอดทั้งชุดทดสอบ    level=INFO

รอให้ออกจากหน้าเข้าสู่ระบบ
    [Documentation]    รอจน URL ออกจากหน้าเข้าสู่ระบบ คืน True เมื่อออกแล้ว
    FOR    ${Round}    IN RANGE    20
        ${Url}=     Get Url
        ${Left}=    Evaluate    "login-owner" not in $Url
        IF    ${Left}    RETURN    ${True}
        Sleep    0.5s
    END
    RETURN    ${False}

ปิดชุดทดสอบ
    [Documentation]    บันทึกไฟล์ Excel และปิดทรัพยากรทั้งหมด
    Run Keyword And Ignore Error    เซฟไฟล์ Excel อย่างปลอดภัย
    Run Keyword And Ignore Error    Close All Excel Documents
    Close All Test Browsers

เก็บผลท้ายกรณีทดสอบ
    [Documentation]    เก็บภาพเมื่อไม่ผ่าน แล้วเขียนผลกลับลง Excel
    ...                ไม่ปิด context เหมือนยูสเคสอื่น เพราะต้องรักษาสถานะเข้าสู่ระบบไว้ให้กรณีถัดไป
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

    # ปิดฟอร์มที่ค้างอยู่ ให้กรณีถัดไปเริ่มจากหน้ารายการอุปกรณ์ตามปกติ
    Run Keyword And Ignore Error    Click Cancel Equipment Button


# =====================================================================
# 2. การอ่านและเขียนไฟล์ Excel
# =====================================================================

หาแถวของกรณีทดสอบ
    [Documentation]    ค้นหมายเลขแถวจากรหัสกรณีทดสอบในคอลัมน์ B (index 0 คือหัวตาราง แถวจึงเป็น index + 1)
    ...                คืน 0 เมื่อไม่พบ เพื่อให้ teardown ข้ามการเขียนผลแทนที่จะล้ม
    [Arguments]    ${TestCase}
    ${Ids}=    Read Excel Column    ${COL_ID}    sheet_name=${SHEET}
    ${Ids}=    Evaluate    ["" if v is None else str(v).strip() for v in $Ids]

    ${Found}=    Run Keyword And Return Status    List Should Contain Value    ${Ids}    ${TestCase}
    IF    not ${Found}
        Log    ไม่พบ ${TestCase} ในคอลัมน์ B ของชีต ${SHEET} จึงไม่เขียนผลกลับ    level=WARN
        RETURN    ${0}
    END

    ${Index}=    Get Index From List    ${Ids}    ${TestCase}
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
    [Documentation]    กรอกฟอร์มเพิ่มอุปกรณ์ครบทุกช่อง กดปุ่ม "บันทึก" จริง
    ...                แล้วตัดสินผลจากข้อความที่ระบบแจ้ง คู่กับว่าระบบยอมบันทึกให้หรือไม่
    [Arguments]
    ...    ${Run}                ${TestCase}           ${TestScenario}
    ...    ${EquipmentName}      ${EquipmentDetail}    ${Price}       ${Status}
    ...    ${EquipmentFeature}   ${EquipmentAddress}   ${EquipmentImage}
    ...    ${ExpectedResult}

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

    ${Data}=    Create Dictionary
    ...    EquipmentName=${EquipmentName}          EquipmentDetail=${EquipmentDetail}
    ...    Price=${Price}                          Status=${Status}
    ...    EquipmentFeature=${EquipmentFeature}    EquipmentAddress=${EquipmentAddress}
    ...    EquipmentImage=${EquipmentImage}
    ${Data}=    ปรับค่าจาก Excel ให้เป็นข้อความ    ${Data}
    Log    ${TestCase} : ${TestScenario} | ข้อมูลที่ใช้ทดสอบ ${Data}    level=INFO

    ตรวจข้อความแจ้งเตือนรายฟิลด์    ${Data}    ${ExpectedResult}

ปรับค่าจาก Excel ให้เป็นข้อความ
    [Documentation]    ช่องตัวเลขใน Excel อาจถูกอ่านมาเป็น 700.0 ทำให้กรอกลงฟอร์มผิดจากที่เอกสารกำหนด
    ...                จึงตัด .0 ท้ายออก และเปลี่ยนช่องว่างเป็นข้อความว่าง
    [Arguments]    ${Data}
    ${Keys}=    Get Dictionary Keys    ${Data}
    FOR    ${Key}    IN    @{Keys}
        ${Value}=    Get From Dictionary    ${Data}    ${Key}
        ${Value}=    Evaluate
        ...    "" if $Value is None else (str(int($Value)) if isinstance($Value, float) and $Value.is_integer() else str($Value))
        Set To Dictionary    ${Data}    ${Key}=${Value}
    END
    RETURN    ${Data}


# =====================================================================
# 4. การทดสอบรายฟิลด์ (TC03_01 - TC03_73)
# =====================================================================

ตรวจข้อความแจ้งเตือนรายฟิลด์
    [Documentation]    กรอกฟอร์มครบทุกช่องแล้วกดปุ่ม "บันทึก" จริง
    ...                ตัดสินผลจากสองอย่างคู่กัน คือข้อความที่ระบบแจ้ง และระบบยอมบันทึกให้หรือไม่
    [Arguments]    ${Data}    ${ExpectedResult}

    Open Add Equipment Page
    กรอกข้อมูลอุปกรณ์    ${Data}

    ${Clicked}=     Click Save Equipment Button
    ${Messages}=    Get Validation Messages
    ${Saved}=       Set Variable    ${EMPTY}
    ${Blocked}=     Set Variable    ${EMPTY}

    IF    ${Clicked}
        ${Saved}=    รอผลการบันทึก
    ELSE
        ${Blocked}=    Set Variable    ปุ่ม "บันทึก" ถูกปิดใช้งาน ระบบไม่ให้เพิ่มอุปกรณ์
        Log    ${Blocked}    level=INFO
    END

    ${ActualResult}=    สรุปผลที่ได้จริง          ${Messages}    ${Saved}    ${Blocked}
    ${Matched}=         ผลตรงกับที่เอกสารกำหนด    ${Messages}    ${Saved}    ${ExpectedResult}

    บันทึกผลที่ได้จริง    ${ActualResult}
    Should Be True    ${Matched}
    ...    msg=${TC_ID} : ระบบตอบว่า "${ActualResult}" แต่เอกสารกำหนดไว้ว่า "${ExpectedResult}"

กรอกข้อมูลอุปกรณ์
    [Documentation]    กรอกทั้ง 7 ช่องตามลำดับบนหน้าจอ กรอกทุกช่องแม้ค่าว่างเพื่อให้ระบบตรวจสอบช่องนั้น
    [Arguments]    ${Data}
    Input Equipment Name       ${Data}[EquipmentName]
    Input Equipment Detail     ${Data}[EquipmentDetail]
    Input Equipment Price      ${Data}[Price]
    Select Equipment Status    ${Data}[Status]
    Input Equipment Feature    ${Data}[EquipmentFeature]
    Input Equipment Address    ${Data}[EquipmentAddress]
    Upload Equipment Picture   ${Data}[EquipmentImage]

    # ช่องสุดท้ายไม่มีช่องถัดไปมา blur ให้ ต้อง Tab ออกเองระบบจึงจะตรวจสอบ
    Keyboard Key    press    Tab

รอผลการบันทึก
    [Documentation]    รอ popup แจ้งบันทึกสำเร็จสั้น ๆ คืนข้อความบน popup ถ้าไม่พบให้คืนข้อความว่าง
    ...                ถ้าไม่มี popup แต่ฟอร์มปิดลง ถือว่าระบบบันทึกให้แล้วเช่นกัน
    ${Success}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Popup_Success}    visible    ${POPUP_TIMEOUT}

    IF    ${Success}
        ${Text}=    Get Text        ${Popup_Success}
        ${Text}=    Strip String    ${Text}
        RETURN    ${Text}
    END

    ${FormOpen}=    Is Equipment Form Displayed
    IF    not ${FormOpen}    RETURN    ระบบบันทึกอุปกรณ์สำเร็จ (ฟอร์มปิดลงโดยไม่มีข้อความแจ้งเตือน)
    RETURN    ${EMPTY}

สรุปผลที่ได้จริง
    [Documentation]    ข้อความที่จะบันทึกลงคอลัมน์ ActualResult คือสิ่งที่ระบบตอบมาจริง เรียงตามลำดับ
    ...                บันทึกสำเร็จ         -> ข้อความบน popup
    ...                มีข้อความแจ้งเตือน    -> รวมทุกข้อความที่พบ
    ...                ไม่มีข้อความ          -> ระบุว่าระบบกันไว้ตรงไหน เช่น ปุ่มถูกปิดใช้งานโดยไม่แจ้งเหตุผล
    [Arguments]    ${Messages}    ${Saved}    ${Blocked}
    ${SavedLen}=    Get Length    ${Saved}
    IF    ${SavedLen} > 0    RETURN    ${Saved}

    ${Count}=    Get Length    ${Messages}
    IF    ${Count} > 0
        ${Joined}=    Evaluate    " | ".join($Messages)
        RETURN    ${Joined}
    END

    ${BlockedLen}=    Get Length    ${Blocked}
    IF    ${BlockedLen} == 0    RETURN    ${NO_RESPONSE}
    RETURN    ${Blocked} (ไม่มีข้อความแจ้งเตือน)

ผลตรงกับที่เอกสารกำหนด
    [Documentation]    เอกสารระบุ "ผ่านการตรวจสอบ" -> ต้องไม่มีข้อความแจ้งเตือน และระบบต้องบันทึกให้สำเร็จ
    ...                เอกสารระบุข้อความแจ้งเตือน   -> ระบบต้องไม่บันทึกให้ และข้อความต้องตรงกับเอกสาร
    [Arguments]    ${Messages}    ${Saved}    ${ExpectedResult}
    ${Count}=       Get Length    ${Messages}
    ${SavedLen}=    Get Length    ${Saved}

    ${ExpNorm}=     Normalize Message    ${ExpectedResult}
    ${PassNorm}=    Normalize Message    ${PASS_MESSAGE}
    ${WantPass}=    Evaluate    $ExpNorm == $PassNorm

    IF    ${WantPass}
        ${Ok}=    Evaluate    ${Count} == 0 and ${SavedLen} > 0
        IF    not ${Ok}
            Log    ข้อมูลถูกต้องตามเอกสาร แต่ระบบไม่ได้บันทึกอุปกรณ์ให้ (ข้อความแจ้งเตือน ${Count} รายการ)    level=WARN
        END
        RETURN    ${Ok}
    END

    IF    ${SavedLen} > 0
        Log    ระบบบันทึกอุปกรณ์สำเร็จ ทั้งที่เอกสารกำหนดว่าต้องแจ้งเตือน "${ExpectedResult}"    level=WARN
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

Normalize Message
    [Documentation]    ปรับข้อความเป็นรูปมาตรฐาน รวมขีดกลางทุกแบบ ตัดช่องว่าง ไม่แยกตัวพิมพ์
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
    [Documentation]    ตัดสินว่าข้อความตรงกับเอกสารไหม ตามลำดับ ตรงตัว > เป็นส่วนของกัน > รายการอนุโลม > ระดับคำ
    [Arguments]    ${Message}    ${ExpectedResult}    ${TestCase}
    ${Actual}=      Normalize Message    ${Message}
    ${Expected}=    Normalize Message    ${ExpectedResult}

    IF    $Actual == $Expected                           RETURN    ${True}
    IF    $Expected in $Actual or $Actual in $Expected    RETURN    ${True}

    ${Accepted}=    Get From Dictionary    ${ACCEPTED_MESSAGE}    ${TestCase}    default=${EMPTY}
    IF    '${Accepted}' == '${EMPTY}'
        ${ByWords}=    Is Message Matched By Words    ${Message}    ${ExpectedResult}
        IF    ${ByWords}    Log    ${TestCase} : ต่างสำนวนแต่คำหลักตรงและเป็นฟิลด์เดียวกัน    level=INFO
        RETURN    ${ByWords}
    END

    ${AcceptedNorm}=    Normalize Message    ${Accepted}
    ${Matched}=         Evaluate    $Actual == $AcceptedNorm
    IF    ${Matched}    Log    ${TestCase} : ต่างสำนวน แต่อยู่ในรายการที่อนุโลมไว้    level=WARN
    RETURN    ${Matched}


# =====================================================================
# 6. คีย์เวิร์ดช่วยเหลือ : บันทึกผลและเก็บหลักฐาน
# =====================================================================

บันทึกผลที่ได้จริง
    [Documentation]    จำข้อความที่ระบบตอบกลับไว้ ให้ teardown เขียนลงคอลัมน์ ActualResult
    [Arguments]    ${Text}
    Set Test Variable    ${ACTUAL_MESSAGE}    ${Text}

เก็บภาพหลักฐาน
    [Documentation]    บันทึกภาพหน้าจอไว้เป็นหลักฐานประกอบรายงาน ตั้งชื่อเป็น <ยูสเคส>_<รหัส>_<คำอธิบาย>
    [Arguments]    ${Name}
    Run Keyword And Ignore Error
    ...    Take Screenshot    ${SCREENSHOT_DIR}/${USECASE}_${TC_ID}_${Name}    fullPage=True

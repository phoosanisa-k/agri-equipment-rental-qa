*** Settings ***
Documentation     TC03 - Add Equipment Owner (Usecase) | อ้างอิงหัวข้อ 8.3.3 (Basic Flow 1-7, Alternate Flow 3.1)
...               แยกจาก Testcase/AddEQ_owner.robot (ตรวจข้อความแจ้งเตือนรายฟิลด์จาก Excel); ไฟล์นี้ทดสอบ Flow จริง ใช้ข้อมูลคงที่
...               Pre-Condition (8.3.2): login เป็น Owner ก่อน (login ครั้งเดียว ใช้ session เดิมทั้งชุด, ${OwnerUser}/${OwnerPass})
...
...               TC03_F01→Basic Flow1-7(เพิ่มอุปกรณ์) | F02→Basic Flow5.1,6(ยืนยันบันทึกลง DB) | F03→AB3.1(ข้อมูลว่าง)
...               F04→AB3.1(ราคาต่ำกว่าเกณฑ์) | F05→AB3.1(ไม่เลือกประเภท ห้ามเข้าฟอร์ม)
...               หมายเหตุ: F01 บันทึกจริงลง DB ทดสอบ ชื่ออุปกรณ์ต่อท้ายด้วยเลขเวลาให้ไม่ซ้ำ เพื่อให้ F02 อ้างอิงได้
Metadata          Use Case    TC03 Add Equipment Owner (Functional Flow)

Resource          ../Resources/keywords.robot
Library           OperatingSystem
Library           String
Library           Collections

Suite Setup       เปิดชุดทดสอบ
Suite Teardown    ปิดชุดทดสอบ
Test Teardown     เก็บผลท้ายกรณีทดสอบ    Click Cancel Equipment Button

*** Variables ***
# ---------- ไฟล์และโฟลเดอร์ ----------
${USECASE}             TC03_Usecase_AddEQ_Owner
${SCREENSHOT_DIR}      ${CURDIR}/../Screenshot/${USECASE}

# ---------- ข้อความที่คาดหวังตามเอกสารเทสเคส (เทียบตรงกัน 100%) ----------
${EXP_LOGIN_SUCCESS}    เข้าสู่ระบบสำเร็จ                                   # AE01-01
${EXP_ADD_SUCCESS}      เพิ่มอุปกรณ์สำเร็จ                                  # AE01-05
# AE03-03 : ข้อความแจ้งเตือนภาษาไทยตามเอกสาร dev ทั้ง 7 ช่อง เรียงตามลำดับช่อง (ชื่อ รายละเอียด ราคา สถานะ คุณสมบัติ ที่อยู่ รูป)
${EXP_EMPTY_FORM}       กรุณากรอกชื่ออุปกรณ์ | กรุณากรอกรายละเอียดของอุปกรณ์ | กรุณากรอกราคา | กรุณาเลือกสถานะ | กรุณากรอกคุณสมบัติของอุปกรณ์ | กรุณากรอกที่อยู่ | กรุณาอัปโหลดรูปภาพอุปกรณ์
# AE04-04 : ข้อความแจ้งเตือนใต้ช่องราคา
${EXP_PRICE_TOO_LOW}    ราคาเช่าอุปกรณ์ต้องไม่น้อยกว่า 500 บาท
${EXP_NO_TYPE_HINT}     กรุณาเลือกประเภทอุปกรณ์ก่อนเพิ่มอุปกรณ์               # AE05-03 (คำอธิบายบนปุ่มที่ถูกปิดใช้งาน)

# กล่องแจ้งผลการบันทึก (toast) หายเองภายใน 2.5 วินาที ต้องอ่านทันทีหลังกดบันทึก (locator เดียวกับ Testcase/AddEQ_owner.robot)
${Toast_Text}          //div[@role='status' and contains(@class,'fixed')]//div[contains(@class,'text-sm')]
# รอสั้น ๆ เพราะกรณีที่ต้องไม่สำเร็จจะไม่มี popup ขึ้นเลย
${POPUP_TIMEOUT}       5s

# ---------- ข้อมูลอุปกรณ์ที่ถูกต้องครบถ้วนทั้ง 7 ฟิลด์ ----------
# เกณฑ์รายฟิลด์ (ความยาว ช่วงราคา ชนิดไฟล์) ถูกทดสอบไว้แล้วใน Testcase/AddEQ_owner.robot
# ไฟล์นี้จึงใช้ค่าที่ผ่านเกณฑ์ทุกข้อ เพื่อให้เหลือแค่การทดสอบ Flow ล้วน ๆ
${EQ_NAME_PREFIX}      รถไถเดินตามทดสอบยูสเคส
# ประเภทต้องตรงกับอุปกรณ์ ระบบจึงจะเปิดปุ่ม "บันทึก" ให้ และต้องเป็นค่าที่มีใน dropdown ของระบบเท่านั้น
${EQ_TYPE}             รถไถเดินตาม
${EQ_DETAIL}           รถไถเดินตามขนาดเล็ก เหมาะกับแปลงนาขนาด 1-5 ไร่ เครื่องยนต์ดีเซล พร้อมใบมีดไถ 2 ใบ
${EQ_PRICE}            1500
${EQ_STATUS}           พร้อมให้เช่า
${EQ_FEATURE}          เครื่องยนต์ดีเซล 8 แรงม้า ใบมีดไถ 2 ใบ ถังน้ำมันความจุ 3.5 ลิตร น้ำหนัก 120 กิโลกรัม
${EQ_ADDRESS}          88 หมู่ 5 ตำบลหนองหาร อำเภอสันทราย จังหวัดเชียงใหม่ 50290
${EQ_PICTURE}          walkingtractor.jpg

# ราคาต่ำกว่าขั้นต่ำที่เอกสารกำหนด (500) ใช้แทนกรณี "ข้อมูลไม่ถูกต้อง" ของ Alternate Flow 3.1
${EQ_PRICE_TOO_LOW}    100

# ---------- ตัวแปรระดับชุดทดสอบและกรณีทดสอบ ----------
# ชื่ออุปกรณ์จริงของรอบนี้ ตั้งค่าตอนเปิดชุดทดสอบ ให้ F01 กับ F02 อ้างตัวเดียวกัน
${EQ_NAME}             ${EMPTY}
${TC_ID}               UNKNOWN
${ACTUAL_MESSAGE}      ${EMPTY}

*** Test Cases ***
TC03_F01 - เพิ่มอุปกรณ์ด้วยข้อมูลถูกต้องครบถ้วน
    #TC03-AE01 : กรอกครบทุกช่องตามเงื่อนไข กดบันทึก ต้องได้ "เพิ่มอุปกรณ์สำเร็จ"
    Set Test Variable    ${TC_ID}    TC03_F01
    กรณี TC03_F01

TC03_F02 - อุปกรณ์ที่เพิ่มต้องปรากฏในรายการอุปกรณ์
    #TC03-AE02 : ชื่ออุปกรณ์ที่ F01 เพิ่มต้องปรากฏในหน้ารายการอุปกรณ์ (ต้องรัน F01 ผ่านก่อน)
    Set Test Variable    ${TC_ID}    TC03_F02
    กรณี TC03_F02

TC03_F03 - เว้นว่างทุกช่องแล้วกดบันทึก
    #TC03-AE03 : เว้นว่างทุกช่อง ต้องแสดงข้อความตรงตาม ${EXP_EMPTY_FORM} และไม่บันทึก
    Set Test Variable    ${TC_ID}    TC03_F03
    กรณี TC03_F03

TC03_F04 - กรอกราคาต่ำกว่าเกณฑ์ที่กำหนด
    #TC03-AE04 : ราคาต่ำกว่า 500 ต้องแสดงข้อความตรงตาม ${EXP_PRICE_TOO_LOW} และไม่บันทึก
    Set Test Variable    ${TC_ID}    TC03_F04
    กรณี TC03_F04

TC03_F05 - ไม่เลือกประเภทอุปกรณ์แล้วพยายามเข้าฟอร์ม
    #TC03-AE05 : ไม่เลือกประเภท ปุ่ม "เพิ่มอุปกรณ์" ต้องถูกปิดใช้งาน (คำอธิบาย "กรุณาเลือกประเภทอุปกรณ์ก่อนเพิ่มอุปกรณ์") และฟอร์มไม่เปิด
    Set Test Variable    ${TC_ID}    TC03_F05
    กรณี TC03_F05

*** Keywords ***
# =====================================================================
# 1. การเตรียมและปิดชุดทดสอบ
# =====================================================================

เปิดชุดทดสอบ
    #เตรียมชุดทดสอบ: ล้างภาพเก่า ตั้งชื่ออุปกรณ์ เปิดเบราว์เซอร์ และ login เป็น Owner (ใช้ session เดิมทั้งชุด)
    เตรียมชุดทดสอบยูสเคส

    ${Stamp}=    Get Time    epoch
    ${Suffix}=   Evaluate    str($Stamp)[-6:]
    Set Suite Variable    ${EQ_NAME}    ${EQ_NAME_PREFIX} ${Suffix}
    Log    ชื่ออุปกรณ์ที่ใช้ทดสอบรอบนี้ : ${EQ_NAME}    level=INFO

    เข้าสู่ระบบเป็นเจ้าของอุปกรณ์

เข้าสู่ระบบเป็นเจ้าของอุปกรณ์
    #เข้าสู่ระบบด้วย ${OwnerUser}/${OwnerPass} (Resources/variables.robot) ล้มทั้งชุดทันทีถ้าเข้าไม่ได้
    ${UserLen}=    Get Length    ${OwnerUser}
    ${PassLen}=    Get Length    ${OwnerPass}
    IF    ${UserLen} == 0 or ${PassLen} == 0
        Fail    ยังไม่ได้ตั้งค่าบัญชี Owner กรุณาเติม \${TEST_OWNER_USER} และ \${TEST_OWNER_PASS} ใน Resources/variables.robot
    END

    Open Login Owner Page
    Input Owner Username    ${OwnerUser}
    Input Owner Password    ${OwnerPass}
    Keyboard Key            press    Tab
    ${Clicked}=    Click Owner Login Button
    Should Be True    ${Clicked}    ปุ่มเข้าสู่ระบบถูกปิดใช้งาน จึงเข้าสู่ระบบไม่ได้

    # AE01-01 : หัวข้อ popup ต้องเป็น "เข้าสู่ระบบสำเร็จ"
    # popup ฝั่ง Owner ใช้ปุ่ม "ไปหน้าแรก" ต้องกดปุ่มนี้ระบบจึงจะพาออกจากหน้าเข้าสู่ระบบ
    ${HasPopup}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Popup_Title}    visible    ${POPUP_TIMEOUT}
    ${Title}=    Set Variable    ${EMPTY}
    IF    ${HasPopup}
        ${Title}=    Get Popup Title
    END
    เทียบผลจริงกับที่คาดหวัง    ${Title}    ${EXP_LOGIN_SUCCESS}
    ${HasButton}=    Is Element Visible    ${Btn_OGoHome}
    IF    ${HasButton}    Run Keyword And Ignore Error    Click    ${Btn_OGoHome}

    ${LoggedIn}=    รอให้ออกจากหน้าเข้าสู่ระบบ
    Should Be True    ${LoggedIn}
    ...    msg=เข้าสู่ระบบด้วยบัญชี "${OwnerUser}" ไม่สำเร็จ จึงเริ่มทดสอบการเพิ่มอุปกรณ์ไม่ได้
    Log    เข้าสู่ระบบเป็น Owner "${OwnerUser}" สำเร็จ ใช้ session นี้ตลอดทั้งชุดทดสอบ    level=INFO

รอให้ออกจากหน้าเข้าสู่ระบบ
    #รอจน URL ออกจากหน้าเข้าสู่ระบบ คืน True เมื่อออกแล้ว
    FOR    ${Round}    IN RANGE    20
        ${Url}=     Get Url
        ${Left}=    Evaluate    "login-owner" not in $Url
        IF    ${Left}    RETURN    ${True}
        Sleep    0.5s
    END
    RETURN    ${False}

# =====================================================================
# 2. กรณีทดสอบยูสเคสเพิ่มอุปกรณ์จริง (TC03_F01 ถึง F04)
# =====================================================================

กรณี TC03_F01
    #AE01-04 ถึง AE01-05 : กรอกข้อมูลถูกต้องครบทุกช่องแล้วกดบันทึก ข้อความต้องเป็น "เพิ่มอุปกรณ์สำเร็จ"
    ${Data}=    สร้างข้อมูลอุปกรณ์    ${EQ_PRICE}
    ${Message}=    เพิ่มอุปกรณ์    ${Data}
    บันทึกผลที่ได้จริง    ${Message}
    เทียบผลจริงกับที่คาดหวัง    ${Message}    ${EXP_ADD_SUCCESS}

กรณี TC03_F02
    #AE02-02 ถึง AE02-03 : เปิดหน้ารายการอุปกรณ์ ต้องพบการ์ดที่ชื่อตรงกับชื่อที่ F01 เพิ่ม (เทียบทั้งชื่อ)
    เปิดหน้ารายการอุปกรณ์
    ${Found}=    อุปกรณ์อยู่ในรายการ    ${EQ_NAME}
    ${State}=    Set Variable If    ${Found}    พบ "${EQ_NAME}" ในหน้ารายการอุปกรณ์    ไม่พบ "${EQ_NAME}" ในหน้ารายการอุปกรณ์
    บันทึกผลที่ได้จริง    ${State}
    Should Be True    ${Found}
    ...    msg=ไม่พบอุปกรณ์ "${EQ_NAME}" ในหน้ารายการอุปกรณ์ (หรือ TC03_F01 ไม่ผ่าน)

กรณี TC03_F03
    #AE03-02 ถึง AE03-03 : เลือกประเภทเพื่อเปิดฟอร์ม แล้วเว้นว่างทุกช่องในฟอร์ม กดบันทึก ข้อความต้องตรง ${EXP_EMPTY_FORM}
    #ประเภทต้องเลือกจริง เพราะเป็นเงื่อนไขของหน้ารายการอุปกรณ์ที่จะเปิดฟอร์มให้ ไม่ใช่ช่องในฟอร์ม
    ${Data}=    Create Dictionary
    ...    EquipmentName=${EMPTY}       EquipmentType=${EQ_TYPE}
    ...    EquipmentDetail=${EMPTY}     Price=${EMPTY}
    ...    Status=${EMPTY}              EquipmentFeature=${EMPTY}
    ...    EquipmentAddress=${EMPTY}    EquipmentImage=${EMPTY}
    ${Message}=    เพิ่มอุปกรณ์    ${Data}
    บันทึกผลที่ได้จริง    ${Message}
    เทียบผลจริงกับที่คาดหวัง    ${Message}    ${EXP_EMPTY_FORM}

กรณี TC03_F04
    #AE04-03 ถึง AE04-04 : กรอกครบทุกช่องแต่ราคาต่ำกว่า 500 ข้อความต้องตรง ${EXP_PRICE_TOO_LOW}
    ${Data}=    สร้างข้อมูลอุปกรณ์    ${EQ_PRICE_TOO_LOW}
    ${Message}=    เพิ่มอุปกรณ์    ${Data}
    บันทึกผลที่ได้จริง    ${Message}
    เทียบผลจริงกับที่คาดหวัง    ${Message}    ${EXP_PRICE_TOO_LOW}

กรณี TC03_F05
    #AE05-02 ถึง AE05-03 : ไม่เลือกประเภท ปุ่ม "เพิ่มอุปกรณ์" ต้องถูกปิดใช้งาน คำอธิบายบนปุ่มต้องตรงเอกสาร และฟอร์มต้องไม่เปิด
    #เดินขั้นตอนเอง ไม่ใช้ "Open Add Equipment Page" เพราะคีย์เวิร์ดนั้นบังคับให้ปุ่มกดได้
    Go To                  ${AddEQ_ownerURL}
    Wait For Load State    domcontentloaded    ${DEFAULT_TIMEOUT}
    Select Add Equipment Type    ${EMPTY}

    ${Enabled}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Btn_AddEQ}    enabled    ${SHORT_TIMEOUT}
    ${Hint}=       อ่านคำอธิบายบนปุ่มเพิ่มอุปกรณ์
    ${FormOpen}=   Is Equipment Form Displayed
    บันทึกผลที่ได้จริง    ${Hint}

    Should Not Be True    ${Enabled}
    ...    msg=ระบบเปิดปุ่ม "เพิ่มอุปกรณ์" ให้กดได้ ทั้งที่ยังไม่ได้เลือกประเภทอุปกรณ์
    เทียบผลจริงกับที่คาดหวัง    ${Hint}    ${EXP_NO_TYPE_HINT}
    Should Not Be True    ${FormOpen}
    ...    msg=ฟอร์มเพิ่มอุปกรณ์เปิดขึ้นมา ทั้งที่ยังไม่ได้เลือกประเภทอุปกรณ์

อ่านคำอธิบายบนปุ่มเพิ่มอุปกรณ์
    #อ่าน title ของปุ่ม "เพิ่มอุปกรณ์" (เหตุผลที่ปุ่มถูกปิดใช้งาน) ไม่มีคืนค่าว่าง
    ${Ok}    ${Title}=    Run Keyword And Ignore Error    Get Attribute    ${Btn_AddEQ}    title
    IF    '${Ok}' == 'FAIL' or $Title is None    RETURN    ${EMPTY}
    RETURN    ${Title}

# =====================================================================
# 3. ขั้นตอนย่อยของการเพิ่มอุปกรณ์
# =====================================================================

สร้างข้อมูลอุปกรณ์
    #ประกอบข้อมูลอุปกรณ์ถูกต้องครบทุกช่อง เปลี่ยนได้เฉพาะราคา (ให้ F04 ใช้ชุดเดียวกับ F01 ต่างแค่ราคา)
    [Arguments]    ${Price}
    ${Data}=    Create Dictionary
    ...    EquipmentName=${EQ_NAME}             EquipmentType=${EQ_TYPE}
    ...    EquipmentDetail=${EQ_DETAIL}         Price=${Price}
    ...    Status=${EQ_STATUS}                  EquipmentFeature=${EQ_FEATURE}
    ...    EquipmentAddress=${EQ_ADDRESS}       EquipmentImage=${EQ_PICTURE}
    RETURN    ${Data}

เพิ่มอุปกรณ์
    #เปิดฟอร์ม กรอกครบทุกช่อง กดบันทึกจริง คืนข้อความที่ระบบแสดง (เทียบเฉพาะข้อความภาษาไทยที่เว็บแสดง)
    #อ่าน toast ก่อนเพราะหายเองใน 2.5 วินาที ไม่มี toast จึงอ่านข้อความแจ้งเตือนใต้ช่อง (ภาษาไทยที่เว็บแสดง) คั่นด้วย " | " ไม่มีเลยคืนค่าว่าง
    #ไม่อ่านข้อความภาษาอังกฤษของเบราว์เซอร์ (เช่น Please fill out this field.) เพราะเอกสาร dev ไม่ได้ระบุไว้
    [Arguments]    ${Data}
    Open Add Equipment Page    ${Data}[EquipmentType]
    กรอกข้อมูลอุปกรณ์    ${Data}
    ${Clicked}=    Click Save Equipment Button
    IF    ${Clicked}
        ${Saved}=    รอผลการบันทึก
        IF    $Saved != ''    RETURN    ${Saved}
    END
    ${Messages}=    Get Validation Messages
    ${Text}=        Evaluate    " | ".join($Messages)
    RETURN    ${Text}

กรอกข้อมูลอุปกรณ์
    #กรอกครบ 7 ช่องตามลำดับ (แม้ค่าว่าง) ประเภทอุปกรณ์เลือกไว้แล้วตอนเปิดฟอร์มใน "Open Add Equipment Page"
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
    #รอกล่องแจ้งผลการบันทึก (${Toast_Text}) คืนข้อความที่อ่านได้ ไม่มีกล่องหรืออ่านไม่ทันคืนค่าว่าง
    ${Shown}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Toast_Text}    visible    ${POPUP_TIMEOUT}
    IF    not ${Shown}    RETURN    ${EMPTY}
    Set Browser Timeout    ${SHORT_TIMEOUT}
    ${Ok}    ${Text}=    Run Keyword And Ignore Error    Get Text    ${Toast_Text}
    Set Browser Timeout    ${DEFAULT_TIMEOUT}
    IF    '${Ok}' == 'FAIL'    RETURN    ${EMPTY}
    ${Text}=    Strip String    ${Text}
    RETURN    ${Text}

เปิดหน้ารายการอุปกรณ์
    #เปิดหน้ารายการอุปกรณ์ (ใช้ Go To ไม่ใช่ New Context เพื่อรักษา session ที่ login ไว้)
    Run Keyword And Ignore Error    Click Cancel Equipment Button
    Go To                  ${AddEQ_ownerURL}
    Wait For Load State    domcontentloaded    ${DEFAULT_TIMEOUT}
    # หน้านี้ดึงรายการอุปกรณ์มาแสดงหลังโหลดหน้าเสร็จ จึงรอสั้น ๆ ก่อนเริ่มอ่านข้อความบนหน้า
    Sleep    1s

อุปกรณ์อยู่ในรายการ
    #ตรวจว่ามี element ที่ข้อความตรงกับชื่ออุปกรณ์ทั้งชื่อ (ไม่ใช่การหาคำบางส่วนในหน้า)
    [Arguments]    ${Name}
    ${Count}=    Get Element Count    xpath=//*[normalize-space(text())='${Name}']
    ${Found}=    Evaluate    ${Count} > 0
    RETURN    ${Found}

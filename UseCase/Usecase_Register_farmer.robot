*** Settings ***
Documentation     TC02 - Register Farmer (Usecase) | ทดสอบยูสเคสสมัครสมาชิกระดับ Flow ตาม TESTDESIGN 7.2.5.17 ครอบคลุม Basic Flow (RF01-02/03) และ Alternate/Exception Flow
...               ใช้ข้อมูลคงที่ตามเอกสาร เทียบข้อความที่ระบบแสดงกับเอกสารแบบตรงกัน 100% (TC02_F00 สร้างบัญชีตั้งต้นให้ F02/F03/F07)
...               ตัดออก: TC02_F04 (อีเมลผิดรูปแบบ ซ้ำกับ TC02_024) และ TC02_F08 (ปุ่มย้อนกลับ เป็น UI state ไม่ใช่พฤติกรรมยูสเคส)
Metadata          Use Case    TC02 Register Farmer (Basic Flow + Alternate/Exception Flow)

Resource          ../Resources/keywords.robot
Library           OperatingSystem
Library           String
Library           Collections

Suite Setup       เตรียมชุดทดสอบยูสเคส
Suite Teardown    ปิดชุดทดสอบ
Test Teardown     เก็บผลท้ายกรณีทดสอบ

*** Variables ***
# ---------- ไฟล์และโฟลเดอร์ ----------
${USECASE}            TC02_Usecase_Register_Farmer
${SCREENSHOT_DIR}     ${CURDIR}/../Screenshot/${USECASE}

# ---------- ข้อความที่คาดหวังตามเอกสารเทสเคส (เทียบตรงกัน 100%) ----------
${EXP_REGISTER_SUCCESS}    สมัครสมาชิกสำเร็จ!                                     # RF01-05 / F00
${EXP_LOGIN_SUCCESS}       เข้าสู่ระบบสำเร็จ                                      # RF01-06
${EXP_DUP_USERNAME}        Username นี้ไม่สามารถใช้งานได้                          # RF02-03
${EXP_DUP_EMAIL}           Email นี้ไม่สามารถใช้งานได้                             # RF03-03
${EXP_DUP_TEL}             เบอร์โทรศัพท์นี้ไม่สามารถใช้งานได้                       # RF06-03
${EXP_EMPTY_STEP1}         กรุณากรอกชื่อผู้ใช้ | กรุณากรอกอีเมล | กรุณากรอกรหัสผ่าน    # RF04-02 (ข้อความแดงใต้ช่อง เรียงตามลำดับช่อง)
# รอสั้น ๆ เพราะกรณีที่ต้องไม่สำเร็จจะไม่มี popup ขึ้นเลย
${POPUP_TIMEOUT}      5s

# ---------- โปรไฟล์กลาง : ข้อมูลส่วนตัว/ที่อยู่ที่ใช้ร่วมทุกบัญชี (ไม่มีผลต่อสิ่งที่แต่ละเคสทดสอบ จึงคงที่ได้) ----------
${REG_PASSWORD}    PK01010101
&{DATA_PROFILE}
...    Firstname=ภูษณิศา    Surname=คำมา ศรีสุข    Gender=หญิง
...    Daybirth=15    Monthbirth=8    Yearbirth=2540
...    Hnum=99/1    Alley=สุขสวัสดิ์ 20    Group=หมู่ 3
...    District=บางบอน    Canton=บางบอน    Province=กรุงเทพมหานคร    Postcode=10150

# ---------- บัญชีคงที่เฉพาะจุดที่แต่ละเคสต้องต่างกัน (username/email/เบอร์โทร) ----------
# ACC_BASE คือบัญชีตั้งต้นของ TC02_F00 ที่ F02/F03/F07 เอาไปใช้ทดสอบข้อมูลซ้ำ
&{ACC_BASE}             UsernameR=ucregbase01    Email=ucregbase01@mail.com    Tel=0899990001
&{ACC_SUCCESS}          UsernameR=ucregok01      Email=ucregok01@mail.com      Tel=0899990002
&{ACC_DUP_USERNAME}     UsernameR=ucregbase01    Email=ucregdup02@mail.com     Tel=0899990003
&{ACC_DUP_EMAIL}        UsernameR=ucregdup03     Email=ucregbase01@mail.com    Tel=0899990004
&{ACC_DUP_TEL}          UsernameR=ucregdup07     Email=ucregdup07@mail.com     Tel=0899990001
&{ACC_INCOMPLETE}       UsernameR=ucregdup06     Email=ucregdup06@mail.com     Tel=${EMPTY}

# ข้อมูลเว้นว่างทั้งหมดของ TC02_F05 (ไม่ผ่าน "สร้างข้อมูลผู้สมัคร" เพราะต้องการให้ทุกช่องว่างจริง ๆ)
&{DATA_EMPTY_STEP1}
...    Picture=${EMPTY}    UsernameR=${EMPTY}    Email=${EMPTY}
...    PasswordR=${EMPTY}    Confirmpassword=${EMPTY}

# ---------- ตัวแปรระดับกรณีทดสอบ ใช้ส่งข้อมูลให้ teardown ----------
${TC_ID}             UNKNOWN
${ACTUAL_MESSAGE}    ${EMPTY}

*** Test Cases ***
TC02_F00 - สร้างบัญชีตั้งต้นสำหรับใช้ในเคสอื่น
    #Fixture : สร้างบัญชีตั้งต้นให้ F02/F03/F07 ใช้ทดสอบข้อมูลซ้ำ ต้องได้ "สมัครสมาชิกสำเร็จ!"
    Set Test Variable    ${TC_ID}    TC02_F00
    ${Data}=    สร้างข้อมูลผู้สมัคร    ${ACC_BASE}
    สมัครแล้วเทียบข้อความ    ${Data}    ${EXP_REGISTER_SUCCESS}

TC02_F01 - สมัครสมาชิกด้วยข้อมูลถูกต้องครบถ้วน (Basic Flow)
    #TC02-RF01 : ต้องได้ "สมัครสมาชิกสำเร็จ!" แล้วเข้าสู่ระบบด้วยบัญชีนี้ต้องได้ "เข้าสู่ระบบสำเร็จ" (Post-Condition)
    Set Test Variable    ${TC_ID}    TC02_F01
    ${Data}=    สร้างข้อมูลผู้สมัคร    ${ACC_SUCCESS}
    สมัครแล้วเทียบข้อความ    ${Data}    ${EXP_REGISTER_SUCCESS}
    ต้องเข้าสู่ระบบได้จริง    ${Data}[UsernameR]    ${Data}[PasswordR]

TC02_F02 - ชื่อผู้ใช้ซ้ำกับบัญชีตั้งต้น
    #TC02-RF02 : ชื่อผู้ใช้ซ้ำ ต้องแสดง "Username นี้ไม่สามารถใช้งานได้"
    Set Test Variable    ${TC_ID}    TC02_F02
    ${Data}=    สร้างข้อมูลผู้สมัคร    ${ACC_DUP_USERNAME}
    สมัครแล้วเทียบข้อความ    ${Data}    ${EXP_DUP_USERNAME}

TC02_F03 - อีเมลซ้ำกับบัญชีตั้งต้น
    #TC02-RF03 : อีเมลซ้ำ ต้องแสดง "Email นี้ไม่สามารถใช้งานได้"
    Set Test Variable    ${TC_ID}    TC02_F03
    ${Data}=    สร้างข้อมูลผู้สมัคร    ${ACC_DUP_EMAIL}
    สมัครแล้วเทียบข้อความ    ${Data}    ${EXP_DUP_EMAIL}

TC02_F05 - เว้นว่างทุกช่องในขั้นตอนที่ 1
    #TC02-RF04 : ไม่กรอกอะไรเลยแล้วกดถัดไป ต้องแสดงข้อความแจ้งเตือนตรงตาม ${EXP_EMPTY_STEP1} และไม่ไปขั้นตอนที่ 2
    Set Test Variable    ${TC_ID}    TC02_F05
    กรณี TC02_F05    ${DATA_EMPTY_STEP1}

TC02_F06 - ผ่านขั้นตอนที่ 1 แต่เว้นข้อมูลส่วนตัวไว้
    #TC02-RF05 : ผ่านขั้นตอนที่ 1 แต่ไม่กรอกขั้นตอนที่ 2 ปุ่มสมัครสมาชิกต้องถูกปิดใช้งาน
    Set Test Variable    ${TC_ID}    TC02_F06
    ${Data}=    สร้างข้อมูลผู้สมัคร    ${ACC_INCOMPLETE}
    กรณี TC02_F06    ${Data}

TC02_F07 - เบอร์โทรซ้ำกับบัญชีตั้งต้น
    #TC02-RF06 : เบอร์โทรซ้ำ ต้องแสดง "เบอร์โทรศัพท์นี้ไม่สามารถใช้งานได้"
    Set Test Variable    ${TC_ID}    TC02_F07
    ${Data}=    สร้างข้อมูลผู้สมัคร    ${ACC_DUP_TEL}
    สมัครแล้วเทียบข้อความ    ${Data}    ${EXP_DUP_TEL}

*** Keywords ***
# =====================================================================
# 1. เตรียมข้อมูลทดสอบ (ไม่มี Excel : ประกอบจากบัญชีคงที่ + โปรไฟล์กลาง)
# =====================================================================

สร้างข้อมูลผู้สมัคร
    #รวมข้อมูลบัญชี (username/email/เบอร์โทร จาก ${Account}) เข้ากับโปรไฟล์กลาง ${DATA_PROFILE} ให้ครบทุกฟิลด์ของฟอร์มสมัคร
    [Arguments]    ${Account}
    ${Data}=    Copy Dictionary    ${DATA_PROFILE}
    Set To Dictionary    ${Data}
    ...    Picture=farmer.jpg              UsernameR=${Account}[UsernameR]
    ...    Email=${Account}[Email]         Tel=${Account}[Tel]
    ...    PasswordR=${REG_PASSWORD}       Confirmpassword=${REG_PASSWORD}
    RETURN    ${Data}

# =====================================================================
# 2. กรณีทดสอบยูสเคสสมัครสมาชิก
# =====================================================================

สมัครแล้วเทียบข้อความ
    #ใช้ร่วมกันใน F00 F01 F02 F03 F07 : สมัครจนจบ แล้วเทียบข้อความที่ระบบแสดงกับเอกสารแบบตรงกัน 100%
    [Arguments]    ${Data}    ${ExpectedResult}
    ${Message}=    ดำเนินการสมัครสมาชิก    ${Data}
    บันทึกผลที่ได้จริง    ${Message}
    เทียบผลจริงกับที่คาดหวัง    ${Message}    ${ExpectedResult}

กรณี TC02_F05
    #RF04-02 : เว้นว่างทุกช่องในขั้นตอนที่ 1 ข้อความต้องตรงเอกสาร และต้องไม่ไปขั้นตอนที่ 2
    [Arguments]    ${Data}
    Open Register Page
    กรอกข้อมูลบัญชีผู้ใช้    ${Data}
    Click Next Button
    ${Messages}=    Get Validation Messages
    ${Summary}=     Evaluate    " | ".join($Messages)
    บันทึกผลที่ได้จริง    ${Summary}
    เทียบผลจริงกับที่คาดหวัง    ${Summary}    ${EXP_EMPTY_STEP1}
    ${OnStep2}=    Is Register Step2 Displayed
    Should Not Be True    ${OnStep2}    msg=ระบบยอมให้ไปขั้นตอนที่ 2 ทั้งที่ไม่ได้กรอกข้อมูล

กรณี TC02_F06
    #RF05-02 ถึง RF05-03 : ผ่านขั้นตอนที่ 1 แล้ว ปุ่มสมัครสมาชิกต้องถูกปิดใช้งานเมื่อไม่กรอกขั้นตอนที่ 2
    [Arguments]    ${Data}
    ผ่านไปยังขั้นตอนที่ 2    ${Data}
    ${Clicked}=    Click Register Button
    ${State}=    Set Variable If    ${Clicked}    ปุ่มสมัครสมาชิกกดได้    ปุ่มสมัครสมาชิกถูกปิดใช้งาน
    บันทึกผลที่ได้จริง    ${State}
    Should Not Be True    ${Clicked}    msg=ระบบยอมให้กดสมัครสมาชิกทั้งที่ข้อมูลไม่ครบ

ผ่านไปยังขั้นตอนที่ 2
    #RF05-02 : เปิดหน้าสมัคร กรอกขั้นตอนที่ 1 แล้วกด "ถัดไป" ต้องไปถึงขั้นตอนที่ 2
    [Arguments]    ${Data}
    Open Register Page
    กรอกข้อมูลบัญชีผู้ใช้    ${Data}
    ${Clicked}=    Click Next Button
    Should Be True    ${Clicked}    msg=ปุ่มถัดไปถูกปิดใช้งาน ไม่สามารถผ่านขั้นตอนที่ 1 ได้
    ${OnStep2}=    Is Register Step2 Displayed
    Should Be True    ${OnStep2}    msg=ระบบไม่ได้พาไปยังขั้นตอนที่ 2

ต้องเข้าสู่ระบบได้จริง
    #RF01-06 Post-Condition : เข้าสู่ระบบด้วยบัญชีที่สมัคร หัวข้อ popup ต้องเป็น "เข้าสู่ระบบสำเร็จ"
    [Arguments]    ${Username}    ${Password}
    Run Keyword And Ignore Error    Close Test Context
    Open Login Page
    Input Username    ${Username}
    Input Password    ${Password}
    Keyboard Key    press    Tab
    Click Button If Enabled    ${Btn_Login}
    ${HasPopup}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Popup_Title}    visible    ${POPUP_TIMEOUT}
    ${Message}=    Set Variable    ${EMPTY}
    IF    ${HasPopup}
        ${Message}=    Get Popup Title
        Close Login Popup
    END
    บันทึกผลที่ได้จริง    ${Message}
    เทียบผลจริงกับที่คาดหวัง    ${Message}    ${EXP_LOGIN_SUCCESS}
    Run Keyword And Ignore Error    Close Test Context

# =====================================================================
# 3. ขั้นตอนย่อยของการสมัครสมาชิก (คัดลอกจาก Register_farmer.robot เพราะไฟล์นี้ต้องใช้ร่วมด้วย)
# =====================================================================

กรอกข้อมูลบัญชีผู้ใช้
    #กรอกข้อมูลขั้นตอนที่ 1 (รูปโปรไฟล์ ชื่อผู้ใช้ อีเมล รหัสผ่าน)
    [Arguments]    ${Data}
    Upload Picture           ${Data}[Picture]
    Input UsernameR          ${Data}[UsernameR]
    Input Email              ${Data}[Email]
    Input PasswordR          ${Data}[PasswordR]
    Input Confirmpassword    ${Data}[Confirmpassword]

    # ช่องสุดท้ายไม่มีช่องถัดไปมา blur ให้ ต้อง Tab ออกเองระบบจึงจะตรวจสอบ
    Keyboard Key    press    Tab

กรอกข้อมูลส่วนตัว
    #กรอกข้อมูลขั้นตอนที่ 2 (ข้อมูลส่วนตัวและที่อยู่)
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

ดำเนินการสมัครสมาชิก
    #RF01-03 ถึง RF01-05 : กรอกครบ 2 ขั้นตอนแล้วกดสมัคร คืนหัวข้อ popup ที่ระบบแสดง
    #ถ้าติดที่ขั้นตอนใด คืนข้อความแจ้งเตือนบนหน้าจอ (คั่นด้วย " | ") ไม่มีข้อความเลยคืนค่าว่าง
    [Arguments]    ${Data}
    Open Register Page
    กรอกข้อมูลบัญชีผู้ใช้    ${Data}
    ${Clicked}=    Click Next Button
    ${OnStep2}=    Is Register Step2 Displayed
    IF    not ${Clicked} or not ${OnStep2}
        ${Result}=    อ่านข้อความแจ้งเตือนบนหน้าจอ
        RETURN    ${Result}
    END

    กรอกข้อมูลส่วนตัว    ${Data}
    ${Clicked}=    Click Register Button
    IF    not ${Clicked}
        ${Result}=    อ่านข้อความแจ้งเตือนบนหน้าจอ
        RETURN    ${Result}
    END

    ${Registered}=    รอผลการสมัคร
    IF    $Registered != ''    RETURN    ${Registered}
    ${Result}=    อ่านข้อความแจ้งเตือนบนหน้าจอ
    RETURN    ${Result}

รอผลการสมัคร
    #รอ popup ผลการสมัคร คืนหัวข้อ popup (${Popup_Title}) ไม่พบให้คืนค่าว่าง
    ${HasPopup}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Popup_Title}    visible    ${POPUP_TIMEOUT}
    IF    not ${HasPopup}    RETURN    ${EMPTY}
    ${Text}=    Get Popup Title
    RETURN    ${Text}

# =====================================================================
# 4. คีย์เวิร์ดช่วยเหลือ
# =====================================================================

อ่านข้อความแจ้งเตือนบนหน้าจอ
    #อ่านข้อความแจ้งเตือนสีแดงบนหน้าจอ รวมเป็นข้อความเดียวคั่นด้วย " | " ไม่พบคืนค่าว่าง
    ${Messages}=    Get Validation Messages
    ${Text}=    Evaluate    " | ".join($Messages)
    RETURN    ${Text}

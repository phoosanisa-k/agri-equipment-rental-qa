*** Settings ***
Documentation     TC02 - Register Farmer (Usecase) | ทดสอบยูสเคสสมัครสมาชิกจริงระดับ Flow ตาม TESTDESIGN 7.2.5.17
...               ครอบคลุม Basic Flow (RF01-02/03) และ Alternate/Exception Flow ที่ field test (Register_farmer.robot)
...               ไม่ได้ครอบคลุม คือการตรวจข้อมูลซ้ำ (username/email/เบอร์โทร) ซึ่งต้องเช็คผ่านฐานข้อมูลจริงเท่านั้น
...               ใช้ข้อมูลคงที่ (fix ค่าตายตัวในสคริปต์) ไม่อ่าน/เขียน Excel เพราะรันซ้ำได้ในตัวอยู่แล้ว (ดูหมายเหตุที่ TC02_F00/F01)
...
...               เคสที่ตัดออกเพราะซ้ำกับ field test แล้ว : TC02_F04 (อีเมลผิดรูปแบบ ซ้ำกับ TC02_024)
...               เคสที่ตัดออกเพราะไม่อยู่ใน use case spec : TC02_F08 (ปุ่มย้อนกลับ เป็นเทส UI state ไม่ใช่พฤติกรรมของยูสเคส)
Metadata          System      ระบบเว็บศูนย์กลางให้บริการเช่าอุปกรณ์ทางการเกษตร (SRS v7.0)
Metadata          Use Case    TC02 Register Farmer (Basic Flow + Alternate/Exception Flow)

Resource          ../Resources/keywords.robot
Library           OperatingSystem
Library           String
Library           Collections

Suite Setup       เปิดชุดทดสอบ
Suite Teardown    ปิดชุดทดสอบ
Test Teardown     เก็บผลท้ายกรณีทดสอบ


*** Variables ***
# ---------- ไฟล์และโฟลเดอร์ ----------
${SCREENSHOT_DIR}     ${CURDIR}/../Screenshot
${USECASE}            TC02_Usecase_Register_Farmer

# ---------- ตัวชี้วัดที่ใช้ตัดสินผล ----------
${SUCCESS_KEYWORD}    สำเร็จ
${Popup_Success}      text=${SUCCESS_KEYWORD}
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
    [Documentation]    Fixture : สร้างบัญชีตั้งต้นไว้ให้ F02/F03/F07 ใช้ทดสอบข้อมูลซ้ำ
    ...                รันซ้ำแล้วเจอ "บัญชีถูกใช้งานแล้ว" แทน "สำเร็จ" ถือว่าปกติ เพราะข้อมูลคงที่ไม่ได้สุ่มใหม่ทุกรอบ
    Set Test Variable    ${TC_ID}    TC02_F00
    ${Data}=    สร้างข้อมูลผู้สมัคร    ${ACC_BASE}
    กรณี TC02_F00    ${Data}

TC02_F01 - สมัครสมาชิกด้วยข้อมูลถูกต้องครบถ้วน (Basic Flow)
    [Documentation]    RF01-02/03 : กรอกข้อมูลถูกต้องครบทั้ง 2 ขั้นตอนแล้วกดสมัคร
    ...                ยอมรับทั้ง "สมัครสำเร็จ" และ "บัญชีถูกใช้งานแล้ว" (รันซ้ำได้เหมือน F00)
    ...                แต่ไม่ว่าผลจะออกมาแบบไหน ต้องเข้าสู่ระบบด้วยบัญชีนี้ได้จริงเสมอ (Post-Condition ของยูสเคส)
    Set Test Variable    ${TC_ID}    TC02_F01
    ${Data}=    สร้างข้อมูลผู้สมัคร    ${ACC_SUCCESS}
    กรณี TC02_F01    ${Data}

TC02_F02 - ชื่อผู้ใช้ซ้ำกับบัญชีตั้งต้น
    [Documentation]    RF01-04 : ใช้ชื่อผู้ใช้ของบัญชีตั้งต้น + อีเมลใหม่ ระบบต้องปฏิเสธและแจ้งเรื่องชื่อผู้ใช้
    Set Test Variable    ${TC_ID}    TC02_F02
    ${Data}=    สร้างข้อมูลผู้สมัคร    ${ACC_DUP_USERNAME}
    กรณี TC02_F02    ${Data}

TC02_F03 - อีเมลซ้ำกับบัญชีตั้งต้น
    [Documentation]    RF01-05 : ใช้อีเมลของบัญชีตั้งต้น + ชื่อผู้ใช้ใหม่ ระบบต้องปฏิเสธและแจ้งเรื่องอีเมล
    Set Test Variable    ${TC_ID}    TC02_F03
    ${Data}=    สร้างข้อมูลผู้สมัคร    ${ACC_DUP_EMAIL}
    กรณี TC02_F03    ${Data}

TC02_F05 - เว้นว่างทุกช่องในขั้นตอนที่ 1
    [Documentation]    RF01-07 : ไม่กรอกอะไรเลยแล้วกดถัดไป ระบบต้องแจ้งเตือนและไม่ให้ไปขั้นตอนที่ 2
    Set Test Variable    ${TC_ID}    TC02_F05
    กรณี TC02_F05    ${DATA_EMPTY_STEP1}

TC02_F06 - ผ่านขั้นตอนที่ 1 แต่เว้นข้อมูลส่วนตัวไว้
    [Documentation]    RF01-08 : ผ่านขั้นตอนที่ 1 ได้ แต่ไม่กรอกขั้นตอนที่ 2 เลย ระบบต้องไม่ยอมสร้างบัญชีให้
    Set Test Variable    ${TC_ID}    TC02_F06
    ${Data}=    สร้างข้อมูลผู้สมัคร    ${ACC_INCOMPLETE}
    กรณี TC02_F06    ${Data}

TC02_F07 - เบอร์โทรซ้ำกับบัญชีตั้งต้น
    [Documentation]    7.2.5.17 : ระบบต้องตรวจสอบความซ้ำซ้อนของเบอร์โทรศัพท์ด้วยเช่นเดียวกับชื่อผู้ใช้และอีเมล
    ...                ใช้เบอร์โทรของบัญชีตั้งต้น + ชื่อผู้ใช้/อีเมลใหม่ ระบบต้องปฏิเสธและแจ้งเรื่องเบอร์โทร
    Set Test Variable    ${TC_ID}    TC02_F07
    ${Data}=    สร้างข้อมูลผู้สมัคร    ${ACC_DUP_TEL}
    กรณี TC02_F07    ${Data}


*** Keywords ***
# =====================================================================
# 1. การเตรียมและปิดชุดทดสอบ
# =====================================================================

เปิดชุดทดสอบ
    [Documentation]    ล้างภาพของรอบก่อน และเปิดเบราว์เซอร์ (ไม่ต้องเปิด Excel เพราะไฟล์นี้ fix ค่าตายตัว ไม่มีการเขียนผลกลับ)
    Create Directory    ${SCREENSHOT_DIR}
    ลบภาพของรอบก่อน    ${SCREENSHOT_DIR}
    Open Test Browser

ลบภาพของรอบก่อน
    [Documentation]    ลบเฉพาะภาพของยูสเคสนี้ ไม่ลบตัวโฟลเดอร์เพราะ OneDrive มักคืน Access denied
    [Arguments]    ${Folder}
    ${Files}=    List Files In Directory    ${Folder}    ${USECASE}_*.png
    FOR    ${File}    IN    @{Files}
        ${Removed}=    Run Keyword And Return Status    Remove File    ${Folder}/${File}
        IF    not ${Removed}    Log    ลบ ${File} ไม่สำเร็จ ภาพอาจปนกับรอบก่อน    level=WARN
    END

ปิดชุดทดสอบ
    [Documentation]    ปิดเบราว์เซอร์ทั้งหมด
    Close All Test Browsers

เก็บผลท้ายกรณีทดสอบ
    [Documentation]    เก็บภาพเมื่อไม่ผ่าน แล้วปิด context (ไม่มีการเขียนผลกลับ Excel เพราะไฟล์นี้ fix ค่าตายตัว)
    IF    '${TEST STATUS}' == 'FAIL'
        Run Keyword And Ignore Error
        ...    Take Screenshot    ${SCREENSHOT_DIR}/${USECASE}_${TC_ID}_FAILED    fullPage=True
    END
    # Ignore Error เพราะบางกรณีอาจยังไม่มี context ถูกเปิด
    Run Keyword And Ignore Error    Close Test Context


# =====================================================================
# 2. เตรียมข้อมูลทดสอบ (ไม่มี Excel : ประกอบจากบัญชีคงที่ + โปรไฟล์กลาง)
# =====================================================================

สร้างข้อมูลผู้สมัคร
    [Documentation]    รวมข้อมูลบัญชี (username/email/เบอร์โทร จาก ${Account}) เข้ากับโปรไฟล์กลาง ${DATA_PROFILE}
    ...                ให้เป็นชุดข้อมูลครบทุกฟิลด์ที่กรอกฟอร์มสมัครสมาชิกได้ (กันไม่ต้องพิมพ์ข้อมูลส่วนตัวซ้ำทุกเคส)
    [Arguments]    ${Account}
    ${Data}=    Copy Dictionary    ${DATA_PROFILE}
    Set To Dictionary    ${Data}
    ...    Picture=farmer.jpg              UsernameR=${Account}[UsernameR]
    ...    Email=${Account}[Email]         Tel=${Account}[Tel]
    ...    PasswordR=${REG_PASSWORD}       Confirmpassword=${REG_PASSWORD}
    RETURN    ${Data}


# =====================================================================
# 3. กรณีทดสอบยูสเคสสมัครสมาชิกจริง (TC02_F00, F01, F02, F03, F05, F06, F07)
# =====================================================================

กรณี TC02_F00
    [Documentation]    สร้างบัญชีตั้งต้น ยอมรับทั้งข้อความสำเร็จและ "ถูกใช้งานแล้ว" (รันซ้ำได้)
    [Arguments]    ${Data}
    ${Message}=    สมัครและบันทึกผล    ${Data}    สร้างบัญชีตั้งต้น
    ข้อความต้องกล่าวถึง    ${Message}    ${SUCCESS_KEYWORD}    ถูกใช้งานแล้ว    ซ้ำ

กรณี TC02_F01
    [Documentation]    สมัครสมาชิกด้วยข้อมูลที่ถูกต้องครบถ้วน แล้วตรวจ Post-Condition ว่าเข้าสู่ระบบด้วยบัญชีนี้ได้จริง
    [Arguments]    ${Data}
    ${Message}=    สมัครและบันทึกผล    ${Data}    สมัครสำเร็จ
    ข้อความต้องกล่าวถึง    ${Message}    ${SUCCESS_KEYWORD}    ถูกใช้งานแล้ว
    ต้องเข้าสู่ระบบได้จริง    ${Data}[UsernameR]    ${Data}[PasswordR]

กรณี TC02_F02
    [Documentation]    ชื่อผู้ใช้ของบัญชีตั้งต้น + อีเมลใหม่ ระบบต้องปฏิเสธและแจ้งเรื่องชื่อผู้ใช้
    [Arguments]    ${Data}
    กรณีที่ระบบต้องปฏิเสธ    ${Data}    ชื่อผู้ใช้ซ้ำ    ชื่อผู้ใช้    username

กรณี TC02_F03
    [Documentation]    อีเมลของบัญชีตั้งต้น + ชื่อผู้ใช้ใหม่ ระบบต้องปฏิเสธและแจ้งเรื่องอีเมล
    [Arguments]    ${Data}
    กรณีที่ระบบต้องปฏิเสธ    ${Data}    อีเมลซ้ำ    อีเมล    email

กรณี TC02_F05
    [Documentation]    เว้นว่างทุกช่องในขั้นตอนที่ 1 ระบบต้องแจ้งเตือนและไม่ให้ไปต่อ
    [Arguments]    ${Data}

    Open Register Page
    กรอกข้อมูลบัญชีผู้ใช้    ${Data}

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

กรณี TC02_F06
    [Documentation]    ผ่านขั้นตอนที่ 1 แต่เว้นข้อมูลส่วนตัวไว้ ระบบต้องไม่สมัครให้
    [Arguments]    ${Data}

    ผ่านไปยังขั้นตอนที่ 2    ${Data}

    ${Clicked}=    Click Register Button
    ${Summary}=    สรุปข้อความบนหน้าจอ    ปุ่มสมัครสมาชิกถูกปิดใช้งาน ระบบไม่สร้างบัญชี

    บันทึกผลที่ได้จริง    ${Summary}
    เก็บภาพหลักฐาน       ข้อมูลไม่ครบ

    Should Not Be True    ${Clicked}
    ...    msg=ระบบยอมให้กดสมัครสมาชิกทั้งที่ข้อมูลไม่ครบ

กรณี TC02_F07
    [Documentation]    เบอร์โทรของบัญชีตั้งต้น + ชื่อผู้ใช้และอีเมลใหม่ (7.2.5.17 : ระบบต้องตรวจเบอร์โทรซ้ำด้วย)
    [Arguments]    ${Data}
    กรณีที่ระบบต้องปฏิเสธ    ${Data}    เบอร์โทรซ้ำ    เบอร์    โทรศัพท์    phone    tel

สมัครและบันทึกผล
    [Documentation]    ท่าประจำของเคสที่สมัครจนจบ : สมัคร -> บันทึกผล -> เก็บภาพ แล้วคืนข้อความที่ระบบตอบกลับ
    [Arguments]    ${Data}    ${Name}
    ${Message}=    ดำเนินการสมัครสมาชิก    ${Data}
    บันทึกผลที่ได้จริง    ${Message}
    เก็บภาพหลักฐาน       ${Name}
    RETURN    ${Message}

กรณีที่ระบบต้องปฏิเสธ
    [Documentation]    ใช้ร่วมกันใน F02 / F03 / F07 ต่างกันแค่ชื่อภาพหลักฐาน และคำที่ระบบต้องกล่าวถึง
    [Arguments]    ${Data}    ${Name}    @{Keywords}
    ${Message}=    สมัครและบันทึกผล    ${Data}    ${Name}
    ต้องสมัครไม่สำเร็จ     ${Message}
    ข้อความต้องกล่าวถึง    ${Message}    @{Keywords}

ผ่านไปยังขั้นตอนที่ 2
    [Documentation]    เปิดหน้าสมัคร กรอกขั้นตอนที่ 1 แล้วกด "ถัดไป" ให้ถึงขั้นตอนที่ 2 (ใช้ใน F06)
    [Arguments]    ${Data}
    Open Register Page
    กรอกข้อมูลบัญชีผู้ใช้    ${Data}

    ${Clicked}=    Click Next Button
    Should Be True    ${Clicked}    ไม่สามารถผ่านขั้นตอนที่ 1 ได้

    ${OnStep2}=    Is Register Step2 Displayed
    Should Be True    ${OnStep2}    ระบบไม่ได้พาไปยังขั้นตอนที่ 2

ต้องเข้าสู่ระบบได้จริง
    [Documentation]    ตรวจ Post-Condition ของยูสเคส Register : "ผู้เป็นสมาชิกสามารถเข้าสู่ระบบได้"
    ...                ทำหลังสมัครเสร็จ (หรือรันซ้ำแล้วเจอบัญชีเดิม) เพื่อยืนยันว่าบัญชีนี้ใช้เข้าสู่ระบบได้จริง ไม่ใช่แค่ระบบแจ้งข้อความเฉย ๆ
    [Arguments]    ${Username}    ${Password}
    Run Keyword And Ignore Error    Close Test Context
    Open Login Page
    Input Username    ${Username}
    Input Password    ${Password}
    Keyboard Key    press    Tab
    Click Button If Enabled    ${Btn_Login}

    ${Success}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Popup_Success}    visible    ${POPUP_TIMEOUT}
    IF    ${Success}    Close Login Popup

    เก็บภาพหลักฐาน    ตรวจ Post-Condition เข้าสู่ระบบ
    Should Be True    ${Success}
    ...    msg=สมัครสมาชิกสำเร็จ แต่เข้าสู่ระบบด้วยบัญชี "${Username}" ไม่ได้ (Post-Condition ของยูสเคสไม่ผ่าน)

    Run Keyword And Ignore Error    Close Test Context


# =====================================================================
# 4. ขั้นตอนย่อยของการสมัครสมาชิก (คัดลอกจาก Register_farmer.robot เพราะไฟล์นี้ต้องใช้ร่วมด้วย)
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

ดำเนินการสมัครสมาชิก
    [Documentation]    กรอกครบ 2 ขั้นตอนแล้วกดสมัคร คืนข้อความที่ระบบตอบกลับ ถ้าติดตั้งแต่ขั้นตอนที่ 1 จะคืนข้อความแจ้งเตือนแทน
    [Arguments]    ${Data}

    Open Register Page
    กรอกข้อมูลบัญชีผู้ใช้    ${Data}

    ${Clicked}=    Click Next Button
    IF    not ${Clicked}
        ${Result}=    สรุปข้อความบนหน้าจอ    ไม่ผ่านขั้นตอนที่ 1 และไม่พบข้อความแจ้งเตือน
        RETURN    ${Result}
    END

    ${OnStep2}=    Is Register Step2 Displayed
    IF    not ${OnStep2}
        ${Result}=    สรุปข้อความบนหน้าจอ    ไม่สามารถไปยังขั้นตอนที่ 2 ได้
        RETURN    ${Result}
    END

    กรอกข้อมูลส่วนตัว    ${Data}

    ${Clicked}=    Click Register Button
    IF    not ${Clicked}
        ${Result}=    สรุปข้อความบนหน้าจอ    ปุ่มสมัครสมาชิกถูกปิดใช้งาน
        RETURN    ${Result}
    END

    ${Registered}=    รอผลการสมัคร
    ${RegLen}=        Get Length    ${Registered}
    IF    ${RegLen} > 0
        Log    ข้อความที่ระบบตอบกลับ : ${Registered}    level=INFO
        RETURN    ${Registered}
    END

    ${Result}=    สรุปข้อความบนหน้าจอ    ไม่พบทั้งข้อความแจ้งสำเร็จและข้อความแจ้งเตือน
    Log    ข้อความที่ระบบตอบกลับ : ${Result}    level=INFO
    RETURN    ${Result}

รอผลการสมัคร
    [Documentation]    รอ popup แจ้งสมัครสำเร็จ คืนข้อความบน popup ไม่พบให้คืนค่าว่าง (รอสั้นเพราะเคสที่ต้องไม่สำเร็จจะไม่มี popup)
    ${Success}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Popup_Success}    visible    ${POPUP_TIMEOUT}
    IF    not ${Success}    RETURN    ${EMPTY}

    ${Text}=    Get Text        ${Popup_Success}
    ${Text}=    Strip String    ${Text}
    RETURN    ${Text}


# =====================================================================
# 5. คีย์เวิร์ดช่วยเหลือ : บันทึกผล ตรวจผล และเก็บหลักฐาน
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

สรุปข้อความบนหน้าจอ
    [Documentation]    อ่านข้อความแจ้งเตือนบนหน้าจอแล้วรวมเป็นข้อความเดียว ไม่พบข้อความให้ใช้ข้อความสำรอง
    [Arguments]    ${Fallback}
    ${Messages}=    Get Validation Messages
    ${Result}=      รวมข้อความ    ${Messages}    ${Fallback}
    RETURN    ${Result}

ต้องสมัครไม่สำเร็จ
    [Documentation]    ยืนยันว่าระบบไม่ได้สมัครสมาชิกให้
    [Arguments]    ${Message}
    Should Not Contain    ${Message}    ${SUCCESS_KEYWORD}
    ...    msg=ระบบสมัครสมาชิกสำเร็จ ทั้งที่ควรปฏิเสธ (ข้อความ "${Message}")

ข้อความต้องกล่าวถึง
    [Documentation]    ยืนยันว่าข้อความที่ระบบตอบกลับมีคำที่กำหนดไว้อย่างน้อยหนึ่งคำ
    [Arguments]    ${Message}    @{Keywords}
    ${Lower}=    Convert To Lower Case    ${Message}
    # lambda รับค่าผ่าน default argument เพราะ RF มองไม่เห็น $ตัวแปร ใน comprehension
    ${Matched}=    Evaluate    any(map(lambda k, t=$Lower: k.lower() in t, $Keywords))
    Should Be True    ${Matched}
    ...    msg=ข้อความ "${Message}" ไม่ได้กล่าวถึง ${Keywords} จึงไม่แน่ใจว่าระบบตอบด้วยเหตุผลที่ถูกต้อง

เก็บภาพหลักฐาน
    [Documentation]    บันทึกภาพหน้าจอเป็นหลักฐานประกอบรายงาน ตั้งชื่อ <ยูสเคส>_<รหัส>_<คำอธิบาย>
    [Arguments]    ${Name}
    Run Keyword And Ignore Error
    ...    Take Screenshot    ${SCREENSHOT_DIR}/${USECASE}_${TC_ID}_${Name}    fullPage=True

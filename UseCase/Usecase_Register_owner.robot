*** Settings ***
Documentation     TC02 - Register Owner (Usecase) | ทดสอบยูสเคสสมัครสมาชิก Functional Flow ของ Owner ตามตาราง 8.2.6 (RO02-01 ถึง RO02-09)
...               ทดสอบเฉพาะ Functional Flow (field validation ตรวจซ้ำแล้วใน Register_farmer.robot ฝั่ง Owner ใช้เงื่อนไขเดียวกัน) ใช้ข้อมูลคงที่
...               *** ต้องล้างตาราง Owner ในฐานข้อมูลก่อนรันไฟล์นี้ทุกครั้ง *** เพราะระบบจริงไม่ปฏิเสธ username/email ซ้ำ (บั๊กที่ RO2/RO3 ตรวจเจอ)
...               รันซ้ำโดยไม่ล้างตารางจะทำให้ทุกบัญชีมีหลายแถวและเข้าสู่ระบบไม่ได้ TC02_RO0 จึงแยกเป็นบัญชีตั้งต้นให้ RO2/RO3 ทดสอบซ้ำ
...               โดยไม่แตะบัญชีของ RO1 (บัญชีที่ Usecase_Login_owner.robot ใช้เข้าสู่ระบบ ต้องมีแถวเดียวเสมอ)
Metadata          Use Case    TC02 Register Owner (Functional Flow)

Resource          ../Resources/keywords.robot
Library           OperatingSystem
Library           String
Library           Collections

Suite Setup       เตรียมชุดทดสอบยูสเคส
Suite Teardown    ปิดชุดทดสอบ
Test Teardown     เก็บผลท้ายกรณีทดสอบ

*** Variables ***
# ---------- ไฟล์และโฟลเดอร์ ----------
${USECASE}            TC02_Usecase_Register_Owner
${SCREENSHOT_DIR}     ${CURDIR}/../Screenshot/${USECASE}

# ---------- ข้อความที่คาดหวังตามเอกสารเทสเคส (เทียบตรงกัน 100%) ----------
${EXP_REGISTER_SUCCESS}    สมัครสมาชิกสำเร็จ!                                     # RO01-05 / RO0
${EXP_DUP_USERNAME}        Username นี้ไม่สามารถใช้งานได้                          # RO02-03
${EXP_DUP_EMAIL}           Email นี้ไม่สามารถใช้งานได้                             # RO03-03
${EXP_INVALID_EMAIL}       รูปแบบอีเมลไม่ถูกต้อง                                   # RO04-03
${EXP_EMPTY_STEP1}         กรุณากรอกชื่อผู้ใช้ | กรุณากรอกอีเมล | กรุณากรอกรหัสผ่าน    # RO05-03 (ข้อความแดงใต้ช่อง เรียงตามลำดับช่อง)
# รอสั้น ๆ เพราะกรณีที่ต้องไม่สำเร็จจะไม่มี popup ขึ้นเลย
${POPUP_TIMEOUT}      5s

# ---------- รหัสผ่านและรูปโปรไฟล์ ใช้ค่าเดียวกันได้ทุกบัญชี (ระบบไม่เช็ครูปซ้ำ เช็คซ้ำแค่ username/email) ----------
${REG_PASSWORD}    Owner1234!
${OWNER_PICTURE}    owner.jpg

# ---------- บัญชีทดสอบ : แต่ละบัญชีเป็นคนละคนกัน ให้ข้อมูลดูสมจริง ----------
# ACC_SEED คือบัญชีตั้งต้นของ TC02_RO0 มีไว้ให้ RO2/RO3 เอาชื่อผู้ใช้และอีเมลไปสมัครซ้ำโดยเฉพาะ
# ห้ามเอาบัญชีนี้ไปใช้เข้าสู่ระบบ เพราะจะถูก RO2 สมัครซ้ำจนมีหลายแถวในตารางเสมอ
&{ACC_SEED}
...    Firstname=ธีรภัทร    Surname=พงษ์ไพบูลย์    Gender=ชาย
...    Daybirth=5    Monthbirth=8    Yearbirth=2531
...    Hnum=45/7    Alley=เพชรบุรีตัดใหม่ 15    Group=หมู่ 3
...    District=ราชเทวี    Canton=ราชเทวี    Province=กรุงเทพมหานคร    Postcode=10400
...    UsernameR=seedowner01    Email=seed.owner01@gmail.com    Tel=0812345600

# ACC_SUCCESS คือบัญชีของ TC02_RO1 (Basic Flow) และเป็นบัญชีที่ Usecase_Login_owner.robot ใช้เข้าสู่ระบบ
# ต้องมีแถวเดียวในตารางเสมอ จึงห้ามให้ RO2/RO3 เอาชื่อผู้ใช้หรืออีเมลของบัญชีนี้ไปสมัครซ้ำ
&{ACC_SUCCESS}
...    Firstname=วิภาวรรณ    Surname=ธนกิจไพศาล    Gender=หญิง
...    Daybirth=14    Monthbirth=11    Yearbirth=2532
...    Hnum=99/2    Alley=ลาดพร้าว 71    Group=หมู่ 4
...    District=วังทองหลาง    Canton=วังทองหลาง    Province=กรุงเทพมหานคร    Postcode=10310
...    UsernameR=wipawantanakit    Email=wipawan.tanakit@gmail.com    Tel=0812345606

&{ACC_DUP_USERNAME}
...    Firstname=สมชาติ    Surname=แซ่ตั้ง    Gender=ชาย
...    Daybirth=2    Monthbirth=9    Yearbirth=2531
...    Hnum=5/9    Alley=รามคำแหง 24    Group=หมู่ 2
...    District=บางกะปิ    Canton=บางกะปิ    Province=กรุงเทพมหานคร    Postcode=10240
...    UsernameR=seedowner01    Email=somchat.duplicate@gmail.com    Tel=0812345603

&{ACC_DUP_EMAIL}
...    Firstname=กมลชนก    Surname=อินทร์แก้ว    Gender=หญิง
...    Daybirth=18    Monthbirth=1    Yearbirth=2534
...    Hnum=23    Alley=งามวงศ์วาน    Group=หมู่ 6
...    District=จตุจักร    Canton=จตุจักร    Province=กรุงเทพมหานคร    Postcode=10900
...    UsernameR=kamolchanoki    Email=seed.owner01@gmail.com    Tel=0812345604

&{ACC_INVALID_EMAIL}
...    Firstname=พงศกร    Surname=เรืองศรี    Gender=ชาย
...    Daybirth=7    Monthbirth=7    Yearbirth=2532
...    Hnum=101/2    Alley=พระราม 9    Group=หมู่ 1
...    District=ห้วยขวาง    Canton=ห้วยขวาง    Province=กรุงเทพมหานคร    Postcode=10310
...    UsernameR=pongsakornr    Email=pongsakorn.rgmail.com    Tel=0812345605

# ข้อมูลเว้นว่างทั้งหมดของ TC02_RO5 (ไม่ผ่าน "สร้างข้อมูลผู้สมัคร Owner" เพราะต้องการให้ทุกช่องว่างจริง ๆ)
&{DATA_EMPTY_STEP1}
...    Picture=${EMPTY}    UsernameR=${EMPTY}    Email=${EMPTY}
...    PasswordR=${EMPTY}    Confirmpassword=${EMPTY}

# ---------- ตัวแปรระดับกรณีทดสอบ ใช้ส่งข้อมูลให้ teardown ----------
${TC_ID}             UNKNOWN
${ACTUAL_MESSAGE}    ${EMPTY}

*** Test Cases ***
TC02_RO0 - สร้างบัญชีตั้งต้นสำหรับทดสอบข้อมูลซ้ำ
    #Fixture : สร้างบัญชีตั้งต้นให้ RO2/RO3 ทดสอบข้อมูลซ้ำ ต้องได้ "สมัครสมาชิกสำเร็จ!" (แยกจากบัญชีของ RO1 เพื่อไม่ให้มีหลายแถว)
    Set Test Variable    ${TC_ID}    TC02_RO0
    ${Data}=    สร้างข้อมูลผู้สมัคร Owner    ${ACC_SEED}
    สมัครแล้วเทียบข้อความ    ${Data}    ${EXP_REGISTER_SUCCESS}

TC02_RO1 - สมัครสมาชิกด้วยข้อมูลถูกต้องครบถ้วน
    #TC02-RO01 : ข้อมูลถูกต้องครบถ้วน ต้องได้ "สมัครสมาชิกสำเร็จ!" (บัญชีนี้ใช้เข้าสู่ระบบใน Usecase_Login_owner.robot)
    Set Test Variable    ${TC_ID}    TC02_RO1
    ${Data}=    สร้างข้อมูลผู้สมัคร Owner    ${ACC_SUCCESS}
    สมัครแล้วเทียบข้อความ    ${Data}    ${EXP_REGISTER_SUCCESS}

TC02_RO2 - ชื่อผู้ใช้ซ้ำกับบัญชีตั้งต้น
    #TC02-RO02 : ชื่อผู้ใช้ซ้ำ ต้องแสดง "Username นี้ไม่สามารถใช้งานได้"
    Set Test Variable    ${TC_ID}    TC02_RO2
    ${Data}=    สร้างข้อมูลผู้สมัคร Owner    ${ACC_DUP_USERNAME}
    สมัครแล้วเทียบข้อความ    ${Data}    ${EXP_DUP_USERNAME}

TC02_RO3 - อีเมลซ้ำกับบัญชีตั้งต้น
    #TC02-RO03 : อีเมลซ้ำ ต้องแสดง "Email นี้ไม่สามารถใช้งานได้"
    Set Test Variable    ${TC_ID}    TC02_RO3
    ${Data}=    สร้างข้อมูลผู้สมัคร Owner    ${ACC_DUP_EMAIL}
    สมัครแล้วเทียบข้อความ    ${Data}    ${EXP_DUP_EMAIL}

TC02_RO4 - อีเมลไม่มีเครื่องหมาย @
    #TC02-RO04 : อีเมลผิดรูปแบบ ต้องแสดง "รูปแบบอีเมลไม่ถูกต้อง" และไม่ไปขั้นตอนที่ 2
    Set Test Variable    ${TC_ID}    TC02_RO4
    ${Data}=    สร้างข้อมูลผู้สมัคร Owner    ${ACC_INVALID_EMAIL}
    กดถัดไปแล้วต้องติดขั้นตอนที่ 1    ${Data}    ${EXP_INVALID_EMAIL}

TC02_RO5 - เว้นว่างทุกช่องในขั้นตอนที่ 1
    #TC02-RO05 : เว้นว่างทุกช่อง ต้องแสดงข้อความแจ้งเตือนตรงตาม ${EXP_EMPTY_STEP1} และไม่ไปขั้นตอนที่ 2
    Set Test Variable    ${TC_ID}    TC02_RO5
    กดถัดไปแล้วต้องติดขั้นตอนที่ 1    ${DATA_EMPTY_STEP1}    ${EXP_EMPTY_STEP1}

*** Keywords ***
# =====================================================================
# 1. เตรียมข้อมูลทดสอบ (ไม่มี Excel : ประกอบจากบัญชีคงที่ + โปรไฟล์กลาง)
# =====================================================================

สร้างข้อมูลผู้สมัคร Owner
    #เติม Picture และรหัสผ่านให้ครบฟอร์มสมัคร Owner (ข้อมูลส่วนตัว/username/email/เบอร์โทร มากับ ${Account} แล้ว)
    [Arguments]    ${Account}
    ${Data}=    Copy Dictionary    ${Account}
    Set To Dictionary    ${Data}
    ...    Picture=${OWNER_PICTURE}
    ...    PasswordR=${REG_PASSWORD}    Confirmpassword=${REG_PASSWORD}
    RETURN    ${Data}

# =====================================================================
# 2. กรณีทดสอบยูสเคสสมัครสมาชิก (TC02_RO0 ถึง RO5)
# =====================================================================

สมัครแล้วเทียบข้อความ
    #ใช้ร่วมกันใน RO0 RO1 RO2 RO3 : สมัครจนจบ แล้วเทียบข้อความที่ระบบแสดงกับเอกสารแบบตรงกัน 100%
    [Arguments]    ${Data}    ${ExpectedResult}
    ${Message}=    ดำเนินการสมัครสมาชิก Owner    ${Data}
    บันทึกผลที่ได้จริง    ${Message}
    เทียบผลจริงกับที่คาดหวัง    ${Message}    ${ExpectedResult}

กดถัดไปแล้วต้องติดขั้นตอนที่ 1
    #ใช้ร่วมกันใน RO4 RO5 : กรอกขั้นตอนที่ 1 กด "ถัดไป" ข้อความแจ้งเตือนต้องตรงเอกสาร และต้องไม่ไปขั้นตอนที่ 2
    [Arguments]    ${Data}    ${ExpectedResult}
    Open Register Owner Page
    กรอกข้อมูลบัญชีผู้ใช้ Owner    ${Data}
    Click Next Button
    ${Message}=    อ่านข้อความแจ้งเตือนบนหน้าจอ
    บันทึกผลที่ได้จริง    ${Message}
    เทียบผลจริงกับที่คาดหวัง    ${Message}    ${ExpectedResult}
    ${OnStep2}=    Is Register Owner Step2 Displayed
    Should Not Be True    ${OnStep2}    msg=ระบบยอมให้ไปขั้นตอนที่ 2 ทั้งที่ข้อมูลขั้นตอนที่ 1 ไม่ถูกต้อง

# =====================================================================
# 3. ขั้นตอนย่อยของการสมัครสมาชิก Owner
# =====================================================================

กรอกข้อมูลบัญชีผู้ใช้ Owner
    #กรอกข้อมูลขั้นตอนที่ 1 (รูปเจ้าของอุปกรณ์ ชื่อผู้ใช้ อีเมล รหัสผ่าน)
    [Arguments]    ${Data}
    Upload Owner Picture           ${Data}[Picture]
    Input Owner UsernameR          ${Data}[UsernameR]
    Input Owner Email              ${Data}[Email]
    Input Owner PasswordR          ${Data}[PasswordR]
    Input Owner Confirmpassword    ${Data}[Confirmpassword]

    # ช่องสุดท้ายไม่มีช่องถัดไปมา blur ให้ ต้อง Tab ออกเองระบบจึงจะตรวจสอบ
    Keyboard Key    press    Tab

กรอกข้อมูลส่วนตัว Owner
    #กรอกข้อมูลขั้นตอนที่ 2 (ข้อมูลส่วนตัวและที่อยู่)
    [Arguments]    ${Data}
    Input Owner Firstname    ${Data}[Firstname]
    Input Owner Surname      ${Data}[Surname]
    Select Owner Gender      ${Data}[Gender]
    Input Birthdate          ${Data}[Daybirth]    ${Data}[Monthbirth]    ${Data}[Yearbirth]
    Input Owner Tel          ${Data}[Tel]
    Input Owner Hnum         ${Data}[Hnum]
    Input Owner Alley        ${Data}[Alley]
    Input Owner Group        ${Data}[Group]
    Input Owner District     ${Data}[District]
    Input Owner Canton       ${Data}[Canton]
    Input Owner Province     ${Data}[Province]
    Input Owner Postcode     ${Data}[Postcode]
    Keyboard Key             press    Tab

ดำเนินการสมัครสมาชิก Owner
    #กรอกครบ 2 ขั้นตอนแล้วกดสมัคร คืนหัวข้อ popup ที่ระบบแสดง
    #ถ้าติดที่ขั้นตอนใด คืนข้อความแจ้งเตือนบนหน้าจอ (คั่นด้วย " | ") ไม่มีข้อความเลยคืนค่าว่าง
    [Arguments]    ${Data}
    Open Register Owner Page
    กรอกข้อมูลบัญชีผู้ใช้ Owner    ${Data}
    ${Clicked}=    Click Next Button
    ${OnStep2}=    Is Register Owner Step2 Displayed
    IF    not ${Clicked} or not ${OnStep2}
        ${Result}=    อ่านข้อความแจ้งเตือนบนหน้าจอ
        RETURN    ${Result}
    END

    กรอกข้อมูลส่วนตัว Owner    ${Data}
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

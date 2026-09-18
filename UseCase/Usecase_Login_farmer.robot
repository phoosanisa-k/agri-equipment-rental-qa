*** Settings ***
Documentation     TC01 - Login Farmer (Usecase) | ทดสอบขั้นตอนการเข้าสู่ระบบจริงแบบครบยูสเคส (TC01_F01-F06)
...               แยกมาจาก Login_farmer.robot (ซึ่งเหลือเฉพาะทดสอบข้อความแจ้งเตือนรายฟิลด์ TC01_01-27)
...               ใช้ข้อมูลคงที่ (fix ค่าตายตัวในสคริปต์) ไม่อ่าน/เขียน Excel เพราะแต่ละสเต็ปมีลำดับและ state ต่อเนื่องกัน
...               (เช่น TC01_F06 ต้องกรอกรหัสผิดติดกัน 3 ครั้งจนบัญชีถูกล็อกในเซสชันเดียว)
...               อ้างอิงจากตาราง TC01-LF01 (LF01-01 ถึง LF01-09) และ TESTDESIGN TC01
Metadata          System      ระบบเว็บศูนย์กลางให้บริการเช่าอุปกรณ์ทางการเกษตร (SRS v7.0)
Metadata          Use Case    TC01 Login Farmer (ยูสเคสเข้าสู่ระบบจริง)

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
${USECASE}            TC01_Usecase_Login_Farmer

# ---------- ตัวชี้วัดที่ใช้ตัดสินผล ----------
${SUCCESS_KEYWORD}    สำเร็จ
${Popup_Success}      text=${SUCCESS_KEYWORD}
${LOGIN_URL_PART}     login-farmer      # ส่วนของ URL ที่บอกว่ายังอยู่หน้าเข้าสู่ระบบ
${POPUP_TIMEOUT}      5s                # รอสั้น ๆ เพราะกรณีที่ต้องไม่สำเร็จจะไม่มี popup

# ---------- บัญชีคงที่ : ผู้ใช้สร้างไว้ล่วงหน้าในระบบจริงแล้ว ใช้กับ F01/F05 ----------
${LOGIN_USERNAME}     somchaikaew
${LOGIN_PASSWORD}     Somc1442!

# รหัสผ่านผิด 3 ชุดตามเอกสาร (LF01-02 ถึง LF01-07) กรอกเรียงกันจนระบบล็อกบัญชี
@{WRONG_PASSWORDS}    wrong123    wrong456    wrong789

# ---------- ตัวแปรระดับกรณีทดสอบ ใช้ส่งข้อมูลให้ teardown ----------
${TC_ID}              UNKNOWN
${ACTUAL_MESSAGE}     ${EMPTY}


*** Test Cases ***
TC01_F01 - เข้าสู่ระบบด้วยบัญชีที่ถูกต้อง
    [Documentation]    Basic Flow (TC01) : บัญชีถูกต้อง ต้องเข้าสู่ระบบสำเร็จ
    Set Test Variable    ${TC_ID}    TC01_F01
    กรณี TC01_F01    ${LOGIN_USERNAME}    ${LOGIN_PASSWORD}

TC01_F02 - เข้าสู่ระบบด้วยรหัสผ่านที่ไม่ถูกต้อง
    [Documentation]    Alternate Flow 5.2.1 : รหัสผ่านไม่ถูกต้อง ต้องถูกปฏิเสธ
    Set Test Variable    ${TC_ID}    TC01_F02
    กรณี TC01_F02    ${LOGIN_USERNAME}    wrong123    รหัสผ่านไม่ถูกต้อง

TC01_F03 - เข้าสู่ระบบด้วยชื่อผู้ใช้ที่ไม่มีในระบบ
    [Documentation]    Alternate Flow 5.2.1 : ไม่พบชื่อผู้ใช้นี้ในระบบ ต้องถูกปฏิเสธ
    Set Test Variable    ${TC_ID}    TC01_F03
    กรณี TC01_F03    notexistuser99    PK01010101    ไม่พบข้อมูลผู้ใช้

TC01_F04 - ไม่กรอกข้อมูลแล้วกดเข้าสู่ระบบ
    [Documentation]    Alternate Flow 3.1 : ไม่กรอกข้อมูล ระบบต้องกันไว้ (แจ้งเตือน หรือปิดปุ่ม)
    Set Test Variable    ${TC_ID}    TC01_F04
    กรณี TC01_F04    ${EMPTY}    ${EMPTY}

TC01_F05 - ออกจากระบบแล้วต้องกลับมาหน้าเข้าสู่ระบบ
    [Documentation]    ออกจากระบบได้ และกลับมาที่หน้าเข้าสู่ระบบ
    Set Test Variable    ${TC_ID}    TC01_F05
    กรณี TC01_F05    ${LOGIN_USERNAME}    ${LOGIN_PASSWORD}

TC01_F06 - กรอกรหัสผ่านผิด 3 ครั้งติดกัน บัญชีต้องถูกระงับ
    [Documentation]    TC01-LF01 (LF01-01 ถึง LF01-09) : รหัสผ่านผิด 3 ครั้งติดกันแล้วบัญชีถูกล็อก
    ...                ใช้บัญชีคงที่ ${LOGIN_USERNAME} เดียวกับ F01/F05 : เคสนี้จะทำให้บัญชีถูกล็อกถาวร
    ...                รันครั้งต่อไป F01/F05/F02 จะเข้าสู่ระบบด้วยบัญชีนี้ไม่ได้อีก ต้องสร้าง/ปลดล็อกบัญชีใหม่ก่อนรันซ้ำ
    Set Test Variable    ${TC_ID}    TC01_F06
    กรณี TC01_F06    ${LOGIN_USERNAME}    ${LOGIN_PASSWORD}


*** Keywords ***
# ---------- 1. เตรียมและปิดชุดทดสอบ ----------

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


# ---------- 2. กรณีทดสอบยูสเคสเข้าสู่ระบบจริง (TC01_F01 - TC01_F06) ----------

กรณี TC01_F01
    [Documentation]    บัญชีถูกต้อง ต้องมีข้อความแจ้งสำเร็จ และต้องออกจากหน้าเข้าสู่ระบบจริง
    ...                ใช้บัญชีคงที่ ${LOGIN_USERNAME} ที่สร้างไว้ล่วงหน้าในระบบแล้ว
    [Arguments]    ${Username}    ${Password}

    ${Message}=    เข้าสู่ระบบ    ${Username}    ${Password}
    ${Left}=       รอสถานะหน้าเข้าสู่ระบบ    ${False}
    ${Url}=        Get Url

    บันทึกผลที่ได้จริง    ${Message} (หน้าปัจจุบัน ${Url})
    เก็บภาพหลักฐาน       เข้าสู่ระบบสำเร็จ

    Should Contain    ${Message}    ${SUCCESS_KEYWORD}
    ...    msg=เข้าสู่ระบบไม่สำเร็จ ระบบตอบกลับว่า "${Message}"
    Should Be True    ${Left}
    ...    msg=ระบบแจ้งว่าสำเร็จ แต่ยังคงอยู่ที่หน้าเข้าสู่ระบบ (${Url})

กรณี TC01_F02
    [Documentation]    รหัสผ่านไม่ถูกต้อง ต้องถูกปฏิเสธ (ใส่ผิดครั้งเดียว ไม่ถึงเกณฑ์ล็อกบัญชีของ F06)
    [Arguments]    ${Username}    ${Password}    ${ExpectedResult}
    เข้าสู่ระบบแล้วต้องถูกปฏิเสธ    ${Username}    ${Password}    ${ExpectedResult}    รหัสผ่านไม่ถูกต้อง

กรณี TC01_F03
    [Documentation]    ชื่อผู้ใช้ที่ไม่มีในระบบ ต้องถูกปฏิเสธและไม่พาออกจากหน้าเข้าสู่ระบบ
    [Arguments]    ${Username}    ${Password}    ${ExpectedResult}
    เข้าสู่ระบบแล้วต้องถูกปฏิเสธ    ${Username}    ${Password}    ${ExpectedResult}    ไม่มีชื่อผู้ใช้นี้

เข้าสู่ระบบแล้วต้องถูกปฏิเสธ
    [Documentation]    ขั้นตอนร่วมของ TC01_F02 และ TC01_F03 : เข้าสู่ระบบแล้วต้องไม่ผ่าน และข้อความต้องตรงเอกสาร
    [Arguments]    ${Username}    ${Password}    ${ExpectedResult}    ${ชื่อภาพ}

    ${Message}=    เข้าสู่ระบบ    ${Username}    ${Password}

    บันทึกผลที่ได้จริง    ${Message}
    เก็บภาพหลักฐาน       ${ชื่อภาพ}

    ต้องเข้าสู่ระบบไม่สำเร็จ       ${Message}
    ข้อความต้องตรงกับที่คาดหวัง    ${Message}    ${ExpectedResult}

กรณี TC01_F04
    [Documentation]    ไม่กรอกข้อมูลแล้วกดปุ่ม ระบบต้องกันไว้ (แจ้งเตือน หรือปิดปุ่ม ถือว่าป้องกันได้ทั้งสองทาง)
    [Arguments]    ${Username}    ${Password}

    Open Login Page
    Input Username    ${Username}
    Input Password    ${Password}
    Keyboard Key      press    Tab

    ${Clicked}=     Click Button If Enabled    ${Btn_Login}
    ${Messages}=    Get Validation Messages
    ${Count}=       Get Length    ${Messages}
    ${Summary}=     รวมข้อความ    ${Messages}    ปุ่มเข้าสู่ระบบถูกปิดใช้งาน ระบบไม่ให้เข้าสู่ระบบ
    ${Left}=        รอสถานะหน้าเข้าสู่ระบบ    ${False}

    บันทึกผลที่ได้จริง    ${Summary}
    เก็บภาพหลักฐาน       ไม่กรอกข้อมูล

    Should Not Be True    ${Left}    msg=ระบบยอมให้เข้าสู่ระบบทั้งที่ไม่ได้กรอกข้อมูล
    ${Prevented}=    Evaluate    (not ${Clicked}) or ${Count} > 0
    Should Be True    ${Prevented}    msg=ระบบไม่ได้แจ้งเตือนและไม่ได้ปิดปุ่มไว้เมื่อไม่กรอกข้อมูล

กรณี TC01_F05
    [Documentation]    ออกจากระบบแล้วต้องกลับมาหน้าหลัก
    ...                ปุ่มออกจากระบบซ่อนอยู่ในเมนูโปรไฟล์ ต้องกดปุ่มโปรไฟล์เปิดเมนูก่อนจึงจะเห็น
    ...                ใช้บัญชีคงที่ ${LOGIN_USERNAME} ที่สร้างไว้ล่วงหน้าในระบบแล้ว
    [Arguments]    ${Username}    ${Password}

    ${Message}=    เข้าสู่ระบบ    ${Username}    ${Password}
    ${Left}=       รอสถานะหน้าเข้าสู่ระบบ    ${False}
    Should Be True    ${Left}
    ...    msg=เข้าสู่ระบบไม่สำเร็จ จึงยังทดสอบการออกจากระบบไม่ได้ (${Message})

    ${Found}=    Is Element Visible    ${Btn_UserProfile}
    Should Be True    ${Found}    msg=ไม่พบปุ่มโปรไฟล์บนหัวเว็บ จึงเปิดเมนูออกจากระบบไม่ได้
    Click    ${Btn_UserProfile}
    Click    ${Btn_Logout}

    ${BackToHome}=    รอกลับหน้าหลัก    ${20}
    ${Url}=           Get Url

    บันทึกผลที่ได้จริง    ออกจากระบบแล้วไปที่หน้า ${Url}
    เก็บภาพหลักฐาน       ออกจากระบบ

    Should Be True    ${BackToHome}
    ...    msg=กดออกจากระบบแล้วไม่ได้กลับมาหน้าหลัก (อยู่ที่ ${Url})

กรณี TC01_F06
    [Documentation]    รหัสผ่านผิด 3 ครั้งติดกันแล้วระบบต้องระงับบัญชี (LF01-01 ถึง LF01-09)
    ...                ใช้บัญชีสมัครใหม่ เพราะบัญชีที่ถูกล็อกแล้วใช้ซ้ำในรอบถัดไปไม่ได้
    [Arguments]    ${Username}    ${Password}

    ${Records}=    Create List

    # LF01-02 ถึง LF01-07 : กรอกรหัสผ่านผิด 3 ครั้ง
    FOR    ${Index}    ${Wrong}    IN ENUMERATE    @{WRONG_PASSWORDS}    start=1
        ${Message}=    เข้าสู่ระบบ    ${Username}    ${Wrong}
        Append To List    ${Records}    ครั้งที่ ${Index} (${Wrong}) : ${Message}
        เก็บภาพหลักฐาน    ผิดครั้งที่ ${Index}
        ต้องเข้าสู่ระบบไม่สำเร็จ    ${Message}
    END

    # LF01-08 ถึง LF01-09 : รหัสผ่านถูกต้อง แต่บัญชีถูกระงับไปแล้ว
    ${Final}=    เข้าสู่ระบบ    ${Username}    ${Password}
    Append To List    ${Records}    รหัสผ่านถูกต้องหลังถูกล็อก : ${Final}
    เก็บภาพหลักฐาน    บัญชีถูกระงับ

    ${Summary}=    Evaluate    " | ".join($Records)
    บันทึกผลที่ได้จริง    ${Summary}

    ต้องเข้าสู่ระบบไม่สำเร็จ    ${Final}
    ข้อความต้องกล่าวถึง        ${Final}    ระงับ    ล็อก    ล็อค    lock    suspend


# ---------- 3. ขั้นตอนย่อยของการเข้าสู่ระบบ ----------

เข้าสู่ระบบ
    [Documentation]    เปิด context ใหม่ กรอกข้อมูล กดปุ่ม แล้วคืนข้อความที่ระบบตอบกลับ
    [Arguments]    ${Username}    ${Password}

    Run Keyword And Ignore Error    Close Test Context
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
    [Documentation]    รอ popup แจ้งสำเร็จก่อน ไม่มีจึงดูว่าเปลี่ยนหน้าไปแล้วหรือมีข้อความแจ้งเตือน
    ${Success}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Popup_Success}    visible    ${POPUP_TIMEOUT}

    IF    ${Success}
        ${Text}=    Get Text    ${Popup_Success}
        Close Login Popup
        RETURN    ${Text}
    END

    # บางหน้าไม่มี popup แต่เด้งไปหน้าถัดไปเลย ถือว่าสำเร็จเช่นกัน
    ${Left}=    รอสถานะหน้าเข้าสู่ระบบ    ${False}
    IF    ${Left}
        ${Url}=    Get Url
        RETURN    เข้าสู่ระบบสำเร็จ (เปลี่ยนไปหน้า ${Url})
    END

    ${Messages}=    Get Validation Messages
    ${Result}=      รวมข้อความ    ${Messages}    ระบบไม่ตอบสนองใด ๆ (ไม่มี popup และไม่มีข้อความแจ้งเตือน)
    RETURN    ${Result}

รอสถานะหน้าเข้าสู่ระบบ
    [Documentation]    รอจน URL ถึงสถานะที่ต้องการ (${True} = กลับมาหน้าเข้าสู่ระบบ / ${False} = ออกจากหน้าแล้ว)
    ...                รอเป็นรอบสั้น ๆ เพื่อไม่ให้กรณีที่ต้องไม่สำเร็จเสียเวลารอนาน
    [Arguments]    ${OnLoginPage}    ${Rounds}=${10}
    FOR    ${Round}    IN RANGE    ${Rounds}
        ${Url}=    Get Url
        ${Now}=    Evaluate    '${LOGIN_URL_PART}' in $Url
        IF    ${Now} == ${OnLoginPage}    RETURN    ${True}
        Sleep    0.5s
    END
    RETURN    ${False}

รอกลับหน้าหลัก
    [Documentation]    รอจน URL เป็นหน้าหลัก (${Base_URL}/ เฉย ๆ ไม่มี path ต่อท้าย) ภายในเวลาที่กำหนด
    [Arguments]    ${Rounds}=${10}
    FOR    ${Round}    IN RANGE    ${Rounds}
        ${Url}=    Get Url
        ${Now}=    Evaluate    $Url.rstrip('/') == '${Base_URL}'.rstrip('/')
        IF    ${Now}    RETURN    ${True}
        Sleep    0.5s
    END
    RETURN    ${False}


# ---------- 4. คีย์เวิร์ดช่วยเหลือ : บันทึกผล ตรวจผล เก็บหลักฐาน ----------

บันทึกผลที่ได้จริง
    [Documentation]    จำข้อความที่ระบบตอบกลับไว้ให้ teardown ใช้เขียน log เมื่อกรณีทดสอบไม่ผ่าน
    [Arguments]    ${Text}
    Set Test Variable    ${ACTUAL_MESSAGE}    ${Text}

รวมข้อความ
    [Documentation]    รวมข้อความในลิสต์เป็นข้อความเดียว ลิสต์ว่างให้ใช้ข้อความสำรอง
    [Arguments]    ${Messages}    ${Fallback}
    ${Count}=    Get Length    ${Messages}
    IF    ${Count} == 0    RETURN    ${Fallback}
    ${Joined}=    Evaluate    " | ".join($Messages)
    RETURN    ${Joined}

ต้องเข้าสู่ระบบไม่สำเร็จ
    [Documentation]    ยืนยันว่าไม่มีข้อความแจ้งสำเร็จ และยังอยู่ที่หน้าเข้าสู่ระบบ
    [Arguments]    ${Message}
    ${Url}=    Get Url
    Should Not Contain    ${Message}    ${SUCCESS_KEYWORD}
    ...    msg=ระบบให้เข้าสู่ระบบสำเร็จ ทั้งที่ควรปฏิเสธ (ข้อความ "${Message}")
    Should Contain    ${Url}    ${LOGIN_URL_PART}
    ...    msg=ระบบพาออกจากหน้าเข้าสู่ระบบ ทั้งที่ควรปฏิเสธ (ไปที่ ${Url})

ข้อความต้องตรงกับที่คาดหวัง
    [Documentation]    ยืนยันว่าข้อความตรงกับ ExpectedResult ที่กำหนดไว้ในสคริปต์
    [Arguments]    ${Message}    ${ExpectedResult}
    ${Matched}=    ข้อความตรงกับที่คาดหวัง    ${Message}    ${ExpectedResult}
    Should Be True    ${Matched}
    ...    msg=ระบบตอบว่า "${Message}" แต่ที่กำหนดไว้คือ "${ExpectedResult}"

ข้อความต้องกล่าวถึง
    [Documentation]    ยืนยันว่ามีคำที่กำหนดอย่างน้อยหนึ่งคำ ใช้กับกรณีที่ข้อความระบบเป็นประโยคยาว
    [Arguments]    ${Message}    @{Keywords}
    ${Lower}=    Convert To Lower Case    ${Message}
    # lambda รับค่าผ่าน default argument เพราะ RF มองไม่เห็น $ตัวแปร ใน comprehension
    ${Matched}=    Evaluate    any(map(lambda k, t=$Lower: k.lower() in t, $Keywords))
    Should Be True    ${Matched}
    ...    msg=ข้อความ "${Message}" ไม่มีคำว่า ${Keywords} จึงไม่ตรงกับที่กำหนดไว้

เก็บภาพหลักฐาน
    [Documentation]    บันทึกภาพหน้าจอเป็นหลักฐาน ตั้งชื่อ <ยูสเคส>_<รหัส>_<คำอธิบาย>
    [Arguments]    ${Name}
    Run Keyword And Ignore Error
    ...    Take Screenshot    ${SCREENSHOT_DIR}/${USECASE}_${TC_ID}_${Name}    fullPage=True

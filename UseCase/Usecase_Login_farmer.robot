*** Settings ***
Documentation     TC01 - Login Farmer (Usecase) | ทดสอบยูสเคสเข้าสู่ระบบครบ TC01_F01-F06 ตาม TC01-LF01 (LF01-01 ถึง LF01-09) และ TESTDESIGN TC01
...               ใช้ข้อมูลคงที่ ไม่อ่าน/เขียน Excel เพราะแต่ละสเต็ปมีลำดับ state ต่อเนื่องกัน (F06 กรอกรหัสผิด 3 ครั้งจนบัญชีถูกล็อกในเซสชันเดียว)
Metadata          Use Case    TC01 Login Farmer (ยูสเคสเข้าสู่ระบบจริง)

Resource          ../Resources/keywords.robot
Library           OperatingSystem
Library           String
Library           Collections

Suite Setup       เตรียมชุดทดสอบยูสเคส
Suite Teardown    ปิดชุดทดสอบ
Test Teardown     เก็บผลท้ายกรณีทดสอบ

*** Variables ***
# ---------- ไฟล์และโฟลเดอร์ ----------
${USECASE}            TC01_Usecase_Login_Farmer
${SCREENSHOT_DIR}     ${CURDIR}/../Screenshot/${USECASE}

# ---------- ข้อความที่คาดหวังตามเอกสารเทสเคส (เทียบตรงกัน 100%) ----------
${EXP_LOGIN_SUCCESS}      เข้าสู่ระบบสำเร็จ           # LF02-03 / LF06-03
${EXP_WRONG_PASSWORD}     รหัสผ่านไม่ถูกต้อง          # LF01-03 / LF01-05 / LF03-03
${EXP_USER_NOT_FOUND}     ไม่พบข้อมูลผู้ใช้           # LF04-03
${EXP_EMPTY_LOGIN}        กรุณากรอกชื่อผู้ใช้ | กรุณากรอกรหัสผ่าน    # LF05-03 (ข้อความแดงใต้ช่อง เรียงตามลำดับช่อง คั่นด้วย " | ")
${EXP_ACCOUNT_LOCKED}     บัญชีถูกระงับการใช้งาน       # LF01-09

# ---------- ตัวชี้วัดสถานะหน้า ----------
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
    #TC01-LF02 : บัญชีถูกต้อง ต้องแสดง "เข้าสู่ระบบสำเร็จ" และออกจากหน้าเข้าสู่ระบบ
    Set Test Variable    ${TC_ID}    TC01_F01
    กรณี TC01_F01    ${LOGIN_USERNAME}    ${LOGIN_PASSWORD}

TC01_F02 - เข้าสู่ระบบด้วยรหัสผ่านที่ไม่ถูกต้อง
    #TC01-LF03 : รหัสผ่านไม่ถูกต้อง ต้องแสดง "รหัสผ่านไม่ถูกต้อง" และยังอยู่ที่หน้าเข้าสู่ระบบ
    Set Test Variable    ${TC_ID}    TC01_F02
    เข้าสู่ระบบแล้วต้องถูกปฏิเสธ    ${LOGIN_USERNAME}    wrong123    ${EXP_WRONG_PASSWORD}

TC01_F03 - เข้าสู่ระบบด้วยชื่อผู้ใช้ที่ไม่มีในระบบ
    #TC01-LF04 : ไม่มีชื่อผู้ใช้นี้ ต้องแสดง "ไม่พบข้อมูลผู้ใช้" และยังอยู่ที่หน้าเข้าสู่ระบบ
    Set Test Variable    ${TC_ID}    TC01_F03
    เข้าสู่ระบบแล้วต้องถูกปฏิเสธ    notexistuser99    PK01010101    ${EXP_USER_NOT_FOUND}

TC01_F04 - ไม่กรอกข้อมูลแล้วกดเข้าสู่ระบบ
    #TC01-LF05 : ไม่กรอกข้อมูล ต้องแสดง "กรุณากรอกชื่อผู้ใช้" และ "กรุณากรอกรหัสผ่าน" และยังอยู่ที่หน้าเข้าสู่ระบบ
    Set Test Variable    ${TC_ID}    TC01_F04
    เข้าสู่ระบบแล้วต้องถูกปฏิเสธ    ${EMPTY}    ${EMPTY}    ${EXP_EMPTY_LOGIN}

TC01_F05 - ออกจากระบบแล้วต้องกลับมาหน้าหลัก
    #TC01-LF06 : เข้าสู่ระบบ -> เปิดเมนูโปรไฟล์ -> ออกจากระบบ แล้วต้องกลับมาหน้าหลัก
    Set Test Variable    ${TC_ID}    TC01_F05
    กรณี TC01_F05    ${LOGIN_USERNAME}    ${LOGIN_PASSWORD}

TC01_F06 - กรอกรหัสผ่านผิด 3 ครั้งติดกัน บัญชีต้องถูกระงับ
    #TC01-LF01 (LF01-01 ถึง LF01-09) : รหัสผ่านผิด 3 ครั้งติดกัน แล้วกรอกรหัสถูกต้องต้องแสดง "บัญชีถูกระงับการใช้งาน"
    Set Test Variable    ${TC_ID}    TC01_F06
    กรณี TC01_F06    ${LOGIN_USERNAME}    ${LOGIN_PASSWORD}

*** Keywords ***
# ---------- 1. กรณีทดสอบยูสเคสเข้าสู่ระบบ ----------

กรณี TC01_F01
    #LF02-03 : ข้อความต้องเป็น "เข้าสู่ระบบสำเร็จ" และต้องออกจากหน้าเข้าสู่ระบบ
    [Arguments]    ${Username}    ${Password}
    ${Message}=    เข้าสู่ระบบ    ${Username}    ${Password}
    บันทึกผลที่ได้จริง    ${Message}
    เทียบผลจริงกับที่คาดหวัง    ${Message}    ${EXP_LOGIN_SUCCESS}
    ${Left}=    รอสถานะหน้าเข้าสู่ระบบ    ${False}
    Should Be True    ${Left}    msg=ระบบแจ้งว่าสำเร็จ แต่ยังคงอยู่ที่หน้าเข้าสู่ระบบ

เข้าสู่ระบบแล้วต้องถูกปฏิเสธ
    #ขั้นตอนร่วมของ F02 F03 F04 : ข้อความต้องตรงเอกสาร 100% และต้องยังอยู่ที่หน้าเข้าสู่ระบบ
    [Arguments]    ${Username}    ${Password}    ${ExpectedResult}
    ${Message}=    เข้าสู่ระบบ    ${Username}    ${Password}
    บันทึกผลที่ได้จริง    ${Message}
    เทียบผลจริงกับที่คาดหวัง    ${Message}    ${ExpectedResult}
    ต้องยังอยู่ที่หน้าเข้าสู่ระบบ

กรณี TC01_F05
    #LF06-03 ถึง LF06-05 : เข้าสู่ระบบสำเร็จ -> เมนูโปรไฟล์มีปุ่มออกจากระบบ -> ออกจากระบบแล้วกลับหน้าหลัก
    [Arguments]    ${Username}    ${Password}
    ${Message}=    เข้าสู่ระบบ    ${Username}    ${Password}
    บันทึกผลที่ได้จริง    ${Message}
    เทียบผลจริงกับที่คาดหวัง    ${Message}    ${EXP_LOGIN_SUCCESS}
    ${Left}=    รอสถานะหน้าเข้าสู่ระบบ    ${False}
    Should Be True    ${Left}    msg=เข้าสู่ระบบแล้วยังอยู่ที่หน้าเข้าสู่ระบบ จึงทดสอบการออกจากระบบไม่ได้

    # LF06-04 : เปิดเมนูโปรไฟล์ ต้องมีปุ่มออกจากระบบ
    Click    ${Btn_UserProfile}
    ${HasLogout}=    Is Element Visible    ${Btn_Logout}
    Should Be True    ${HasLogout}    msg=เปิดเมนูโปรไฟล์แล้วไม่พบปุ่มออกจากระบบ

    # LF06-05 : ออกจากระบบแล้วต้องกลับหน้าหลัก
    Click    ${Btn_Logout}
    ${BackToHome}=    รอกลับหน้าหลัก    ${20}
    ${Url}=           Get Url
    บันทึกผลที่ได้จริง    ${Url}
    Should Be True    ${BackToHome}    msg=กดออกจากระบบแล้วไม่ได้กลับมาหน้าหลัก (อยู่ที่ ${Url})

กรณี TC01_F06
    #LF01-02 ถึง LF01-09 : ผิด 3 ครั้งต้องได้ "รหัสผ่านไม่ถูกต้อง" ทุกครั้ง แล้วรหัสถูกต้องต้องได้ "บัญชีถูกระงับการใช้งาน"
    #ตรวจครบทุกครั้งก่อนสรุป (Continue On Failure) เพื่อให้เห็นผลของทุกสเต็ปใน log
    [Arguments]    ${Username}    ${Password}
    ${Records}=    Create List
    FOR    ${Index}    ${Wrong}    IN ENUMERATE    @{WRONG_PASSWORDS}    start=1
        ${Message}=    เข้าสู่ระบบ    ${Username}    ${Wrong}
        Append To List    ${Records}    ครั้งที่ ${Index} (${Wrong}) : "${Message}"
        Run Keyword And Continue On Failure    เทียบผลจริงกับที่คาดหวัง    ${Message}    ${EXP_WRONG_PASSWORD}
    END

    ${Final}=    เข้าสู่ระบบ    ${Username}    ${Password}
    Append To List    ${Records}    รหัสผ่านถูกต้องหลังผิด 3 ครั้ง : "${Final}"
    ${Summary}=    Evaluate    " | ".join($Records)
    บันทึกผลที่ได้จริง    ${Summary}
    เทียบผลจริงกับที่คาดหวัง    ${Final}    ${EXP_ACCOUNT_LOCKED}

# ---------- 2. ขั้นตอนย่อยของการเข้าสู่ระบบ ----------

เข้าสู่ระบบ
    #เปิด context ใหม่ กรอกข้อมูล กดปุ่ม แล้วคืนข้อความที่ระบบแสดง (ไม่มีข้อความคืนค่าว่าง)
    [Arguments]    ${Username}    ${Password}
    Run Keyword And Ignore Error    Close Test Context
    Open Login Page
    Input Username    ${Username}
    Input Password    ${Password}
    Keyboard Key      press    Tab
    ${Clicked}=    Click Button If Enabled    ${Btn_Login}
    ${Message}=    อ่านข้อความหลังกดเข้าสู่ระบบ    ${Clicked}
    RETURN    ${Message}

อ่านข้อความหลังกดเข้าสู่ระบบ
    #อ่านตามลำดับ : หัวข้อ popup (${Popup_Title}) -> ข้อความแจ้งเตือนสีแดงใต้ช่อง ไม่พบเลยคืนค่าว่าง
    #ไม่อ่านข้อความภาษาอังกฤษของเบราว์เซอร์ (เช่น Please fill out this field.) เพราะเอกสาร dev ไม่ได้ระบุไว้
    [Arguments]    ${Clicked}
    IF    ${Clicked}
        ${HasPopup}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${Popup_Title}    visible    ${POPUP_TIMEOUT}
        IF    ${HasPopup}
            ${Text}=    Get Popup Title
            Close Login Popup
            RETURN    ${Text}
        END
    END
    ${Messages}=    Get Validation Messages
    ${Text}=    Evaluate    " | ".join($Messages)
    RETURN    ${Text}

รอสถานะหน้าเข้าสู่ระบบ
    #รอจน URL ถึงสถานะที่ต้องการ (${True}=อยู่หน้าเข้าสู่ระบบ, ${False}=ออกแล้ว)
    [Arguments]    ${OnLoginPage}    ${Rounds}=${10}
    FOR    ${Round}    IN RANGE    ${Rounds}
        ${Url}=    Get Url
        ${Now}=    Evaluate    '${LOGIN_URL_PART}' in $Url
        IF    ${Now} == ${OnLoginPage}    RETURN    ${True}
        Sleep    0.5s
    END
    RETURN    ${False}

รอกลับหน้าหลัก
    #รอจน URL เป็นหน้าหลัก (${Base_URL}/ ไม่มี path ต่อท้าย)
    [Arguments]    ${Rounds}=${10}
    FOR    ${Round}    IN RANGE    ${Rounds}
        ${Url}=    Get Url
        ${Now}=    Evaluate    $Url.rstrip('/') == '${Base_URL}'.rstrip('/')
        IF    ${Now}    RETURN    ${True}
        Sleep    0.5s
    END
    RETURN    ${False}

ต้องยังอยู่ที่หน้าเข้าสู่ระบบ
    #ยืนยันว่า URL ยังเป็นหน้าเข้าสู่ระบบ
    ${Url}=    Get Url
    ${OnLogin}=    Evaluate    '${LOGIN_URL_PART}' in $Url
    Should Be True    ${OnLogin}    msg=ระบบพาออกจากหน้าเข้าสู่ระบบ ทั้งที่ควรปฏิเสธ (ไปที่ ${Url})

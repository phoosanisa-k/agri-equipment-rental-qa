*** Settings ***
Documentation     TC01 - Login Owner (Usecase) | ทดสอบยูสเคสเข้าสู่ระบบ Functional Flow ของ Owner ตามตาราง 8.1.5 (LO01-01 ถึง LO01-09)
...               ทดสอบเฉพาะ Functional Flow (field validation ตรวจซ้ำแล้วใน Login_farmer.robot ฝั่ง Owner ใช้เงื่อนไขเดียวกัน)
...               ใช้ข้อมูลคงที่ Pre-Condition: บัญชี ${OwnerUser} (Resources/variables.robot) ต้องมีอยู่ในระบบจริง
...               TC01_F06 สมัครบัญชีใหม่เองแทนการใช้ ${LOGIN_USERNAME} เพราะเคสนี้ทำให้บัญชีถูกล็อก
Metadata          Use Case    TC01 Login Owner (Functional Flow)

Resource          ../Resources/keywords.robot
Library           OperatingSystem
Library           String
Library           Collections

Suite Setup       เตรียมชุดทดสอบยูสเคส
Suite Teardown    ปิดชุดทดสอบ
Test Teardown     เก็บผลท้ายกรณีทดสอบ

*** Variables ***
# ---------- ไฟล์และโฟลเดอร์ ----------
${USECASE}            TC01_Usecase_Login_Owner
${SCREENSHOT_DIR}     ${CURDIR}/../Screenshot/${USECASE}

# ---------- ข้อความที่คาดหวังตามเอกสารเทสเคส (เทียบตรงกัน 100%) ----------
${EXP_LOGIN_SUCCESS}      เข้าสู่ระบบสำเร็จ               # LO02-04 / LO06-01
${EXP_USER_NOT_FOUND}     ไม่พบข้อมูลผู้ใช้               # LO01-03 / LO01-05 / LO03-04 / LO04-04
${EXP_EMPTY_LOGIN}        กรุณากรอกชื่อผู้ใช้ | กรุณากรอกรหัสผ่าน    # LO05-02 (ข้อความแดงใต้ช่อง เรียงตามลำดับช่อง คั่นด้วย " | ")
${EXP_LOGOUT_SUCCESS}     ออกจากระบบสำเร็จ!              # LO06-03
${EXP_ACCOUNT_LOCKED}     บัญชีถูกระงับการใช้งาน           # LO01-09
${EXP_REGISTER_SUCCESS}   สมัครสมาชิกสำเร็จ!             # ใช้ตอนสมัครบัญชีสำรองให้ TC01_F06

# ---------- ตัวชี้วัดสถานะหน้า ----------
${LOGIN_URL_PART}     login-owner    # ส่วนของ URL ที่บอกว่ายังอยู่หน้าเข้าสู่ระบบ
${POPUP_TIMEOUT}      5s             # รอสั้น ๆ เพราะกรณีที่ต้องไม่สำเร็จจะไม่มี popup

# ---------- บัญชีคงที่ : ผู้ใช้สร้างไว้ล่วงหน้าในระบบจริงแล้ว ใช้กับ F01/F02/F05 ----------
# ใช้บัญชี Owner กลางจาก Resources/variables.robot (${TEST_OWNER_USER} / ${TEST_OWNER_PASS}) ซึ่งมีอยู่ในระบบจริงแล้ว
${LOGIN_USERNAME}     ${OwnerUser}
${LOGIN_PASSWORD}     ${OwnerPass}

# ---------- ใช้เฉพาะตอนสมัครบัญชีสำรองขึ้นมาใหม่ให้ TC01_F06 ----------
${REG_PASSWORD}       PK01010101
${REG_PICTURE}        owner.jpg

# รหัสผ่านผิด 3 ชุดตามเอกสาร (LO01-02 ถึง LO01-07) กรอกเรียงกันจนระบบล็อกบัญชี
@{WRONG_PASSWORDS}    wrong123    wrong456    wrong789

# ---------- ตัวแปรระดับกรณีทดสอบ ใช้ส่งข้อมูลให้ teardown ----------
${TC_ID}              UNKNOWN
${ACTUAL_MESSAGE}     ${EMPTY}

*** Test Cases ***
TC01_F01 - เข้าสู่ระบบด้วยบัญชีที่ถูกต้อง
    #TC01-LO02 : บัญชีถูกต้อง ต้องแสดง "เข้าสู่ระบบสำเร็จ" และออกจากหน้าเข้าสู่ระบบ
    Set Test Variable    ${TC_ID}    TC01_F01
    กรณี TC01_F01    ${LOGIN_USERNAME}    ${LOGIN_PASSWORD}

TC01_F02 - เข้าสู่ระบบด้วยรหัสผ่านที่ไม่ถูกต้อง
    #TC01-LO03 : รหัสผ่านไม่ถูกต้อง ต้องแสดง "ไม่พบข้อมูลผู้ใช้" และยังอยู่ที่หน้าเข้าสู่ระบบ
    Set Test Variable    ${TC_ID}    TC01_F02
    เข้าสู่ระบบแล้วต้องถูกปฏิเสธ    ${LOGIN_USERNAME}    wrong123    ${EXP_USER_NOT_FOUND}

TC01_F03 - เข้าสู่ระบบด้วยชื่อผู้ใช้ที่ไม่มีในระบบ
    #TC01-LO04 : ไม่มีชื่อผู้ใช้นี้ ต้องแสดง "ไม่พบข้อมูลผู้ใช้" และยังอยู่ที่หน้าเข้าสู่ระบบ
    Set Test Variable    ${TC_ID}    TC01_F03
    เข้าสู่ระบบแล้วต้องถูกปฏิเสธ    notexistowner99    ${LOGIN_PASSWORD}    ${EXP_USER_NOT_FOUND}

TC01_F04 - ไม่กรอกข้อมูลแล้วกดปุ่มเข้าสู่ระบบ
    #TC01-LO05 : ไม่กรอกข้อมูล ต้องแสดง "กรุณากรอกชื่อผู้ใช้" และ "กรุณากรอกรหัสผ่าน" และยังอยู่ที่หน้าเข้าสู่ระบบ
    Set Test Variable    ${TC_ID}    TC01_F04
    เข้าสู่ระบบแล้วต้องถูกปฏิเสธ    ${EMPTY}    ${EMPTY}    ${EXP_EMPTY_LOGIN}

TC01_F05 - ออกจากระบบแล้วต้องกลับมาหน้าหลัก
    #TC01-LO06 : ออกจากระบบแล้วต้องแสดง "ออกจากระบบสำเร็จ!" และกลับมาที่หน้าหลัก
    Set Test Variable    ${TC_ID}    TC01_F05
    กรณี TC01_F05    ${LOGIN_USERNAME}    ${LOGIN_PASSWORD}

TC01_F06 - กรอกรหัสผ่านผิด 3 ครั้งติดกัน บัญชีต้องถูกระงับ
    #TC01-LO01 : สมัครบัญชีใหม่ กรอกรหัสผิด 3 ครั้ง (ต้องได้ "ไม่พบข้อมูลผู้ใช้" ทุกครั้ง) แล้วรหัสถูกต้องต้องได้ "บัญชีถูกระงับการใช้งาน"
    Set Test Variable    ${TC_ID}    TC01_F06
    กรณี TC01_F06

*** Keywords ***
# =====================================================================
# 1. กรณีทดสอบยูสเคสเข้าสู่ระบบ (TC01_F01 ถึง F06)
# =====================================================================

กรณี TC01_F01
    #LO02-04 : ข้อความต้องเป็น "เข้าสู่ระบบสำเร็จ" และต้องออกจากหน้าเข้าสู่ระบบ
    [Arguments]    ${Username}    ${Password}
    ${Message}=    เข้าสู่ระบบ Owner    ${Username}    ${Password}
    บันทึกผลที่ได้จริง    ${Message}
    เทียบผลจริงกับที่คาดหวัง    ${Message}    ${EXP_LOGIN_SUCCESS}
    ${Left}=    รอให้ออกจากหน้าเข้าสู่ระบบ
    Should Be True    ${Left}    msg=ระบบแจ้งว่าสำเร็จ แต่ยังคงอยู่ที่หน้าเข้าสู่ระบบ

เข้าสู่ระบบแล้วต้องถูกปฏิเสธ
    #ขั้นตอนร่วมของ F02 F03 F04 : ข้อความต้องตรงเอกสาร 100% และต้องยังอยู่ที่หน้าเข้าสู่ระบบ
    [Arguments]    ${Username}    ${Password}    ${ExpectedResult}
    ${Message}=    เข้าสู่ระบบ Owner    ${Username}    ${Password}
    บันทึกผลที่ได้จริง    ${Message}
    เทียบผลจริงกับที่คาดหวัง    ${Message}    ${ExpectedResult}
    ต้องยังอยู่ที่หน้าเข้าสู่ระบบ

กรณี TC01_F05
    #LO06-01 ถึง LO06-03 : เข้าสู่ระบบสำเร็จ -> เปิดเมนูโปรไฟล์ -> ออกจากระบบ ต้องแสดง "ออกจากระบบสำเร็จ!" และกลับหน้าหลัก
    [Arguments]    ${Username}    ${Password}
    ${Message}=    เข้าสู่ระบบ Owner    ${Username}    ${Password}
    บันทึกผลที่ได้จริง    ${Message}
    เทียบผลจริงกับที่คาดหวัง    ${Message}    ${EXP_LOGIN_SUCCESS}
    ${Left}=    รอให้ออกจากหน้าเข้าสู่ระบบ
    Should Be True    ${Left}    msg=เข้าสู่ระบบแล้วยังอยู่ที่หน้าเข้าสู่ระบบ จึงทดสอบการออกจากระบบไม่ได้

    # LO06-02 : ปุ่มออกจากระบบอยู่ในเมนูโปรไฟล์ ต้องกดเปิดเมนูก่อน
    Click    ${Btn_UserProfile}
    ${HasLogout}=    Is Element Visible    ${Btn_Logout}
    Should Be True    ${HasLogout}    msg=เปิดเมนูโปรไฟล์แล้วไม่พบปุ่มออกจากระบบ

    # LO06-03 : กดออกจากระบบ อ่านหัวข้อ popup แล้วต้องกลับหน้าหลัก
    Click    ${Btn_Logout}
    ${HasPopup}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Popup_Title}    visible    ${POPUP_TIMEOUT}
    ${Logout}=    Set Variable    ${EMPTY}
    IF    ${HasPopup}
        ${Logout}=    Get Popup Title
    END
    บันทึกผลที่ได้จริง    ${Logout}
    เทียบผลจริงกับที่คาดหวัง    ${Logout}    ${EXP_LOGOUT_SUCCESS}
    ${BackToHome}=    รอกลับหน้าหลัก
    ${Url}=    Get Url
    Should Be True    ${BackToHome}    msg=กดออกจากระบบแล้วไม่ได้กลับมาหน้าหลัก (อยู่ที่ ${Url})

กรณี TC01_F06
    #สมัครบัญชีใหม่เอง (ไม่ใช้ ${LOGIN_USERNAME} เพราะเคสนี้ทำให้บัญชีถูกล็อก)
    #LO01-02 ถึง LO01-09 : ผิด 3 ครั้งต้องได้ "ไม่พบข้อมูลผู้ใช้" ทุกครั้ง แล้วรหัสถูกต้องต้องได้ "บัญชีถูกระงับการใช้งาน"
    #ตรวจครบทุกครั้งก่อนสรุป (Continue On Failure) เพื่อให้เห็นผลของทุกสเต็ปใน log
    ${Username}=    สมัครบัญชี Owner สำหรับทดสอบ    ${REG_PASSWORD}
    ${Records}=     Create List
    FOR    ${Index}    ${Wrong}    IN ENUMERATE    @{WRONG_PASSWORDS}    start=1
        ${Message}=    เข้าสู่ระบบ Owner    ${Username}    ${Wrong}
        Append To List    ${Records}    ครั้งที่ ${Index} (${Wrong}) : "${Message}"
        Run Keyword And Continue On Failure    เทียบผลจริงกับที่คาดหวัง    ${Message}    ${EXP_USER_NOT_FOUND}
    END

    ${Final}=    เข้าสู่ระบบ Owner    ${Username}    ${REG_PASSWORD}
    Append To List    ${Records}    รหัสผ่านถูกต้องหลังผิด 3 ครั้ง : "${Final}"
    ${Summary}=    Evaluate    " | ".join($Records)
    บันทึกผลที่ได้จริง    ${Summary}
    เทียบผลจริงกับที่คาดหวัง    ${Final}    ${EXP_ACCOUNT_LOCKED}

# =====================================================================
# 2. ขั้นตอนย่อยของการเข้าสู่ระบบ
# =====================================================================

เข้าสู่ระบบ Owner
    #เปิด context ใหม่ กรอกข้อมูล กดปุ่มเข้าสู่ระบบ แล้วคืนข้อความที่ระบบแสดง (ไม่มีข้อความคืนค่าว่าง)
    [Arguments]    ${Username}    ${Password}
    Run Keyword And Ignore Error    Close Test Context
    Open Login Owner Page
    Input Owner Username    ${Username}
    Input Owner Password    ${Password}
    Keyboard Key             press    Tab
    ${Clicked}=    Click Owner Login Button
    ${Message}=    อ่านข้อความหลังกดเข้าสู่ระบบ    ${Clicked}
    RETURN    ${Message}

อ่านข้อความหลังกดเข้าสู่ระบบ
    #อ่านตามลำดับ : หัวข้อ popup (${Popup_Title}) -> ข้อความแจ้งเตือนสีแดงใต้ช่อง ไม่พบเลยคืนค่าว่าง
    #ไม่อ่านข้อความภาษาอังกฤษของเบราว์เซอร์ (เช่น Please fill out this field.) เพราะเอกสาร dev ไม่ได้ระบุไว้
    #popup สำเร็จฝั่ง Owner ปิดด้วยปุ่ม "ไปหน้าแรก" (${Btn_OGoHome})
    [Arguments]    ${Clicked}
    IF    ${Clicked}
        ${HasPopup}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${Popup_Title}    visible    ${POPUP_TIMEOUT}
        IF    ${HasPopup}
            ${Text}=    Get Popup Title
            ${HasButton}=    Is Element Visible    ${Btn_OGoHome}
            IF    ${HasButton}    Run Keyword And Ignore Error    Click    ${Btn_OGoHome}
            RETURN    ${Text}
        END
    END
    ${Messages}=    Get Validation Messages
    ${Text}=    Evaluate    " | ".join($Messages)
    RETURN    ${Text}

รอให้ออกจากหน้าเข้าสู่ระบบ
    #รอจน URL ออกจากหน้าเข้าสู่ระบบ คืน True เมื่อออกแล้ว (รอ 20 รอบ/10s กันหน้าเปลี่ยนช้ากว่า popup)
    FOR    ${Round}    IN RANGE    20
        ${Url}=     Get Url
        ${Left}=    Evaluate    '${LOGIN_URL_PART}' not in $Url
        IF    ${Left}    RETURN    ${True}
        Sleep    0.5s
    END
    RETURN    ${False}

รอกลับหน้าหลัก
    #รอจน URL เป็นหน้าหลัก (${Base_URL}/ ไม่มี path ต่อท้าย)
    FOR    ${Round}    IN RANGE    20
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

สมัครบัญชี Owner สำหรับทดสอบ
    #สมัครบัญชี Owner ใหม่ผ่านหน้าสมัครจริง คืนชื่อผู้ใช้ที่ได้ (กัน TC01_F06 แตะบัญชีหลัก ${LOGIN_USERNAME})
    [Arguments]    ${Password}
    ${Stamp}=       Get Time    epoch
    ${Suffix}=      Evaluate    str($Stamp)[-8:] + str(random.randint(100, 999))    modules=random
    ${Username}=    Set Variable    lockowner${Suffix}
    ${Tel}=         Evaluate    "09" + "".join(str(random.randint(0, 9)) for _ in range(8))    modules=random

    Run Keyword And Ignore Error    Close Test Context
    Open Register Owner Page

    # ---------- ขั้นตอนที่ 1 : บัญชีและรหัสผ่าน ----------
    Upload Owner Picture           ${REG_PICTURE}
    Input Owner UsernameR          ${Username}
    Input Owner Email              ${Username}@mail.com
    Input Owner PasswordR          ${Password}
    Input Owner Confirmpassword    ${Password}
    Keyboard Key    press    Tab
    ${Clicked}=    Click Next Button
    Should Be True    ${Clicked}    msg=สมัครบัญชี Owner สำหรับทดสอบไม่สำเร็จ (ไม่ผ่านขั้นตอนที่ 1)

    # ---------- ขั้นตอนที่ 2 : ข้อมูลส่วนตัวและที่อยู่ ----------
    Input Owner Firstname    ภูษณิศา
    Input Owner Surname      คำมา ศรีสุข
    Select Owner Gender      หญิง
    Input Birthdate          12    6    2546
    Input Owner Tel          ${Tel}
    Input Owner Hnum         10/3ก
    Input Owner Alley        สุขุมวิท 11/2
    Input Owner Group        หมู่ 5
    Input Owner District     บางนา
    Input Owner Canton       บางรัก
    Input Owner Province     สุราษฎร์ธานี
    Input Owner Postcode     12345
    Keyboard Key             press    Tab
    ${Clicked}=    Click Register Button
    Should Be True    ${Clicked}    msg=สมัครบัญชี Owner สำหรับทดสอบไม่สำเร็จ (ปุ่มสมัครสมาชิกถูกปิดใช้งาน)

    # ต้องได้ popup "สมัครสมาชิกสำเร็จ!" ตรงตัว
    ${HasPopup}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Popup_Title}    visible    ${DEFAULT_TIMEOUT}
    ${Registered}=    Set Variable    ${EMPTY}
    IF    ${HasPopup}
        ${Registered}=    Get Popup Title
    END
    เทียบผลจริงกับที่คาดหวัง    ${Registered}    ${EXP_REGISTER_SUCCESS}

    Log    บัญชี Owner ที่สมัครขึ้นเพื่อทดสอบ : ${Username}    level=INFO
    Run Keyword And Ignore Error    Close Test Context
    RETURN    ${Username}

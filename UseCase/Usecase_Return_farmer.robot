*** Settings ***
Documentation     TC05 - Return Equipment Farmer (Usecase) | อ้างอิงหัวข้อ 7.5 หน้า 79-82
...               Pre-Condition: Login แล้ว + มีรายการสถานะ "จัดส่งเรียบร้อย" อย่างน้อย 1 รายการ
...               (รัน Usecase_ApproveBooking_owner แล้วตาม Usecase_UpdateDelivery_owner ก่อน ไม่สร้างการจองเอง)
...               กลไกปุ่มตามสถานะ: จัดส่งเรียบร้อย→"ยืนยันรับอุปกรณ์" | ได้รับอุปกรณ์→"ส่งคืนอุปกรณ์" | ส่งคืนอุปกรณ์→ไม่มีปุ่ม
...
...               TC05_F01→RT01-01,02(สถานะยังไม่ถูกต้อง) | F02→Pre-Condition(ยืนยันรับ) | F03→BasicFlow ข้อ5(ยกเลิกส่งคืน)
...               F04→BasicFlow 1-7(ส่งคืนสำเร็จ) | F05→RT01-03(คืนซ้ำไม่ได้) | F06→Pre-Condition(ยังไม่ login)
...               RT01-04 ไม่ทำเป็นเคส เพราะต้องจำลองเซิร์ฟเวอร์ล้มขณะทดสอบซึ่งทำผ่านหน้าเว็บไม่ได้
...               หมายเหตุ: เปลี่ยนสถานะจริง รันจบแล้วรายการอยู่ที่ "ส่งคืนอุปกรณ์" ให้ Update Delivery (F06 ฝั่ง Owner) ใช้ต่อ
Metadata          Use Case    TC05 Return Equipment Farmer (Functional Flow)

Resource          ../Resources/keywords.robot
Library           OperatingSystem
Library           String
Library           Collections

Suite Setup       เปิดชุดทดสอบ
Suite Teardown    ปิดชุดทดสอบ
Test Teardown     เก็บผลท้ายกรณีทดสอบ    ปิดกล่องโต้ตอบที่ค้างอยู่

*** Variables ***
# ---------- ไฟล์และโฟลเดอร์ ----------
${USECASE}            TC05_Usecase_Return_Farmer
${SCREENSHOT_DIR}     ${CURDIR}/../Screenshot/${USECASE}

# ---------- บัญชีคงที่ : ผู้เช่าที่มีรายการเช่าอยู่จริงในระบบ ----------
${LOGIN_USERNAME}     somchaikaew
${LOGIN_PASSWORD}     Somc1442!

# ---------- ข้อความที่คาดหวังตามเอกสารเทสเคส (เทียบตรงกัน 100%) ----------
${EXP_LOGIN_SUCCESS}      เข้าสู่ระบบสำเร็จ                       # RT01-01 ถึง RT05-01
${RECEIVE_SUCCESS}        ยืนยันการรับอุปกรณ์เรียบร้อยแล้ว          # RT02-03
${RETURN_QUESTION}        ยืนยันการส่งคืนอุปกรณ์ใช่หรือไม่?          # RT04-03
${RETURN_SUCCESS}         ส่งคืนอุปกรณ์เรียบร้อยแล้ว                # RT04-04

# ---------- ข้อความบนปุ่ม ----------
${BTN_TEXT_RECEIVE}   ยืนยันรับอุปกรณ์
${BTN_TEXT_RETURN}    ส่งคืนอุปกรณ์
${BTN_TEXT_CONFIRM}   ยืนยัน

# ---------- ตัวจับบนหน้า "การจัดส่งและคืน" ----------
# หัวการ์ดแต่ละใบ เช่น "🚚 การขนส่ง #1 (รหัส: 10)"
${Head_FarmerDelivery}    //h3[contains(.,'การขนส่ง #')]
${Btn_DialogCancel}       //button[contains(@class,'swal2-cancel')]
${LIST_TIMEOUT}           ${CARD_TIMEOUT}

# อ่านรหัสและปุ่มของการ์ดทุกใบ คืนเป็นลิสต์ของ {id, buttons}
${JS_READ_DELIVERIES}     () => [...document.querySelectorAll('h3')].filter(h => h.textContent.includes('การขนส่ง #')).map(h => { const m = h.textContent.match(/รหัส:\\s*([^)\\s]+)/); let row = h; while (row && !row.querySelector('button')) row = row.parentElement; return {id: m ? m[1] : '', buttons: row ? [...row.querySelectorAll('button')].map(b => b.textContent.replace(/\\s+/g, ' ').trim()) : []}; })

# ---------- ตัวแปรระดับชุดทดสอบ ----------
${DELIVERY_ID}        ${EMPTY}
${RECEIVED}           ${False}
${RETURNED}           ${False}

# ---------- ตัวแปรระดับกรณีทดสอบ ----------
${TC_ID}              UNKNOWN
${ACTUAL_MESSAGE}     ${EMPTY}

*** Test Cases ***
TC05_F01 - รายการที่ยังไม่ได้รับอุปกรณ์ต้องส่งคืนไม่ได้
    #RT01-01, RT01-02: สถานะ "จัดส่งเรียบร้อย" (ยังไม่รับอุปกรณ์) ต้องมีปุ่มยืนยันรับ แต่ไม่มีปุ่มส่งคืน
    Set Test Variable    ${TC_ID}    TC05_F01
    กรณี TC05_F01

TC05_F02 - ยืนยันรับอุปกรณ์
    #Pre-Condition(F-MAIN-25~27): ยืนยันรับอุปกรณ์แล้วระบบต้องแจ้งสำเร็จ และการ์ดเปลี่ยนเป็นปุ่มส่งคืน
    Set Test Variable    ${TC_ID}    TC05_F02
    กรณี TC05_F02

TC05_F03 - กดส่งคืนแล้วไม่ยืนยัน
    #Basic Flow ข้อ 5: กดส่งคืนแล้วเลือก "ยกเลิก" ต้องไม่บันทึกการส่งคืน (ปุ่มส่งคืนต้องยังอยู่)
    Set Test Variable    ${TC_ID}    TC05_F03
    กรณี TC05_F03

TC05_F04 - ส่งคืนอุปกรณ์สำเร็จตาม Basic Flow
    #Basic Flow 1-7 : กดส่งคืนอุปกรณ์แล้วยืนยัน ระบบต้องแจ้ง "ส่งคืนอุปกรณ์เรียบร้อยแล้ว"
    Set Test Variable    ${TC_ID}    TC05_F04
    กรณี TC05_F04

TC05_F05 - ส่งคืนรายการที่คืนไปแล้วซ้ำไม่ได้
    #RT01-03 : รายการที่ส่งคืนแล้วต้องไม่มีปุ่มส่งคืนให้กดอีก
    Set Test Variable    ${TC_ID}    TC05_F05
    กรณี TC05_F05

TC05_F06 - เปิดหน้าส่งคืนโดยยังไม่เข้าสู่ระบบ
    #Pre-Condition: เปิด context ใหม่ที่ยังไม่ login แล้วเข้าหน้าตรง ๆ ต้องไม่มีปุ่มให้ทำรายการ
    Set Test Variable    ${TC_ID}    TC05_F06
    กรณี TC05_F06

*** Keywords ***
# =====================================================================
# 1. การเตรียมและปิดชุดทดสอบ
# =====================================================================

เปิดชุดทดสอบ
    #ล้างภาพของรอบก่อน เข้าสู่ระบบเป็นเกษตรกรค้างไว้ทั้งชุด แล้วเลือกรายการที่จะใช้ทดสอบ
    เตรียมชุดทดสอบยูสเคส
    เข้าสู่ระบบเกษตรกร
    เลือกรายการที่จะใช้ทดสอบ

เลือกรายการที่จะใช้ทดสอบ
    #เลือกรายการแรกที่รอรับอุปกรณ์ ถ้าไม่มีใช้รายการที่รอส่งคืนแทน (F01-F02 จะถูกข้าม) ถ้าไม่มีทั้งคู่ แปลว่ายังไม่ครบ Pre-Condition จึง Fail ทั้งชุดพร้อมบอกวิธีแก้
    เปิดหน้าการจัดส่งและคืน
    ${Items}=    Evaluate JavaScript    ${None}    ${JS_READ_DELIVERIES}
    Log    รายการในหน้าการจัดส่งและคืน : ${Items}    level=INFO

    ${ToReceive}=    Evaluate    [i["id"] for i in $Items if $BTN_TEXT_RECEIVE in i["buttons"]]
    ${ToReturn}=     Evaluate    [i["id"] for i in $Items if $BTN_TEXT_RETURN in i["buttons"]]

    IF    $ToReceive
        Set Suite Variable    ${DELIVERY_ID}    ${ToReceive}[0]
    ELSE IF    $ToReturn
        Set Suite Variable    ${DELIVERY_ID}    ${ToReturn}[0]
        Set Suite Variable    ${RECEIVED}       ${True}
        Log    ไม่มีรายการที่รอยืนยันรับอุปกรณ์ จึงใช้รายการที่ได้รับอุปกรณ์แล้ว F01-F02 จะถูกข้าม    level=WARN
    ELSE
        Fail    ไม่มีรายการที่ยืนยันรับหรือส่งคืนได้ในหน้าการจัดส่งและคืนของ ${LOGIN_USERNAME} จึงยังไม่ครบ Pre-Condition กรุณารัน Usecase_ApproveBooking_owner และ Usecase_UpdateDelivery_owner ก่อน
    END
    Log    รายการที่ใช้ทดสอบ : รหัส ${DELIVERY_ID}    level=INFO

# =====================================================================
# 2. การเข้าสู่ระบบ
# =====================================================================

เข้าสู่ระบบเกษตรกร
    #Pre-Condition ของเอกสาร : ต้องเข้าสู่ระบบก่อนจึงจะเห็นรายการเช่าของตนเอง (Inter-Case Dependency กับ TC01)
    Open Login Page
    กรอกบัญชีเกษตรกรแล้วกดเข้าสู่ระบบ
    Log    เข้าสู่ระบบเป็น "${LOGIN_USERNAME}" สำเร็จ ใช้ session นี้ตลอดทั้งชุดทดสอบ    level=INFO

กรอกบัญชีเกษตรกรแล้วกดเข้าสู่ระบบ
    #กรอกบัญชี กดเข้าสู่ระบบ ตรวจว่าสำเร็จ แล้วกด "ตกลง" บน popup (รอได้ถึง 10s)
    Input Username    ${LOGIN_USERNAME}
    Input Password    ${LOGIN_PASSWORD}
    Keyboard Key      press    Tab
    ${Clicked}=    Click Button If Enabled    ${Btn_Login}
    Should Be True    ${Clicked}    msg=ปุ่มเข้าสู่ระบบถูกปิดใช้งาน จึงเข้าสู่ระบบไม่ได้

    ${Shown}=    Run Keyword And Return Status    Wait For Elements State    ${Popup_Title}    visible    10s
    Should Be True    ${Shown}
    ...    msg=กดเข้าสู่ระบบด้วยบัญชี "${LOGIN_USERNAME}" แล้วไม่มี popup ผลการเข้าสู่ระบบขึ้นมาภายใน 10 วินาที
    ${Title}=    Get Popup Title
    เทียบผลจริงกับที่คาดหวัง    ${Title}    ${EXP_LOGIN_SUCCESS}
    Click    ${Btn_Verify}

    FOR    ${Round}    IN RANGE    20
        ${Url}=    Get Url
        IF    "login-farmer" not in $Url    RETURN
        Sleep    0.5s
    END
    Fail    กด "ตกลง" บน popup แล้วยังค้างอยู่ที่หน้าเข้าสู่ระบบ (${Url})

เปิดหน้าการจัดส่งและคืน
    #เปิดหน้า "การจัดส่งและคืน" ถ้า session หมดอายุแล้วระบบพากลับหน้าเข้าสู่ระบบ จะเข้าสู่ระบบใหม่แล้วเปิดอีกครั้ง
    Go To                  ${Return_farmerURL}
    Wait For Load State    domcontentloaded    ${DEFAULT_TIMEOUT}
    Sleep    1s
    ${Url}=    Get Url
    IF    "login-farmer" in $Url
        Log    session ของเกษตรกรหมดอายุ จึงเข้าสู่ระบบใหม่    level=WARN
        กรอกบัญชีเกษตรกรแล้วกดเข้าสู่ระบบ
        Go To                  ${Return_farmerURL}
        Wait For Load State    domcontentloaded    ${DEFAULT_TIMEOUT}
    END
    # หน้านี้ดึงรายการมาแสดงหลังโหลดหน้าเสร็จ
    Run Keyword And Ignore Error
    ...    Wait For Elements State    ${Head_FarmerDelivery} >> nth=0    visible    ${LIST_TIMEOUT}
    Sleep    0.5s

# =====================================================================
# 3. กรณีทดสอบ
# =====================================================================

กรณี TC05_F01
    #RT01-01, RT01-02 : รายการที่ยังไม่ได้รับอุปกรณ์ต้องไม่มีปุ่มส่งคืน
    IF    ${RECEIVED}
        Skip    ไม่ได้ทดสอบ เพราะรายการรหัส ${DELIVERY_ID} ได้รับอุปกรณ์ไปแล้วก่อนรันชุดนี้ จึงไม่มีรายการในสถานะที่ยังส่งคืนไม่ได้
    END

    ${Buttons}=    อ่านปุ่มของรายการทดสอบ
    บันทึกผลที่ได้จริง    รหัส ${DELIVERY_ID} มีปุ่ม : ${Buttons}

    # RT01-03 : ข้อความบนปุ่มเทียบทั้งข้อความ (ทีละปุ่มในลิสต์) ไม่ใช่การหาคำบางส่วน
    List Should Contain Value        ${Buttons}    ${BTN_TEXT_RECEIVE}
    ...    msg=รายการรหัส ${DELIVERY_ID} ไม่มีปุ่ม "${BTN_TEXT_RECEIVE}" (มีปุ่ม ${Buttons})
    List Should Not Contain Value    ${Buttons}    ${BTN_TEXT_RETURN}
    ...    msg=รายการที่ยังไม่ได้ยืนยันรับอุปกรณ์มีปุ่ม "${BTN_TEXT_RETURN}" ให้กดได้ ทั้งที่สถานะยังไม่ถูกต้อง

กรณี TC05_F02
    #ยืนยันรับอุปกรณ์ แล้วการ์ดต้องเปลี่ยนเป็นปุ่มส่งคืนอุปกรณ์
    IF    ${RECEIVED}
        Skip    ไม่ได้ทดสอบ เพราะรายการรหัส ${DELIVERY_ID} ได้รับอุปกรณ์ไปแล้วก่อนรันชุดนี้
    END

    ${Question}    ${Result}=    กดปุ่มบนรายการแล้วยืนยัน    ${BTN_TEXT_RECEIVE}
    ${Buttons}=    อ่านปุ่มของรายการทดสอบ
    บันทึกผลที่ได้จริง    ${Result} | ปุ่มบนการ์ดตอนนี้ : ${Buttons}

    # RT02-03 : ข้อความต้องเป็น "ยืนยันการรับอุปกรณ์เรียบร้อยแล้ว" ตรงตัว
    เทียบผลจริงกับที่คาดหวัง    ${Result}    ${RECEIVE_SUCCESS}
    # RT02-04 : การ์ดต้องเปลี่ยนเป็นมีปุ่ม "ส่งคืนอุปกรณ์"
    List Should Contain Value    ${Buttons}    ${BTN_TEXT_RETURN}
    ...    msg=ยืนยันรับอุปกรณ์แล้ว แต่การ์ดไม่มีปุ่ม "${BTN_TEXT_RETURN}" (มีปุ่ม ${Buttons})
    Set Suite Variable    ${RECEIVED}    ${True}

กรณี TC05_F03
    #Basic Flow ข้อ 5 : กดส่งคืนแล้วเลือกยกเลิก รายการต้องยังส่งคืนได้เหมือนเดิม
    ต้องได้รับอุปกรณ์ก่อน

    เปิดหน้าการจัดส่งและคืน
    ${Button}=    ปุ่มบนรายการทดสอบ    ${BTN_TEXT_RETURN}
    ${Clicked}=    Click Button If Enabled    ${Button}
    Should Be True    ${Clicked}    msg=กดปุ่ม "${BTN_TEXT_RETURN}" ของรายการรหัส ${DELIVERY_ID} ไม่ได้
    ${Shown}=    Run Keyword And Return Status    Wait For Elements State    ${Popup_Title}    visible    5s
    Should Be True    ${Shown}    msg=กดส่งคืนแล้วไม่มีกล่องยืนยันเด้งขึ้นมา
    ${Question}=    Get Popup Title
    Click    ${Btn_DialogCancel}
    Sleep    1s

    ${Buttons}=    อ่านปุ่มของรายการทดสอบ
    บันทึกผลที่ได้จริง    ${Question} -> กดยกเลิก | ปุ่มบนการ์ดตอนนี้ : ${Buttons}

    # RT03-04 : การ์ดต้องยังมีปุ่ม "ส่งคืนอุปกรณ์" เหมือนเดิม
    List Should Contain Value    ${Buttons}    ${BTN_TEXT_RETURN}
    ...    msg=กดยกเลิกในกล่องยืนยันแล้ว แต่รายการไม่มีปุ่ม "${BTN_TEXT_RETURN}" แล้ว แปลว่าระบบบันทึกการส่งคืนไปแล้ว

กรณี TC05_F04
    #Basic Flow 1-7 : กดส่งคืนอุปกรณ์แล้วยืนยัน ระบบต้องแจ้งส่งคืนเรียบร้อย
    ต้องได้รับอุปกรณ์ก่อน

    ${Question}    ${Result}=    กดปุ่มบนรายการแล้วยืนยัน    ${BTN_TEXT_RETURN}
    บันทึกผลที่ได้จริง    ${Result}

    # RT04-03 / RT04-04 : ข้อความในกล่องยืนยันและข้อความผลลัพธ์ต้องตรงเอกสาร 100%
    Run Keyword And Continue On Failure    เทียบผลจริงกับที่คาดหวัง    ${Question}    ${RETURN_QUESTION}
    เทียบผลจริงกับที่คาดหวัง    ${Result}    ${RETURN_SUCCESS}
    Set Suite Variable    ${RETURNED}    ${True}

กรณี TC05_F05
    #RT01-03 : รายการที่ส่งคืนแล้วต้องไม่มีปุ่มส่งคืนให้กดซ้ำ
    IF    not ${RETURNED}
        Skip    ไม่ได้ทดสอบ เพราะขึ้นกับ TC05_F04 ที่ยังส่งคืนไม่สำเร็จ
    END

    ${Buttons}=    อ่านปุ่มของรายการทดสอบ
    บันทึกผลที่ได้จริง    รหัส ${DELIVERY_ID} หลังส่งคืน มีปุ่ม : ${Buttons}

    List Should Not Contain Value    ${Buttons}    ${BTN_TEXT_RETURN}
    ...    msg=รายการที่ส่งคืนแล้วยังมีปุ่ม "${BTN_TEXT_RETURN}" ให้กดซ้ำได้
    List Should Not Contain Value    ${Buttons}    ${BTN_TEXT_RECEIVE}
    ...    msg=รายการที่ส่งคืนแล้วกลับไปมีปุ่ม "${BTN_TEXT_RECEIVE}"

กรณี TC05_F06
    #เปิด context ใหม่ที่ยังไม่เข้าสู่ระบบ แล้วเข้าหน้าการจัดส่งและคืนตรง ๆ ต้องไม่มีปุ่มยืนยันรับหรือส่งคืนให้กด (เป็นเคสสุดท้าย จึงไม่ต้องสลับกลับ context เดิม)
    New Context
    New Page             ${Return_farmerURL}
    Set Viewport Size    ${VIEWPORT_WIDTH}    ${VIEWPORT_HEIGHT}
    Sleep    2s

    ${Url}=      Get Url
    ${Receive}=    Get Element Count    //button[contains(.,'${BTN_TEXT_RECEIVE}')]
    ${Return}=     Get Element Count    //button[contains(.,'${BTN_TEXT_RETURN}')]
    ${Popup}=    Get Popup Title
    บันทึกผลที่ได้จริง    หน้าที่ระบบพาไป ${Url} | ปุ่มยืนยันรับ ${Receive} ปุ่ม | ปุ่มส่งคืน ${Return} ปุ่ม | ข้อความแจ้งเตือน "${Popup}"

    Should Be Equal As Integers    ${Receive}    ${0}
    ...    msg=ยังไม่ได้เข้าสู่ระบบ แต่หน้ายังแสดงปุ่ม "${BTN_TEXT_RECEIVE}" ให้กดได้ ${Receive} ปุ่ม
    Should Be Equal As Integers    ${Return}    ${0}
    ...    msg=ยังไม่ได้เข้าสู่ระบบ แต่หน้ายังแสดงปุ่ม "${BTN_TEXT_RETURN}" ให้กดได้ ${Return} ปุ่ม

ต้องได้รับอุปกรณ์ก่อน
    #กรณีที่ต้องใช้ปุ่มส่งคืน ถ้ายังยืนยันรับอุปกรณ์ไม่สำเร็จจะ Skip แทนการล้ม เพราะไม่ได้ทดสอบจริง
    IF    not ${RECEIVED}
        Skip    ไม่ได้ทดสอบ เพราะขึ้นกับ TC05_F02 ที่ยังยืนยันรับอุปกรณ์ไม่สำเร็จ
    END

# =====================================================================
# 4. ขั้นตอนย่อยบนหน้า "การจัดส่งและคืน"
# =====================================================================

ปุ่มบนรายการทดสอบ
    #คืน locator ของปุ่มที่มีข้อความที่ระบุ บนแถวหัวการ์ดของรายการรหัส ${DELIVERY_ID}
    [Arguments]    ${ButtonText}
    ${Head}=    Set Variable    //h3[contains(.,'การขนส่ง #') and contains(.,'รหัส: ${DELIVERY_ID})')]
    RETURN    xpath=(${Head}/ancestor::div[.//button][1]//button[contains(.,'${ButtonText}')])[1]

อ่านปุ่มของรายการทดสอบ
    #เปิดหน้าใหม่แล้วอ่านปุ่มทั้งหมดของรายการรหัส ${DELIVERY_ID} (คืนลิสต์ว่างถ้าไม่พบ)
    เปิดหน้าการจัดส่งและคืน
    ${Items}=    Evaluate JavaScript    ${None}    ${JS_READ_DELIVERIES}
    ${Found}=    Evaluate    [i["buttons"] for i in $Items if i["id"] == $DELIVERY_ID]
    IF    not $Found
        Log    ไม่พบรายการรหัส ${DELIVERY_ID} บนหน้า (${Items})    level=WARN
        ${Empty}=    Create List
        RETURN    ${Empty}
    END
    RETURN    ${Found}[0]

กดปุ่มบนรายการแล้วยืนยัน
    #เปิดหน้าใหม่ กดปุ่มบนการ์ด กดยืนยันในกล่องโต้ตอบ แล้วอ่านผล คืน 2 ค่า: หัวข้อกล่องยืนยัน, หัวข้อผลลัพธ์
    [Arguments]    ${ButtonText}
    เปิดหน้าการจัดส่งและคืน
    ${Button}=    ปุ่มบนรายการทดสอบ    ${ButtonText}
    ${Clicked}=    Click Button If Enabled    ${Button}
    IF    not ${Clicked}
        Log    ไม่มีปุ่ม "${ButtonText}" ที่กดได้บนรายการรหัส ${DELIVERY_ID}    level=WARN
        RETURN    ${EMPTY}    ${EMPTY}
    END

    ${Shown}=    Run Keyword And Return Status    Wait For Elements State    ${Popup_Title}    visible    5s
    IF    not ${Shown}
        Log    กดปุ่ม "${ButtonText}" แล้วไม่มีกล่องยืนยันเด้งขึ้นมา    level=WARN
        RETURN    ${EMPTY}    ${EMPTY}
    END
    ${Question}=    Get Popup Title

    ${Confirm}=    Set Variable    //button[contains(@class,'swal2-confirm') and normalize-space()='${BTN_TEXT_CONFIRM}']
    ${Confirmed}=    Click Button If Enabled    ${Confirm}
    IF    not ${Confirmed}
        Log    ไม่พบปุ่ม "${BTN_TEXT_CONFIRM}" ในกล่องยืนยัน    level=WARN
        RETURN    ${Question}    ${EMPTY}
    END

    ${Result}=    รอหัวข้อ popup ใหม่    ${Question}
    Run Keyword And Ignore Error    Click Button If Enabled    ${Btn_PopupConfirm}
    Sleep    1s
    RETURN    ${Question}    ${Result}

รอหัวข้อ popup ใหม่
    #รอจนกล่องโต้ตอบขึ้นหัวข้อใหม่ที่ไม่ใช่ค่าเดิมและไม่ว่าง คืนหัวข้อใหม่ ไม่พบคืนค่าว่าง
    [Arguments]    ${Previous}
    FOR    ${Round}    IN RANGE    40
        ${Now}=    Get Popup Title
        IF    $Now and $Now != $Previous    RETURN    ${Now}
        Sleep    0.3s
    END
    Log    ไม่พบข้อความตอบกลับจากระบบ (กล่องโต้ตอบยังค้างที่ "${Previous}")    level=WARN
    RETURN    ${EMPTY}

ปิดกล่องโต้ตอบที่ค้างอยู่
    #กล่องยืนยันกด "ยกเลิก" กล่องผลลัพธ์กด "ตกลง" (เช็คปุ่มยกเลิกก่อน กันเผลอกดยืนยันรายการค้าง)
    ${HasCancel}=    Is Element Visible    ${Btn_DialogCancel}
    IF    ${HasCancel}
        Click    ${Btn_DialogCancel}
    ELSE
        ${HasConfirm}=    Is Element Visible    ${Btn_PopupConfirm}
        IF    ${HasConfirm}    Click    ${Btn_PopupConfirm}
    END
    Sleep    0.3s

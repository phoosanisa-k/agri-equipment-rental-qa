*** Settings ***
Documentation     F-MAIN - System Flow Testing (User Journey)
...               อ้างอิง Test Case v4.4 ข้อ 9.1 หน้า 125 - 142

Resource          ../Resources/keywords.robot
Suite Setup       Open Test Browser
Suite Teardown    Close All Test Browsers
Test Teardown     เก็บภาพเมื่อไม่ผ่าน


*** Variables ***
${SCREENSHOT_DIR}    ${CURDIR}/../Screenshot
${USECASE}           FMAIN_SystemFlow
${FARMER_CTX}        ${EMPTY}
${OWNER_CTX}         ${EMPTY}
${STEP_ID}           F-MAIN-00


*** Test Cases ***
F-MAIN : User Journey เช่าอุปกรณ์ตั้งแต่เข้าสู่ระบบจนคืนอุปกรณ์
    [Tags]    systemflow    e2e
    Phase 1 - เข้าสู่ระบบ                        # F-MAIN-01 - F-MAIN-04
    Phase 2 - เพิ่มตะกร้าและสร้างการจอง          # F-MAIN-05 - F-MAIN-10
    # Phase 3 - Owner ตรวจสอบและอนุมัติการจอง    # F-MAIN-11 - F-MAIN-14
    # Phase 4 - Owner อนุมัติการชำระเงินและจัดส่ง # F-MAIN-15 - F-MAIN-24
    # Phase 5 - Farmer ยืนยันรับอุปกรณ์          # F-MAIN-25 - F-MAIN-27
    # Phase 6 - Farmer คืนอุปกรณ์                # F-MAIN-28 - F-MAIN-30
    # Phase 7 - Owner ยืนยันรับคืนและปิดรายการ   # F-MAIN-31 - F-MAIN-33
    # Phase 8 - ออกจากระบบ                       # F-MAIN-34 - F-MAIN-35


*** Keywords ***
ขั้นตอน
    [Arguments]    ${StepId}    ${Detail}
    Set Suite Variable    ${STEP_ID}    ${StepId}
    Log To Console        ${StepId} : ${Detail}

เก็บภาพเมื่อไม่ผ่าน
    IF    '${TEST STATUS}' == 'FAIL'
        Run Keyword And Ignore Error
        ...    Take Screenshot    ${SCREENSHOT_DIR}/${USECASE}_${STEP_ID}_FAILED    fullPage=True
    END

ต้องเข้าสู่ระบบสำเร็จ
    # ปุ่มบน popup ของสองบทบาทใช้คนละคำ จึงรับปุ่มเข้ามาแทนการเดา
    [Arguments]    ${Actor}    ${LoginUrlPart}    ${ConfirmButton}
    Wait For Elements State    ${Popup_Title}    visible    10s
    ${Message}=    Get Text       ${Popup_Title}
    Should Contain    ${Message}    เข้าสู่ระบบสำเร็จ
    Click    ${ConfirmButton}
    ${Url}=    รอให้ออกจากหน้าเข้าสู่ระบบ    ${LoginUrlPart}
    ขั้นตอน           ${STEP_ID}    ${Actor} : ${Message} ไปที่ ${Url}
    Take Screenshot    ${SCREENSHOT_DIR}/${USECASE}_Phase1_${Actor}    fullPage=True

รอให้ออกจากหน้าเข้าสู่ระบบ
    # หน้านี้ไม่ได้ถอดฟอร์มออกจาก DOM ตอนเปลี่ยนหน้า จึงดูที่ URL แทน
    [Arguments]    ${LoginUrlPart}
    FOR    ${Round}    IN RANGE    20
        ${Url}=    Get Url
        IF    '${LoginUrlPart}' not in $Url    RETURN    ${Url}
        Sleep    0.5s
    END
    Fail    กดปุ่มบน popup แล้วยังอยู่ที่หน้าเข้าสู่ระบบ (${Url})

รอให้ไปถึงหน้า
    [Arguments]    ${ExpectedUrl}
    FOR    ${Round}    IN RANGE    20
        ${Url}=    Get Url
        IF    '${ExpectedUrl}' in $Url    RETURN    ${Url}
        Sleep    0.5s
    END
    Fail    ไม่ได้ไปที่ ${ExpectedUrl} (อยู่ที่ ${Url})


สลับไปหน้าจอเกษตรกร
    Switch Context    ${FARMER_CTX}

เลือกวันที่ลงช่อง
    # ช่องวันที่เป็น readonly ต้องคลิกจากปฏิทิน และปฏิทินล็อกเดือนปัจจุบันไว้ ต้องกดเลื่อนเดือนไปข้างหน้าเอง
    # ปฏิทินของช่องเริ่ม/สิ้นสุดใช้ไอคอนชุดเดียวกัน locator จึงเจอ 2 ปุ่ม ต้องเจาะเฉพาะปฏิทินที่เปิดอยู่ด้วย visible=true
    [Arguments]    ${Field}    ${Offset}
    ${Date}=    Evaluate    datetime.date.today() + datetime.timedelta(days=${Offset})    modules=datetime
    ${Day}=     Set Variable    xpath=//button[not(@disabled)][.//span[normalize-space(text())='${Date.day}']] >> visible=true >> nth=0
    ${Next}=    Set Variable    ${Cal_NextMonth} >> visible=true >> nth=0

    Click    ${Field}
    FOR    ${Round}    IN RANGE    6
        ${Ready}=    Run Keyword And Return Status    Wait For Elements State    ${Day}    visible    2s
        IF    ${Ready}    BREAK
        Click    ${Next}
        Sleep    0.3s
    END
    Should Be True    ${Ready}    msg=ปฏิทินไม่ให้เลือกวันที่ ${Date.day}/${Date.month}/${Date.year} แม้เลื่อนไปข้างหน้าแล้ว 6 เดือน
    Click    ${Day}

    ${Value}=    Get Attribute    ${Field}    value
    Should Not Be Empty    ${Value}    msg=กดวันที่ ${Date.day}/${Date.month}/${Date.year} แล้วช่องยังว่าง
    RETURN    ${Value}

#--------------Phase 1 - เข้าสู่ระบบ----------------
Phase 1 - เข้าสู่ระบบ
    เข้าสู่ระบบเกษตรกร
    เข้าสู่ระบบเจ้าของอุปกรณ์

เข้าสู่ระบบเกษตรกร
    ขั้นตอน    F-MAIN-01    เกษตรกรเปิดหน้าเข้าสู่ระบบ
    Open Login Page
    ${Ctx}=    Get Context Ids    ACTIVE    ACTIVE
    Set Suite Variable    ${FARMER_CTX}    ${Ctx}[0]

    ขั้นตอน    F-MAIN-02    เกษตรกรกรอกข้อมูล
    Input Username    ${TEST_FARMER_USER}
    Input Password    ${TEST_FARMER_PASS}
    Keyboard Key      press    Tab    # ให้ช่องสุดท้ายถูกตรวจก่อน ปุ่มจึงเปิดใช้งาน

    ขั้นตอน    F-MAIN-04    เกษตรกรกดปุ่มเข้าสู่ระบบ
    Click    ${Btn_Login}
    ต้องเข้าสู่ระบบสำเร็จ    Farmer    login-farmer    ${Btn_Verify}

เข้าสู่ระบบเจ้าของอุปกรณ์
    ขั้นตอน    F-MAIN-01    เจ้าของอุปกรณ์เปิดหน้าเข้าสู่ระบบ
    Open Login Owner Page
    ${Ctx}=    Get Context Ids    ACTIVE    ACTIVE
    Set Suite Variable    ${OWNER_CTX}    ${Ctx}[0]

    ขั้นตอน    F-MAIN-03    เจ้าของอุปกรณ์กรอกข้อมูล
    Input Owner Username    ${TEST_OWNER_USER}
    Input Owner Password    ${TEST_OWNER_PASS}
    Keyboard Key    press    Tab

    ขั้นตอน    F-MAIN-04    เจ้าของอุปกรณ์กดปุ่มเข้าสู่ระบบ
    Click    ${Btn_OLogin}
    ต้องเข้าสู่ระบบสำเร็จ    Owner     login-owner     ${Btn_OGoHome}

#--------------Phase 2 - เพิ่มตะกร้าและสร้างการจอง----------------
Phase 2 - เพิ่มตะกร้าและสร้างการจอง
    สลับไปหน้าจอเกษตรกร

    ขั้นตอน    F-MAIN-05    เกษตรกรเปิดหน้าค้นหาอุปกรณ์
    Open Search Equipment Page
    Clear Cart    # ล้างของค้างจากรอบก่อน ไม่ให้ติดไปกับรายการจองรอบนี้

    ขั้นตอน    F-MAIN-06    ค้นหาอุปกรณ์ "${FM_EQ_NAME}"
    Select Equipment Type     ${EMPTY}
    Input Search Equipment    ${FM_EQ_NAME}
    ${Cards}=    Get Equipment Card Count
    Should Be True    ${Cards} > 0    msg=ค้นหา "${FM_EQ_NAME}" แล้วไม่พบอุปกรณ์

    ขั้นตอน    F-MAIN-07    เพิ่มอุปกรณ์ลงตะกร้า
    Click    ${Btn_AddToCart} >> nth=0
    Click    ${Btn_OpenCart}

    ขั้นตอน    F-MAIN-08    กรอกวันที่เช่าและที่อยู่จัดส่ง
    ${Start}=    เลือกวันที่ลงช่อง    ${Text_StartDate}    ${FM_START_OFFSET}
    ${End}=      เลือกวันที่ลงช่อง    ${Text_EndDate}      ${FM_END_OFFSET}
    Input Booking Address    ${FM_BOOK_ADDRESS}

    ขั้นตอน    F-MAIN-09    กดปุ่มสั่งจอง (${Start} ถึง ${End})
    ${Clicked}=    Click Booking Button
    Should Be True    ${Clicked}    msg=ปุ่มสั่งจองกดไม่ได้ (ปุ่มถูกปิดใช้งาน หรือวันที่/ที่อยู่ยังไม่ครบ)

    ขั้นตอน    F-MAIN-10    ยอมรับข้อกำหนดและยืนยันการจอง
    ${Before}=     Get Popup Title
    Accept Booking Terms
    ${Message}=    Wait For Popup Title Change    ${Before}
    Should Contain    ${Message}    สำเร็จ    msg=จองไม่สำเร็จ ระบบตอบว่า "${Message}"
    Click    ${Btn_PopupConfirm}
    ${Url}=    รอให้ไปถึงหน้า    ${MyBooking_farmerURL}
    ขั้นตอน    F-MAIN-10    ${Message} | หน้าปัจจุบัน ${Url}
    Take Screenshot    ${SCREENSHOT_DIR}/${USECASE}_Phase2_รายการจองของฉัน    fullPage=True

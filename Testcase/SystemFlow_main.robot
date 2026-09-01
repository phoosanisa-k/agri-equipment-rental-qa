*** Settings ***
Documentation     F-MAIN - System Flow Testing (end-to-end user journey)
...               Reference: Test Case v4.4 section 9.1, pages 125-142
...
...               One test case walks the whole flow in 8 phases, from login to logout,
...               switching between the Farmer and the Owner browser context.
...               Test data lives in Resources/variables.robot - no DataDriver, no Excel.

Resource          ../Resources/keywords.robot

Suite Setup       Open Test Browser
Suite Teardown    Close All Test Browsers
Test Teardown     Capture Failure Screenshot


*** Variables ***
${SCREENSHOT_DIR}    ${CURDIR}/../Screenshot
${USECASE}           FMAIN_SystemFlow

# ตัวแปรที่เก็บค่าระหว่างรัน
${FARMER_CTX}        ${EMPTY}
${OWNER_CTX}         ${EMPTY}
${STEP_ID}           F-MAIN-00


*** Test Cases ***
F-MAIN : Rent Equipment Journey From Login To Return
    [Tags]    System Flow Testing    end to end
    Phase 1 - เข้าสู่ระบบ                              # F-MAIN-01 - F-MAIN-04
    Phase 2 - เพิ่มตะกร้าและสร้างการจอง (Farmer)        # F-MAIN-05 - F-MAIN-10
    Phase 3 - Owner ตรวจสอบและอนุมัติการจอง           # F-MAIN-11 - F-MAIN-14
    Phase 4 - Owner อนุมัติการชำระเงินและจัดส่ง           # F-MAIN-15 - F-MAIN-24
    Phase 5 - Farmer ยืนยันรับอุปกรณ์                  # F-MAIN-25 - F-MAIN-27
    Phase 6 - Farmer คืนอุปกรณ์                      # F-MAIN-28 - F-MAIN-30
    Phase 7 - Owner ยืนยันรับคืนและปิดรายการ            # F-MAIN-31 - F-MAIN-33
    Phase 8 - ออกจากระบบ                           # F-MAIN-34 - F-MAIN-35


*** Keywords ***
# =====================================================================
# คีย์เวิร์ดช่วยเหลือ
# =====================================================================

Step
    [Arguments]    ${StepId}    ${Detail}
    Set Suite Variable    ${STEP_ID}    ${StepId}
    Log To Console        ${StepId} : ${Detail}

Save Evidence
    [Arguments]    ${Name}
    Take Screenshot    ${SCREENSHOT_DIR}/${USECASE}_${Name}    fullPage=True

Capture Failure Screenshot
    IF    '${TEST STATUS}' == 'FAIL'
        Run Keyword And Ignore Error
        ...    Take Screenshot    ${SCREENSHOT_DIR}/${USECASE}_${STEP_ID}_FAILED    fullPage=True
    END

Switch To Farmer
    Switch Context    ${FARMER_CTX}

Switch To Owner
    Switch Context    ${OWNER_CTX}

Wait Until Login Page Is Left
    # หน้านี้ไม่ถอดฟอร์มออกจาก DOM ตอนเปลี่ยนหน้า จึงดูที่ URL แทน
    [Arguments]    ${LoginUrlPart}
    FOR    ${Round}    IN RANGE    20
        ${Url}=    Get Url
        IF    '${LoginUrlPart}' not in $Url    RETURN    ${Url}
        Sleep    0.5s
    END
    Fail    Still on the login page after confirming the popup (${Url})

Wait Until Page Is Opened
    [Arguments]    ${ExpectedUrl}
    FOR    ${Round}    IN RANGE    20
        ${Url}=    Get Url
        IF    '${ExpectedUrl}' in $Url    RETURN    ${Url}
        Sleep    0.5s
    END
    Fail    Never reached ${ExpectedUrl} (still on ${Url})

Login Should Succeed
    # ปุ่มบน popup ของสองบทบาทใช้คนละคำ จึงรับปุ่มเข้ามา
    [Arguments]    ${Actor}    ${LoginUrlPart}    ${ConfirmButton}
    Wait For Elements State    ${Popup_Title}    visible    10s
    ${Message}=    Get Text    ${Popup_Title}
    Should Contain    ${Message}    เข้าสู่ระบบสำเร็จ    msg=${Actor} could not log in, the system answered "${Message}"
    Click    ${ConfirmButton}
    ${Url}=    Wait Until Login Page Is Left    ${LoginUrlPart}
    Step             ${STEP_ID}    ${Actor} : ${Message} -> ${Url}
    Save Evidence    Phase1_${Actor}

Pick Date In Field
    # ช่องวันที่พิมพ์ไม่ได้ ต้องคลิกจากปฏิทิน และปฏิทินล็อกเดือนปัจจุบันไว้ ต้องกดเลื่อนเดือนเอง
    # ปฏิทินของสองช่องใช้ไอคอนชุดเดียวกัน จึงเจาะเฉพาะอันที่เปิดอยู่ด้วย visible=true
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
    Should Be True    ${Ready}
    ...    msg=${Date.day}/${Date.month}/${Date.year} stayed disabled after moving 6 months forward
    Click    ${Day}

    ${Value}=    Get Attribute    ${Field}    value
    Should Not Be Empty    ${Value}    msg=Clicked ${Date.day}/${Date.month}/${Date.year} but the field is still empty
    RETURN    ${Value}

Update Booking Status
    # ทุกขั้นของ Phase 3-4 ทำเหมือนกัน : เลือกแท็บ - กดปุ่มอัปเดต - ยืนยัน - อ่านผล
    # ชื่อสถานะเปลี่ยนทุกครั้ง locator จึงเขียนเป็นแม่แบบไว้ตรงนี้
    [Arguments]    ${StepId}    ${TabName}    ${NextStatus}
    Step    ${StepId}    Open the "${TabName}" tab and update to "${NextStatus}"
    Click    //button[contains(.,'${TabName}') and not(contains(.,'อัปเดต'))]
    Sleep    1s    # หน้ากรองรายการใหม่หลังเปลี่ยนแท็บ
    Click    //button[contains(.,'อัปเดตเป็น') and contains(.,'${NextStatus}')] >> nth=0

    ${Before}=     Get Popup Title
    Click          ${Btn_PopupConfirm}
    ${Message}=    Wait For Popup Title Change    ${Before}
    Should Contain    ${Message}    สำเร็จ
    ...    msg=Update to "${NextStatus}" failed, the system answered "${Message}"
    Click    ${Btn_PopupConfirm}
    Step    ${StepId}    ${Message} : ${TabName} -> ${NextStatus}

Log Out As
    # สองบทบาททำเหมือนกัน ต่างแค่หน้า login ที่ระบบพากลับไป
    [Arguments]    ${Actor}    ${LoginUrl}
    Step    F-MAIN-34    ${Actor} opens the profile menu
    Click    ${Btn_UserProfile}

    Step    F-MAIN-35    ${Actor} clicks log out
    Click    ${Btn_Logout}
    ${Url}=    Wait Until Page Is Opened    ${LoginUrl}
    Step             F-MAIN-35    ${Actor} logged out -> ${Url}
    Save Evidence    Phase8_Logout_${Actor}


# =====================================================================
# Phase 1 - เข้าสู่ระบบ (F-MAIN-01 - F-MAIN-04)
# =====================================================================

Phase 1 - เข้าสู่ระบบ
    Login As Farmer
    Login As Owner

Login As Farmer
    Step    F-MAIN-01    Farmer opens the login page
    Open Login Page
    ${Ctx}=    Get Context Ids    ACTIVE    ACTIVE
    Set Suite Variable    ${FARMER_CTX}    ${Ctx}[0]

    Step    F-MAIN-02    Farmer fills in the credentials
    Input Username    ${TEST_FARMER_USER}
    Input Password    ${TEST_FARMER_PASS}
    Keyboard Key      press    Tab    # กด Tab ให้ช่องสุดท้ายถูกตรวจ ปุ่มจึงเปิดใช้งาน

    Step    F-MAIN-04    Farmer clicks the login button
    Click    ${Btn_Login}
    Login Should Succeed    Farmer    login-farmer    ${Btn_Verify}

Login As Owner
    Step    F-MAIN-01    Owner opens the login page
    Open Login Owner Page
    ${Ctx}=    Get Context Ids    ACTIVE    ACTIVE
    Set Suite Variable    ${OWNER_CTX}    ${Ctx}[0]

    Step    F-MAIN-03    Owner fills in the credentials
    Input Owner Username    ${TEST_OWNER_USER}
    Input Owner Password    ${TEST_OWNER_PASS}
    Keyboard Key            press    Tab

    Step    F-MAIN-04    Owner clicks the login button
    Click    ${Btn_OLogin}
    Login Should Succeed    Owner    login-owner    ${Btn_OGoHome}


# =====================================================================
# Phase 2 - เพิ่มตะกร้าและสร้างการจอง (F-MAIN-05 - F-MAIN-10)
# =====================================================================

Phase 2 - เพิ่มตะกร้าและสร้างการจอง (Farmer) 
    Switch To Farmer

    Step    F-MAIN-05    Farmer opens the equipment search page
    Open Search Equipment Page
    Clear Cart    # ล้างของค้างจากรอบก่อน ไม่ให้ติดมากับการจองรอบนี้

    Step    F-MAIN-06    Search for "${FM_EQ_NAME}"
    Select Equipment Type     ${EMPTY}
    Input Search Equipment    ${FM_EQ_NAME}
    ${Cards}=    Get Equipment Card Count
    Should Be True    ${Cards} > 0    msg=No equipment found for "${FM_EQ_NAME}"

    Step    F-MAIN-07    Add the equipment to the cart
    Click    ${Btn_AddToCart} >> nth=0
    Click    ${Btn_OpenCart}

    Step    F-MAIN-08    Fill in the rental dates and the delivery address
    ${Start}=    Pick Date In Field    ${Text_StartDate}    ${FM_START_OFFSET}
    ${End}=      Pick Date In Field    ${Text_EndDate}      ${FM_END_OFFSET}
    Input Booking Address    ${FM_BOOK_ADDRESS}

    Step    F-MAIN-09    Submit the booking (${Start} to ${End})
    ${Clicked}=    Click Booking Button
    Should Be True    ${Clicked}    msg=The booking button is disabled - dates or address are incomplete

    Step    F-MAIN-10    Accept the rental terms and confirm the booking
    ${Before}=     Get Popup Title
    Accept Booking Terms
    ${Message}=    Wait For Popup Title Change    ${Before}
    Should Contain    ${Message}    สำเร็จ    msg=Booking failed, the system answered "${Message}"
    Click    ${Btn_PopupConfirm}

    ${Url}=          Wait Until Page Is Opened    ${MyBooking_farmerURL}
    Step             F-MAIN-10    ${Message} | now on ${Url}
    Save Evidence    Phase2_MyBookings


# =====================================================================
# Phase 3 - Owner ตรวจสอบและอนุมัติการจอง (F-MAIN-11 - F-MAIN-14)
# =====================================================================

Phase 3 - Owner ตรวจสอบและอนุมัติการจอง  
    Switch To Owner

    Step    F-MAIN-11    Owner opens the booking list
    Open Owner Booking Page

    Update Booking Status    F-MAIN-12    รอดำเนินการ    รอการชำระเงิน
    Save Evidence            Phase3_WaitingPayment


# =====================================================================
# Phase 4 - Owner อนุมัติการชำระเงินและจัดส่ง (F-MAIN-15 - F-MAIN-24)
# =====================================================================

Phase 4 - Owner อนุมัติการชำระเงินและจัดส่ง
    Switch To Owner
    Update Booking Status    F-MAIN-15    รอการชำระเงิน       อนุมัติการชำระเงิน
    Update Booking Status    F-MAIN-18    อนุมัติการชำระเงิน    รอการจัดส่ง
    Update Booking Status    F-MAIN-21    รอการจัดส่ง          จัดส่งเรียบร้อย

    Step    F-MAIN-24    Open the "จัดส่งเรียบร้อย" tab to read the booking details
    Click    //button[contains(.,'จัดส่งเรียบร้อย') and not(contains(.,'อัปเดต'))]
    Sleep    1s
    Save Evidence    Phase4_Shipped


# =====================================================================
# Phase 5 - Farmer ยืนยันรับอุปกรณ์ (F-MAIN-25 - F-MAIN-27)
# =====================================================================

Phase 5 - Farmer ยืนยันรับอุปกรณ์
    Switch To Farmer

    Step    F-MAIN-25    Farmer opens the delivery page
    Go To                  ${Pickup_farmerURL}
    Wait For Load State    domcontentloaded    ${DEFAULT_TIMEOUT}
    Sleep    1s    # หน้าดึงรายการมาแสดงหลังโหลดเสร็จ

    Step    F-MAIN-26    Click the receive button
    Click    ${Btn_ReceiptEQ} >> nth=0

    Step    F-MAIN-27    Confirm the receipt
    ${Before}=     Get Popup Title
    Click          ${Btn_PopupConfirm}
    ${Message}=    Wait For Popup Title Change    ${Before}
    Should Contain    ${Message}    ยืนยันการรับอุปกรณ์เรียบร้อยแล้ว
    ...    msg=Receipt failed, the system answered "${Message}"
    Click    ${Btn_PopupConfirm}

    Step             F-MAIN-27    ${Message}
    Save Evidence    Phase5_Receipt


# =====================================================================
# Phase 6 - Farmer คืนอุปกรณ์ (F-MAIN-28 - F-MAIN-30)
# =====================================================================

Phase 6 - Farmer คืนอุปกรณ์
    Switch To Farmer

    Step    F-MAIN-28    Farmer opens the return page
    Open Return Equipment Page

    Step    F-MAIN-29    Click the return button
    Click    ${Btn_ReturnEQ} >> nth=0

    Step    F-MAIN-30    Confirm the return
    ${Before}=     Get Popup Title
    Click          ${Btn_PopupConfirm}
    ${Message}=    Wait For Popup Title Change    ${Before}
    Should Contain    ${Message}    ส่งคืนอุปกรณ์เรียบร้อยแล้ว
    ...    msg=Return failed, the system answered "${Message}"
    Click    ${Btn_PopupConfirm}

    Step             F-MAIN-30    ${Message}
    Save Evidence    Phase6_Returned


# =====================================================================
# Phase 7 - Owner ยืนยันรับคืนและปิดรายการ (F-MAIN-31 - F-MAIN-33)
# =====================================================================

Phase 7 - Owner ยืนยันรับคืนและปิดรายการ
    Switch To Owner

    Step    F-MAIN-31    Owner opens the return page
    Go To                  ${Return_ownerURL}
    Wait For Load State    domcontentloaded    ${DEFAULT_TIMEOUT}
    Sleep    1s    # หน้าดึงรายการมาแสดงหลังโหลดเสร็จ

    Step    F-MAIN-32    Click the confirm-returned button
    Click    ${Btn_ConfirmReturned} >> nth=0

    Step    F-MAIN-33    Confirm and close the booking
    # popup ของหน้านี้เก็บผลไว้ในเนื้อความ ไม่ใช่หัวข้อ
    ${Before}=     Get Booking Dialog Text
    Click          ${Btn_PopupConfirm}
    ${Message}=    Wait For Booking Dialog Change    ${Before}
    Should Contain    ${Message}    ยืนยันการรับคืนอุปกรณ์เรียบร้อยแล้ว
    ...    msg=Closing the booking failed, the system answered "${Message}"
    Click    ${Btn_PopupConfirm}

    Step             F-MAIN-33    ${Message}
    Save Evidence    Phase7_Closed


# =====================================================================
# Phase 8 - ออกจากระบบ (F-MAIN-34 - F-MAIN-35)
# =====================================================================

Phase 8 - ออกจากระบบ
    Switch To Farmer
    Log Out As    Farmer    ${Login_farmerURL}
    Switch To Owner
    Log Out As    Owner     ${Login_ownerURL}

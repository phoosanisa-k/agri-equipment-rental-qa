*** Settings ***
Documentation     F-MAIN - System Flow Testing : ทดสอบลำดับการทำงานของระบบแบบ End-to-End (Happy Flow) 8 Phase ตามเอกสารหัวข้อ 9
...               แต่ละ Phase นำ flow ที่สำเร็จ (happy path) ของยูสเคสในโฟลเดอร์ UseCase มาต่อกัน ใช้ข้อมูลทดสอบและข้อความที่คาดหวังชุดเดียวกัน
...               Phase 1 = TC01 Login (LF02 / LO02) | Phase 2 = TC03 Add Cart (AC01) + TC04 Booking (BK01)
...               Phase 3-4 = TC04 Approve Booking (AB02 / AB05) + TC05 Update Delivery (DEL03 / DEL04)
...               Phase 5-6 = TC05 Return Equipment (RT02 / RT04) | Phase 7 = TC05 Update Delivery (DEL06) | Phase 8 = TC01 Login (LF06 / LO06)
...               เทียบข้อความแบบตรงกัน 100% ด้วย "เทียบผลจริงกับที่คาดหวัง" สลับทำงานระหว่าง Farmer และ Owner คนละ context
Name              System Flow Testing

Resource          ../Resources/keywords.robot
Library           Collections

Suite Setup       เตรียมชุดทดสอบยูสเคส
Suite Teardown    ปิดชุดทดสอบ
Test Teardown     เก็บผลท้ายกรณีทดสอบ    No Operation

*** Variables ***
# ---------- ไฟล์และโฟลเดอร์ ----------
${USECASE}              FMAIN_SystemFlow
${SCREENSHOT_DIR}       ${CURDIR}/../Screenshot/${USECASE}

# ---------- บัญชีที่ใช้ทดสอบ (ชุดเดียวกับ UseCase) ----------
${FARMER_USER}          somchaikaew
${FARMER_PASS}          Somc1442!
# บัญชี Owner ใช้ ${OwnerUser} / ${OwnerPass} จาก Resources/variables.robot ตรง ๆ
# (Robot Framework ไม่สนตัวพิมพ์เล็กใหญ่และ _ ในชื่อตัวแปร ถ้าตั้งชื่อ OWNER_USER จะชนกับ OwnerUser)

# ---------- อุปกรณ์ วันที่ และที่อยู่ที่ใช้จอง (ชุดเดียวกับ Usecase_Booking_farmer) ----------
${EQ_TYPE}              รถไถเดินตาม
${EQ_NAME}              รถไถเดินตาม
# วันเริ่ม = วันแรกที่ปฏิทินเปิดให้เลือก วันสิ้นสุด = วันเริ่ม + 3 วัน
${END_AFTER_DAYS}       ${3}
${BOOK_ADDRESS}         123/45 หมู่ 5 ตำบลสุเทพ อำเภอเมือง จังหวัดเชียงใหม่ 50200

# ---------- สถานะการจอง ----------
${STATUS_PENDING}       รอดำเนินการ
${STATUS_WAITPAY}       รอการชำระเงิน
${STATUS_PAID}          อนุมัติการชำระเงิน
${STATUS_WAITDELIVERY}  รอการจัดส่ง
${STATUS_DELIVERED}     จัดส่งเรียบร้อย

# ---------- ข้อความที่คาดหวังตามเอกสาร (เทียบตรงกัน 100%) ----------
${EXP_LOGIN_SUCCESS}    เข้าสู่ระบบสำเร็จ                      # F-MAIN-04
${EXP_BOOK_SUCCESS}     การจองสำเร็จ!                          # F-MAIN-10
${EXP_UPDATE_SUCCESS}   อัปเดตสถานะสำเร็จ!                     # F-MAIN-14 / 17 / 20 / 23
${EXP_RECEIVE_Q}        ยืนยันการรับอุปกรณ์เรียบร้อยแล้วใช่หรือไม่?   # F-MAIN-26
${EXP_RECEIVE_DONE}     ยืนยันการรับอุปกรณ์เรียบร้อยแล้ว           # F-MAIN-27
${EXP_RETURN_Q}         ยืนยันการส่งคืนอุปกรณ์ใช่หรือไม่?           # F-MAIN-29
${EXP_RETURN_DONE}      ส่งคืนอุปกรณ์เรียบร้อยแล้ว                 # F-MAIN-30
${EXP_RETURNED_DONE}    ยืนยันการรับคืนอุปกรณ์เรียบร้อยแล้ว         # F-MAIN-33 (popup หน้านี้แสดงผลในเนื้อความ ไม่ใช่หัวข้อ)
${EXP_LOGOUT_SUCCESS}   ออกจากระบบสำเร็จ!                      # F-MAIN-35

# ---------- ข้อความบนปุ่ม ----------
${BTN_TEXT_UPDATE}      อัปเดตเป็น
${BTN_TEXT_CONFIRM}     ยืนยัน
${BTN_TEXT_RECEIVE}     ยืนยันรับอุปกรณ์
${BTN_TEXT_RETURN}      ส่งคืนอุปกรณ์

# ---------- ตัวจับบนหน้าเว็บ (ชุดเดียวกับ UseCase) ----------
${Card_OwnerBooking}    //div[contains(@class,'border-emerald-200')][.//h3[contains(.,'การจอง #')]]
${Btn_NextPage}         //button[contains(.,'ถัดไป')]
${LIST_TIMEOUT}         ${CARD_TIMEOUT}
${POPUP_TIMEOUT}        10s
${JS_READ_CARDS}        () => [...document.querySelectorAll('div.border-emerald-200')].filter(d => (d.querySelector('h3') || {textContent: ''}).textContent.includes('การจอง #')).map(d => { const t = e => e ? e.textContent.replace(/\\s+/g, ' ').trim() : ''; const ps = [...d.querySelectorAll('p')]; const st = ps.find(p => p.textContent.includes('เริ่มต้น')); const en = ps.find(p => p.textContent.includes('สิ้นสุด')); const sp = [...d.querySelectorAll('span')]; const tn = sp.find(s => s.textContent.trim().startsWith('ผู้เช่า:')); const ss = sp.find(s => s.textContent.trim().startsWith('สถานะ :')); return {tenant: t(tn).replace('ผู้เช่า:', '').trim(), status: t(ss).replace('สถานะ :', '').trim(), start: t(st && st.querySelector('span')), end: t(en && en.querySelector('span')), equipment: [...d.querySelectorAll('h5')].map(t)}; })
${JS_READ_DELIVERIES}   () => [...document.querySelectorAll('h3')].filter(h => h.textContent.includes('การขนส่ง #')).map(h => { const m = h.textContent.match(/รหัส:\\s*([^)\\s]+)/); let row = h; while (row && !row.querySelector('button')) row = row.parentElement; return {id: m ? m[1] : '', buttons: row ? [...row.querySelectorAll('button')].map(b => b.textContent.replace(/\\s+/g, ' ').trim()) : []}; })

# ---------- ตัวแปรระดับชุดทดสอบ ตั้งค่าระหว่างรัน ----------
${FARMER_CTX}           ${EMPTY}
${OWNER_CTX}            ${EMPTY}
${BOOK_START}           ${EMPTY}
${BOOK_END}             ${EMPTY}
${BOOKING_CARD}         ${EMPTY}
${DELIVERY_ID}          ${EMPTY}
${TC_ID}                F-MAIN
${ACTUAL_MESSAGE}       ${EMPTY}

*** Test Cases ***
F-MAIN : Rent Equipment Journey From Login To Logout
    [Tags]    System Flow Testing    end to end
    #Happy Flow ตั้งแต่เข้าสู่ระบบ จอง อนุมัติ จัดส่ง รับ คืน ยืนยันรับคืน จนออกจากระบบ (F-MAIN-01 ถึง F-MAIN-35)
    Phase 1 - เข้าสู่ระบบ
    Phase 2 - เพิ่มตะกร้าและสร้างการจอง (Farmer)
    Phase 3 - Owner ตรวจสอบและอนุมัติการจอง
    Phase 4 - Owner อนุมัติการชำระเงินและจัดส่ง
    Phase 5 - Farmer ยืนยันรับอุปกรณ์
    Phase 6 - Farmer คืนอุปกรณ์
    Phase 7 - Owner ยืนยันรับคืนและปิดรายการ
    Phase 8 - ออกจากระบบ

*** Keywords ***
# แต่ละขั้นเขียนเป็น GROUP "F-MAIN-xx : ชื่อขั้น" ใน log.html จะเห็นทีละขั้นพร้อมผล PASS/FAIL

# ---------- 1. Phase 1 : เข้าสู่ระบบ (TC01 LF02 / LO02) ----------
Phase 1 - เข้าสู่ระบบ
    GROUP    F-MAIN-01 : Farmer และ Owner เปิดหน้าเข้าสู่ระบบ
        Open Login Page
        ${Ctx}=    Get Context Ids    ACTIVE    ACTIVE
        Set Suite Variable    ${FARMER_CTX}    ${Ctx}[0]
        Open Login Owner Page
        ${Ctx}=    Get Context Ids    ACTIVE    ACTIVE
        Set Suite Variable    ${OWNER_CTX}    ${Ctx}[0]
    END
    GROUP    F-MAIN-02 : Farmer กรอกชื่อผู้ใช้และรหัสผ่าน
        Switch Context    ${FARMER_CTX}
        Input Username    ${FARMER_USER}
        Input Password    ${FARMER_PASS}
        Keyboard Key      press    Tab
    END
    GROUP    F-MAIN-03 : Owner กรอกชื่อผู้ใช้และรหัสผ่าน
        Switch Context    ${OWNER_CTX}
        Input Owner Username    ${OwnerUser}
        Input Owner Password    ${OwnerPass}
        Keyboard Key            press    Tab
    END
    GROUP    F-MAIN-04 : Farmer และ Owner กดปุ่มเข้าสู่ระบบ
        Switch Context    ${FARMER_CTX}
        ${Clicked}=    Click Button If Enabled    ${Btn_Login}
        Should Be True    ${Clicked}    msg=ปุ่มเข้าสู่ระบบของ Farmer ถูกปิดใช้งาน
        เข้าสู่ระบบต้องสำเร็จ    login-farmer    ${Btn_Verify}

        Switch Context    ${OWNER_CTX}
        ${Clicked}=    Click Owner Login Button
        Should Be True    ${Clicked}    msg=ปุ่มเข้าสู่ระบบของ Owner ถูกปิดใช้งาน
        เข้าสู่ระบบต้องสำเร็จ    login-owner    ${Btn_OGoHome}
    END

# ---------- 2. Phase 2 : เพิ่มตะกร้าและสร้างการจอง (TC03 AC01 + TC04 BK01) ----------
Phase 2 - เพิ่มตะกร้าและสร้างการจอง (Farmer)
    Switch Context    ${FARMER_CTX}
    GROUP    F-MAIN-05 : เปิดหน้าค้นหาอุปกรณ์
        Open Search Equipment Page
        Clear Cart
    END
    GROUP    F-MAIN-06 : ค้นหาอุปกรณ์ "${EQ_NAME}"
        Select Equipment Type     ${EQ_TYPE}
        Input Search Equipment    ${EQ_NAME}
        ${Cards}=    Get Equipment Card Count
        Should Be True    ${Cards} > 0    msg=ค้นหา "${EQ_NAME}" ในประเภท "${EQ_TYPE}" แล้วไม่พบอุปกรณ์
    END
    GROUP    F-MAIN-07 : กดเพิ่มอุปกรณ์ลงตะกร้า
        ${Added}=    Click Add To Cart
        Should Be True    ${Added}    msg=ปุ่ม "เพิ่มในตะกร้า" กดไม่ได้
        ${State}=    Get Equipment Button State
        บันทึกผลที่ได้จริง    ${State}
        เทียบผลจริงกับที่คาดหวัง    ${State}    ${State_InCart}
    END
    GROUP    F-MAIN-08 : เลือกวันที่เช่าและกรอกที่อยู่จัดส่ง
        ${Opened}=    Open Cart
        Should Be True    ${Opened}    msg=เปิดกล่องตะกร้าไม่ได้
        ${Form}=    Is Booking Form Displayed
        Should Be True    ${Form}    msg=เปิดตะกร้าแล้วไม่พบฟอร์มจอง
        ${First}=    หาวันแรกที่ระบบเปิดให้เลือก    ${Text_StartDate}
        Should Not Be Empty    ${First}    msg=ปฏิทินไม่เปิดให้เลือกวันไหนเลยในช่วง 12 เดือนข้างหน้า
        ${End}=    Evaluate    (datetime.date.fromisoformat($First) + datetime.timedelta(days=${END_AFTER_DAYS})).isoformat()    modules=datetime
        Set Suite Variable    ${BOOK_START}    ${First}
        Set Suite Variable    ${BOOK_END}      ${End}
        เลือกวันที่จอง    ${Text_StartDate}    ${BOOK_START}
        เลือกวันที่จอง    ${Text_EndDate}      ${BOOK_END}
        Input Booking Address    ${BOOK_ADDRESS}
        Log    จองวันที่ ${BOOK_START} ถึง ${BOOK_END}    level=INFO
    END
    GROUP    F-MAIN-09 : กดปุ่มสั่งจอง
        ${Clicked}=    Click Booking Button
        Should Be True    ${Clicked}    msg=ปุ่มสั่งจองถูกปิดใช้งาน
        ${Terms}=    Is Terms Popup Shown
        Should Be True    ${Terms}    msg=กดสั่งจองแล้วไม่มี popup ข้อกำหนดการใช้งาน
    END
    GROUP    F-MAIN-10 : ยอมรับข้อกำหนดและยืนยันการจอง
        ${Accepted}=    Accept Booking Terms
        Should Be True    ${Accepted}    msg=ติ๊กยอมรับแล้วแต่กดปุ่ม "ยอมรับ" ไม่ได้
        ${Message}=    อ่านหัวข้อ popup
        บันทึกผลที่ได้จริง    ${Message}
        เทียบผลจริงกับที่คาดหวัง    ${Message}    ${EXP_BOOK_SUCCESS}
        # ระบบพาไปหน้ารายการจองของฉันหลังกด "ตกลง" บน popup เท่านั้น
        ${Confirmed}=    Click Button If Enabled    ${Btn_PopupConfirm}
        Should Be True    ${Confirmed}    msg=ไม่พบปุ่ม "ตกลง" บน popup การจองสำเร็จ
        รอจนอยู่ที่หน้า    /farmer/bookings
    END

# ---------- 3. Phase 3 : Owner ตรวจสอบและอนุมัติการจอง (TC04 AB01 / AB02) ----------
Phase 3 - Owner ตรวจสอบและอนุมัติการจอง
    Switch Context    ${OWNER_CTX}
    GROUP    F-MAIN-11 : เปิดหน้ารายการจอง
        Go To                  ${ApproveBooking_ownerURL}
        Wait For Load State    domcontentloaded    ${DEFAULT_TIMEOUT}
        รอจนอยู่ที่หน้า    /owner/bookings
    END
    GROUP    F-MAIN-12 : เปิดแท็บ "${STATUS_PENDING}" และหาการจองที่เพิ่งสร้าง
        ${Locator}=    หาการ์ดการจองที่เพิ่งสร้าง
        Set Suite Variable    ${BOOKING_CARD}    ${Locator}
        ${Status}=    อ่านสถานะบนการ์ด    ${BOOKING_CARD}
        เทียบผลจริงกับที่คาดหวัง    ${Status}    สถานะ : ${STATUS_PENDING}
    END
    อัปเดตสถานะการจอง    F-MAIN-13    F-MAIN-14    ${STATUS_PENDING}    ${STATUS_WAITPAY}

# ---------- 4. Phase 4 : อนุมัติการชำระเงินและจัดส่ง (TC04 AB05 + TC05 DEL03 / DEL04) ----------
Phase 4 - Owner อนุมัติการชำระเงินและจัดส่ง
    Switch Context    ${OWNER_CTX}
    GROUP    F-MAIN-15 : เปิดแท็บ "${STATUS_WAITPAY}"
        ${Card}=    หาการ์ดการจอง    ${STATUS_WAITPAY}    ${BOOKING_CARD}
        Should Not Be Empty    ${Card}    msg=ไม่พบการจองในแท็บ "${STATUS_WAITPAY}"
    END
    อัปเดตสถานะการจอง    F-MAIN-16    F-MAIN-17    ${STATUS_WAITPAY}    ${STATUS_PAID}
    GROUP    F-MAIN-18 : เปิดแท็บ "${STATUS_PAID}"
        ${Card}=    หาการ์ดการจอง    ${STATUS_PAID}    ${BOOKING_CARD}
        Should Not Be Empty    ${Card}    msg=ไม่พบการจองในแท็บ "${STATUS_PAID}"
    END
    อัปเดตสถานะการจอง    F-MAIN-19    F-MAIN-20    ${STATUS_PAID}    ${STATUS_WAITDELIVERY}
    GROUP    F-MAIN-21 : เปิดแท็บ "${STATUS_WAITDELIVERY}"
        ${Card}=    หาการ์ดการจอง    ${STATUS_WAITDELIVERY}    ${BOOKING_CARD}
        Should Not Be Empty    ${Card}    msg=ไม่พบการจองในแท็บ "${STATUS_WAITDELIVERY}"
    END
    อัปเดตสถานะการจอง    F-MAIN-22    F-MAIN-23    ${STATUS_WAITDELIVERY}    ${STATUS_DELIVERED}
    GROUP    F-MAIN-24 : เปิดแท็บ "${STATUS_DELIVERED}" ดูรายละเอียดการจอง
        ${Card}=    หาการ์ดการจอง    ${STATUS_DELIVERED}    ${BOOKING_CARD}
        Should Not Be Empty    ${Card}    msg=ไม่พบการจองในแท็บ "${STATUS_DELIVERED}"
        ${Status}=    อ่านสถานะบนการ์ด    ${Card}
        บันทึกผลที่ได้จริง    ${Status}
        เทียบผลจริงกับที่คาดหวัง    ${Status}    สถานะ : ${STATUS_DELIVERED}
        ${Button}=    อ่านข้อความปุ่มบนการ์ด    ${Card}    ${BTN_TEXT_UPDATE}
        Should Be Empty    ${Button}    msg=รายการที่จัดส่งเรียบร้อยแล้วยังมีปุ่ม ${Button}
    END

# ---------- 5. Phase 5 : Farmer ยืนยันรับอุปกรณ์ (TC05 RT02) ----------
Phase 5 - Farmer ยืนยันรับอุปกรณ์
    Switch Context    ${FARMER_CTX}
    GROUP    F-MAIN-25 : เปิดหน้าการจัดส่งและคืน
        เปิดหน้าการจัดส่งและคืน
        เลือกรายการที่เพิ่งจัดส่ง
    END
    GROUP    F-MAIN-26 : กดปุ่ม "${BTN_TEXT_RECEIVE}"
        ${Question}=    กดปุ่มบนรายการจัดส่ง    ${BTN_TEXT_RECEIVE}
        เทียบผลจริงกับที่คาดหวัง    ${Question}    ${EXP_RECEIVE_Q}
    END
    GROUP    F-MAIN-27 : ยืนยันการรับอุปกรณ์
        ${Result}=    ยืนยันบนกล่องโต้ตอบ    ${Question}
        บันทึกผลที่ได้จริง    ${Result}
        เทียบผลจริงกับที่คาดหวัง    ${Result}    ${EXP_RECEIVE_DONE}
        ${Buttons}=    อ่านปุ่มของรายการจัดส่ง
        List Should Contain Value    ${Buttons}    ${BTN_TEXT_RETURN}
        ...    msg=ยืนยันรับอุปกรณ์แล้ว แต่การ์ดไม่มีปุ่ม "${BTN_TEXT_RETURN}" (มีปุ่ม ${Buttons})
    END

# ---------- 6. Phase 6 : Farmer คืนอุปกรณ์ (TC05 RT04) ----------
Phase 6 - Farmer คืนอุปกรณ์
    Switch Context    ${FARMER_CTX}
    GROUP    F-MAIN-28 : เปิดหน้าการจัดส่งและคืน
        เปิดหน้าการจัดส่งและคืน
    END
    GROUP    F-MAIN-29 : กดปุ่ม "${BTN_TEXT_RETURN}"
        ${Question}=    กดปุ่มบนรายการจัดส่ง    ${BTN_TEXT_RETURN}
        เทียบผลจริงกับที่คาดหวัง    ${Question}    ${EXP_RETURN_Q}
    END
    GROUP    F-MAIN-30 : ยืนยันการส่งคืนอุปกรณ์
        ${Result}=    ยืนยันบนกล่องโต้ตอบ    ${Question}
        บันทึกผลที่ได้จริง    ${Result}
        เทียบผลจริงกับที่คาดหวัง    ${Result}    ${EXP_RETURN_DONE}
    END

# ---------- 7. Phase 7 : Owner ยืนยันรับคืนและปิดรายการ (TC05 DEL06) ----------
Phase 7 - Owner ยืนยันรับคืนและปิดรายการ
    Switch Context    ${OWNER_CTX}
    GROUP    F-MAIN-31 : เปิดหน้าการจัดส่งผ่านเมนูโปรไฟล์
        Go To                  ${Base_URL}
        Wait For Load State    domcontentloaded    ${DEFAULT_TIMEOUT}
        Click    ${Btn_UserProfile}
        Wait For Elements State    ${Menu_OwnerDelivery}    visible    ${DEFAULT_TIMEOUT}
        Click    ${Menu_OwnerDelivery}
        รอจนอยู่ที่หน้า    /owner/delivery
    END
    ${Card}=    Set Variable    xpath=(${Card_OwnerReturn}\[.//h3[contains(.,'รหัส: ${DELIVERY_ID})')]])[1]
    GROUP    F-MAIN-32 : กดปุ่ม "ยืนยันรับคืนแล้ว" บนรายการรหัส ${DELIVERY_ID}
        Wait For Elements State    ${Card}    visible    ${LIST_TIMEOUT}
        ...    message=ไม่พบรายการส่งคืนรหัส ${DELIVERY_ID} บนหน้าการจัดส่งของ Owner
        ${Clicked}=    Click Button If Enabled    ${Card} >> xpath=.${Btn_ConfirmReturned}
        Should Be True    ${Clicked}    msg=กดปุ่ม "ยืนยันรับคืนแล้ว" ของรายการรหัส ${DELIVERY_ID} ไม่ได้
        Wait For Elements State    ${Btn_PopupConfirm}    visible    5s    message=กดยืนยันรับคืนแล้วไม่มีกล่องยืนยันเด้งขึ้นมา
    END
    GROUP    F-MAIN-33 : ยืนยันรับคืนและปิดรายการจอง
        # popup ของหน้านี้แสดงผลในเนื้อความ ไม่ใช่หัวข้อ
        ${Before}=    Get Booking Dialog Text
        Click    //button[contains(@class,'swal2-confirm') and normalize-space()='${BTN_TEXT_CONFIRM}']
        ${Result}=    Wait For Booking Dialog Change    ${Before}
        IF    $Result == $Before
            ${Result}=    Set Variable    ${EMPTY}
        END
        บันทึกผลที่ได้จริง    ${Result}
        เทียบผลจริงกับที่คาดหวัง    ${Result}    ${EXP_RETURNED_DONE}
        Run Keyword And Ignore Error    Click Button If Enabled    ${Btn_PopupConfirm}
        Sleep    1.5s
        ${Remain}=    Run Keyword And Return Status    Wait For Elements State    ${Card}    visible    ${SHORT_TIMEOUT}
        Should Not Be True    ${Remain}    msg=ยืนยันรับคืนแล้ว แต่รายการรหัส ${DELIVERY_ID} ยังอยู่ในหน้ารายการที่ต้องได้รับคืน
    END

# ---------- 8. Phase 8 : ออกจากระบบ (TC01 LF06 / LO06) ----------
Phase 8 - ออกจากระบบ
    Switch Context    ${FARMER_CTX}
    ออกจากระบบ    Farmer
    Switch Context    ${OWNER_CTX}
    ออกจากระบบ    Owner

# ---------- 9. ขั้นตอนย่อย ----------
เข้าสู่ระบบต้องสำเร็จ
    #หัวข้อ popup ต้องเป็น "เข้าสู่ระบบสำเร็จ" กดปุ่มบน popup แล้วต้องออกจากหน้าเข้าสู่ระบบ (ปุ่มของสองบทบาทใช้คนละคำ)
    [Arguments]    ${LoginUrlPart}    ${ConfirmButton}
    ${Message}=    อ่านหัวข้อ popup
    บันทึกผลที่ได้จริง    ${Message}
    เทียบผลจริงกับที่คาดหวัง    ${Message}    ${EXP_LOGIN_SUCCESS}
    Click    ${ConfirmButton}
    FOR    ${Round}    IN RANGE    20
        ${Url}=    Get Url
        IF    $LoginUrlPart not in $Url    RETURN
        Sleep    0.5s
    END
    Fail    กดปุ่มบน popup แล้วยังค้างอยู่ที่หน้าเข้าสู่ระบบ (${Url})

ออกจากระบบ
    #F-MAIN-34 ถึง 35 : เริ่มจากหน้าหลัก เปิดเมนูโปรไฟล์ กดออกจากระบบ ต้องแสดง "ออกจากระบบสำเร็จ!" และกลับหน้าหลัก
    [Arguments]    ${Actor}
    GROUP    F-MAIN-34 : ${Actor} เปิดเมนูโปรไฟล์
        Go To                  ${Base_URL}
        Wait For Load State    domcontentloaded    ${DEFAULT_TIMEOUT}
        Click    ${Btn_UserProfile}
        ${HasLogout}=    Is Element Visible    ${Btn_Logout}
        Should Be True    ${HasLogout}    msg=เปิดเมนูโปรไฟล์ของ ${Actor} แล้วไม่พบปุ่มออกจากระบบ
    END
    GROUP    F-MAIN-35 : ${Actor} กดออกจากระบบ
        Click    ${Btn_Logout}
        ${Message}=    อ่านหัวข้อ popup
        บันทึกผลที่ได้จริง    ${Message}
        เทียบผลจริงกับที่คาดหวัง    ${Message}    ${EXP_LOGOUT_SUCCESS}
        รอจนอยู่ที่หน้า    ${EMPTY}
    END

อ่านหัวข้อ popup
    #รอ popup (${Popup_Title}) แล้วคืนหัวข้อ ไม่มี popup คืนค่าว่าง
    ${HasPopup}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Popup_Title}    visible    ${POPUP_TIMEOUT}
    IF    not ${HasPopup}    RETURN    ${EMPTY}
    ${Text}=    Get Popup Title
    RETURN    ${Text}

รอจนอยู่ที่หน้า
    #รอจน path ของ URL ตรงกับที่ระบุแบบตรงตัว (ค่าว่าง = หน้าหลัก)
    [Arguments]    ${ExpectedPath}
    FOR    ${Round}    IN RANGE    20
        ${Url}=     Get Url
        ${Path}=    Evaluate    urllib.parse.urlparse($Url).path.rstrip('/')    modules=urllib.parse
        IF    $Path == $ExpectedPath    RETURN
        Sleep    0.5s
    END
    Should Be Equal    ${Path}    ${ExpectedPath}    msg=ไม่ได้ไปที่หน้า "${ExpectedPath}" (อยู่ที่ ${Url})

เลือกวันที่จอง
    #เลือกวันที่ (ปปปป-ดด-วว) จากปฏิทินของช่องที่ระบุ ค่าที่ลงช่องต้องเป็นวันที่ที่ตั้งใจเลือก
    [Arguments]    ${Field}    ${IsoDate}
    ${Date}=          Evaluate    datetime.date.fromisoformat($IsoDate)    modules=datetime
    ${MonthIndex}=    Evaluate    $Date.year * 12 + $Date.month
    ${Display}=       Evaluate    "%02d/%02d/%d" % ($Date.day, $Date.month, $Date.year + ${THAI_YEAR_OFFSET})
    ${Value}=         Pick Date From Calendar    ${Field}    ${Date.day}    ${MonthIndex}    ${Display}
    ${Matched}=       ค่าวันที่ตรงกับเป้าหมาย    ${Value}    ${Date.day}    ${MonthIndex}
    Should Be True    ${Matched}    msg=เลือกวันที่ ${Display} แล้วช่องได้ค่า "${Value}"

หาการ์ดการจองที่เพิ่งสร้าง
    #ไล่ทุกหน้าในแท็บ "รอดำเนินการ" หาการ์ดที่อุปกรณ์และวันเริ่ม-วันสิ้นสุดตรงกับการจองที่เพิ่งสร้าง คืน locator ของการ์ดนั้น
    เปิดแท็บสถานะ    ${STATUS_PENDING}
    Run Keyword And Ignore Error
    ...    Wait For Elements State    ${Card_OwnerBooking} >> nth=0    visible    ${LIST_TIMEOUT}
    ${Start}=    Evaluate    datetime.date.fromisoformat($BOOK_START).toordinal()    modules=datetime
    ${End}=      Evaluate    datetime.date.fromisoformat($BOOK_END).toordinal()      modules=datetime
    FOR    ${Page}    IN RANGE    30
        ${Cards}=    Evaluate JavaScript    ${None}    ${JS_READ_CARDS}
        FOR    ${Item}    IN    @{Cards}
            ${From}=    แปลงวันที่ไทยเป็นเลขวัน    ${Item}[start]
            ${To}=      แปลงวันที่ไทยเป็นเลขวัน    ${Item}[end]
            ${Match}=    Evaluate    $EQ_NAME in $Item["equipment"] and $From == ${Start} and $To == ${End}
            IF    ${Match}
                ${Booking}=    Evaluate    dict($Item)
                Log    การจองที่เพิ่งสร้าง : ${Booking}    level=INFO
                ${Locator}=    สร้างตัวจับการ์ดการจอง    ${Booking}
                RETURN    ${Locator}
            END
        END
        ${HasNext}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${Btn_NextPage}    enabled    ${SHORT_TIMEOUT}
        IF    not ${HasNext}    BREAK
        Click    ${Btn_NextPage}
        Sleep    1s
    END
    Fail    ไม่พบการจอง "${EQ_NAME}" วันที่ ${BOOK_START} ถึง ${BOOK_END} ในแท็บ "${STATUS_PENDING}"

อัปเดตสถานะการจอง
    #กดปุ่ม อัปเดตเป็น "<สถานะใหม่>" บนการ์ด (ข้อความปุ่มต้องตรงตัว) ยืนยัน แล้วต้องได้ "อัปเดตสถานะสำเร็จ!" และการ์ดย้ายไปแท็บใหม่พร้อมสถานะตรงกัน
    [Arguments]    ${ClickStep}    ${ConfirmStep}    ${From}    ${To}
    GROUP    ${ClickStep} : กดปุ่ม อัปเดตเป็น "${To}"
        ${Card}=    หาการ์ดการจอง    ${From}    ${BOOKING_CARD}
        Should Not Be Empty    ${Card}    msg=ไม่พบการจองในแท็บ "${From}"
        ${Button}=    อ่านข้อความปุ่มบนการ์ด    ${Card}    ${BTN_TEXT_UPDATE}
        เทียบผลจริงกับที่คาดหวัง    ${Button}    ${BTN_TEXT_UPDATE} "${To}"
        ${Clicked}=    Click Button If Enabled    ${Card} >> xpath=.//button[contains(.,'${BTN_TEXT_UPDATE}')]
        Should Be True    ${Clicked}    msg=กดปุ่ม ${Button} ไม่ได้
        ${Question}=    อ่านหัวข้อ popup
        Should Not Be Empty    ${Question}    msg=กดปุ่ม ${Button} แล้วไม่มีกล่องยืนยันเด้งขึ้นมา
    END
    GROUP    ${ConfirmStep} : ยืนยันการอัปเดตเป็น "${To}"
        ${Result}=    ยืนยันบนกล่องโต้ตอบ    ${Question}
        บันทึกผลที่ได้จริง    ${Result}
        เทียบผลจริงกับที่คาดหวัง    ${Result}    ${EXP_UPDATE_SUCCESS}
        ${Moved}=    หาการ์ดการจอง    ${To}    ${BOOKING_CARD}
        Should Not Be Empty    ${Moved}    msg=ระบบแจ้งสำเร็จ แต่ไม่พบการจองในแท็บ "${To}"
        ${Status}=    อ่านสถานะบนการ์ด    ${Moved}
        เทียบผลจริงกับที่คาดหวัง    ${Status}    สถานะ : ${To}
    END

ยืนยันบนกล่องโต้ตอบ
    #กดปุ่ม "ยืนยัน" บนกล่องยืนยัน รอหัวข้อ popup เปลี่ยนเป็นผลลัพธ์ แล้วกดปิด คืนหัวข้อผลลัพธ์ ไม่เปลี่ยนคืนค่าว่าง
    [Arguments]    ${Question}
    ${Confirm}=    Set Variable    //button[contains(@class,'swal2-confirm') and normalize-space()='${BTN_TEXT_CONFIRM}']
    ${Confirmed}=    Click Button If Enabled    ${Confirm}
    Should Be True    ${Confirmed}    msg=ไม่พบปุ่ม "${BTN_TEXT_CONFIRM}" ในกล่องยืนยัน
    ${Result}=    Wait For Popup Title Change    ${Question}
    IF    $Result == $Question
        ${Result}=    Set Variable    ${EMPTY}
    END
    Run Keyword And Ignore Error    Click Button If Enabled    ${Btn_PopupConfirm}
    Sleep    1s
    RETURN    ${Result}

เปิดหน้าการจัดส่งและคืน
    #เปิดหน้า "การจัดส่งและคืน" ของ Farmer แล้วรอรายการแสดง
    Go To                  ${Return_farmerURL}
    Wait For Load State    domcontentloaded    ${DEFAULT_TIMEOUT}
    รอจนอยู่ที่หน้า    /farmer/delivery
    Run Keyword And Ignore Error
    ...    Wait For Elements State    //h3[contains(.,'การขนส่ง #')] >> nth=0    visible    ${LIST_TIMEOUT}
    Sleep    0.5s

เลือกรายการที่เพิ่งจัดส่ง
    #รายการที่เพิ่งจัดส่งคือรายการที่มีปุ่ม "ยืนยันรับอุปกรณ์" และรหัสใหม่ที่สุด จำรหัสไว้ใช้ทั้ง Phase 5-7
    ${Items}=    Evaluate JavaScript    ${None}    ${JS_READ_DELIVERIES}
    Log    รายการในหน้าการจัดส่งและคืน : ${Items}    level=INFO
    ${Ids}=    Evaluate    [int(i["id"]) for i in $Items if $BTN_TEXT_RECEIVE in i["buttons"] and i["id"].isdigit()]
    ${Count}=    Get Length    ${Ids}
    Should Be True    ${Count} > 0    msg=ไม่พบรายการที่มีปุ่ม "${BTN_TEXT_RECEIVE}" หลัง Owner อัปเดตเป็น "${STATUS_DELIVERED}"
    ${Newest}=    Evaluate    str(max($Ids))
    Set Suite Variable    ${DELIVERY_ID}    ${Newest}
    Log    รายการจัดส่งที่ใช้ทดสอบ : รหัส ${DELIVERY_ID}    level=INFO

กดปุ่มบนรายการจัดส่ง
    #กดปุ่มบนการ์ดของรายการรหัส ${DELIVERY_ID} คืนหัวข้อกล่องยืนยัน (ไม่มีกล่องคืนค่าว่าง)
    [Arguments]    ${ButtonText}
    ${Head}=      Set Variable    //h3[contains(.,'การขนส่ง #') and contains(.,'รหัส: ${DELIVERY_ID})')]
    ${Button}=    Set Variable    xpath=(${Head}/ancestor::div[.//button][1]//button[contains(.,'${ButtonText}')])[1]
    ${Clicked}=    Click Button If Enabled    ${Button}
    Should Be True    ${Clicked}    msg=ไม่มีปุ่ม "${ButtonText}" ที่กดได้บนรายการรหัส ${DELIVERY_ID}
    ${Question}=    อ่านหัวข้อ popup
    RETURN    ${Question}

อ่านปุ่มของรายการจัดส่ง
    #เปิดหน้าใหม่แล้วอ่านข้อความปุ่มทั้งหมดของรายการรหัส ${DELIVERY_ID} (ไม่พบคืนลิสต์ว่าง)
    เปิดหน้าการจัดส่งและคืน
    ${Items}=    Evaluate JavaScript    ${None}    ${JS_READ_DELIVERIES}
    ${Found}=    Evaluate    [i["buttons"] for i in $Items if i["id"] == $DELIVERY_ID]
    IF    not $Found
        ${Empty}=    Create List
        RETURN    ${Empty}
    END
    RETURN    ${Found}[0]

# ---------- 10. ขั้นตอนย่อยบนหน้ารายการจองของ Owner (ชุดเดียวกับ Usecase_ApproveBooking_owner) ----------
แปลงวันที่ไทยเป็นเลขวัน
    #แปลงวันที่แบบหน้าเว็บ (เช่น 21 กันยายน 2569) เป็นเลขลำดับวัน คืน None เมื่ออ่านไม่ออก
    [Arguments]    ${Text}
    ${Parts}=    Split String    ${Text}
    ${Count}=    Get Length    ${Parts}
    IF    ${Count} != 3    RETURN    ${None}
    ${Month}=    Get From Dictionary    ${THAI_MONTHS}    ${Parts}[1]    default=${0}
    IF    ${Month} == 0    RETURN    ${None}
    ${Year}=     เทียบปีให้เป็น ค.ศ.    ${Parts}[2]
    ${Day}=      Convert To Integer    ${Parts}[0]
    ${Ordinal}=    Evaluate    datetime.date(${Year}, ${Month}, ${Day}).toordinal()    modules=datetime
    RETURN    ${Ordinal}

สร้างตัวจับการ์ดการจอง
    #สร้าง locator การ์ดจาก ผู้เช่า+อุปกรณ์+วันเริ่ม+วันสิ้นสุด (ชี้การ์ดได้ใบเดียวแม้ย้ายแท็บหรือหน้าเรียงลำดับใหม่)
    [Arguments]    ${Booking}
    ${Equipment}=    Set Variable    ${Booking}[equipment][0]
    ${Locator}=    Catenate    SEPARATOR=
    ...    xpath=(${Card_OwnerBooking}
    ...    [.//span[normalize-space()='ผู้เช่า: ${Booking}[tenant]']]
    ...    [.//h5[normalize-space()='${Equipment}']]
    ...    [.//p[contains(.,'เริ่มต้น')]/span[normalize-space()='${Booking}[start]']]
    ...    [.//p[contains(.,'สิ้นสุด')]/span[normalize-space()='${Booking}[end]']])[1]
    RETURN    ${Locator}

เปิดแท็บสถานะ
    #เปิดหน้ารายการจองแล้วกดแท็บตามสถานะ (เทียบข้อความแท็บตรงตัว ไม่ให้ไปโดนปุ่ม อัปเดตเป็น "...")
    [Arguments]    ${Status}
    Go To                  ${ApproveBooking_ownerURL}
    Wait For Load State    domcontentloaded    ${DEFAULT_TIMEOUT}
    Sleep    1s
    ${Tab}=    Set Variable    //button[normalize-space()='${Status}']
    Wait For Elements State    ${Tab}    visible    ${DEFAULT_TIMEOUT}
    Click    ${Tab}
    Sleep    1.5s

หาการ์ดการจอง
    #เปิดแท็บตามสถานะแล้วหาการ์ดตาม locator ไล่ทุกหน้า คืน locator เมื่อพบ หรือค่าว่างเมื่อไม่พบ
    [Arguments]    ${Status}    ${Card}
    เปิดแท็บสถานะ    ${Status}
    ${Timeout}=    Set Variable    ${LIST_TIMEOUT}
    FOR    ${Page}    IN RANGE    30
        ${Found}=    Run Keyword And Return Status    Wait For Elements State    ${Card}    visible    ${Timeout}
        IF    ${Found}    RETURN    ${Card}
        ${HasNext}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${Btn_NextPage}    enabled    ${SHORT_TIMEOUT}
        IF    not ${HasNext}    BREAK
        Click    ${Btn_NextPage}
        Sleep    1s
        ${Timeout}=    Set Variable    ${SHORT_TIMEOUT}
    END
    RETURN    ${EMPTY}

อ่านสถานะบนการ์ด
    #อ่านข้อความ "สถานะ : ..." บนการ์ด รวมช่องว่างให้เหลือช่องเดียว ไม่พบคืนค่าว่าง
    [Arguments]    ${Card}
    ${Span}=    Set Variable    ${Card} >> xpath=.//span[starts-with(normalize-space(),'สถานะ :')]
    ${Found}=    Is Element Visible    ${Span}
    IF    not ${Found}    RETURN    ${EMPTY}
    ${Text}=    Get Text    ${Span}
    ${Text}=    Evaluate    " ".join($Text.split())
    RETURN    ${Text}

อ่านข้อความปุ่มบนการ์ด
    #อ่านข้อความบนปุ่มของการ์ดที่มีคำที่ระบุ คืนค่าว่างเมื่อการ์ดไม่มีปุ่มนั้น
    [Arguments]    ${Card}    ${ButtonText}
    ${Button}=    Set Variable    ${Card} >> xpath=.//button[contains(.,'${ButtonText}')]
    ${Found}=    Is Element Visible    ${Button}
    IF    not ${Found}    RETURN    ${EMPTY}
    ${Text}=    Get Text    ${Button}
    ${Text}=    Evaluate    " ".join($Text.split())
    RETURN    ${Text}

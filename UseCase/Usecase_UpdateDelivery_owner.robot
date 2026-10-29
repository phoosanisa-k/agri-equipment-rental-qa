*** Settings ***
Documentation     TC05 - Update Delivery and Pick Up Owner (Usecase) | อ้างอิงหัวข้อ 8.5 (Basic Flow 1-10,
...               Alternate Flow 6.1, ตาราง DEL-01~DEL-06) และ TC09 ในเอกสาร Test Design
...               Pre-Condition: Owner login แล้ว + "ผ่านขั้นตอนการอนุมัติการชำระเงิน" (ไฟล์นี้รันแยกอิสระได้
...               ถ้าแท็บ "อนุมัติการชำระเงิน" ว่าง จะอนุมัติคำขอจองแรกในแท็บ "รอดำเนินการ" ให้เองด้วยกลไกเดียวกับ
...               Usecase_ApproveBooking_owner.robot จนถึงขั้นนี้ ก่อนเริ่มทดสอบ F01-F05, F07)
...
...               สถานะเว็บเทียบเอกสาร: อนุมัติการชำระเงิน→รอการจัดส่ง=DEL-03(On Delivery) |
...               รอการจัดส่ง→จัดส่งเรียบร้อย=DEL-04(Delivered) | เกษตรกรส่งคืนแล้ว→ยืนยันรับคืนแล้ว=DEL-05(Returned)
...
...               TC05_F01→DEL-01,02/BasicFlow1-4(เห็นรายการพร้อมจัดส่ง) | F02→AltFlow6.1(ยกเลิกอัปเดต)
...               F03→DEL-03/BasicFlow5-9(→รอการจัดส่ง) | F04→DEL-04/BasicFlow5-9(→จัดส่งเรียบร้อย)
...               F05→Invalid 8.5.1(เปลี่ยนข้ามลำดับไม่ได้) | F06→DEL-05(ยืนยันรับคืน, Skip ถ้ายังไม่มีรายการส่งคืน)
...               F07→DEL-06(ตรวจสถานะล่าสุด)
...
...               หมายเหตุ: เปลี่ยนสถานะจริง รันหนึ่งรอบใช้รายการในแท็บ "อนุมัติการชำระเงิน" ไป 1 รายการ
Metadata          Use Case    TC05 Update Delivery and Pick Up Owner (Functional Flow)

Resource          ../Resources/keywords.robot
Library           OperatingSystem
Library           String
Library           Collections

Suite Setup       เปิดชุดทดสอบ
Suite Teardown    ปิดชุดทดสอบ
Test Teardown     เก็บผลท้ายกรณีทดสอบ    ปิดกล่องโต้ตอบที่ค้างอยู่

*** Variables ***
# ---------- ไฟล์และโฟลเดอร์ ----------
${USECASE}              TC05_Usecase_UpdateDelivery_Owner
${SCREENSHOT_DIR}       ${CURDIR}/../Screenshot/${USECASE}

# ---------- สถานะการจองบนหน้ารายการจอง ----------
${STATUS_PENDING}       รอดำเนินการ
${STATUS_WAITPAY}       รอการชำระเงิน
${STATUS_PAID}          อนุมัติการชำระเงิน
${STATUS_WAITDELIVERY}  รอการจัดส่ง
${STATUS_DELIVERED}     จัดส่งเรียบร้อย
@{ALL_STATUSES}         รอดำเนินการ    รอการชำระเงิน    อนุมัติการชำระเงิน    รอการจัดส่ง    จัดส่งเรียบร้อย

# ---------- ข้อความที่ระบบตอบกลับจริง ใช้ตัดสินผล ----------
${EXP_LOGIN_SUCCESS}        เข้าสู่ระบบสำเร็จ                          # เข้าสู่ระบบ Owner
${UPDATE_SUCCESS}           อัปเดตสถานะสำเร็จ!                         # DEL03-01 / DEL04-01
${RETURN_DONE}              ยืนยันการรับคืนอุปกรณ์เรียบร้อยแล้ว          # DEL06-02
# ข้อความบนปุ่มอัปเดตสถานะ ระบบใช้เครื่องหมายคำพูดตรง " " เช่น อัปเดตเป็น "รอการจัดส่ง"
${EXP_BTN_TO_WAITDELIVERY}  อัปเดตเป็น "${STATUS_WAITDELIVERY}"         # DEL01-03 / DEL05-01
${EXP_BTN_TO_DELIVERED}     อัปเดตเป็น "${STATUS_DELIVERED}"            # DEL05-02

# ---------- ข้อความบนปุ่ม ----------
${BTN_TEXT_UPDATE}      อัปเดตเป็น
${BTN_TEXT_CONFIRM}     ยืนยัน

# ---------- ตัวจับบนหน้ารายการจองของ Owner ----------
# การ์ดรายการจองแต่ละใบคือ div กรอบ border-emerald-200 ที่มีหัวข้อ "การจอง #n"
${Card_OwnerBooking}    //div[contains(@class,'border-emerald-200')][.//h3[contains(.,'การจอง #')]]
# ปุ่มเปลี่ยนหน้า แสดงเฉพาะเมื่อมีมากกว่า 3 รายการ
${Btn_NextPage}         //button[contains(.,'ถัดไป')]
# ปุ่ม "ยกเลิก" ของกล่องยืนยัน แปลว่าไม่ทำรายการต่อ
${Btn_DialogCancel}     //button[contains(@class,'swal2-cancel')]
${LIST_TIMEOUT}         ${CARD_TIMEOUT}

# อ่านข้อมูลของการ์ดทุกใบบนหน้าที่แสดงอยู่ คืนเป็นลิสต์ของ {tenant, status, start, end, address, equipment}
${JS_READ_CARDS}        () => [...document.querySelectorAll('div.border-emerald-200')].filter(d => (d.querySelector('h3') || {textContent: ''}).textContent.includes('การจอง #')).map(d => { const t = e => e ? e.textContent.replace(/\\s+/g, ' ').trim() : ''; const ps = [...d.querySelectorAll('p')]; const st = ps.find(p => p.textContent.includes('เริ่มต้น')); const en = ps.find(p => p.textContent.includes('สิ้นสุด')); const ah = [...d.querySelectorAll('h4')].find(h => h.textContent.includes('ที่อยู่จัดส่ง')); const ad = ah ? ah.closest('div').parentElement.querySelector('p') : null; const sp = [...d.querySelectorAll('span')]; const tn = sp.find(s => s.textContent.trim().startsWith('ผู้เช่า:')); const ss = sp.find(s => s.textContent.trim().startsWith('สถานะ :')); return {tenant: t(tn).replace('ผู้เช่า:', '').trim(), status: t(ss).replace('สถานะ :', '').trim(), start: t(st && st.querySelector('span')), end: t(en && en.querySelector('span')), address: t(ad), equipment: [...d.querySelectorAll('h5')].map(t)}; })

# ---------- ตัวแปรระดับชุดทดสอบ ----------
&{TARGET}               tenant=${EMPTY}
${TARGET_CARD}          ${EMPTY}
${ON_DELIVERY}          ${False}
${DELIVERED}            ${False}

# ---------- ตัวแปรระดับกรณีทดสอบ ----------
${TC_ID}                UNKNOWN
${ACTUAL_MESSAGE}       ${EMPTY}

*** Test Cases ***
TC05_F01 - เปิดหน้าผ่านเมนูบัญชีแล้วเห็นรายการที่พร้อมจัดส่ง
    #DEL-01, DEL-02 / Basic Flow 1-4: แท็บ "อนุมัติการชำระเงิน" ต้องแสดงข้อมูลครบและมีปุ่ม "อัปเดตเป็นรอการจัดส่ง"
    Set Test Variable    ${TC_ID}    TC05_F01
    กรณี TC05_F01

TC05_F02 - กดอัปเดตแล้วเลือกยกเลิกในกล่องยืนยัน
    #Alternate Flow 6.1 : ผู้ใช้ไม่ยืนยันการอัปเดตสถานะ ระบบต้องไม่เปลี่ยนสถานะของรายการ
    Set Test Variable    ${TC_ID}    TC05_F02
    กรณี TC05_F02

TC05_F03 - อัปเดตสถานะเป็นรอการจัดส่ง
    #DEL-03 (On Delivery) / Basic Flow 5-9: อัปเดตสำเร็จ และรายการย้ายไปแท็บ "รอการจัดส่ง" จริง
    Set Test Variable    ${TC_ID}    TC05_F03
    กรณี TC05_F03

TC05_F04 - อัปเดตสถานะเป็นจัดส่งเรียบร้อย
    #DEL-04 (Delivered) / Basic Flow 5-9: อัปเดตสำเร็จ และรายการย้ายไปแท็บ "จัดส่งเรียบร้อย" จริง
    Set Test Variable    ${TC_ID}    TC05_F04
    กรณี TC05_F04

TC05_F05 - เปลี่ยนสถานะข้ามลำดับไม่ได้
    #Invalid 8.5.1: ปุ่มบนการ์ดต้องมีแค่สถานะถัดไป และรายการที่จัดส่งเรียบร้อยแล้วต้องไม่มีปุ่มอัปเดต
    Set Test Variable    ${TC_ID}    TC05_F05
    กรณี TC05_F05

TC05_F06 - ยืนยันรับคืนอุปกรณ์
    #DEL-05 (Returned): กด "ยืนยันรับคืนแล้ว" ต้องแจ้งสำเร็จและรายการหายจากหน้านี้ (Skip ถ้ายังไม่มีรายการส่งคืน)
    Set Test Variable    ${TC_ID}    TC05_F06
    กรณี TC05_F06

TC05_F07 - ตรวจสถานะล่าสุดของรายการ
    #DEL-06 : รายการทดสอบต้องแสดงสถานะล่าสุดถูกต้อง คืออยู่ในแท็บ "จัดส่งเรียบร้อย" แท็บเดียว
    Set Test Variable    ${TC_ID}    TC05_F07
    กรณี TC05_F07

*** Keywords ***
# =====================================================================
# 1. การเตรียมและปิดชุดทดสอบ
# =====================================================================

เปิดชุดทดสอบ
    #ล้างภาพของรอบก่อน เข้าสู่ระบบเป็น Owner ค้างไว้ทั้งชุด แล้วเลือกรายการที่จะใช้ทดสอบ
    เตรียมชุดทดสอบยูสเคส
    ตรวจว่าตั้งค่าครบแล้วหรือยัง

    เข้าสู่ระบบเป็นเจ้าของอุปกรณ์
    เลือกรายการที่จะใช้ทดสอบ

ตรวจว่าตั้งค่าครบแล้วหรือยัง
    #ล้มทั้งชุดทันทีเมื่อยังไม่ได้ตั้งบัญชี Owner เพราะทุกกรณีทดสอบต้องเข้าสู่ระบบก่อน
    ${UserLen}=    Get Length    ${OwnerUser}
    ${PassLen}=    Get Length    ${OwnerPass}
    IF    ${UserLen} == 0 or ${PassLen} == 0
        Fail    ยังไม่ได้ตั้งค่าบัญชี Owner กรุณาเติม \${TEST_OWNER_USER} และ \${TEST_OWNER_PASS} ใน Resources/variables.robot
    END

เลือกรายการที่จะใช้ทดสอบ
    #ใช้รายการแรกในแท็บ "อนุมัติการชำระเงิน" ถ้าแท็บว่างจะเตรียมรายการเองจากคำขอจองที่มีอยู่ แล้วจำ ผู้เช่า/อุปกรณ์/วันเริ่ม/วันสิ้นสุด ไว้ตามหารายการเดิมทั้งชุด
    ${Target}=    หารายการพร้อมทดสอบในแท็บ    ${STATUS_PAID}
    IF    not $Target
        Log    ไม่มีรายการค้างในแท็บ "${STATUS_PAID}" จึงจะอนุมัติคำขอจองที่มีอยู่แล้วในระบบให้ถึงขั้นนี้เอง    level=INFO
        เตรียมรายการใหม่จนถึงอนุมัติการชำระเงิน
        ${Target}=    หารายการพร้อมทดสอบในแท็บ    ${STATUS_PAID}
        Should Not Be Empty    ${Target}
        ...    msg=เตรียมรายการจนถึงแท็บ "${STATUS_PAID}" ให้แล้ว แต่กลับมาหาในแท็บนี้ไม่เจออีกครั้ง
    END

    Set Suite Variable    ${TARGET}    ${Target}
    ${Locator}=    สร้างตัวจับการ์ดการจอง    ${Target}
    Set Suite Variable    ${TARGET_CARD}    ${Locator}
    Log    รายการที่ใช้ทดสอบ : ${TARGET}    level=INFO

หารายการพร้อมทดสอบในแท็บ
    #เปิดแท็บตามสถานะ อ่านการ์ดใบแรก คืน dict ของรายการ หรือค่าว่างถ้าแท็บว่าง (ลองอ่านซ้ำได้ถึง 3 ครั้ง)
    [Arguments]    ${Status}
    เปิดแท็บสถานะ    ${Status}
    Run Keyword And Ignore Error
    ...    Wait For Elements State    ${Card_OwnerBooking} >> nth=0    visible    ${LIST_TIMEOUT}

    ${Cards}=    Set Variable    ${None}
    FOR    ${Attempt}    IN RANGE    3
        ${Cards}=    Evaluate JavaScript    ${None}    ${JS_READ_CARDS}
        IF    $Cards is not None    BREAK
        Sleep    1s
    END
    IF    $Cards is None
        Log    Evaluate JavaScript คืนค่า None ซ้ำ 3 ครั้งติดในแท็บ "${Status}" ถือว่าไม่มีรายการ    level=WARN
        RETURN    ${EMPTY}
    END

    ${Count}=    Get Length    ${Cards}
    IF    ${Count} == 0    RETURN    ${EMPTY}
    ${Target}=    Evaluate    dict($Cards[0])
    RETURN    ${Target}

เตรียมรายการใหม่จนถึงอนุมัติการชำระเงิน
    #หยิบคำขอจองแรกในแท็บ "รอดำเนินการ" มาอนุมัติจนถึงแท็บ "อนุมัติการชำระเงิน" (กลไกเดียวกับ ApproveBooking_owner)
    ${Pending}=    หารายการพร้อมทดสอบในแท็บ    ${STATUS_PENDING}
    Should Not Be Empty    ${Pending}
    ...    msg=ไม่มีคำขอจองค้างในแท็บ "${STATUS_PENDING}" เลย จึงเตรียมรายการทดสอบเองไม่ได้ กรุณาสร้างคำขอจองก่อน (เช่นรัน UseCase/Usecase_Booking_farmer.robot)
    ${Locator}=    สร้างตัวจับการ์ดการจอง    ${Pending}

    ${Card}=    หาการ์ดการจอง    ${STATUS_PENDING}    ${Locator}
    Should Not Be Empty    ${Card}
    ...    msg=เพิ่งเจอคำขอจองในแท็บ "${STATUS_PENDING}" แต่หาการ์ดเดิมซ้ำไม่เจอ
    ${Question}    ${Result}=    กดปุ่มบนการ์ดแล้วยืนยัน    ${Card}    ${BTN_TEXT_UPDATE}    ${BTN_TEXT_CONFIRM}
    เทียบผลจริงกับที่คาดหวัง    ${Result}    ${UPDATE_SUCCESS}

    ${Card}=    หาการ์ดการจอง    ${STATUS_WAITPAY}    ${Locator}
    Should Not Be Empty    ${Card}
    ...    msg=อนุมัติคำขอจองแล้ว แต่หารายการในแท็บ "${STATUS_WAITPAY}" ไม่เจอ
    ${Question}    ${Result}=    กดปุ่มบนการ์ดแล้วยืนยัน    ${Card}    ${BTN_TEXT_UPDATE}    ${BTN_TEXT_CONFIRM}
    เทียบผลจริงกับที่คาดหวัง    ${Result}    ${UPDATE_SUCCESS}
    Log    เตรียมรายการทดสอบขึ้นมาเองสำเร็จ : ${Pending}    level=INFO

# =====================================================================
# 2. การเข้าสู่ระบบและเมนูของ Owner
# =====================================================================

เข้าสู่ระบบเป็นเจ้าของอุปกรณ์
    #เปิด context ใหม่แล้วเข้าสู่ระบบด้วย ${OwnerUser} / ${OwnerPass} ใช้ session นี้ตลอดทั้งชุด
    Open Login Owner Page
    กรอกบัญชี Owner แล้วกดเข้าสู่ระบบ
    Log    เข้าสู่ระบบเป็น Owner "${OwnerUser}" สำเร็จ ใช้ session นี้ตลอดทั้งชุดทดสอบ    level=INFO

กรอกบัญชี Owner แล้วกดเข้าสู่ระบบ
    #กรอกบัญชี กดเข้าสู่ระบบ แล้วกด "ไปหน้าแรก" บน popup (ใช้ทั้งตอนเริ่มชุดทดสอบและตอน session หมดอายุ)
    Input Owner Username    ${OwnerUser}
    Input Owner Password    ${OwnerPass}
    Keyboard Key            press    Tab
    ${Clicked}=    Click Owner Login Button
    Should Be True    ${Clicked}    msg=ปุ่มเข้าสู่ระบบถูกปิดใช้งาน จึงเข้าสู่ระบบไม่ได้

    # popup ฝั่ง Owner ใช้ปุ่ม "ไปหน้าแรก" ไม่ใช่ "ตกลง" เหมือนฝั่ง Farmer และอาจขึ้นช้า จึงรอได้ถึง 10 วินาที
    ${Shown}=    Run Keyword And Return Status    Wait For Elements State    ${Popup_Title}    visible    10s
    Should Be True    ${Shown}    msg=กดเข้าสู่ระบบแล้วไม่มี popup ผลการเข้าสู่ระบบขึ้นมาภายใน 10 วินาที
    ${Title}=    Get Popup Title
    เทียบผลจริงกับที่คาดหวัง    ${Title}    ${EXP_LOGIN_SUCCESS}
    ${HasButton}=    Is Element Visible    ${Btn_OGoHome}
    IF    ${HasButton}    Click    ${Btn_OGoHome}

    ${LoggedIn}=    รอให้ออกจากหน้าเข้าสู่ระบบ
    Should Be True    ${LoggedIn}
    ...    msg=กดปุ่มบน popup แล้วยังค้างอยู่ที่หน้าเข้าสู่ระบบของ Owner

รอให้ออกจากหน้าเข้าสู่ระบบ
    #รอจน URL ออกจากหน้าเข้าสู่ระบบ คืน True เมื่อออกแล้ว
    FOR    ${Round}    IN RANGE    20
        ${Url}=     Get Url
        ${Left}=    Evaluate    "login-owner" not in $Url
        IF    ${Left}    RETURN    ${True}
        Sleep    0.5s
    END
    RETURN    ${False}

เข้าสู่ระบบใหม่ถ้า session หมดอายุ
    #ถ้าระบบพากลับหน้าเข้าสู่ระบบ ให้เข้าสู่ระบบใหม่บนหน้าเดิม คืน True เมื่อต้องเข้าสู่ระบบใหม่
    ${Url}=    Get Url
    IF    "login-owner" not in $Url    RETURN    ${False}
    Log    session ของ Owner หมดอายุ จึงเข้าสู่ระบบใหม่    level=WARN
    กรอกบัญชี Owner แล้วกดเข้าสู่ระบบ
    RETURN    ${True}

เปิดเมนูบัญชีแล้วเลือก
    #TC09: คลิกไอคอนโปรไฟล์แล้วเลือกเมนูใน dropdown เริ่มจากหน้าแรกทุกครั้งเหมือนผู้ใช้จริง
    [Arguments]    ${Menu}    ${ExpectedUrl}
    Go To                  ${Base_URL}
    Wait For Load State    domcontentloaded    ${DEFAULT_TIMEOUT}
    ${Relogin}=    เข้าสู่ระบบใหม่ถ้า session หมดอายุ
    IF    ${Relogin}    Go To    ${Base_URL}

    Wait For Elements State    ${Btn_UserProfile}    visible    ${DEFAULT_TIMEOUT}
    Click    ${Btn_UserProfile}
    Wait For Elements State    ${Menu}    visible    ${DEFAULT_TIMEOUT}
    Click    ${Menu}

    # เทียบ path ของ URL ตรงตัว (ไม่ใช่การหาคำบางส่วนใน URL)
    FOR    ${Round}    IN RANGE    20
        ${Url}=     Get Url
        ${Path}=    Evaluate    urllib.parse.urlparse($Url).path.rstrip('/')    modules=urllib.parse
        IF    $Path == $ExpectedUrl    BREAK
        Sleep    0.5s
    END
    Should Be Equal    ${Path}    ${ExpectedUrl}    msg=เลือกเมนูแล้วไม่ได้ไปที่หน้า ${ExpectedUrl} (อยู่ที่ ${Url})
    Sleep    1s

# =====================================================================
# 3. กรณีทดสอบตามตาราง DEL
# =====================================================================

กรณี TC05_F01
    #DEL-01, DEL-02: แท็บ "อนุมัติการชำระเงิน" ต้องแสดงรายการทดสอบข้อมูลครบและมีปุ่มอัปเดตเป็น "รอการจัดส่ง"
    เปิดเมนูบัญชีแล้วเลือก    ${Menu_OwnerBookings}    /owner/bookings
    เลือกแท็บบนหน้าที่เปิดอยู่    ${STATUS_PAID}
    ${Card}=    หาการ์ดบนหน้าที่เปิดอยู่    ${TARGET_CARD}
    Should Not Be Empty    ${Card}
    ...    msg=ไม่พบรายการทดสอบในแท็บ "${STATUS_PAID}" (${TARGET})

    ${Text}=    อ่านข้อความบนการ์ด    ${Card}
    บันทึกผลที่ได้จริง    ${Text}

    FOR    ${Field}    IN    tenant    start    end    address
        Should Not Be Empty    ${TARGET}[${Field}]
        ...    msg=การ์ดไม่มีข้อมูลช่อง ${Field} (ข้อความบนการ์ด : ${Text})
    END
    # DEL01-02 : การ์ดต้องแสดง "สถานะ : อนุมัติการชำระเงิน" ตรงตัว
    ${Status}=    อ่านสถานะบนการ์ด    ${Card}
    เทียบผลจริงกับที่คาดหวัง    ${Status}    สถานะ : ${STATUS_PAID}
    # DEL01-03 : ปุ่มบนการ์ดต้องเป็น อัปเดตเป็น "รอการจัดส่ง" ตรงตัว
    ${Button}=    อ่านข้อความปุ่มบนการ์ด    ${Card}    ${BTN_TEXT_UPDATE}
    บันทึกผลที่ได้จริง    ${Status} | ${Button}
    เทียบผลจริงกับที่คาดหวัง    ${Button}    ${EXP_BTN_TO_WAITDELIVERY}

กรณี TC05_F02
    #Alternate Flow 6.1: กดอัปเดตแล้วกด "ยกเลิก" รายการต้องยังอยู่แท็บ "อนุมัติการชำระเงิน" สถานะไม่เปลี่ยน
    ${Card}=    หาการ์ดการจอง    ${STATUS_PAID}    ${TARGET_CARD}
    Should Not Be Empty    ${Card}
    ...    msg=ไม่พบรายการทดสอบในแท็บ "${STATUS_PAID}" จึงยังทดสอบการยกเลิกการอัปเดตไม่ได้

    ${Button}=    Set Variable    ${Card} >> xpath=.//button[contains(.,'${BTN_TEXT_UPDATE}')]
    ${Clicked}=    Click Button If Enabled    ${Button}
    Should Be True    ${Clicked}    msg=กดปุ่มอัปเดตสถานะบนการ์ดไม่ได้
    ${Shown}=    Run Keyword And Return Status    Wait For Elements State    ${Popup_Title}    visible    5s
    Should Be True    ${Shown}    msg=กดปุ่มอัปเดตแล้วไม่มีกล่องยืนยันเด้งขึ้นมา
    ${Question}=    Get Popup Title
    Click    ${Btn_DialogCancel}
    Sleep    1s

    ${Still}=     หาการ์ดการจอง    ${STATUS_PAID}    ${TARGET_CARD}
    ${Moved}=     หาการ์ดการจอง    ${STATUS_WAITDELIVERY}    ${TARGET_CARD}
    ${InPaid}=    Set Variable If    $Still    ยังอยู่    ไม่พบแล้ว
    ${InWait}=    Set Variable If    $Moved    พบรายการ    ไม่พบ
    บันทึกผลที่ได้จริง    ${Question} -> กดยกเลิก | แท็บ${STATUS_PAID} : ${InPaid} | แท็บ${STATUS_WAITDELIVERY} : ${InWait}

    Should Not Be Empty    ${Still}
    ...    msg=กดยกเลิกในกล่องยืนยันแล้ว แต่รายการหายจากแท็บ "${STATUS_PAID}"
    Should Be Empty    ${Moved}
    ...    msg=กดยกเลิกในกล่องยืนยันแล้ว แต่ระบบยังอัปเดตรายการเป็น "${STATUS_WAITDELIVERY}"

กรณี TC05_F03
    #DEL-03 : อัปเดตจาก "อนุมัติการชำระเงิน" เป็น "รอการจัดส่ง"
    อัปเดตสถานะรายการทดสอบ    ${STATUS_PAID}    ${STATUS_WAITDELIVERY}
    Set Suite Variable    ${ON_DELIVERY}    ${True}

กรณี TC05_F04
    #DEL-04 : อัปเดตจาก "รอการจัดส่ง" เป็น "จัดส่งเรียบร้อย"
    IF    not ${ON_DELIVERY}
        Skip    ไม่ได้ทดสอบ เพราะขึ้นกับ TC05_F03 ที่ยังอัปเดตเป็น "${STATUS_WAITDELIVERY}" ไม่สำเร็จ
    END
    อัปเดตสถานะรายการทดสอบ    ${STATUS_WAITDELIVERY}    ${STATUS_DELIVERED}
    Set Suite Variable    ${DELIVERED}    ${True}

กรณี TC05_F05
    #Invalid: ทุกการ์ดต้องมีปุ่มอัปเดตแค่ปุ่มเดียวที่ชี้สถานะถัดไป และรายการที่จัดส่งเรียบร้อยแล้วต้องไม่มีปุ่มอัปเดต
    IF    not ${DELIVERED}
        Skip    ไม่ได้ทดสอบ เพราะขึ้นกับ TC05_F04 ที่ยังอัปเดตเป็น "${STATUS_DELIVERED}" ไม่สำเร็จ
    END

    ${Problems}=    Create List
    FOR    ${Status}    ${Next}    IN
    ...    ${STATUS_PAID}            ${STATUS_WAITDELIVERY}
    ...    ${STATUS_WAITDELIVERY}    ${STATUS_DELIVERED}
        ${Labels}=    อ่านปุ่มอัปเดตทุกการ์ดในแท็บ    ${Status}
        FOR    ${Label}    IN    @{Labels}
            ${Ok}=    Evaluate    $Label == 'อัปเดตเป็น "' + $Next + '"'
            IF    not ${Ok}    Append To List    ${Problems}    แท็บ${Status} มีปุ่ม ${Label}
        END
    END

    ${Card}=    หาการ์ดการจอง    ${STATUS_DELIVERED}    ${TARGET_CARD}
    Should Not Be Empty    ${Card}    msg=ไม่พบรายการทดสอบในแท็บ "${STATUS_DELIVERED}"
    ${Button}=    อ่านข้อความปุ่มบนการ์ด    ${Card}    ${BTN_TEXT_UPDATE}
    ${HasButton}=    Evaluate    $Button != ''
    IF    ${HasButton}    Append To List    ${Problems}    รายการที่จัดส่งเรียบร้อยแล้วยังมีปุ่ม ${Button}

    ${Summary}=    Evaluate    " | ".join($Problems) if $Problems else "ทุกการ์ดมีปุ่มแค่สถานะถัดไป และรายการที่จัดส่งเรียบร้อยไม่มีปุ่มอัปเดตแล้ว"
    บันทึกผลที่ได้จริง    ${Summary}
    Should Be Empty    ${Problems}    msg=ระบบเปิดทางให้เปลี่ยนสถานะข้ามลำดับได้ : ${Summary}

กรณี TC05_F06
    #DEL-05: กด "ยืนยันรับคืนแล้ว" ของรายการส่งคืนแรก ต้องแจ้งสำเร็จและรายการหายจากหน้านี้
    เปิดเมนูบัญชีแล้วเลือก    ${Menu_OwnerDelivery}    /owner/delivery
    ${HasItem}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Card_OwnerReturn} >> nth=0    visible    ${LIST_TIMEOUT}
    IF    not ${HasItem}
        ${Empty}=    Is Element Visible    ${Text_NoReturnItem}
        ${Shown}=    Set Variable If    ${Empty}    ยังไม่มีอุปกรณ์ที่ส่งคืน    ไม่พบรายการส่งคืน
        บันทึกผลที่ได้จริง    หน้าการจัดส่งแสดง "${Shown}"
        Skip    ยังไม่มีรายการที่เกษตรกรส่งคืนในระบบ ต้องให้เกษตรกรยืนยันรับอุปกรณ์และส่งคืนก่อน (ยูสเคส Return Equipment Farmer) จึงจะทดสอบ DEL-05 ได้
    END

    ${Header}=    Get Text    ${Card_OwnerReturn} >> nth=0 >> xpath=.//h3
    ${DeliveryId}=    Evaluate    (re.search(r"รหัส:\\s*([^)\\s]+)", $Header) or [None, ""])[1]    modules=re
    Should Not Be Empty    ${DeliveryId}    msg=อ่านรหัสรายการส่งคืนจากหัวการ์ดไม่ได้ (${Header})
    ${Card}=    Set Variable    xpath=(${Card_OwnerReturn}\[.//h3[contains(.,'รหัส: ${DeliveryId})')]])[1]

    ${Button}=    Set Variable    ${Card} >> xpath=.${Btn_ConfirmReturned}
    ${Clicked}=    Click Button If Enabled    ${Button}
    Should Be True    ${Clicked}    msg=กดปุ่ม "ยืนยันรับคืนแล้ว" ของรายการรหัส ${DeliveryId} ไม่ได้
    # กล่องโต้ตอบของหน้านี้ไม่มีหัวข้อ แสดงคำถามและผลลัพธ์ในเนื้อความ จึงรอปุ่มยืนยันแล้วอ่านจากเนื้อความ (Get Booking Dialog Text)
    ${Confirm}=    Set Variable    //button[contains(@class,'swal2-confirm') and normalize-space()='${BTN_TEXT_CONFIRM}']
    ${Shown}=    Run Keyword And Return Status    Wait For Elements State    ${Confirm}    visible    5s
    Should Be True    ${Shown}    msg=กดยืนยันรับคืนแล้วไม่มีกล่องยืนยันเด้งขึ้นมา
    ${Question}=    Get Booking Dialog Text
    Click    ${Confirm}
    ${Result}=    Wait For Booking Dialog Change    ${Question}
    IF    $Result == $Question
        ${Result}=    Set Variable    ${EMPTY}
    END
    Log    กล่องยืนยัน "${Question}" -> ผลลัพธ์ "${Result}"    level=INFO
    Run Keyword And Ignore Error    Click Button If Enabled    ${Btn_PopupConfirm}
    Sleep    1.5s

    ${Remain}=    Run Keyword And Return Status    Wait For Elements State    ${Card}    visible    ${SHORT_TIMEOUT}
    ${State}=     Set Variable If    ${Remain}    ยังอยู่ในหน้ารายการที่ต้องได้รับคืน    หายจากหน้ารายการที่ต้องได้รับคืนแล้ว
    บันทึกผลที่ได้จริง    รหัส ${DeliveryId} : ${Result} | ${State}

    # DEL06-02 : ข้อความในเนื้อความกล่องโต้ตอบต้องเป็น "ยืนยันการรับคืนอุปกรณ์เรียบร้อยแล้ว" ตรงตัว
    Run Keyword And Continue On Failure    เทียบผลจริงกับที่คาดหวัง    ${Result}    ${RETURN_DONE}
    Should Not Be True    ${Remain}
    ...    msg=ระบบแจ้งสำเร็จ แต่รายการรหัส ${DeliveryId} ยังอยู่ในหน้ารายการที่ต้องได้รับคืน

กรณี TC05_F07
    #DEL-06: รายการทดสอบต้องอยู่ในแท็บ "จัดส่งเรียบร้อย" แท็บเดียว และสถานะบนการ์ดตรงกัน
    IF    not ${DELIVERED}
        Skip    ไม่ได้ทดสอบ เพราะขึ้นกับ TC05_F04 ที่ยังอัปเดตเป็น "${STATUS_DELIVERED}" ไม่สำเร็จ
    END

    ${FoundIn}=    Create List
    FOR    ${Status}    IN    @{ALL_STATUSES}
        ${Card}=    หาการ์ดการจอง    ${Status}    ${TARGET_CARD}
        IF    $Card    Append To List    ${FoundIn}    ${Status}
    END
    ${Where}=    Evaluate    ", ".join($FoundIn) if $FoundIn else "ไม่พบในแท็บใดเลย"

    ${Card}=    หาการ์ดการจอง    ${STATUS_DELIVERED}    ${TARGET_CARD}
    ${Latest}=    Set Variable    ${EMPTY}
    IF    $Card
        ${Latest}=    อ่านสถานะบนการ์ด    ${Card}
    END
    บันทึกผลที่ได้จริง    พบรายการในแท็บ : ${Where} | ${Latest}

    # DEL07-01 : ต้องพบในแท็บ "จัดส่งเรียบร้อย" แท็บเดียว
    Should Be Equal    ${Where}    ${STATUS_DELIVERED}
    ...    msg=รายการทดสอบควรอยู่ในแท็บ "${STATUS_DELIVERED}" แท็บเดียว แต่พบใน : ${Where}
    # DEL07-02 : การ์ดต้องแสดง "สถานะ : จัดส่งเรียบร้อย" ตรงตัว
    เทียบผลจริงกับที่คาดหวัง    ${Latest}    สถานะ : ${STATUS_DELIVERED}

# =====================================================================
# 4. ขั้นตอนย่อยบนหน้ารายการจองของ Owner
# =====================================================================

อัปเดตสถานะรายการทดสอบ
    #หารายการในแท็บ ${From} กดอัปเดตและยืนยัน ตรวจว่าสำเร็จและย้ายไปแท็บ ${To} พร้อมสถานะตรงกัน
    [Arguments]    ${From}    ${To}
    ${Card}=    หาการ์ดการจอง    ${From}    ${TARGET_CARD}
    Should Not Be Empty    ${Card}
    ...    msg=ไม่พบรายการทดสอบในแท็บ "${From}" จึงยังอัปเดตเป็น "${To}" ไม่ได้

    # DEL03-01 / DEL04-01 : หัวข้อ popup ผลลัพธ์ต้องเป็น "อัปเดตสถานะสำเร็จ!" ตรงตัว
    ${Question}    ${Result}=    กดปุ่มบนการ์ดแล้วยืนยัน    ${Card}    ${BTN_TEXT_UPDATE}    ${BTN_TEXT_CONFIRM}
    บันทึกผลที่ได้จริง    ${Result}
    เทียบผลจริงกับที่คาดหวัง    ${Result}    ${UPDATE_SUCCESS}

    # Basic Flow 8.1 และ 9 : ต้องบันทึกจริง รายการจึงต้องย้ายไปแท็บใหม่
    ${Moved}=    หาการ์ดการจอง    ${To}    ${TARGET_CARD}
    Should Not Be Empty    ${Moved}
    ...    msg=ระบบแจ้งสำเร็จ แต่ไม่พบรายการในแท็บ "${To}" แปลว่าสถานะไม่ได้ถูกบันทึกจริง
    # DEL03-02 / DEL04-02 : การ์ดต้องแสดง "สถานะ : <สถานะใหม่>" ตรงตัว
    ${Status}=    อ่านสถานะบนการ์ด    ${Moved}
    บันทึกผลที่ได้จริง    ${Result} | ${Status}
    เทียบผลจริงกับที่คาดหวัง    ${Status}    สถานะ : ${To}

อ่านปุ่มอัปเดตทุกการ์ดในแท็บ
    #เปิดแท็บตามสถานะ แล้วอ่านข้อความปุ่มอัปเดตของการ์ดทุกใบทุกหน้า คืนเป็นลิสต์ข้อความ
    [Arguments]    ${Status}
    เปิดแท็บสถานะ    ${Status}
    Run Keyword And Ignore Error
    ...    Wait For Elements State    ${Card_OwnerBooking} >> nth=0    visible    ${LIST_TIMEOUT}
    ${All}=    Create List
    FOR    ${Page}    IN RANGE    30
        ${Labels}=    Evaluate JavaScript    ${None}
        ...    () => [...document.querySelectorAll('button')].map(b => b.textContent.replace(/\\s+/g, ' ').trim()).filter(t => t.startsWith('อัปเดตเป็น'))
        FOR    ${Label}    IN    @{Labels}
            Append To List    ${All}    ${Label}
        END
        ${HasNext}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${Btn_NextPage}    enabled    ${SHORT_TIMEOUT}
        IF    not ${HasNext}    BREAK
        Click    ${Btn_NextPage}
        Sleep    1s
    END
    Log    ปุ่มอัปเดตในแท็บ "${Status}" : ${All}    level=INFO
    RETURN    ${All}

สร้างตัวจับการ์ดการจอง
    #สร้าง locator จาก ผู้เช่า+อุปกรณ์+วันเริ่ม+วันสิ้นสุด ชี้การ์ดได้ใบเดียวแม้หน้าจะเรียงลำดับใหม่
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
    #เปิดหน้ารายการจองแล้วกดแท็บตามสถานะ (เข้าสู่ระบบใหม่อัตโนมัติถ้า session หมดอายุ)
    [Arguments]    ${Status}
    Go To                  ${ApproveBooking_ownerURL}
    Wait For Load State    domcontentloaded    ${DEFAULT_TIMEOUT}
    Sleep    1s
    ${Relogin}=    เข้าสู่ระบบใหม่ถ้า session หมดอายุ
    IF    ${Relogin}
        Go To                  ${ApproveBooking_ownerURL}
        Wait For Load State    domcontentloaded    ${DEFAULT_TIMEOUT}
    END
    เลือกแท็บบนหน้าที่เปิดอยู่    ${Status}

เลือกแท็บบนหน้าที่เปิดอยู่
    #กดแท็บตามสถานะบนหน้ารายการจองที่เปิดอยู่แล้ว (เทียบข้อความตรงตัว ไม่ให้ไปโดนปุ่ม อัปเดตเป็น "...")
    [Arguments]    ${Status}
    ${Tab}=    Set Variable    //button[normalize-space()='${Status}']
    Wait For Elements State    ${Tab}    visible    ${DEFAULT_TIMEOUT}
    Click    ${Tab}
    # หน้าโหลดรายการใหม่หลังเปลี่ยนแท็บ
    Sleep    1.5s

หาการ์ดการจอง
    #เปิดแท็บตามสถานะแล้วหาการ์ดตาม locator ที่ส่งมา คืน locator เดิมเมื่อพบ หรือค่าว่างเมื่อไม่พบ
    [Arguments]    ${Status}    ${Card}
    เปิดแท็บสถานะ    ${Status}
    ${Found}=    หาการ์ดบนหน้าที่เปิดอยู่    ${Card}
    RETURN    ${Found}

หาการ์ดบนหน้าที่เปิดอยู่
    #หาการ์ดในแท็บที่เลือกไว้ ไล่ทุกหน้า (แสดงทีละ 3 รายการ) คืน locator เดิมเมื่อพบ หรือค่าว่าง
    [Arguments]    ${Card}
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

อ่านข้อความบนการ์ด
    #อ่านข้อความทั้งหมดบนการ์ด แล้วรวมช่องว่างและขึ้นบรรทัดใหม่ให้เหลือช่องว่างเดียว
    [Arguments]    ${Card}
    ${Text}=    Get Text    ${Card}
    ${Text}=    Evaluate    " ".join($Text.split())
    RETURN    ${Text}

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
    #อ่านข้อความบนปุ่มของการ์ดที่ขึ้นต้นด้วยคำที่ระบุ คืนค่าว่างเมื่อการ์ดไม่มีปุ่มนั้น
    [Arguments]    ${Card}    ${ButtonText}
    ${Button}=    Set Variable    ${Card} >> xpath=.//button[contains(.,'${ButtonText}')]
    ${Found}=    Is Element Visible    ${Button}
    IF    not ${Found}    RETURN    ${EMPTY}
    ${Text}=    Get Text    ${Button}
    ${Text}=    Evaluate    " ".join($Text.split())
    RETURN    ${Text}

กดปุ่มบนการ์ดแล้วยืนยัน
    #กดปุ่มบนการ์ด กดยืนยัน แล้วอ่านผล คืน 2 ค่า: หัวข้อกล่องยืนยัน, หัวข้อ popup ผลลัพธ์ (ทำไม่ได้คืนค่าว่าง)
    [Arguments]    ${Card}    ${ButtonText}    ${ConfirmText}
    ${Button}=    Set Variable    ${Card} >> xpath=.//button[contains(.,'${ButtonText}')]
    ${Clicked}=    Click Button If Enabled    ${Button}
    IF    not ${Clicked}
        Log    ไม่มีปุ่ม "${ButtonText}" ที่กดได้บนการ์ด    level=WARN
        RETURN    ${EMPTY}    ${EMPTY}
    END

    ${Shown}=    Run Keyword And Return Status    Wait For Elements State    ${Popup_Title}    visible    5s
    IF    not ${Shown}
        Log    กดปุ่ม "${ButtonText}" แล้วไม่มีกล่องยืนยันเด้งขึ้นมา    level=WARN
        RETURN    ${EMPTY}    ${EMPTY}
    END
    ${Question}=    Get Popup Title

    ${Confirm}=    Set Variable    //button[contains(@class,'swal2-confirm') and normalize-space()='${ConfirmText}']
    ${Confirmed}=    Click Button If Enabled    ${Confirm}
    IF    not ${Confirmed}
        Log    ไม่พบปุ่ม "${ConfirmText}" ในกล่องยืนยัน    level=WARN
        RETURN    ${Question}    ${EMPTY}
    END

    ${Result}=    รอหัวข้อ popup ใหม่    ${Question}
    ${Detail}=    Get Booking Dialog Text
    Log    กล่องยืนยัน "${Question}" -> ผลลัพธ์ "${Result}" | เนื้อความ "${Detail}"    level=INFO

    # ปิดกล่องผลลัพธ์ หน้าจะโหลดรายการใหม่หลังจากนี้
    Run Keyword And Ignore Error    Click Button If Enabled    ${Btn_PopupConfirm}
    Sleep    1s
    RETURN    ${Question}    ${Result}

รอหัวข้อ popup ใหม่
    #รอจนกล่องโต้ตอบขึ้นหัวข้อใหม่ที่ไม่ใช่ค่าเดิมและไม่ว่าง คืนหัวข้อใหม่
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

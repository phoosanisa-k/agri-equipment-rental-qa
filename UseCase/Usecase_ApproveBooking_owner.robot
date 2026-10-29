*** Settings ***
Documentation     TC04 - Approve Booking Owner (Usecase) | อ้างอิงหัวข้อ 8.4 (Basic Flow 1-7, ตาราง AB01) และ TC-OW-01
...               Pre-Condition: Owner login แล้ว + มีคำขอจองในแท็บ "รอดำเนินการ" อย่างน้อย 1 รายการ (ไม่สร้างเอง)
...               ใช้คำขอ 2 รายการ: รายการหลัก (F02→F05 ค้างที่ "อนุมัติการชำระเงิน" ให้ Update Delivery ใช้ต่อ)
...               รายการที่ 2 (F06-F07 ทดสอบยกเลิก, Skip ถ้ามีรายการเดียว)
...
...               TC04_F01→Basic Flow1 | F02→Basic Flow2-7(อนุมัติ) | F03→AB01-01(ชนเวลา) | F04→AB01-04(อนุมัติซ้ำ)
...               F05→F-OWN-02(อนุมัติชำระเงิน) | F06→AB01-02(ยกเลิก) | F07→AB01-05(ยกเลิกซ้ำ)
...               AB01-03 ไม่ทำเป็นเคส เพราะปุ่มมีเฉพาะรายการที่มีจริง
Metadata          Use Case    TC04 Approve Booking Owner (Functional Flow)

Resource          ../Resources/keywords.robot
Library           OperatingSystem
Library           String
Library           Collections

Suite Setup       เปิดชุดทดสอบ
Suite Teardown    ปิดชุดทดสอบ
Test Teardown     เก็บผลท้ายกรณีทดสอบ    ปิดกล่องโต้ตอบที่ค้างอยู่

*** Variables ***
# ---------- ไฟล์และโฟลเดอร์ ----------
${USECASE}              TC04_Usecase_ApproveBooking_Owner
${SCREENSHOT_DIR}       ${CURDIR}/../Screenshot/${USECASE}

# ---------- สถานะการจองบนหน้ารายการจอง ----------
${STATUS_PENDING}       รอดำเนินการ
${STATUS_WAITPAY}       รอการชำระเงิน
${STATUS_PAID}          อนุมัติการชำระเงิน
# แท็บที่ถือว่าการจองยังมีผลอยู่ ใช้หาการจองที่ช่วงเวลาชนกันใน TC04_F03
@{ACTIVE_STATUSES}      รอดำเนินการ    รอการชำระเงิน    อนุมัติการชำระเงิน    รอการจัดส่ง

# ---------- ข้อความที่คาดหวังตามเอกสารเทสเคส (เทียบตรงกัน 100%) ----------
${EXP_LOGIN_SUCCESS}    เข้าสู่ระบบสำเร็จ             # AB01-01
${UPDATE_SUCCESS}       อัปเดตสถานะสำเร็จ!            # AB02-02 / AB04-01 / AB05-02 / AB06-02
${CANCEL_SUCCESS}       ยกเลิกการจองสำเร็จ            # AB06-03 / AB07-01
${CONFLICT_MESSAGE}     ไม่สามารถดำเนินการได้          # AB03-02
# ข้อความบนปุ่มอัปเดตสถานะ ระบบใช้เครื่องหมายคำพูดตรง " " เช่น อัปเดตเป็น "รอการชำระเงิน"
${EXP_BTN_TO_WAITPAY}   อัปเดตเป็น "${STATUS_WAITPAY}"    # AB01-03
${EXP_BTN_TO_PAID}      อัปเดตเป็น "${STATUS_PAID}"       # AB04-03

# ---------- ข้อความบนปุ่ม ----------
${BTN_TEXT_UPDATE}      อัปเดตเป็น
${BTN_TEXT_CANCEL}      ยกเลิกการจอง
${BTN_TEXT_CONFIRM}     ยืนยัน
${BTN_TEXT_CONFIRM_CANCEL}    ยืนยันยกเลิก

# ---------- ตัวจับบนหน้ารายการจองของ Owner ----------
# การ์ดรายการจองแต่ละใบคือ div กรอบ border-emerald-200 ที่มีหัวข้อ "การจอง #n"
# (กล่องปฏิทินการจัดส่งกับแถบแท็บก็ใช้กรอบเดียวกัน จึงต้องเจาะด้วยหัวข้อด้วย)
${Card_OwnerBooking}    //div[contains(@class,'border-emerald-200')][.//h3[contains(.,'การจอง #')]]
# ปุ่มเปลี่ยนหน้า แสดงเฉพาะเมื่อมีมากกว่า 3 รายการ
${Btn_NextPage}         //button[contains(.,'ถัดไป')]
# ปุ่ม "ยกเลิก" ของกล่องยืนยัน แปลว่าไม่ทำรายการต่อ
${Btn_DialogCancel}     //button[contains(@class,'swal2-cancel')]
${LIST_TIMEOUT}         ${CARD_TIMEOUT}

# อ่านข้อมูลของการ์ดทุกใบบนหน้าที่แสดงอยู่ในครั้งเดียว คืนเป็นลิสต์ของ
# {tenant, status, start, end, address, equipment} ใช้ทั้งตอนเลือกรายการทดสอบและตอนหาการจองที่ชนกัน
${JS_READ_CARDS}        () => [...document.querySelectorAll('div.border-emerald-200')].filter(d => (d.querySelector('h3') || {textContent: ''}).textContent.includes('การจอง #')).map(d => { const t = e => e ? e.textContent.replace(/\\s+/g, ' ').trim() : ''; const ps = [...d.querySelectorAll('p')]; const st = ps.find(p => p.textContent.includes('เริ่มต้น')); const en = ps.find(p => p.textContent.includes('สิ้นสุด')); const ah = [...d.querySelectorAll('h4')].find(h => h.textContent.includes('ที่อยู่จัดส่ง')); const ad = ah ? ah.closest('div').parentElement.querySelector('p') : null; const sp = [...d.querySelectorAll('span')]; const tn = sp.find(s => s.textContent.trim().startsWith('ผู้เช่า:')); const ss = sp.find(s => s.textContent.trim().startsWith('สถานะ :')); return {tenant: t(tn).replace('ผู้เช่า:', '').trim(), status: t(ss).replace('สถานะ :', '').trim(), start: t(st && st.querySelector('span')), end: t(en && en.querySelector('span')), address: t(ad), equipment: [...d.querySelectorAll('h5')].map(t)}; })

# ---------- ตัวแปรระดับชุดทดสอบ ตั้งค่าตอนเปิดชุดทดสอบและระหว่างรัน ----------
&{TARGET}               tenant=${EMPTY}
${TARGET_CARD}          ${EMPTY}
&{CANCEL_TARGET}        tenant=${EMPTY}
${CANCEL_CARD}          ${EMPTY}
${APPROVED}             ${False}
${CANCELLED}            ${False}

# ---------- ตัวแปรระดับกรณีทดสอบ ----------
${TC_ID}                UNKNOWN
${ACTUAL_MESSAGE}       ${EMPTY}

*** Test Cases ***
TC04_F01 - เจ้าของอุปกรณ์เห็นคำขอจองในสถานะรอดำเนินการ
    #TC04-AB01 : การ์ดในแท็บ "รอดำเนินการ" ต้องแสดง "สถานะ : รอดำเนินการ" และมีปุ่ม อัปเดตเป็น "รอการชำระเงิน"
    Set Test Variable    ${TC_ID}    TC04_F01
    กรณี TC04_F01

TC04_F02 - อนุมัติการจองที่อยู่ในสถานะรอดำเนินการ
    #TC04-AB02 : อนุมัติแล้วต้องได้ "อัปเดตสถานะสำเร็จ!" และการ์ดย้ายไปแท็บ "รอการชำระเงิน"
    Set Test Variable    ${TC_ID}    TC04_F02
    กรณี TC04_F02

TC04_F03 - อนุมัติรายการที่ช่วงเวลาชนกับผู้จองรายอื่น
    #AB01-01: หาคำขอที่ช่วงเวลาชนกับผู้เช่ารายอื่น กดอนุมัติต้องได้ "ไม่สามารถดำเนินการได้" (ไม่มีคู่ชนกันจะ Skip)
    Set Test Variable    ${TC_ID}    TC04_F03
    กรณี TC04_F03

TC04_F04 - กดอนุมัติซ้ำรายการที่อนุมัติไปแล้ว
    #TC04-AB04 : รายการที่อนุมัติแล้วต้องหายจากแท็บ "รอดำเนินการ" และปุ่มต้องเป็น อัปเดตเป็น "อนุมัติการชำระเงิน"
    Set Test Variable    ${TC_ID}    TC04_F04
    กรณี TC04_F04

TC04_F05 - อนุมัติการชำระเงิน
    #F-OWN-02: อนุมัติการชำระเงิน ต้องแจ้งสำเร็จและย้ายไปสถานะ "อนุมัติการชำระเงิน" จริง (ค้างไว้ให้ Update Delivery ใช้ต่อ)
    Set Test Variable    ${TC_ID}    TC04_F05
    กรณี TC04_F05

TC04_F06 - ยกเลิกการจอง
    #TC04-AB06 : กดยกเลิกการจองแล้วยืนยัน ต้องได้ "ยกเลิกการจองสำเร็จ"
    Set Test Variable    ${TC_ID}    TC04_F06
    กรณี TC04_F06

TC04_F07 - กดยกเลิกซ้ำรายการที่ยกเลิกไปแล้ว
    #AB01-05 : รายการที่ยกเลิกแล้วต้องไม่เหลือปุ่มให้กดยกเลิกซ้ำได้อีก
    Set Test Variable    ${TC_ID}    TC04_F07
    กรณี TC04_F07

*** Keywords ***
# =====================================================================
# 1. การเตรียมและปิดชุดทดสอบ
# =====================================================================

เปิดชุดทดสอบ
    #ล้างภาพของรอบก่อน เข้าสู่ระบบเป็น Owner ค้างไว้ทั้งชุด แล้วเลือกคำขอจองที่จะใช้ทดสอบ
    เตรียมชุดทดสอบยูสเคส
    ตรวจว่าตั้งค่าครบแล้วหรือยัง

    เข้าสู่ระบบเป็นเจ้าของอุปกรณ์
    เลือกคำขอจองที่จะใช้ทดสอบ

ตรวจว่าตั้งค่าครบแล้วหรือยัง
    #ล้มทั้งชุดทันทีเมื่อยังไม่ได้ตั้งบัญชี Owner เพราะทุกกรณีทดสอบต้องเข้าสู่ระบบก่อน
    ${UserLen}=    Get Length    ${OwnerUser}
    ${PassLen}=    Get Length    ${OwnerPass}
    IF    ${UserLen} == 0 or ${PassLen} == 0
        Fail    ยังไม่ได้ตั้งค่าบัญชี Owner กรุณาเติม \${TEST_OWNER_USER} และ \${TEST_OWNER_PASS} ใน Resources/variables.robot
    END

เลือกคำขอจองที่จะใช้ทดสอบ
    #เลือก 2 รายการแรกในแท็บ "รอดำเนินการ" (หลัก+ยกเลิก) จำผู้เช่า/อุปกรณ์/วันที่ไว้ตามหาทั้งชุด ถ้าไม่มีคำขอจองเลย ยังไม่ครบ Pre-Condition จึงหยุดทั้งชุดพร้อมบอกวิธีแก้
    เปิดแท็บสถานะ    ${STATUS_PENDING}
    Run Keyword And Ignore Error
    ...    Wait For Elements State    ${Card_OwnerBooking} >> nth=0    visible    ${LIST_TIMEOUT}
    ${Cards}=    Evaluate JavaScript    ${None}    ${JS_READ_CARDS}
    ${Count}=    Get Length    ${Cards}
    IF    ${Count} == 0
        Fail    ไม่มีคำขอจองในแท็บ "${STATUS_PENDING}" ของบัญชี ${OwnerUser} จึงยังไม่ครบ Pre-Condition "มีคำขอการจองเข้ามา" กรุณาสร้างคำขอจองก่อน (เช่นรัน UseCase/Usecase_Booking_farmer.robot)
    END

    ${Target}=    Evaluate    dict($Cards[0])
    Set Suite Variable    ${TARGET}    ${Target}
    ${Locator}=    สร้างตัวจับการ์ดการจอง    ${Target}
    Set Suite Variable    ${TARGET_CARD}    ${Locator}
    Log    คำขอจองหลัก (อนุมัติแล้วค้างไว้ให้ Update Delivery) : ${TARGET}    level=INFO

    # รายการที่ 2 ใช้ทดสอบการยกเลิก แยกจากรายการหลักเพื่อให้รายการหลักเดินต่อไปขั้นถัดไปได้
    IF    ${Count} >= 2
        ${Cancel}=    Evaluate    dict($Cards[1])
        Set Suite Variable    ${CANCEL_TARGET}    ${Cancel}
        ${Locator}=    สร้างตัวจับการ์ดการจอง    ${Cancel}
        Set Suite Variable    ${CANCEL_CARD}    ${Locator}
        Log    คำขอจองที่ใช้ทดสอบการยกเลิก : ${CANCEL_TARGET}    level=INFO
    ELSE
        Log    มีคำขอรอดำเนินการแค่ 1 รายการ เคสยกเลิกการจอง (F06-F07) จะถูกข้าม    level=WARN
    END

# =====================================================================
# 2. การเข้าสู่ระบบของ Owner
# =====================================================================

เข้าสู่ระบบเป็นเจ้าของอุปกรณ์
    #เปิด context ใหม่แล้วเข้าสู่ระบบด้วย ${OwnerUser} / ${OwnerPass} ใช้ session นี้ตลอดทั้งชุด
    Open Login Owner Page
    กรอกบัญชี Owner แล้วกดเข้าสู่ระบบ
    Log    เข้าสู่ระบบเป็น Owner "${OwnerUser}" สำเร็จ ใช้ session นี้ตลอดทั้งชุดทดสอบ    level=INFO

กรอกบัญชี Owner แล้วกดเข้าสู่ระบบ
    #กรอกบัญชี login กดเข้าสู่ระบบ กดปุ่ม "ไปหน้าแรก" บน popup (ใช้ทั้งตอนเปิดชุดและตอน session หมดอายุ)
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

# =====================================================================
# 3. กรณีทดสอบตามตาราง AB01
# =====================================================================

กรณี TC04_F01
    #Basic Flow 1 : คำขอจองต้องขึ้นในแท็บ "รอดำเนินการ" พร้อมรายละเอียดการจองครบ และมีปุ่มอนุมัติ
    ${Card}=    หาการ์ดการจอง    ${STATUS_PENDING}    ${TARGET_CARD}
    Should Not Be Empty    ${Card}
    ...    msg=ไม่พบคำขอจองที่เลือกไว้ในแท็บ "${STATUS_PENDING}" (${TARGET})

    ${Text}=    อ่านข้อความบนการ์ด    ${Card}
    บันทึกผลที่ได้จริง    ${Text}

    # ทุกช่องต้องมีข้อมูล ไม่ใช่แค่มีหัวข้อ
    FOR    ${Field}    IN    tenant    start    end    address
        Should Not Be Empty    ${TARGET}[${Field}]
        ...    msg=การ์ดคำขอจองไม่มีข้อมูลช่อง ${Field} (ข้อความบนการ์ด : ${Text})
    END
    Should Not Be Empty    ${TARGET}[equipment]
    ...    msg=การ์ดคำขอจองไม่มีรายการอุปกรณ์ที่ถูกจอง (ข้อความบนการ์ด : ${Text})

    # AB01-02 : การ์ดต้องแสดง "สถานะ : รอดำเนินการ" ตรงตัว
    ${Status}=    อ่านสถานะบนการ์ด    ${Card}
    เทียบผลจริงกับที่คาดหวัง    ${Status}    สถานะ : ${STATUS_PENDING}
    # AB01-03 : ปุ่มบนการ์ดต้องเป็น อัปเดตเป็น "รอการชำระเงิน" ตรงตัว
    ${Button}=    อ่านข้อความปุ่มบนการ์ด    ${Card}    ${BTN_TEXT_UPDATE}
    บันทึกผลที่ได้จริง    ${Status} | ${Button}
    เทียบผลจริงกับที่คาดหวัง    ${Button}    ${EXP_BTN_TO_WAITPAY}

กรณี TC04_F02
    #Basic Flow 2-7 : อนุมัติแล้วระบบต้องแจ้งสำเร็จ และบันทึกสถานะใหม่ลงฐานข้อมูลจริง
    ${Card}=    หาการ์ดการจอง    ${STATUS_PENDING}    ${TARGET_CARD}
    Should Not Be Empty    ${Card}
    ...    msg=ไม่พบคำขอจองที่เลือกไว้ในแท็บ "${STATUS_PENDING}" จึงยังทดสอบการอนุมัติไม่ได้

    # AB02-02 : หัวข้อ popup ผลลัพธ์ต้องเป็น "อัปเดตสถานะสำเร็จ!" ตรงตัว
    ${Question}    ${Result}=    กดปุ่มบนการ์ดแล้วยืนยัน    ${Card}    ${BTN_TEXT_UPDATE}    ${BTN_TEXT_CONFIRM}
    บันทึกผลที่ได้จริง    ${Result}
    เทียบผลจริงกับที่คาดหวัง    ${Result}    ${UPDATE_SUCCESS}

    # Basic Flow 5.1 และ 6 : ต้องบันทึกจริง รายการจึงต้องย้ายไปแท็บ "รอการชำระเงิน"
    ${Moved}=    หาการ์ดการจอง    ${STATUS_WAITPAY}    ${TARGET_CARD}
    Should Not Be Empty    ${Moved}
    ...    msg=ระบบแจ้งสำเร็จ แต่ไม่พบรายการในแท็บ "${STATUS_WAITPAY}" แปลว่าสถานะไม่ได้ถูกบันทึกจริง
    # AB02-03 : การ์ดต้องแสดง "สถานะ : รอการชำระเงิน" ตรงตัว
    ${Status}=    อ่านสถานะบนการ์ด    ${Moved}
    บันทึกผลที่ได้จริง    ${Result} | ${Status}
    เทียบผลจริงกับที่คาดหวัง    ${Status}    สถานะ : ${STATUS_WAITPAY}

    Set Suite Variable    ${APPROVED}    ${True}

กรณี TC04_F03
    #AB01-01: หาคำขอที่ชนเวลากับผู้เช่ารายอื่น กดอนุมัติต้องถูกปฏิเสธและแจ้ง "ไม่สามารถดำเนินการได้"
    ${Pair}=    หาคำขอจองที่ช่วงเวลาชนกัน
    IF    $Pair is None
        บันทึกผลที่ได้จริง    ไม่พบคำขอจองที่ช่วงเวลาชนกับผู้เช่ารายอื่นในระบบ
        Skip    ในระบบไม่มีคำขอจองที่ช่วงเวลาชนกับผู้เช่ารายอื่นบนอุปกรณ์เดียวกัน (ปฏิทินฝั่งเกษตรกรกันไว้ตั้งแต่ขั้นจอง) จึงสร้างสถานการณ์ของ AB01-01 ไม่ได้
    END

    ${Pending}=    Set Variable    ${Pair}[0]
    ${Other}=      Set Variable    ${Pair}[1]
    ${Locator}=    สร้างตัวจับการ์ดการจอง    ${Pending}
    ${Card}=    หาการ์ดการจอง    ${STATUS_PENDING}    ${Locator}
    Should Not Be Empty    ${Card}    msg=พบคำขอจองที่ชนกัน แต่หาการ์ดนั้นในแท็บ "${STATUS_PENDING}" ไม่เจอ (${Pending})

    ${Question}    ${Result}=    กดปุ่มบนการ์ดแล้วยืนยัน    ${Card}    ${BTN_TEXT_UPDATE}    ${BTN_TEXT_CONFIRM}
    บันทึกผลที่ได้จริง
    ...    ${Pending}[tenant] (${Pending}[start] - ${Pending}[end]) ชนกับ ${Other}[tenant] (${Other}[start] - ${Other}[end]) | อนุมัติแล้วได้ : ${Result}

    # AB03-02 : ข้อความต้องเป็น "ไม่สามารถดำเนินการได้" ตรงตัว
    เทียบผลจริงกับที่คาดหวัง    ${Result}    ${CONFLICT_MESSAGE}

กรณี TC04_F04
    #AB01-04: รายการที่อนุมัติแล้วต้องหายจาก "รอดำเนินการ" ปุ่มในแท็บถัดไปต้องเป็นขั้นถัดไป ไม่ใช่ปุ่มเดิม
    ต้องผ่าน TC04_F02 ก่อน

    ${Pending}=    หาการ์ดการจอง    ${STATUS_PENDING}    ${TARGET_CARD}
    ${Waiting}=    หาการ์ดการจอง    ${STATUS_WAITPAY}    ${TARGET_CARD}
    ${NextButton}=    Set Variable    ${EMPTY}
    IF    $Waiting
        ${NextButton}=    อ่านข้อความปุ่มบนการ์ด    ${Waiting}    ${BTN_TEXT_UPDATE}
    END
    ${InPending}=    Set Variable If    not $Pending    ไม่พบรายการแล้ว    ยังพบรายการอยู่
    บันทึกผลที่ได้จริง    แท็บ${STATUS_PENDING} : ${InPending} | แท็บ${STATUS_WAITPAY} : ปุ่ม ${NextButton}

    Should Be Empty    ${Pending}
    ...    msg=รายการที่อนุมัติแล้วยังอยู่ในแท็บ "${STATUS_PENDING}" จึงกดอนุมัติซ้ำได้
    Should Not Be Empty    ${Waiting}
    ...    msg=ไม่พบรายการที่อนุมัติแล้วในแท็บ "${STATUS_WAITPAY}"
    # AB04-03 : ปุ่มต้องเปลี่ยนเป็นขั้นถัดไป คือ อัปเดตเป็น "อนุมัติการชำระเงิน" ตรงตัว
    เทียบผลจริงกับที่คาดหวัง    ${NextButton}    ${EXP_BTN_TO_PAID}

กรณี TC04_F05
    #F-OWN-02: กดอัปเดตรายการหลักเป็น "อนุมัติการชำระเงิน" ต้องแจ้งสำเร็จและย้ายแท็บจริง
    ต้องผ่าน TC04_F02 ก่อน

    ${Card}=    หาการ์ดการจอง    ${STATUS_WAITPAY}    ${TARGET_CARD}
    Should Not Be Empty    ${Card}
    ...    msg=ไม่พบรายการที่อนุมัติไว้ในแท็บ "${STATUS_WAITPAY}" จึงยังทดสอบการอนุมัติการชำระเงินไม่ได้

    # AB05-02 : หัวข้อ popup ผลลัพธ์ต้องเป็น "อัปเดตสถานะสำเร็จ!" ตรงตัว
    ${Question}    ${Result}=    กดปุ่มบนการ์ดแล้วยืนยัน    ${Card}    ${BTN_TEXT_UPDATE}    ${BTN_TEXT_CONFIRM}
    บันทึกผลที่ได้จริง    ${Result}
    เทียบผลจริงกับที่คาดหวัง    ${Result}    ${UPDATE_SUCCESS}

    ${Moved}=    หาการ์ดการจอง    ${STATUS_PAID}    ${TARGET_CARD}
    Should Not Be Empty    ${Moved}
    ...    msg=ระบบแจ้งสำเร็จ แต่ไม่พบรายการในแท็บ "${STATUS_PAID}" แปลว่าสถานะไม่ได้ถูกบันทึกจริง
    # AB05-03 : การ์ดต้องแสดง "สถานะ : อนุมัติการชำระเงิน" ตรงตัว (ค้างไว้ให้ Update Delivery)
    ${Status}=    อ่านสถานะบนการ์ด    ${Moved}
    บันทึกผลที่ได้จริง    ${Result} | ${Status}
    เทียบผลจริงกับที่คาดหวัง    ${Status}    สถานะ : ${STATUS_PAID}

กรณี TC04_F06
    #AB01-02: ใช้รายการที่ 2 อนุมัติก่อน (ปุ่มยกเลิกโชว์เฉพาะสถานะ "รอการชำระเงิน") แล้วยกเลิก ต้องแจ้งสำเร็จ
    IF    not $CANCEL_CARD
        Skip    ไม่ได้ทดสอบ เพราะมีคำขอรอดำเนินการแค่ 1 รายการ (ใช้เป็นรายการหลักไปแล้ว) ต้องมีอย่างน้อย 2 รายการ
    END

    # ---------- ขั้นเตรียม : อนุมัติรายการที่ 2 ให้ขึ้นปุ่มยกเลิกการจอง ----------
    ${Pending}=    หาการ์ดการจอง    ${STATUS_PENDING}    ${CANCEL_CARD}
    Should Not Be Empty    ${Pending}
    ...    msg=ไม่พบคำขอจองรายการที่ 2 ในแท็บ "${STATUS_PENDING}" (${CANCEL_TARGET})
    ${Question}    ${Approved}=    กดปุ่มบนการ์ดแล้วยืนยัน    ${Pending}    ${BTN_TEXT_UPDATE}    ${BTN_TEXT_CONFIRM}
    # AB06-02 : อนุมัติรายการที่ 2 ต้องได้ "อัปเดตสถานะสำเร็จ!" ตรงตัว
    เทียบผลจริงกับที่คาดหวัง    ${Approved}    ${UPDATE_SUCCESS}

    # ---------- ยกเลิกการจอง ----------
    ${Card}=    หาการ์ดการจอง    ${STATUS_WAITPAY}    ${CANCEL_CARD}
    Should Not Be Empty    ${Card}
    ...    msg=ไม่พบรายการที่ 2 ในแท็บ "${STATUS_WAITPAY}" จึงยังทดสอบการยกเลิกไม่ได้

    ${Question}    ${Result}=    กดปุ่มบนการ์ดแล้วยืนยัน    ${Card}    ${BTN_TEXT_CANCEL}    ${BTN_TEXT_CONFIRM_CANCEL}
    บันทึกผลที่ได้จริง    ${Result}

    # AB06-03 : ข้อความต้องเป็น "ยกเลิกการจองสำเร็จ" ตรงตัว
    เทียบผลจริงกับที่คาดหวัง    ${Result}    ${CANCEL_SUCCESS}

    Set Suite Variable    ${CANCELLED}    ${True}

กรณี TC04_F07
    #AB01-05: รายการที่ยกเลิกแล้วต้องไม่เหลือในแท็บที่มีปุ่มยกเลิก (ตรวจ "รอการชำระเงิน" และ "รอดำเนินการ")
    IF    not ${CANCELLED}
        Skip    ไม่ได้ทดสอบ เพราะขึ้นกับ TC04_F06 ที่ยังยกเลิกการจองไม่สำเร็จ
    END

    ${Waiting}=    หาการ์ดการจอง    ${STATUS_WAITPAY}    ${CANCEL_CARD}
    ${Pending}=    หาการ์ดการจอง    ${STATUS_PENDING}    ${CANCEL_CARD}
    ${InWaiting}=    Set Variable If    not $Waiting    ไม่พบรายการแล้ว    ยังพบรายการอยู่
    ${InPending}=    Set Variable If    not $Pending    ไม่พบรายการแล้ว    ยังพบรายการอยู่
    บันทึกผลที่ได้จริง    แท็บ${STATUS_WAITPAY} : ${InWaiting} | แท็บ${STATUS_PENDING} : ${InPending}

    Should Be Empty    ${Waiting}
    ...    msg=รายการที่ยกเลิกแล้วยังอยู่ในแท็บ "${STATUS_WAITPAY}" และยังมีปุ่มยกเลิกให้กดซ้ำได้
    Should Be Empty    ${Pending}
    ...    msg=รายการที่ยกเลิกแล้วกลับไปอยู่ในแท็บ "${STATUS_PENDING}"

ต้องผ่าน TC04_F02 ก่อน
    #กรณีที่ต่อจากการอนุมัติ ถ้า TC04_F02 ไม่ผ่านจะ Skip แทนการล้ม เพราะไม่ได้ทดสอบจริง
    IF    not ${APPROVED}
        Skip    ไม่ได้ทดสอบ เพราะขึ้นกับ TC04_F02 ที่ยังอนุมัติการจองไม่สำเร็จ
    END

# =====================================================================
# 4. หาการจองที่ช่วงเวลาชนกัน (TC04_F03)
# =====================================================================

หาคำขอจองที่ช่วงเวลาชนกัน
    #หาคู่การจองที่ชนเวลากัน (ตัวแรกรอดำเนินการ, อุปกรณ์เดียวกัน, คนละผู้เช่า) คืน [A, B] หรือ None
    ${All}=    Create List
    FOR    ${Status}    IN    @{ACTIVE_STATUSES}
        ${Items}=    อ่านการจองทุกหน้าในแท็บ    ${Status}
        FOR    ${Item}    IN    @{Items}
            ${Start}=    แปลงวันที่ไทยเป็นเลขวัน    ${Item}[start]
            ${End}=      แปลงวันที่ไทยเป็นเลขวัน    ${Item}[end]
            Set To Dictionary    ${Item}    tab=${Status}    from=${Start}    to=${End}
            Append To List    ${All}    ${Item}
        END
    END
    ${Count}=    Get Length    ${All}
    Log    อ่านการจองที่ยังมีผลอยู่ได้ ${Count} รายการ : ${All}    level=INFO

    FOR    ${A}    IN    @{All}
        IF    $A["tab"] != $STATUS_PENDING or $A["from"] is None    CONTINUE
        FOR    ${B}    IN    @{All}
            ${Clash}=    Evaluate
            ...    $B is not $A and $B["from"] is not None and $B["tenant"] != $A["tenant"] and bool(set($A["equipment"]) & set($B["equipment"])) and $A["from"] <= $B["to"] and $B["from"] <= $A["to"]
            IF    ${Clash}
                Log    พบคำขอจองที่ชนกัน : ${A} กับ ${B}    level=INFO
                ${Pair}=    Create List    ${A}    ${B}
                RETURN    ${Pair}
            END
        END
    END
    RETURN    ${None}

อ่านการจองทุกหน้าในแท็บ
    #เปิดแท็บตามสถานะ แล้วอ่านข้อมูลการ์ดทุกใบทุกหน้า คืนเป็นลิสต์ของ Dictionary
    [Arguments]    ${Status}
    เปิดแท็บสถานะ    ${Status}
    Run Keyword And Ignore Error
    ...    Wait For Elements State    ${Card_OwnerBooking} >> nth=0    visible    ${LIST_TIMEOUT}
    ${All}=    Create List
    FOR    ${Page}    IN RANGE    30
        ${Cards}=    Evaluate JavaScript    ${None}    ${JS_READ_CARDS}
        FOR    ${Card}    IN    @{Cards}
            ${Item}=    Evaluate    dict($Card)
            Append To List    ${All}    ${Item}
        END
        ${HasNext}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${Btn_NextPage}    enabled    ${SHORT_TIMEOUT}
        IF    not ${HasNext}    BREAK
        Click    ${Btn_NextPage}
        Sleep    1s
    END
    RETURN    ${All}

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

# =====================================================================
# 5. ขั้นตอนย่อยบนหน้ารายการจองของ Owner
# =====================================================================

สร้างตัวจับการ์ดการจอง
    #สร้าง locator การ์ดจาก ผู้เช่า+อุปกรณ์+วันเริ่ม+วันสิ้นสุด (ชี้การ์ดได้ใบเดียวแม้หน้าเรียงลำดับใหม่)
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
    #เปิดหน้ารายการจองแล้วกดแท็บตามสถานะ (login ใหม่อัตโนมัติถ้า session หมดอายุ)
    [Arguments]    ${Status}
    Go To                  ${ApproveBooking_ownerURL}
    Wait For Load State    domcontentloaded    ${DEFAULT_TIMEOUT}
    Sleep    1s
    ${Url}=    Get Url
    IF    "login-owner" in $Url
        Log    session ของ Owner หมดอายุ จึงเข้าสู่ระบบใหม่    level=WARN
        กรอกบัญชี Owner แล้วกดเข้าสู่ระบบ
        Go To                  ${ApproveBooking_ownerURL}
        Wait For Load State    domcontentloaded    ${DEFAULT_TIMEOUT}
    END

    # เทียบข้อความแท็บแบบตรงตัว ไม่ให้ไปโดนปุ่ม อัปเดตเป็น "..." ที่มีชื่อสถานะอยู่ด้วย
    ${Tab}=    Set Variable    //button[normalize-space()='${Status}']
    Wait For Elements State    ${Tab}    visible    ${DEFAULT_TIMEOUT}
    Click    ${Tab}
    # หน้าโหลดรายการใหม่หลังเปลี่ยนแท็บ
    Sleep    1.5s

หาการ์ดการจอง
    #เปิดแท็บตามสถานะแล้วหาการ์ดตาม locator ไล่ทุกหน้า คืน locator เมื่อพบ หรือว่างเมื่อไม่พบในแท็บนั้น
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
    Log    ไม่พบการ์ดการจองที่ต้องการในแท็บ "${Status}"    level=INFO
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
    #กดปุ่มบนการ์ด ยืนยันในกล่องโต้ตอบ แล้วอ่านผล คืน (หัวข้อกล่องยืนยัน, หัวข้อ popup ผลลัพธ์) กดปุ่มไม่ได้ / ไม่มีกล่องยืนยัน / ไม่มี popup ผลลัพธ์ คืนค่าว่าง (เหตุผลเขียนลง log)
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
    #รอจนกล่องโต้ตอบขึ้นหัวข้อใหม่ (ไม่ว่าง ไม่ใช่ค่าเดิม) คืนหัวข้อใหม่ หมดเวลาคืนค่าว่าง
    [Arguments]    ${Previous}
    FOR    ${Round}    IN RANGE    40
        ${Now}=    Get Popup Title
        IF    $Now and $Now != $Previous    RETURN    ${Now}
        Sleep    0.3s
    END
    Log    ไม่พบข้อความตอบกลับจากระบบ (กล่องโต้ตอบยังค้างที่ "${Previous}")    level=WARN
    RETURN    ${EMPTY}

ปิดกล่องโต้ตอบที่ค้างอยู่
    #กล่องยืนยันกด "ยกเลิก" กล่องผลลัพธ์กด "ตกลง" (เช็คปุ่มยกเลิกก่อน กันเผลอยืนยันรายการค้าง)
    ${HasCancel}=    Is Element Visible    ${Btn_DialogCancel}
    IF    ${HasCancel}
        Click    ${Btn_DialogCancel}
    ELSE
        ${HasConfirm}=    Is Element Visible    ${Btn_PopupConfirm}
        IF    ${HasConfirm}    Click    ${Btn_PopupConfirm}
    END
    Sleep    0.3s

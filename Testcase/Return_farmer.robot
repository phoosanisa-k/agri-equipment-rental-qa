*** Settings ***
Documentation     TC05 - Return Equipment Farmer | ยูสเคส "ส่งคืนอุปกรณ์" ของเกษตรกร (เอกสาร Test Case หน้า 79-82)
...
...               ยูสเคสนี้ไม่มีชุดข้อมูลใน Data.xlsx เพราะเป็นการกดปุ่มบนรายการที่มีอยู่แล้วในระบบ
...               ไม่มีฟอร์มให้กรอก กรณีทดสอบจึงเขียนไว้ตรง ๆ ในไฟล์นี้ แต่ยังเขียนผลกลับลงชีต
...               ReturnEQ_Farmer เพื่อให้รูปแบบรายงานเหมือนยูสเคสอื่น
...
...               TC05_F01 : Basic Flow ของเอกสาร - กดส่งคืน ยืนยัน แล้วระบบต้องแจ้งว่าส่งคืนเรียบร้อย
...               TC05_F02 : กดส่งคืนแล้วไม่ยืนยัน ระบบต้องไม่บันทึกการคืน
...               TC05_F03 : RT01-03 - รายการที่คืนไปแล้วต้องส่งคืนซ้ำไม่ได้
...               TC05_F04 : RT01-01, RT01-02 - รายการที่สถานะไม่ถูกต้องต้องไม่มีปุ่มส่งคืนให้กด
...               TC05_F05 : ยังไม่เข้าสู่ระบบแล้วเปิดหน้าส่งคืนตรง ๆ ระบบต้องไม่ให้ทำรายการ
Metadata          System      ระบบเว็บศูนย์กลางให้บริการเช่าอุปกรณ์ทางการเกษตร (SRS v7.0)
Metadata          Use Case    TC05 Return Equipment Farmer
Metadata          Test Data   ไม่มีชุดข้อมูลนำเข้า (เขียนผลกลับ TestData/Data.xlsx sheet: ReturnEQ_Farmer)

Resource          ../Resources/keywords.robot
Library           ExcelLibrary
Library           OperatingSystem
Library           String
Library           Collections

Suite Setup       เปิดชุดทดสอบ
Suite Teardown    ปิดชุดทดสอบ
Test Setup        เริ่มกรณีทดสอบ
Test Teardown     เก็บผลท้ายกรณีทดสอบ


*** Variables ***
# ---------- ที่อยู่ของไฟล์และโฟลเดอร์ ----------
${DATA_FILE}          ${CURDIR}/../TestData/Data.xlsx
${SHEET}              ReturnEQ_Farmer
${SCREENSHOT_DIR}     ${CURDIR}/../Screenshot
${USECASE}            TC05_Return_Farmer

# ---------- ตำแหน่งคอลัมน์ในชีต ----------
# ชีตนี้เป็นชีตรับผลอย่างเดียว จึงมีแค่ รหัส / สถานการณ์ / ผลที่คาดหวัง / ผลที่ได้จริง / Pass-Fail / หมายเหตุ
${COL_ID}             ${1}    # คอลัมน์ A : รหัสกรณีทดสอบ
${COL_ACTUAL}         ${4}    # คอลัมน์ D : ActualResult
${COL_PF}             ${5}    # คอลัมน์ E : Result

# ---------- ข้อความและตัวชี้วัดที่ใช้ตัดสินผล ----------
# ข้อความบน popup เมื่อส่งคืนสำเร็จ ใช้ยืนยันผลของ Basic Flow
${RETURN_SUCCESS}     ส่งคืนอุปกรณ์เรียบร้อยแล้ว
# บัญชีที่ใช้ทุกกรณี ต้องเข้าสู่ระบบก่อนจึงจะเห็นรายการของตนเอง (Inter-Case Dependency กับ TC01)
${RETURN_USERNAME}    PKFarmer01
${RETURN_PASSWORD}    PK01010101

# ---------- ตัวแปรระดับกรณีทดสอบ ใช้ส่งข้อมูลให้ teardown ----------
${TC_ID}              UNKNOWN
${ROW_NUM}            ${0}
${ACTUAL_MESSAGE}     ${EMPTY}


*** Test Cases ***
TC05_F01 : ส่งคืนอุปกรณ์สำเร็จตาม Basic Flow
    [Documentation]    Basic Flow ของเอกสาร ข้อ 2-6 : กดปุ่มส่งคืน ยืนยัน แล้วระบบต้องบันทึกและแจ้งผล
    ...                กรณีนี้เปลี่ยนสถานะรายการจองจริงในระบบ 1 รายการทุกครั้งที่รัน
    เข้าสู่ระบบเกษตรกร
    Open Return Equipment Page

    ${Before}=    Get Returnable Item Count
    เก็บภาพหลักฐาน    ${TC_ID}_รายการที่ต้องส่งคืน
    ต้องมีรายการพร้อมส่งคืน    ${Before}

    ${Clicked}=    Click Return Equipment
    Should Be True    ${Clicked}    msg=กดปุ่ม "ส่งคืนอุปกรณ์" ไม่ได้ ทั้งที่มีรายการพร้อมส่งคืน ${Before} รายการ

    ${Shown}=    Is Return Confirm Popup Shown
    เก็บภาพหลักฐาน    ${TC_ID}_ยืนยันการส่งคืน
    Should Be True    ${Shown}    msg=กดส่งคืนแล้วแต่ popup ยืนยันไม่เด้งขึ้นมา

    ${Message}=    Confirm Return Equipment
    เก็บภาพหลักฐาน    ${TC_ID}_ผลการส่งคืน
    บันทึกผลที่ได้จริง    ${Message}

    Should Contain    ${Message}    ${RETURN_SUCCESS}
    ...    msg=ยืนยันการส่งคืนแล้ว แต่ระบบตอบว่า "${Message}" ไม่ใช่ "${RETURN_SUCCESS}"

TC05_F02 : กดส่งคืนแล้วไม่ยืนยัน ระบบต้องไม่บันทึกการคืน
    [Documentation]    Basic Flow ข้อ 5 ของเอกสาร : ระบบบันทึกการส่งคืนเมื่อผู้ใช้ยืนยันเท่านั้น
    ...                ปิด popup ทิ้งแล้วเปิดหน้าใหม่ จำนวนรายการที่พร้อมส่งคืนต้องเท่าเดิม
    เข้าสู่ระบบเกษตรกร
    Open Return Equipment Page

    ${Before}=    Get Returnable Item Count
    ต้องมีรายการพร้อมส่งคืน    ${Before}

    ${Clicked}=    Click Return Equipment
    Should Be True    ${Clicked}    msg=กดปุ่ม "ส่งคืนอุปกรณ์" ไม่ได้ จึงยังทดสอบการยกเลิกไม่ได้

    ${Shown}=    Is Return Confirm Popup Shown
    เก็บภาพหลักฐาน    ${TC_ID}_ก่อนยกเลิก
    Should Be True    ${Shown}    msg=กดส่งคืนแล้วแต่ popup ยืนยันไม่เด้ง จึงยังไม่มีอะไรให้ยกเลิก

    Dismiss Popup
    Open Return Equipment Page
    ${After}=    Get Returnable Item Count
    เก็บภาพหลักฐาน    ${TC_ID}_หลังยกเลิก

    บันทึกผลที่ได้จริง    ยกเลิกก่อนยืนยัน รายการที่พร้อมส่งคืนคงเหลือ ${After} จาก ${Before} รายการ
    Should Be Equal As Integers    ${After}    ${Before}
    ...    msg=ยังไม่ได้กดยืนยัน แต่ระบบบันทึกการส่งคืนไปแล้ว (เหลือ ${After} จาก ${Before} รายการ)

TC05_F03 : RT01-03 ส่งคืนรายการที่คืนไปแล้วซ้ำไม่ได้
    [Documentation]    RT01-03 ของเอกสาร : เมื่อคืนอุปกรณ์สำเร็จแล้ว รายการนั้นต้องไม่มีปุ่มส่งคืนให้กดอีก
    ...                คืนให้สำเร็จ 1 รายการก่อน แล้วเปิดหน้าใหม่ตรวจว่าจำนวนรายการที่คืนได้ลดลงจริง
    เข้าสู่ระบบเกษตรกร
    Open Return Equipment Page

    ${Before}=    Get Returnable Item Count
    ต้องมีรายการพร้อมส่งคืน    ${Before}

    # ---------- รอบที่ 1 : คืนให้สำเร็จเพื่อสร้างรายการที่อยู่ในสถานะ "คืนแล้ว" ----------
    ${Clicked}=    Click Return Equipment
    Should Be True    ${Clicked}    msg=กดปุ่ม "ส่งคืนอุปกรณ์" ไม่ได้ จึงยังทดสอบการคืนซ้ำไม่ได้

    ${Message}=    Confirm Return Equipment
    เก็บภาพหลักฐาน    ${TC_ID}_คืนรอบแรก
    Should Contain    ${Message}    ${RETURN_SUCCESS}
    ...    msg=คืนรอบแรกไม่สำเร็จ (${Message}) จึงยังทดสอบการคืนซ้ำไม่ได้

    # ---------- รอบที่ 2 : รายการเดิมต้องหายไปจากรายการที่คืนได้ ----------
    Open Return Equipment Page
    ${After}=    Get Returnable Item Count
    เก็บภาพหลักฐาน    ${TC_ID}_หลังคืนสำเร็จ

    ${Expected}=    Evaluate    ${Before} - 1
    บันทึกผลที่ได้จริง    คืนสำเร็จ 1 รายการ รายการที่ยังส่งคืนได้เหลือ ${After} จาก ${Before} รายการ
    Should Be Equal As Integers    ${After}    ${Expected}
    ...    msg=คืนสำเร็จแล้วแต่จำนวนรายการที่ส่งคืนได้เป็น ${After} ไม่ใช่ ${Expected} ระบบอาจยังให้คืนซ้ำได้

TC05_F04 : RT01-01 รายการที่สถานะไม่ถูกต้องต้องไม่มีปุ่มส่งคืน
    [Documentation]    RT01-01 และ RT01-02 ของเอกสาร : ระบบต้องให้ส่งคืนได้เฉพาะรายการที่อยู่ในสถานะ
    ...                "กำลังใช้งาน" หรือ "อยู่ระหว่างการเช่า" เท่านั้น
    ...
    ...                หน้าเว็บกันด้วยการไม่แสดงปุ่มส่งคืน ไม่ใช่การแจ้งเตือนหลังกด จึงตรวจจากการไม่มีปุ่ม
    ...                ถ้ายังมีรายการที่พร้อมส่งคืนอยู่ จะข้ามกรณีนี้ เพราะยังไม่เกิดสถานะที่ต้องการทดสอบ
    เข้าสู่ระบบเกษตรกร
    Open Return Equipment Page

    ${Count}=    Get Returnable Item Count
    เก็บภาพหลักฐาน    ${TC_ID}_สถานะรายการจอง
    IF    ${Count} > 0
        บันทึกผลที่ได้จริง    ยังมีรายการที่อยู่ในสถานะพร้อมส่งคืนอยู่ ${Count} รายการ
        Skip    มีรายการที่พร้อมส่งคืนอยู่ ${Count} รายการ จึงยังไม่เกิดสถานะ "ส่งคืนไม่ได้" บนหน้าจอ
    END

    ${Popup}=      Get Popup Title
    ${Visible}=    Is Element Visible    ${Btn_ReturnEQ}
    ${Detail}=     Set Variable If    '${Popup}' != '${EMPTY}'    ${Popup}
    ...    ไม่มีปุ่ม "ส่งคืนอุปกรณ์" ให้กด เพราะไม่มีรายการที่อยู่ในสถานะพร้อมส่งคืน
    บันทึกผลที่ได้จริง    ${Detail}

    Should Not Be True    ${Visible}
    ...    msg=ไม่มีรายการที่อยู่ในสถานะพร้อมส่งคืน แต่หน้าจอยังแสดงปุ่ม "ส่งคืนอุปกรณ์" ให้กดได้

TC05_F05 : เปิดหน้าส่งคืนโดยยังไม่เข้าสู่ระบบ ระบบต้องไม่ให้ทำรายการ
    [Documentation]    Pre-Condition ของเอกสาร : ผู้ใช้ต้องเข้าสู่ระบบและมีรายการเช่าก่อนจึงจะส่งคืนได้
    ...                เปิด context ใหม่ที่ยังไม่ได้เข้าสู่ระบบ แล้วเข้า URL ของหน้าส่งคืนตรง ๆ
    New Context
    New Page             ${Return_farmerURL}
    Set Viewport Size    ${VIEWPORT_WIDTH}    ${VIEWPORT_HEIGHT}
    Sleep    2s

    ${Url}=      Get Url
    ${Count}=    Get Returnable Item Count
    ${Popup}=    Get Popup Title
    เก็บภาพหลักฐาน    ${TC_ID}_ยังไม่เข้าสู่ระบบ

    บันทึกผลที่ได้จริง    หน้าที่ระบบพาไป ${Url} | ปุ่มส่งคืนที่กดได้ ${Count} ปุ่ม | ข้อความแจ้งเตือน "${Popup}"
    Should Be Equal As Integers    ${Count}    ${0}
    ...    msg=ยังไม่ได้เข้าสู่ระบบ แต่หน้าส่งคืนแสดงปุ่ม "ส่งคืนอุปกรณ์" ให้กดได้ ${Count} ปุ่ม


*** Keywords ***
# =====================================================================
# 1. การเตรียมและปิดงาน
# =====================================================================

เปิดชุดทดสอบ
    [Documentation]    ล้างภาพของรอบก่อน เปิดไฟล์ Excel สำหรับเขียนผล และเปิดเบราว์เซอร์
    Create Directory    ${SCREENSHOT_DIR}
    ลบภาพของรอบก่อน    ${SCREENSHOT_DIR}

    # Ignore Error เพราะถ้ายังไม่มีชีตรับผล ก็ยังรันทดสอบต่อได้ เพียงแต่ไม่ได้เขียนผลกลับ
    Run Keyword And Ignore Error    Open Excel Document    ${DATA_FILE}    Return
    Open Test Browser

ลบภาพของรอบก่อน
    [Documentation]    ลบเฉพาะภาพของยูสเคสนี้ ไม่แตะภาพของยูสเคสอื่นที่อยู่โฟลเดอร์เดียวกัน
    ...                และไม่ลบตัวโฟลเดอร์ เพราะ OneDrive มักคืน Access denied
    [Arguments]    ${Folder}
    ${Files}=    List Files In Directory    ${Folder}    ${USECASE}_*.png
    FOR    ${File}    IN    @{Files}
        ${Removed}=    Run Keyword And Return Status    Remove File    ${Folder}/${File}
        IF    not ${Removed}
            Log    ลบไฟล์ ${File} ไม่สำเร็จ ภาพอาจปนกับรอบก่อน    level=WARN
        END
    END

ปิดชุดทดสอบ
    [Documentation]    บันทึกไฟล์ Excel และปิดทรัพยากรทั้งหมด
    Run Keyword And Ignore Error    Save Excel Document    ${DATA_FILE}
    Run Keyword And Ignore Error    Close All Excel Documents
    Close All Test Browsers

เริ่มกรณีทดสอบ
    [Documentation]    เตรียมตัวแปรของกรณีทดสอบ และหาแถวใน Excel จากรหัสที่อยู่หน้าชื่อเทสต์
    ${Id}=    รหัสกรณีทดสอบจากชื่อเทสต์
    Set Test Variable    ${TC_ID}             ${Id}
    Set Test Variable    ${ACTUAL_MESSAGE}    ${EMPTY}

    ${Ok}    ${Row}=    Run Keyword And Ignore Error    หาแถวของกรณีทดสอบ    ${Id}
    ${Row}=    Set Variable If    '${Ok}' == 'PASS'    ${Row}    ${0}
    Set Test Variable    ${ROW_NUM}    ${Row}

เก็บผลท้ายกรณีทดสอบ
    [Documentation]    เก็บภาพเมื่อไม่ผ่าน เขียนผลกลับลง Excel แล้วปิด context
    ...                กรณีที่ถูกข้ามจะเขียนสถานะ Skip ไว้ ไม่เขียนว่า Fail เพราะไม่ใช่ข้อผิดพลาดของระบบ
    ${Actual}=    Set Variable    ${ACTUAL_MESSAGE}

    IF    '${TEST STATUS}' == 'FAIL'
        Run Keyword And Ignore Error
        ...    Take Screenshot    ${SCREENSHOT_DIR}/${USECASE}_${TC_ID}_FAILED    fullPage=True

        # กรณีที่ล้มก่อนได้ข้อความจากระบบ ให้บันทึกสาเหตุที่ล้มแทน
        ${Length}=    Get Length    ${ACTUAL_MESSAGE}
        IF    ${Length} == 0
            ${Actual}=    Get Line         ${TEST MESSAGE}    0
            ${Actual}=    Get Substring    ${Actual}          0    250
        END
    END

    IF    ${ROW_NUM} > 0
        ${ResultPF}=    สรุปสถานะ Pass Fail
        Run Keyword And Ignore Error    บันทึกผลลง Excel    ${ROW_NUM}    ${Actual}    ${ResultPF}
    END

    # Ignore Error เพราะกรณีที่ล้มตั้งแต่เข้าสู่ระบบอาจยังไม่มี context ถูกเปิด
    Run Keyword And Ignore Error    Close Test Context


# =====================================================================
# 2. การอ่านและเขียนไฟล์ Excel
# =====================================================================

รหัสกรณีทดสอบจากชื่อเทสต์
    [Documentation]    ตัดรหัสหน้าชื่อเทสต์ออกมา เช่น "TC05_F01 : ส่งคืนอุปกรณ์สำเร็จ" ได้ "TC05_F01"
    ...                ผูกรหัสไว้กับชื่อเทสต์ที่เดียว จะได้ไม่ต้องเขียนรหัสซ้ำในทุกกรณีทดสอบ
    ${Parts}=    Split String    ${TEST NAME}    ${SPACE}:${SPACE}    1
    ${Id}=       Strip String    ${Parts}[0]
    RETURN    ${Id}

หาแถวของกรณีทดสอบ
    [Documentation]    ค้นหมายเลขแถวจากรหัสกรณีทดสอบในคอลัมน์ A (index 0 คือหัวตาราง แถวจึงเป็น index + 1)
    ...                คืน 0 เมื่อไม่พบ เพื่อให้ teardown ข้ามการเขียนผลแทนที่จะล้ม
    [Arguments]    ${TestCaseID}
    ${Ids}=    Read Excel Column    ${COL_ID}    sheet_name=${SHEET}
    ${Ids}=    Evaluate    ["" if v is None else str(v).strip() for v in $Ids]

    ${Found}=    Run Keyword And Return Status    List Should Contain Value    ${Ids}    ${TestCaseID}
    IF    not ${Found}
        Log    ไม่พบ ${TestCaseID} ในคอลัมน์ A ของชีต ${SHEET} จึงไม่เขียนผลกลับ    level=WARN
        RETURN    ${0}
    END

    ${Index}=    Get Index From List    ${Ids}    ${TestCaseID}
    ${Row}=      Evaluate    ${Index} + 1
    RETURN    ${Row}

บันทึกผลลง Excel
    [Documentation]    เขียนผลที่ได้จริงและสถานะ Pass/Fail กลับลงไฟล์ Excel ตามแถวของกรณีทดสอบ
    [Arguments]    ${Row}    ${ActualResult}    ${ResultPF}
    Write Excel Cell       ${Row}    ${COL_ACTUAL}    ${ActualResult}    sheet_name=${SHEET}
    Write Excel Cell       ${Row}    ${COL_PF}        ${ResultPF}        sheet_name=${SHEET}
    Save Excel Document    ${DATA_FILE}

สรุปสถานะ Pass Fail
    [Documentation]    แปลงสถานะของ Robot Framework เป็นคำที่ใช้ในรายงาน
    IF    '${TEST STATUS}' == 'PASS'    RETURN    Pass
    IF    '${TEST STATUS}' == 'SKIP'    RETURN    Skip
    RETURN    Fail


# =====================================================================
# 3. คีย์เวิร์ดช่วยเหลือ
# =====================================================================

เข้าสู่ระบบเกษตรกร
    [Documentation]    Pre-Condition ของเอกสาร : ต้องเข้าสู่ระบบก่อนจึงจะเห็นรายการเช่าของตนเอง
    ...                (Inter-Case Dependency กับ TC01 Login ตามที่เอกสารระบุไว้ในหัวข้อ 7.5.2)
    Open Login Page
    Run Keyword And Ignore Error    Handle Future Dialogs    action=accept

    Input Username    ${RETURN_USERNAME}
    Input Password    ${RETURN_PASSWORD}
    Keyboard Key      press    Tab

    ${Clicked}=    Click Button If Enabled    ${Btn_Login}
    Should Be True    ${Clicked}    msg=ปุ่มเข้าสู่ระบบถูกปิดใช้งาน จึงยังทดสอบการส่งคืนไม่ได้
    Close Login Popup

ต้องมีรายการพร้อมส่งคืน
    [Documentation]    ข้ามกรณีทดสอบเมื่อไม่มีรายการที่อยู่ในสถานะพร้อมส่งคืน
    ...                เพราะเป็นเรื่องของข้อมูลตั้งต้นตาม Pre-Condition ของเอกสาร ไม่ใช่ข้อผิดพลาดของระบบ
    [Arguments]    ${Count}
    IF    ${Count} == 0
        บันทึกผลที่ได้จริง    ไม่มีรายการที่อยู่ในสถานะพร้อมส่งคืนบนหน้าจอ
        Skip    ไม่มีรายการที่พร้อมส่งคืน กรุณาจองและรับอุปกรณ์ให้เสร็จก่อน (Pre-Condition ของเอกสาร)
    END

บันทึกผลที่ได้จริง
    [Documentation]    จำข้อความที่ระบบตอบกลับไว้ให้ teardown เขียนลงคอลัมน์ ActualResult
    [Arguments]    ${Text}
    Set Test Variable    ${ACTUAL_MESSAGE}    ${Text}

เก็บภาพหลักฐาน
    [Documentation]    บันทึกภาพหน้าจอไว้เป็นหลักฐานประกอบรายงาน
    [Arguments]    ${Name}
    Run Keyword And Ignore Error
    ...    Take Screenshot    ${SCREENSHOT_DIR}/${USECASE}_${Name}    fullPage=True

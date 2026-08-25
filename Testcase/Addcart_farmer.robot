*** Settings ***
Documentation     TC03 - Add Cart Farmer | ทดสอบยูสเคส "เพิ่มอุปกรณ์ลงตะกร้า" ของเกษตรกร
...
...               ยูสเคสนี้ไม่มีการกรอกฟอร์ม จึงไม่มีการตรวจข้อความแจ้งเตือนรายฟิลด์
...               มีเฉพาะกรณีทดสอบเชิงกระบวนการ (TC03_F01 - TC03_F07) ตามเอกสาร Test Case หน้า 65-68
...               ทุกกรณียกเว้น TC03_F05 ต้องเข้าสู่ระบบก่อน จึงขึ้นกับยูสเคส TC01 Login
...
...               เลือกกรณีที่รันจากคอลัมน์ ${Run} (Yes/No) ใน Data.xlsx และเขียนผลกลับลง ActualResult / Result
Metadata          System      ระบบเว็บศูนย์กลางให้บริการเช่าอุปกรณ์ทางการเกษตร (SRS v7.0)
Metadata          Use Case    TC03 Add Cart Farmer
Metadata          Test Data   TestData/Data.xlsx (sheet: AddCart_Farmer)

Resource          ../Resources/keywords.robot
Library           DataDriver    file=${CURDIR}/../TestData/Data.xlsx    sheet_name=AddCart_Farmer
Library           ExcelLibrary
Library           OperatingSystem
Library           String
Library           Collections

Suite Setup       เปิดชุดทดสอบ
Suite Teardown    ปิดชุดทดสอบ
Test Teardown     เก็บผลท้ายกรณีทดสอบ
Test Template     ดำเนินการกรณีทดสอบ


*** Variables ***
# ---------- ที่อยู่ของไฟล์และโฟลเดอร์ ----------
${DATA_FILE}      ${CURDIR}/../TestData/Data.xlsx
${SHEET}          AddCart_Farmer
${ERROR_DIR}      ${CURDIR}/../Error IMG
${EVIDENCE_DIR}   ${CURDIR}/../Flow IMG
${USECASE}        TC03_AddCart_Farmer

# ---------- ตำแหน่งคอลัมน์ในชีต ----------
${COL_ID}         ${2}     # คอลัมน์ B : ${TestCase}
${COL_ACTUAL}     ${9}     # คอลัมน์ I : ${ActualResult}
${COL_PF}         ${10}    # คอลัมน์ J : ${Result}

# ---------- ข้อความที่ใช้ตรวจการเข้าสู่ระบบ ----------
${SUCCESS_KEYWORD}    สำเร็จ
${Popup_Success}      text=${SUCCESS_KEYWORD}
${POPUP_TIMEOUT}      10s

# ---------- ตัวแปรระดับกรณีทดสอบ ใช้ส่งข้อมูลให้ teardown ----------
${TC_ID}             UNKNOWN
${ROW_NUM}           ${0}
${ACTUAL_MESSAGE}    ${EMPTY}


*** Test Cases ***
Add Cart Farmer : ${TestCase}


*** Keywords ***
# =====================================================================
# 1. การเตรียมและปิดชุดทดสอบ
# =====================================================================

เปิดชุดทดสอบ
    [Documentation]    ล้างภาพของรอบก่อน เปิดไฟล์ Excel สำหรับเขียนผล และเปิดเบราว์เซอร์
    Create Directory    ${ERROR_DIR}
    Create Directory    ${EVIDENCE_DIR}
    ลบภาพของรอบก่อน    ${ERROR_DIR}
    ลบภาพของรอบก่อน    ${EVIDENCE_DIR}

    Open Excel Document    ${DATA_FILE}    AddCart
    Open Login Browser

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
    Close All Login Browsers

เก็บผลท้ายกรณีทดสอบ
    [Documentation]    เก็บภาพเมื่อไม่ผ่าน เขียนผลกลับลง Excel แล้วปิด context
    ...                กรณีที่ถูกข้าม (${ROW_NUM} = 0) จะไม่เขียนทับผลเดิม
    ${Actual}=    Set Variable    ${ACTUAL_MESSAGE}

    IF    '${TEST STATUS}' == 'FAIL'
        Run Keyword And Ignore Error
        ...    Take Screenshot    ${ERROR_DIR}/${USECASE}_${TC_ID}    fullPage=True

        # กรณีที่ล้มก่อนได้ข้อความจากระบบ ให้บันทึกสาเหตุที่ล้มแทน
        ${Length}=    Get Length    ${ACTUAL_MESSAGE}
        IF    ${Length} == 0
            ${Actual}=    Get Line         ${TEST MESSAGE}    0
            ${Actual}=    Get Substring    ${Actual}          0    250
        END
    END

    IF    ${ROW_NUM} > 0
        ${ResultPF}=    Set Variable If    '${TEST STATUS}' == 'PASS'    Pass    Fail
        Run Keyword And Ignore Error    บันทึกผลลง Excel    ${ROW_NUM}    ${Actual}    ${ResultPF}
    END

    # Ignore Error เพราะกรณีที่ถูกข้ามยังไม่มี context ถูกเปิด
    Run Keyword And Ignore Error    Close Login Context


# =====================================================================
# 2. การอ่านและเขียนไฟล์ Excel
# =====================================================================

หาแถวของกรณีทดสอบ
    [Documentation]    ค้นหมายเลขแถวจากรหัสกรณีทดสอบในคอลัมน์ B (index 0 คือหัวตาราง แถวจึงเป็น index + 1)
    ...                คืน 0 เมื่อไม่พบ เพื่อให้ teardown ข้ามการเขียนผลแทนที่จะล้ม
    [Arguments]    ${TestCaseID}
    ${Ids}=    Read Excel Column    ${COL_ID}    sheet_name=${SHEET}
    ${Ids}=    Evaluate    ["" if v is None else str(v).strip() for v in $Ids]

    ${Found}=    Run Keyword And Return Status    List Should Contain Value    ${Ids}    ${TestCaseID}
    IF    not ${Found}
        Log    ไม่พบ ${TestCaseID} ในคอลัมน์ B ของชีต ${SHEET} จึงไม่เขียนผลกลับ    level=WARN
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


# =====================================================================
# 3. จุดเริ่มของทุกกรณีทดสอบ
# =====================================================================

ดำเนินการกรณีทดสอบ
    [Documentation]    อ่านข้อมูลจาก Excel แล้วส่งต่อให้คีย์เวิร์ด "กรณี <รหัสกรณีทดสอบ>"
    [Arguments]    ${Run}              ${TestCase}         ${TestScenario}
    ...            ${Username}         ${Password}
    ...            ${EquipmentType}    ${EquipmentName}    ${ExpectedResult}

    # แถวสรุปผลท้ายชีตไม่มีรหัสกรณีทดสอบ จึงไม่ใช่กรณีทดสอบ
    IF    '${TestCase}' == '${EMPTY}'
        Skip    ไม่ใช่กรณีทดสอบ (แถวสรุปผลในไฟล์ Excel)
    END
    IF    '${Run}' != 'Yes'
        Skip    ไม่ได้เลือกให้รัน (Run = ${Run})
    END

    Set Test Documentation    ${TestScenario}
    Set Test Variable         ${TC_ID}             ${TestCase}
    Set Test Variable         ${ACTUAL_MESSAGE}    ${EMPTY}

    ${Row}=    หาแถวของกรณีทดสอบ    ${TestCase}
    Set Test Variable    ${ROW_NUM}    ${Row}

    ${Data}=    Create Dictionary
    ...    Username=${Username}                Password=${Password}
    ...    EquipmentType=${EquipmentType}      EquipmentName=${EquipmentName}
    Log    ${TestCase} : ${TestScenario} | ข้อมูลที่ใช้ทดสอบ ${Data}    level=INFO

    Run Keyword    กรณี ${TestCase}    ${Data}    ${ExpectedResult}


# =====================================================================
# 4. กรณีทดสอบของยูสเคส (TC03_F01 - TC03_F07)
# =====================================================================

กรณี TC03_F01
    [Documentation]    Basic Flow : ค้นหาแล้วกดเพิ่มในตะกร้า
    ...                ต้องได้ปุ่ม "อยู่ในตะกร้าแล้ว" และมี 1 รายการที่ถูกชิ้นอยู่ในตะกร้า
    [Arguments]    ${Data}    ${ExpectedResult}

    เข้าสู่ระบบและไปหน้าค้นหาอุปกรณ์    ${Data}
    Clear Cart

    ${Cards}=      ค้นหาอุปกรณ์    ${Data}[EquipmentType]    ${Data}[EquipmentName]
    ${Summary}=    Get Found Count Text
    เก็บภาพหลักฐาน    ผลการค้นหา
    Should Be True    ${Cards} > 0
    ...    msg=ค้นหา "${Data}[EquipmentName]" แล้วไม่พบอุปกรณ์ จึงยังทดสอบการเพิ่มตะกร้าไม่ได้ (${Summary})

    # ปุ่มบนการ์ดคือสิ่งที่ระบบใช้บอกสถานะ จึงอ่านทั้งก่อนและหลังกด เพื่อยืนยันว่าเปลี่ยนสถานะจริง
    ${Before}=     Get Equipment Button State
    ${Clicked}=    Click Add To Cart
    ${After}=      Get Equipment Button State
    เก็บภาพหลักฐาน    กดเพิ่มในตะกร้า

    ${Count}=       เปิดตะกร้าและนับรายการ
    ${CartText}=    Get Cart Text
    เก็บภาพหลักฐาน    รายการในตะกร้า

    # เขียนข้อความที่ระบบแสดงจริงลงคอลัมน์ ActualResult ไม่ใช่ประโยคที่สคริปต์แต่งขึ้น
    บันทึกผลที่ได้จริง    ${After}
    Log    ปุ่มก่อนกด "${Before}" หลังกด "${After}" และในตะกร้ามี ${Count} รายการ    level=INFO

    Should Be True    ${Clicked}
    ...    msg=ปุ่ม "${Before}" ถูกปิดใช้งาน จึงเพิ่มอุปกรณ์ลงตะกร้าไม่ได้
    Should Be Equal    ${After}    ${State_InCart}
    ...    msg=กดเพิ่มลงตะกร้าแล้ว แต่ปุ่มบนการ์ดยังเป็น "${After}" ไม่ได้เปลี่ยนเป็น "${State_InCart}"
    Should Be Equal As Integers    ${Count}    ${1}
    ...    msg=กดเพิ่มในตะกร้า 1 ครั้ง แต่ในตะกร้ามี ${Count} รายการ
    Should Contain    ${CartText}    ${Data}[EquipmentName]
    ...    msg=ในตะกร้าไม่มีอุปกรณ์ชื่อ "${Data}[EquipmentName]" ที่เพิ่งเพิ่มไป

กรณี TC03_F02
    [Documentation]    ตามเอกสารข้อ Invalid : กดอุปกรณ์ชิ้นเดิมซ้ำครั้งที่สองต้องกดไม่ได้
    ...                และในตะกร้าต้องเหลือเพียง 1 รายการ
    [Arguments]    ${Data}    ${ExpectedResult}

    เข้าสู่ระบบและไปหน้าค้นหาอุปกรณ์    ${Data}
    Clear Cart

    ${Cards}=    ค้นหาอุปกรณ์    ${Data}[EquipmentType]    ${Data}[EquipmentName]
    Should Be True    ${Cards} > 0
    ...    msg=ค้นหา "${Data}[EquipmentName]" แล้วไม่พบอุปกรณ์ จึงยังทดสอบการเพิ่มซ้ำไม่ได้

    # ---------- ครั้งที่ 1 : ต้องเพิ่มได้ตามปกติ ----------
    ${First}=         Click Add To Cart
    ${AfterFirst}=    Get Equipment Button State
    Should Be True    ${First}
    ...    msg=เพิ่มอุปกรณ์ครั้งแรกไม่สำเร็จ จึงยังทดสอบการเพิ่มซ้ำไม่ได้

    # ---------- ครั้งที่ 2 : ลองกดทั้งปุ่มเดิมและปุ่มที่เปลี่ยนข้อความแล้ว ต้องกดไม่ได้ทั้งสองทาง ----------
    ${Second}=    Click Add To Cart
    ${Retry}=     Click Button If Enabled    ${Btn_InCart} >> nth=0
    ${State}=     Get Equipment Button State
    เก็บภาพหลักฐาน    กดเพิ่มซ้ำ

    ${Count}=    เปิดตะกร้าและนับรายการ
    เก็บภาพหลักฐาน    รายการในตะกร้า

    # ระบบกันการเพิ่มซ้ำด้วยการเปลี่ยนสถานะปุ่ม จึงบันทึกข้อความบนปุ่มเป็นผลที่ได้จริง
    บันทึกผลที่ได้จริง    ${State}
    Log    ปุ่มหลังเพิ่มครั้งแรก "${AfterFirst}" หลังพยายามกดซ้ำ "${State}" และในตะกร้ามี ${Count} รายการ
    ...    level=INFO

    Should Not Be True    ${Second}
    ...    msg=ระบบยังให้กดปุ่ม "${State_AddToCart}" ของอุปกรณ์ที่อยู่ในตะกร้าแล้วได้
    Should Not Be True    ${Retry}
    ...    msg=ปุ่ม "${State_InCart}" ยังกดได้ ทั้งที่ควรถูกปิดใช้งาน
    Should Be Equal    ${State}    ${State_InCart}
    ...    msg=ปุ่มบนการ์ดเป็น "${State}" ไม่ใช่ "${State_InCart}" ระบบจึงไม่ได้กันการเพิ่มซ้ำไว้
    Should Be Equal As Integers    ${Count}    ${1}
    ...    msg=กดเพิ่มอุปกรณ์ชิ้นเดิมซ้ำแล้วในตะกร้ามี ${Count} รายการ ทั้งที่ควรมีเพียง 1 รายการ

กรณี TC03_F03
    [Documentation]    ตามเอกสาร AC01-01 / AC01-02 : อุปกรณ์ที่ไม่พร้อมใช้งาน
    ...                ระบบจะไม่แสดงหรือปิดปุ่มไว้ก็ได้ แต่ตะกร้าต้องยังว่าง
    [Arguments]    ${Data}    ${ExpectedResult}

    เข้าสู่ระบบและไปหน้าค้นหาอุปกรณ์    ${Data}
    Clear Cart

    ${Cards}=      ค้นหาอุปกรณ์    ${Data}[EquipmentType]    ${Data}[EquipmentName]
    ${Summary}=    Get Found Count Text
    ${State}=      Get Equipment Button State
    เก็บภาพหลักฐาน    ผลการค้นหา

    IF    ${Cards} == 0
        # ระบบไม่แสดงอุปกรณ์ที่ไม่พร้อมใช้งานให้เลือกตั้งแต่แรก จึงไม่มีปุ่มให้อ่านสถานะ
        ${Clicked}=    Set Variable    ${False}
        ${Detail}=     Set Variable    ${Summary}
    ELSE
        ${Clicked}=    Click Add To Cart
        # ระบบไม่มี popup แจ้งเตือน จึงใช้ข้อความบนปุ่มเป็นผลที่ได้จริงแทน
        ${State}=      Get Equipment Button State
        ${Detail}=     Set Variable    ${State}
    END
    เก็บภาพหลักฐาน    กดเพิ่มอุปกรณ์ที่ไม่พร้อมใช้งาน

    ${Count}=    เปิดตะกร้าและนับรายการ
    เก็บภาพหลักฐาน    ตะกร้าหลังพยายามเพิ่ม

    บันทึกผลที่ได้จริง    ${Detail}
    Log    ผลการค้นหา "${Summary}" ปุ่มบนการ์ด "${State}" และในตะกร้ามี ${Count} รายการ    level=INFO

    Should Be Equal As Integers    ${Count}    ${0}
    ...    msg=ระบบเพิ่มอุปกรณ์ที่ไม่พร้อมใช้งานลงตะกร้าได้ ทั้งที่ไม่ควรอนุญาต

    # ถ้าระบบแสดงอุปกรณ์ชิ้นนี้ ปุ่มบนการ์ดต้องบอกว่าเช่าไม่ได้ ไม่ใช่ปุ่มเพิ่มปกติ
    IF    ${Cards} > 0
        Should Be Equal    ${State}    ${State_Unavailable}
        ...    msg=อุปกรณ์ที่ไม่พร้อมใช้งานแสดงปุ่ม "${State}" ทั้งที่ควรเป็น "${State_Unavailable}"
    END

    # ตรวจข้อความเฉพาะตอนที่กดปุ่มได้จริง ถ้าปุ่มถูกปิดไว้ก็ไม่มีข้อความแจ้งเตือนให้ตรวจ
    IF    ${Clicked}
        ข้อความต้องกล่าวถึง    ${Detail}    ไม่พร้อม    ไม่สามารถ    ไม่อนุญาต
    END

กรณี TC03_F04
    [Documentation]    ตามเอกสาร TC05 Add cart ขั้นตอน Click clear cart / Verify empty cart
    ...                เพิ่มอุปกรณ์ 1 ชิ้น แล้วกดปุ่ม "ล้างตะกร้า" ตะกร้าต้องว่าง
    [Arguments]    ${Data}    ${ExpectedResult}

    เข้าสู่ระบบและไปหน้าค้นหาอุปกรณ์    ${Data}
    Clear Cart

    ${Cards}=    ค้นหาอุปกรณ์    ${Data}[EquipmentType]    ${Data}[EquipmentName]
    Should Be True    ${Cards} > 0
    ...    msg=ค้นหา "${Data}[EquipmentName]" แล้วไม่พบอุปกรณ์ จึงยังทดสอบการล้างตะกร้าไม่ได้

    ${Clicked}=    Click Add To Cart
    Should Be True    ${Clicked}
    ...    msg=เพิ่มอุปกรณ์ลงตะกร้าไม่สำเร็จ จึงยังทดสอบการล้างตะกร้าไม่ได้

    # เปิดกล่องตะกร้าค้างไว้ แล้วกดล้างในกล่องเดิม ไม่ปิดเปิดซ้ำเพราะปุ่มตะกร้าเป็นแบบสลับเปิด-ปิด
    ${Before}=    เปิดตะกร้าและนับรายการ
    เก็บภาพหลักฐาน    ก่อนล้างตะกร้า
    Should Be Equal As Integers    ${Before}    ${1}
    ...    msg=ก่อนล้างตะกร้าควรมี 1 รายการ แต่พบ ${Before} รายการ

    ${Cleared}=     Click Clear Cart Button
    ${After}=       Get Cart Item Count
    ${CartText}=    Get Cart Text
    เก็บภาพหลักฐาน    หลังล้างตะกร้า
    Close Cart

    บันทึกผลที่ได้จริง    ก่อนล้างมี ${Before} รายการ หลังล้างเหลือ ${After} รายการ
    Log    ข้อความในกล่องตะกร้าหลังล้าง : ${CartText}    level=INFO

    Should Be True    ${Cleared}
    ...    msg=ปุ่ม "ล้างตะกร้า" ถูกปิดใช้งานหรือกดไม่ได้
    Should Be Equal As Integers    ${After}    ${0}
    ...    msg=กดล้างตะกร้าแล้วยังเหลือ ${After} รายการ ทั้งที่ตะกร้าควรว่าง

กรณี TC03_F05
    [Documentation]    ตรวจ Pre-Condition ของเอกสาร : ผู้ใช้ต้องเข้าสู่ระบบก่อนจึงจะเพิ่มลงตะกร้าได้
    ...                เข้าหน้าค้นหาโดยไม่เข้าสู่ระบบ แล้วกดเพิ่มในตะกร้า ระบบต้องกันไว้
    [Arguments]    ${Data}    ${ExpectedResult}

    เปิดหน้าค้นหาอุปกรณ์โดยไม่เข้าสู่ระบบ

    ${Cards}=    ค้นหาอุปกรณ์    ${Data}[EquipmentType]    ${Data}[EquipmentName]
    เก็บภาพหลักฐาน    ผลการค้นหาแบบยังไม่เข้าสู่ระบบ
    Should Be True    ${Cards} > 0
    ...    msg=ค้นหา "${Data}[EquipmentName]" แล้วไม่พบอุปกรณ์ จึงยังทดสอบการกันผู้ใช้ที่ยังไม่เข้าสู่ระบบไม่ได้

    ${Clicked}=    Click Add To Cart
    ${Url}=        Get Url
    ${Count}=      เปิดตะกร้าและนับรายการ
    เก็บภาพหลักฐาน    หลังกดเพิ่มแบบยังไม่เข้าสู่ระบบ

    ${Redirected}=    Evaluate    "login" in $Url
    บันทึกผลที่ได้จริง    กดปุ่มได้ = ${Clicked} | หน้าปัจจุบัน ${Url} | ในตะกร้ามี ${Count} รายการ

    ${Prevented}=    Evaluate    (not ${Clicked}) or ${Redirected} or ${Count} == 0
    Should Be True    ${Prevented}
    ...    msg=ระบบยอมให้เพิ่มอุปกรณ์ลงตะกร้าได้ ทั้งที่ผู้ใช้ยังไม่ได้เข้าสู่ระบบ

กรณี TC03_F06
    [Documentation]    ตะกร้าต้องคงอยู่หลังผู้ใช้รีเฟรชหน้า ไม่หายไปเมื่อโหลดหน้าใหม่
    [Arguments]    ${Data}    ${ExpectedResult}

    เข้าสู่ระบบและไปหน้าค้นหาอุปกรณ์    ${Data}
    Clear Cart

    ${Cards}=    ค้นหาอุปกรณ์    ${Data}[EquipmentType]    ${Data}[EquipmentName]
    Should Be True    ${Cards} > 0
    ...    msg=ค้นหา "${Data}[EquipmentName]" แล้วไม่พบอุปกรณ์ จึงยังทดสอบการรีเฟรชไม่ได้

    ${Clicked}=    Click Add To Cart
    Should Be True    ${Clicked}
    ...    msg=เพิ่มอุปกรณ์ลงตะกร้าไม่สำเร็จ จึงยังทดสอบการรีเฟรชไม่ได้

    ${Before}=    เปิดตะกร้าและนับรายการ
    Close Cart
    เก็บภาพหลักฐาน    ก่อนรีเฟรช
    Should Be Equal As Integers    ${Before}    ${1}
    ...    msg=ก่อนรีเฟรชควรมี 1 รายการ แต่พบ ${Before} รายการ

    # ---------- รีเฟรชหน้า แล้วดูว่าตะกร้ายังอยู่ไหม ----------
    Reload
    Wait For Elements State    ${Btn_OpenCart}    visible    ${DEFAULT_TIMEOUT}

    ${After}=       เปิดตะกร้าและนับรายการ
    ${CartText}=    Get Cart Text
    เก็บภาพหลักฐาน    หลังรีเฟรช
    Close Cart

    บันทึกผลที่ได้จริง    ก่อนรีเฟรชมี ${Before} รายการ หลังรีเฟรชมี ${After} รายการ
    Log    ข้อความในกล่องตะกร้าหลังรีเฟรช : ${CartText}    level=INFO

    Should Be Equal As Integers    ${After}    ${Before}
    ...    msg=รีเฟรชหน้าแล้วรายการในตะกร้าเปลี่ยนจาก ${Before} เป็น ${After} รายการ

กรณี TC03_F07
    [Documentation]    เพิ่มอุปกรณ์ 2 ชิ้นลงตะกร้า แล้วลบทีละรายการจนตะกร้าว่าง
    ...                เว้นประเภทและชื่ออุปกรณ์ว่างไว้ใน Excel เพื่อให้ระบบแสดงอุปกรณ์ทั้งหมด
    [Arguments]    ${Data}    ${ExpectedResult}

    เข้าสู่ระบบและไปหน้าค้นหาอุปกรณ์    ${Data}
    Clear Cart

    ค้นหาอุปกรณ์    ${Data}[EquipmentType]    ${Data}[EquipmentName]
    ${Available}=    Get Available Equipment Count
    เก็บภาพหลักฐาน    ผลการค้นหา
    Should Be True    ${Available} >= 2
    ...    msg=มีอุปกรณ์ที่เพิ่มลงตะกร้าได้เพียง ${Available} ชิ้น จึงยังทดสอบการเพิ่มหลายชิ้นไม่ได้

    # กดเพิ่ม 2 ครั้ง ชิ้นแรกเปลี่ยนเป็น "อยู่ในตะกร้าแล้ว" ครั้งที่สองจึงไปตกที่อุปกรณ์ชิ้นถัดไปเอง
    ${First}=     Click Add To Cart
    ${Second}=    Click Add To Cart
    เก็บภาพหลักฐาน    กดเพิ่ม 2 ชิ้น
    Should Be True    ${First} and ${Second}
    ...    msg=เพิ่มอุปกรณ์ไม่ครบ 2 ชิ้น (ชิ้นแรก ${First} ชิ้นที่สอง ${Second})

    ${Added}=    เปิดตะกร้าและนับรายการ
    เก็บภาพหลักฐาน    ตะกร้าหลังเพิ่ม 2 ชิ้น

    # ---------- ลบทีละรายการ โดยเปิดกล่องตะกร้าค้างไว้ ----------
    Remove First Cart Item
    ${AfterFirstRemove}=    Get Cart Item Count
    Remove First Cart Item
    ${AfterSecondRemove}=    Get Cart Item Count
    เก็บภาพหลักฐาน    ตะกร้าหลังลบทั้งหมด
    Close Cart

    บันทึกผลที่ได้จริง
    ...    เพิ่มแล้วมี ${Added} รายการ ลบครั้งที่ 1 เหลือ ${AfterFirstRemove} รายการ ลบครั้งที่ 2 เหลือ ${AfterSecondRemove} รายการ

    Should Be Equal As Integers    ${Added}    ${2}
    ...    msg=กดเพิ่มอุปกรณ์ 2 ชิ้น แต่ในตะกร้ามี ${Added} รายการ
    Should Be Equal As Integers    ${AfterFirstRemove}    ${1}
    ...    msg=ลบ 1 รายการแล้วควรเหลือ 1 รายการ แต่พบ ${AfterFirstRemove} รายการ
    Should Be Equal As Integers    ${AfterSecondRemove}    ${0}
    ...    msg=ลบครบทุกรายการแล้วควรเหลือ 0 รายการ แต่พบ ${AfterSecondRemove} รายการ


# =====================================================================
# 5. ขั้นตอนย่อยของยูสเคส
# =====================================================================

เข้าสู่ระบบและไปหน้าค้นหาอุปกรณ์
    [Documentation]    ยูสเคสนี้ต้องเข้าสู่ระบบก่อน จึงเข้าสู่ระบบแล้วกดเข้าหน้าค้นหาอุปกรณ์
    [Arguments]    ${Data}

    Run Keyword And Ignore Error    Close Login Context
    Open Login Page

    # เผื่อหน้าเว็บเรียก confirm ของเบราว์เซอร์ ถ้าไม่ตอบไว้ก่อนสคริปต์จะค้างรอจนหมดเวลา
    Run Keyword And Ignore Error    Handle Future Dialogs    action=accept

    Input Username    ${Data}[Username]
    Input Password    ${Data}[Password]
    Keyboard Key      press    Tab

    ${Clicked}=    Click Button If Enabled    ${Btn_Login}
    Should Be True    ${Clicked}    msg=ปุ่มเข้าสู่ระบบถูกปิดใช้งาน

    ${Ok}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Popup_Success}    visible    ${POPUP_TIMEOUT}
    Should Be True    ${Ok}
    ...    msg=เข้าสู่ระบบด้วยบัญชี "${Data}[Username]" ไม่สำเร็จ จึงยังทดสอบการเพิ่มตะกร้าไม่ได้

    Close Login Popup
    Open Search Equipment Page

เปิดหน้าค้นหาอุปกรณ์โดยไม่เข้าสู่ระบบ
    [Documentation]    เปิด context ใหม่ที่ยังไม่ได้เข้าสู่ระบบ แล้วเข้าหน้าค้นหาอุปกรณ์จากหน้าแรกของเว็บ
    Run Keyword And Ignore Error    Close Login Context

    New Context
    New Page             ${Base_URL}
    Set Viewport Size    ${VIEWPORT_WIDTH}    ${VIEWPORT_HEIGHT}

    # เผื่อหน้าเว็บเรียก confirm ของเบราว์เซอร์ ถ้าไม่ตอบไว้ก่อนสคริปต์จะค้างรอจนหมดเวลา
    Run Keyword And Ignore Error    Handle Future Dialogs    action=accept

    ${Opened}=    Run Keyword And Return Status    Open Search Equipment Page
    Should Be True    ${Opened}
    ...    msg=เข้าหน้าค้นหาอุปกรณ์โดยไม่เข้าสู่ระบบไม่ได้ ระบบอาจบังคับให้เข้าสู่ระบบก่อนตั้งแต่หน้าแรก

ค้นหาอุปกรณ์
    [Documentation]    เลือกประเภทอุปกรณ์ (ถ้าระบุมา) แล้วพิมพ์ชื่ออุปกรณ์ลงช่องค้นหา คืนจำนวนการ์ดที่พบ
    [Arguments]    ${Type}    ${Name}
    Select Equipment Type    ${Type}
    Input Search Equipment    ${Name}

    ${Cards}=      Get Equipment Card Count
    ${Summary}=    Get Found Count Text
    Log    ค้นหา "${Name}" แล้วพบ ${Cards} รายการ (${Summary})    level=INFO
    RETURN    ${Cards}

เปิดตะกร้าและนับรายการ
    [Documentation]    เปิดกล่องตะกร้าแล้วนับรายการข้างใน ถ้าเปิดไม่ได้ถือว่าตะกร้าว่าง
    ${Opened}=    Open Cart
    IF    not ${Opened}
        Log    เปิดกล่องตะกร้าไม่ได้ ถือว่าไม่มีรายการในตะกร้า    level=INFO
        RETURN    ${0}
    END
    ${Count}=    Get Cart Item Count
    RETURN    ${Count}


# =====================================================================
# 6. คีย์เวิร์ดช่วยเหลือ : บันทึกผล ตรวจผล และเก็บหลักฐาน
# =====================================================================

บันทึกผลที่ได้จริง
    [Documentation]    จำข้อความที่ระบบตอบกลับไว้ ให้ teardown เขียนลงคอลัมน์ ActualResult
    [Arguments]    ${Text}
    Set Test Variable    ${ACTUAL_MESSAGE}    ${Text}

ข้อความต้องกล่าวถึง
    [Documentation]    ยืนยันว่าข้อความที่ระบบตอบกลับมีคำที่เอกสารระบุไว้อย่างน้อยหนึ่งคำ
    [Arguments]    ${Message}    @{Keywords}
    ${Lower}=    Convert To Lower Case    ${Message}
    # lambda รับค่าผ่าน default argument เพราะ RF มองไม่เห็น $ตัวแปร ใน comprehension
    ${Matched}=    Evaluate    any(map(lambda k, t=$Lower: k.lower() in t, $Keywords))
    Should Be True    ${Matched}
    ...    msg=ข้อความ "${Message}" ไม่มีคำว่า ${Keywords} จึงไม่ตรงกับที่เอกสารกำหนดไว้

เก็บภาพหลักฐาน
    [Documentation]    บันทึกภาพหน้าจอไว้เป็นหลักฐานประกอบรายงาน ตั้งชื่อเป็น <ยูสเคส>_<รหัส>_<คำอธิบาย>
    [Arguments]    ${Name}
    Run Keyword And Ignore Error
    ...    Take Screenshot    ${EVIDENCE_DIR}/${USECASE}_${TC_ID}_${Name}    fullPage=True

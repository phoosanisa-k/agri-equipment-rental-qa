*** Settings ***
Documentation     TC03 - Add Cart Farmer (Flow) | ทดสอบทั้งกระบวนการเพิ่มอุปกรณ์ลงตะกร้าของเกษตรกร
...               ยูสเคสนี้ไม่มีการกรอกฟอร์ม จึงไม่ทดสอบรายฟิลด์ ตามเอกสาร Test Case หน้า 65-68
...               ทุกกรณีต้องเข้าสู่ระบบก่อน (ขึ้นกับ TC01 Login) เลือกรันได้จากคอลัมน์ ${Run}
Metadata          System      ระบบเว็บศูนย์กลางให้บริการเช่าอุปกรณ์ทางการเกษตร (SRS v7.0)
Metadata          Use Case    TC03 Add Cart Farmer - Flow
Metadata          Test Data   TestData/Data.xlsx (sheet: AddCart_Farmer_Flow)

Resource          ../Resources/keywords.robot
Library           ExcelLibrary
Library           OperatingSystem
Library           String
Library           Collections

Suite Setup       Prepare Flow Suite
Suite Teardown    Finish Flow Suite
Test Teardown     Flow Test Teardown


*** Variables ***
${DATA_FILE}      ${CURDIR}/../TestData/Data.xlsx
${SHEET}          AddCart_Farmer_Flow
${EVIDENCE_DIR}   ${CURDIR}/../Flow IMG

${COL_ID}         ${2}     # คอลัมน์ B : ${TestCase}
${COL_ACTUAL}     ${9}     # คอลัมน์ I : ${ActualResult}
${COL_PF}         ${10}    # คอลัมน์ J : ${Result}

# คำที่ต้องพบใน popup เมื่อเข้าสู่ระบบสำเร็จ
${SUCCESS_KEYWORD}    สำเร็จ
${Popup_Success}      text=${SUCCESS_KEYWORD}
${POPUP_TIMEOUT}      10s

# ชื่อคอลัมน์ตามลำดับในชีต ใช้แปลงข้อมูลหนึ่งแถวเป็น dictionary
@{FIELDS}
...    Run    TestCase    TestScenario    Username    Password
...    EquipmentType    EquipmentName    ExpectedResult    ActualResult    Result
...    Rewrite

# ตัวแปรระดับกรณีทดสอบ ใช้ส่งข้อมูลให้ teardown
${ROW_NUM}           ${0}
${ACTUAL_MESSAGE}    ${EMPTY}


*** Test Cases ***
TC03_F01 : ค้นหาอุปกรณ์แล้วเพิ่มลงตะกร้าสำเร็จ
    [Documentation]    Basic Flow : ค้นหาแล้วกดเพิ่มในตะกร้า ต้องได้ปุ่ม "อยู่ในตะกร้าแล้ว" และมี 1 รายการที่ถูกชิ้น
    [Tags]    flow    addcart    farmer    positive

    ${Data}=    เตรียมกรณีทดสอบ    TC03_F01
    เข้าสู่ระบบและไปหน้าค้นหาอุปกรณ์    ${Data}
    Clear Cart

    ${Cards}=    ค้นหาอุปกรณ์    ${Data}[EquipmentType]    ${Data}[EquipmentName]
    ${Summary}=    Get Found Count Text
    เก็บภาพหลักฐาน    TC03_F01_ผลการค้นหา
    Should Be True    ${Cards} > 0
    ...    msg=ค้นหา "${Data}[EquipmentName]" แล้วไม่พบอุปกรณ์ จึงยังทดสอบการเพิ่มตะกร้าไม่ได้ (${Summary})

    # ปุ่มบนการ์ดคือสิ่งที่ระบบใช้บอกสถานะ จึงอ่านทั้งก่อนและหลังกด เพื่อยืนยันว่าเปลี่ยนสถานะจริง
    ${Before}=     Get Equipment Button State
    ${Clicked}=    Click Add To Cart
    ${After}=      Get Equipment Button State
    เก็บภาพหลักฐาน    TC03_F01_กดเพิ่มในตะกร้า

    ${Count}=       เปิดตะกร้าและนับรายการ
    ${CartText}=    Get Cart Text
    เก็บภาพหลักฐาน    TC03_F01_รายการในตะกร้า

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

TC03_F02 : เพิ่มอุปกรณ์รายการซ้ำ ระบบต้องไม่อนุญาต
    [Documentation]    ตามเอกสารข้อ Invalid : กดชิ้นเดิมซ้ำครั้งที่สองต้องกดไม่ได้ และในตะกร้าเหลือ 1 รายการ
    [Tags]    flow    addcart    farmer    negative    duplicate

    ${Data}=    เตรียมกรณีทดสอบ    TC03_F02
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
    เก็บภาพหลักฐาน    TC03_F02_กดเพิ่มซ้ำ

    ${Count}=    เปิดตะกร้าและนับรายการ
    เก็บภาพหลักฐาน    TC03_F02_รายการในตะกร้า

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

TC03_F03 : เพิ่มอุปกรณ์ที่ไม่พร้อมใช้งาน ระบบต้องไม่อนุญาต
    [Documentation]    ตามเอกสาร AC01-01/AC01-02 : ระบบจะไม่แสดงหรือปิดปุ่มก็ได้ แต่ตะกร้าต้องยังว่าง
    [Tags]    flow    addcart    farmer    negative    unavailable

    ${Data}=    เตรียมกรณีทดสอบ    TC03_F03
    เข้าสู่ระบบและไปหน้าค้นหาอุปกรณ์    ${Data}
    Clear Cart

    ${Cards}=      ค้นหาอุปกรณ์    ${Data}[EquipmentType]    ${Data}[EquipmentName]
    ${Summary}=    Get Found Count Text
    ${State}=      Get Equipment Button State
    เก็บภาพหลักฐาน    TC03_F03_ผลการค้นหา

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
    เก็บภาพหลักฐาน    TC03_F03_กดเพิ่มอุปกรณ์ที่ไม่พร้อมใช้งาน

    ${Count}=    เปิดตะกร้าและนับรายการ
    เก็บภาพหลักฐาน    TC03_F03_ตะกร้าหลังพยายามเพิ่ม

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


*** Keywords ***
Prepare Flow Suite
#เตรียมโฟลเดอร์เก็บภาพ เปิดไฟล์ Excel และเปิดเบราว์เซอร์
    Create Directory    ${EVIDENCE_DIR}
    ลบภาพของรอบก่อน
    Open Excel Document    ${DATA_FILE}    AddCartFlow
    Open Login Browser

ลบภาพของรอบก่อน
#ลบเฉพาะภาพของ use case นี้ 
    ${Files}=    List Files In Directory    ${EVIDENCE_DIR}    TC03_*.png
    FOR    ${File}    IN    @{Files}
        ${Removed}=    Run Keyword And Return Status    Remove File    ${EVIDENCE_DIR}/${File}
        IF    not ${Removed}
            Log    ลบไฟล์ ${File} ไม่สำเร็จ ภาพอาจปนกับรอบก่อน    level=WARN
        END
    END

Finish Flow Suite
    [Documentation]    บันทึกไฟล์ Excel และปิดทรัพยากรทั้งหมด
    Run Keyword And Ignore Error    Save Excel Document    ${DATA_FILE}
    Run Keyword And Ignore Error    Close All Excel Documents
    Close All Login Browsers

Flow Test Teardown
    [Documentation]    เก็บภาพเมื่อไม่ผ่าน เขียนผลลง Excel แล้วปิด context (กรณี Skip ${ROW_NUM} ยังเป็น 0 จึงไม่เขียนทับของเดิม)
    ${Note}=    Set Variable    ${EMPTY}

    IF    '${TEST STATUS}' == 'FAIL'
        # ชื่อกรณีทดสอบมี : ซึ่งใช้ในชื่อไฟล์ไม่ได้ จึงแทนด้วยขีดกลาง
        ${Safe}=    Replace String    ${TEST NAME}    :    -
        Run Keyword And Ignore Error
        ...    Take Screenshot    ${EVIDENCE_DIR}/FAILED_${Safe}    fullPage=True

        ${Note}=    Get Line         ${TEST MESSAGE}    0
        ${Note}=    Get Substring    ${Note}            0     250
    END

    IF    ${ROW_NUM} > 0
        ${Length}=    Get Length    ${ACTUAL_MESSAGE}
        ${PF}=        Set Variable If    '${TEST STATUS}' == 'PASS'    Pass    Fail
        ${Actual}=    Set Variable If    ${Length} > 0    ${ACTUAL_MESSAGE}    ${Note}
        Run Keyword And Ignore Error    Record Flow Result    ${ROW_NUM}    ${Actual}    ${PF}
    END

    # ใช้ Ignore Error เพราะกรณีที่ถูก Skip จะยังไม่มี context ถูกเปิด
    Run Keyword And Ignore Error    Close Login Context

Record Flow Result
    [Arguments]    ${Row}    ${ActualResult}    ${ResultPF}
    Write Excel Cell       ${Row}    ${COL_ACTUAL}    ${ActualResult}    sheet_name=${SHEET}
    Write Excel Cell       ${Row}    ${COL_PF}        ${ResultPF}        sheet_name=${SHEET}
    Save Excel Document    ${DATA_FILE}


# =====================================================================
# การอ่านข้อมูลทดสอบจากไฟล์ Excel
# =====================================================================

หาแถวของกรณีทดสอบ
    [Documentation]    ค้นหมายเลขแถวของ TestCase 
    [Arguments]    ${TestCaseID}
    ${Ids}=    Read Excel Column    ${COL_ID}    sheet_name=${SHEET}
    ${Ids}=    Evaluate    ["" if v is None else str(v).strip() for v in $Ids]

    ${Found}=    Run Keyword And Return Status    List Should Contain Value    ${Ids}    ${TestCaseID}
    IF    not ${Found}
        Fail    ไม่พบ ${TestCaseID} ในชีต ${SHEET} ของไฟล์ Data.xlsx
    END

    ${Index}=    Get Index From List    ${Ids}    ${TestCaseID}
    ${Row}=      Evaluate    ${Index} + 1
    RETURN    ${Row}

อ่านข้อมูลจากแถว
    [Documentation]    อ่านข้อมูลหนึ่งแถวเป็น dictionary ตามชื่อคอลัมน์ใน @{FIELDS}

    [Arguments]    ${Row}
    ${Values}=    Read Excel Row    ${Row}    sheet_name=${SHEET}
    ${Values}=    Evaluate    ["" if v is None else str(v).strip() for v in $Values]
    ${Data}=      Evaluate    dict(zip($FIELDS, $Values))
    RETURN    ${Data}

เตรียมกรณีทดสอบ
    [Documentation]    อ่านข้อมูลของกรณีทดสอบ ข้ามถ้าไม่ได้เลือกให้รัน และจำ ${ROW_NUM} ให้ teardown เขียนผลกลับแถวเดิม
    [Arguments]    ${TestCaseID}
    ${Row}=     หาแถวของกรณีทดสอบ    ${TestCaseID}
    ${Data}=    อ่านข้อมูลจากแถว      ${Row}

    # ตรวจก่อนจำแถว เพื่อไม่ให้กรณีที่ถูกข้ามเขียนผลทับของเดิม
    IF    '${Data}[Run]' != 'Yes'
        Skip    ไม่ได้เลือกให้รัน (Run = ${Data}[Run])
    END

    Set Test Variable    ${ROW_NUM}    ${Row}
    Log    ข้อมูลที่ใช้ทดสอบ : ${Data}    level=INFO
    RETURN    ${Data}


# =====================================================================
# ขั้นตอนของยูสเคส
# =====================================================================

เข้าสู่ระบบและไปหน้าค้นหาอุปกรณ์
    [Arguments]    ${Data}

    Run Keyword And Ignore Error    Close Login Context
    Open Login Page

    # เผื่อหน้าเว็บเรียก confirm ของเบราว์เซอร์ ถ้าไม่ตอบไว้ก่อนสคริปต์จะค้างรอจนหมดเวลา
    Run Keyword And Ignore Error    Handle Future Dialogs    action=accept

    Input Username    ${Data}[Username]
    Input Password    ${Data}[Password]
    Keyboard Key      press    Tab

    ${Clicked}=    Click Button If Enabled    ${Btn_Login}
    Should Be True    ${Clicked}
    ...    msg=ปุ่มเข้าสู่ระบบถูกปิดใช้งาน

    ${Ok}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Popup_Success}    visible    ${POPUP_TIMEOUT}
    Should Be True    ${Ok}
    ...    msg=เข้าสู่ระบบด้วยบัญชี "${Data}[Username]" ไม่สำเร็จ จึงยังทดสอบการเพิ่มตะกร้าไม่ได้

    Close Login Popup
    Open Search Equipment Page

ค้นหาอุปกรณ์
    [Documentation]    เลือกประเภทอุปกรณ์ (ถ้าระบุมา) แล้วพิมพ์ชื่ออุปกรณ์ลงช่องค้นหา
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

ข้อความต้องกล่าวถึง
    [Documentation]    ยืนยันว่าข้อความที่ระบบตอบกลับมีคำที่เอกสารระบุไว้อย่างน้อยหนึ่งคำ
    [Arguments]    ${Message}    @{Keywords}
    ${Lower}=    Convert To Lower Case    ${Message}
    # ใช้ lambda รับค่าผ่าน default argument เพราะ Robot Framework มองไม่เห็น $ตัวแปร ที่อยู่ใน comprehension
    ${Matched}=    Evaluate    any(map(lambda k, t=$Lower: k.lower() in t, $Keywords))
    Should Be True    ${Matched}
    ...    msg=ข้อความ "${Message}" ไม่มีคำว่า ${Keywords} จึงไม่ตรงกับที่เอกสารกำหนดไว้


# =====================================================================
# การบันทึกผลและตรวจผลลัพธ์
# =====================================================================

บันทึกผลที่ได้จริง
    [Documentation]    จำข้อความที่ระบบตอบกลับไว้ ให้ teardown เขียนลงคอลัมน์ ActualResult
    [Arguments]    ${Text}
    Set Test Variable    ${ACTUAL_MESSAGE}    ${Text}

เก็บภาพหลักฐาน
    [Documentation]    บันทึกภาพหน้าจอไว้เป็นหลักฐานประกอบรายงาน
    [Arguments]    ${Name}
    Run Keyword And Ignore Error
    ...    Take Screenshot    ${EVIDENCE_DIR}/${Name}    fullPage=True

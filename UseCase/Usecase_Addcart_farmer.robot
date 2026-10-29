*** Settings ***
Documentation     TC03 - Add Cart Farmer (Usecase) | อ้างอิงเอกสาร Test Case หน้า 65-68 (TC03_F01-F07)
...               ทดสอบเชิงกระบวนการล้วน ๆ (ไม่มีฟอร์มให้กรอก) ใช้ข้อมูลคงที่ในสคริปต์ ไม่อ่าน/เขียน Excel
...               Pre-Condition: ทุกกรณียกเว้น F05 ต้องเข้าสู่ระบบก่อน (ขึ้นกับยูสเคส TC01 Login)
Metadata          Use Case    TC03 Add Cart Farmer

Resource          ../Resources/keywords.robot
Library           OperatingSystem
Library           String
Library           Collections

Suite Setup       เตรียมชุดทดสอบยูสเคส
Suite Teardown    ปิดชุดทดสอบ
Test Teardown     เก็บผลท้ายกรณีทดสอบ

*** Variables ***
# ---------- ไฟล์และโฟลเดอร์ ----------
${USECASE}            TC03_Usecase_AddCart_Farmer
${SCREENSHOT_DIR}     ${CURDIR}/../Screenshot/${USECASE}

# ---------- ข้อความที่คาดหวังตามเอกสารเทสเคส (เทียบตรงกัน 100%) ----------
${EXP_LOGIN_SUCCESS}      เข้าสู่ระบบสำเร็จ                     # AC01-01
${EXP_LOGIN_REQUIRED}     โปรดเข้าสู่ระบบก่อนดำเนินการต่อ        # AC05-02
# ข้อความบนปุ่มการ์ด ใช้ ${State_InCart} / ${State_Unavailable} จาก variables.robot (อยู่ในตะกร้าแล้ว / ไม่พร้อมให้เช่า)
${POPUP_TIMEOUT}      10s

# ---------- ชื่ออุปกรณ์บนการ์ด : การ์ดใบแรกที่ยังกดเพิ่มได้ และรายการแรกในกล่องตะกร้า ----------
${Card_AddableName}   xpath=(//button[contains(.,'เพิ่มในตะกร้า')]/ancestor::div[.//h3][1]//h3)[1]
${Cart_ItemName}      xpath=(//button[@title='ลบออกจากตะกร้า']/ancestor::div[.//h3][1]//h3)[1]

# ---------- บัญชีคงที่ : ผู้ใช้สร้างไว้ล่วงหน้าในระบบจริงแล้ว (บัญชีเดียวกับ Usecase_Login_farmer) ----------
${LOGIN_USERNAME}     somchaikaew
${LOGIN_PASSWORD}     Somc1442!

# ---------- อุปกรณ์ที่ใช้ทดสอบ : ต้องมีอยู่จริงในระบบและสถานะตรงตามที่ระบุ ----------
${EQUIP_TYPE}         รถไถเดินตาม
${EQUIP_NAME}         รถไถเดินตาม
${UNAVAIL_TYPE}       เครื่องพ่นยาแบบสะพาย
${UNAVAIL_NAME}       เครื่องพ่นสารการเกษตร

# ---------- ตัวแปรระดับกรณีทดสอบ ใช้ส่งข้อมูลให้ teardown ----------
${TC_ID}             UNKNOWN
${ACTUAL_MESSAGE}    ${EMPTY}

*** Test Cases ***
TC03_F01 - ค้นหาอุปกรณ์แล้วเพิ่มลงตะกร้าสำเร็จ
    #Basic Flow : ค้นหาแล้วกดเพิ่มในตะกร้า ต้องได้ปุ่ม "อยู่ในตะกร้าแล้ว" และมี 1 รายการในตะกร้า
    Set Test Variable    ${TC_ID}    TC03_F01
    ${Data}=    สร้างข้อมูลทดสอบ    ${EQUIP_TYPE}    ${EQUIP_NAME}
    กรณี TC03_F01    ${Data}

TC03_F02 - เพิ่มอุปกรณ์รายการซ้ำ
    #Invalid : กดอุปกรณ์ชิ้นเดิมซ้ำครั้งที่สองต้องกดไม่ได้ และตะกร้าต้องเหลือเพียง 1 รายการ
    Set Test Variable    ${TC_ID}    TC03_F02
    ${Data}=    สร้างข้อมูลทดสอบ    ${EQUIP_TYPE}    ${EQUIP_NAME}
    กรณี TC03_F02    ${Data}

TC03_F03 - เพิ่มอุปกรณ์ที่ไม่พร้อมใช้งาน
    #TC03-AC03 : อุปกรณ์ไม่พร้อมใช้งาน ปุ่มต้องเป็น "ไม่พร้อมให้เช่า" และเพิ่มลงตะกร้าไม่ได้
    Set Test Variable    ${TC_ID}    TC03_F03
    ${Data}=    สร้างข้อมูลทดสอบ    ${UNAVAIL_TYPE}    ${UNAVAIL_NAME}
    กรณี TC03_F03    ${Data}

TC03_F04 - ล้างตะกร้าแล้วตะกร้าต้องว่าง
    #เพิ่มอุปกรณ์ 1 ชิ้น แล้วกดปุ่ม "ล้างตะกร้า" ตะกร้าต้องว่าง
    Set Test Variable    ${TC_ID}    TC03_F04
    ${Data}=    สร้างข้อมูลทดสอบ    ${EQUIP_TYPE}    ${EQUIP_NAME}
    กรณี TC03_F04    ${Data}

TC03_F05 - เพิ่มลงตะกร้าโดยยังไม่เข้าสู่ระบบ
    #ตรวจ Pre-Condition ของเอกสาร : ผู้ใช้ต้องเข้าสู่ระบบก่อนจึงจะเพิ่มลงตะกร้าได้
    Set Test Variable    ${TC_ID}    TC03_F05
    ${Data}=    สร้างข้อมูลทดสอบ    ${EQUIP_TYPE}    ${EQUIP_NAME}
    กรณี TC03_F05    ${Data}

TC03_F06 - ตะกร้าคงอยู่หลังรีเฟรชหน้า
    #ตะกร้าต้องคงอยู่หลังผู้ใช้รีเฟรชหน้า ไม่หายไปเมื่อโหลดหน้าใหม่
    Set Test Variable    ${TC_ID}    TC03_F06
    ${Data}=    สร้างข้อมูลทดสอบ    ${EQUIP_TYPE}    ${EQUIP_NAME}
    กรณี TC03_F06    ${Data}

TC03_F07 - เพิ่มหลายชิ้นแล้วลบทีละรายการ
    #เพิ่มอุปกรณ์ 2 ชิ้นลงตะกร้าแล้วลบทีละรายการจนว่าง (เว้นประเภท/ชื่อไว้เพื่อให้แสดงอุปกรณ์ทั้งหมด)
    Set Test Variable    ${TC_ID}    TC03_F07
    ${Data}=    สร้างข้อมูลทดสอบ    ${EMPTY}    ${EMPTY}
    กรณี TC03_F07    ${Data}

*** Keywords ***
# =====================================================================
# 1. เตรียมข้อมูลทดสอบ
# =====================================================================

สร้างข้อมูลทดสอบ
    #สร้าง Dictionary ข้อมูลสำหรับกรณีทดสอบ ใช้บัญชี login คงที่ร่วมกับประเภท/ชื่ออุปกรณ์ที่ระบุ
    [Arguments]    ${EquipmentType}    ${EquipmentName}
    ${Data}=    Create Dictionary
    ...    Username=${LOGIN_USERNAME}         Password=${LOGIN_PASSWORD}
    ...    EquipmentType=${EquipmentType}     EquipmentName=${EquipmentName}
    RETURN    ${Data}

# =====================================================================
# 2. กรณีทดสอบของยูสเคส (TC03_F01 - TC03_F07)
# =====================================================================

กรณี TC03_F01
    #Basic Flow: ค้นหาแล้วกดเพิ่มในตะกร้า ต้องได้ปุ่ม "อยู่ในตะกร้าแล้ว" และมี 1 รายการในตะกร้า
    [Arguments]    ${Data}

    เข้าสู่ระบบและไปหน้าค้นหาอุปกรณ์    ${Data}
    Clear Cart

    ${Cards}=      ค้นหาอุปกรณ์    ${Data}[EquipmentType]    ${Data}[EquipmentName]
    ${Summary}=    Get Found Count Text
    Should Be True    ${Cards} > 0
    ...    msg=ค้นหา "${Data}[EquipmentName]" แล้วไม่พบอุปกรณ์ จึงยังทดสอบการเพิ่มตะกร้าไม่ได้ (${Summary})

    # AC01-03 : จำชื่ออุปกรณ์บนการ์ดที่จะกด แล้วกดเพิ่ม ปุ่มต้องเป็น "อยู่ในตะกร้าแล้ว" ตะกร้ามี 1 รายการ และชื่อในตะกร้าต้องตรงกับการ์ด
    ${CardName}=    Get Text    ${Card_AddableName}
    ${Clicked}=     Click Add To Cart
    ${After}=       Get Equipment Button State
    ${Count}=       เปิดตะกร้าและนับรายการ
    ${CartName}=    อ่านชื่อรายการแรกในตะกร้า

    บันทึกผลที่ได้จริง    ${After}
    Log    การ์ด "${CardName}" ปุ่มหลังกด "${After}" ในตะกร้ามี ${Count} รายการ ชื่อ "${CartName}"    level=INFO

    Should Be True    ${Clicked}    msg=ปุ่มเพิ่มในตะกร้าถูกปิดใช้งาน จึงเพิ่มอุปกรณ์ลงตะกร้าไม่ได้
    เทียบผลจริงกับที่คาดหวัง       ${After}       ${State_InCart}
    Should Be Equal As Integers    ${Count}       ${1}
    ...    msg=กดเพิ่มในตะกร้า 1 ครั้ง แต่ในตะกร้ามี ${Count} รายการ
    เทียบผลจริงกับที่คาดหวัง       ${CartName}    ${CardName}

กรณี TC03_F02
    #Invalid: กดอุปกรณ์ชิ้นเดิมซ้ำครั้งที่สองต้องกดไม่ได้ ตะกร้าต้องเหลือเพียง 1 รายการ
    [Arguments]    ${Data}

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
    # AC02-02 : ครั้งแรกปุ่มต้องเปลี่ยนเป็น "อยู่ในตะกร้าแล้ว"
    เทียบผลจริงกับที่คาดหวัง    ${AfterFirst}    ${State_InCart}

    # ---------- ครั้งที่ 2 : ลองกดทั้งปุ่มเดิมและปุ่มที่เปลี่ยนข้อความแล้ว ต้องกดไม่ได้ทั้งสองทาง ----------
    ${Second}=    Click Add To Cart
    ${Retry}=     Click Button If Enabled    ${Btn_InCart} >> nth=0
    ${State}=     Get Equipment Button State

    ${Count}=    เปิดตะกร้าและนับรายการ

    # ระบบกันการเพิ่มซ้ำด้วยการเปลี่ยนสถานะปุ่ม จึงบันทึกข้อความบนปุ่มเป็นผลที่ได้จริง
    บันทึกผลที่ได้จริง    ${State}
    Log    ปุ่มหลังเพิ่มครั้งแรก "${AfterFirst}" หลังพยายามกดซ้ำ "${State}" และในตะกร้ามี ${Count} รายการ
    ...    level=INFO

    Should Not Be True    ${Second}
    ...    msg=ระบบยังให้กดปุ่ม "${State_AddToCart}" ของอุปกรณ์ที่อยู่ในตะกร้าแล้วได้
    Should Not Be True    ${Retry}
    ...    msg=ปุ่ม "${State_InCart}" ยังกดได้ ทั้งที่ควรถูกปิดใช้งาน
    เทียบผลจริงกับที่คาดหวัง    ${State}    ${State_InCart}
    Should Be Equal As Integers    ${Count}    ${1}
    ...    msg=กดเพิ่มอุปกรณ์ชิ้นเดิมซ้ำแล้วในตะกร้ามี ${Count} รายการ ทั้งที่ควรมีเพียง 1 รายการ

กรณี TC03_F03
    #AC03-02 : อุปกรณ์ไม่พร้อมใช้งาน ปุ่มบนการ์ดต้องเป็น "ไม่พร้อมให้เช่า" กดไม่ได้ และตะกร้าต้องว่าง
    [Arguments]    ${Data}

    เข้าสู่ระบบและไปหน้าค้นหาอุปกรณ์    ${Data}
    Clear Cart

    ${Cards}=      ค้นหาอุปกรณ์    ${Data}[EquipmentType]    ${Data}[EquipmentName]
    ${Summary}=    Get Found Count Text
    Should Be True    ${Cards} > 0
    ...    msg=ค้นหา "${Data}[EquipmentName]" แล้วไม่พบอุปกรณ์ จึงตรวจปุ่มสถานะไม่ได้ (${Summary})

    ${State}=      Get Equipment Button State
    ${Clicked}=    Click Button If Enabled    ${Card_EQButtons} >> nth=0
    ${Count}=      เปิดตะกร้าและนับรายการ

    บันทึกผลที่ได้จริง    ${State}
    Log    ปุ่มบนการ์ด "${State}" กดได้ = ${Clicked} และในตะกร้ามี ${Count} รายการ    level=INFO

    เทียบผลจริงกับที่คาดหวัง    ${State}    ${State_Unavailable}
    Should Not Be True    ${Clicked}    msg=ปุ่ม "${State}" ของอุปกรณ์ที่ไม่พร้อมใช้งานยังกดได้
    Should Be Equal As Integers    ${Count}    ${0}
    ...    msg=ระบบเพิ่มอุปกรณ์ที่ไม่พร้อมใช้งานลงตะกร้าได้ ทั้งที่ไม่ควรอนุญาต

กรณี TC03_F04
    #TC05 Add cart (Click clear cart / Verify empty cart): เพิ่ม 1 ชิ้นแล้วล้างตะกร้า ต้องว่าง
    [Arguments]    ${Data}

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
    Should Be Equal As Integers    ${Before}    ${1}
    ...    msg=ก่อนล้างตะกร้าควรมี 1 รายการ แต่พบ ${Before} รายการ

    ${Cleared}=     Click Clear Cart Button
    ${After}=       Get Cart Item Count
    ${CartText}=    Get Cart Text
    Close Cart

    บันทึกผลที่ได้จริง    ก่อนล้างมี ${Before} รายการ หลังล้างเหลือ ${After} รายการ
    Log    ข้อความในกล่องตะกร้าหลังล้าง : ${CartText}    level=INFO

    Should Be True    ${Cleared}
    ...    msg=ปุ่ม "ล้างตะกร้า" ถูกปิดใช้งานหรือกดไม่ได้
    Should Be Equal As Integers    ${After}    ${0}
    ...    msg=กดล้างตะกร้าแล้วยังเหลือ ${After} รายการ ทั้งที่ตะกร้าควรว่าง

กรณี TC03_F05
    #AC05-02 : ยังไม่เข้าสู่ระบบแล้วกดเพิ่มในตะกร้า ระบบต้องไม่ให้เพิ่ม และขึ้น popup "โปรดเข้าสู่ระบบก่อนดำเนินการต่อ"
    [Arguments]    ${Data}

    เปิดหน้าค้นหาอุปกรณ์โดยไม่เข้าสู่ระบบ

    ${Cards}=    ค้นหาอุปกรณ์    ${Data}[EquipmentType]    ${Data}[EquipmentName]
    Should Be True    ${Cards} > 0
    ...    msg=ค้นหา "${Data}[EquipmentName]" แล้วไม่พบอุปกรณ์ จึงยังทดสอบการกันผู้ใช้ที่ยังไม่เข้าสู่ระบบไม่ได้

    Click Add To Cart
    # popup คลุมทั้งหน้าจอ จึงอ่านหัวข้อ popup แทนการเปิดตะกร้า (กดปุ่มตะกร้าจะโดนบังจนรอ timeout)
    ${HasPopup}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Popup_Title}    visible    ${POPUP_TIMEOUT}
    ${Message}=    Set Variable    ${EMPTY}
    IF    ${HasPopup}
        ${Message}=    Get Popup Title
    END
    บันทึกผลที่ได้จริง    ${Message}
    เทียบผลจริงกับที่คาดหวัง    ${Message}    ${EXP_LOGIN_REQUIRED}

กรณี TC03_F06
    #ตะกร้าต้องคงอยู่หลังผู้ใช้รีเฟรชหน้า ไม่หายไปเมื่อโหลดหน้าใหม่
    [Arguments]    ${Data}

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
    Should Be Equal As Integers    ${Before}    ${1}
    ...    msg=ก่อนรีเฟรชควรมี 1 รายการ แต่พบ ${Before} รายการ

    # ---------- รีเฟรชหน้า แล้วดูว่าตะกร้ายังอยู่ไหม ----------
    Reload
    Wait For Elements State    ${Btn_OpenCart}    visible    ${DEFAULT_TIMEOUT}

    ${After}=       เปิดตะกร้าและนับรายการ
    ${CartText}=    Get Cart Text
    Close Cart

    บันทึกผลที่ได้จริง    ก่อนรีเฟรชมี ${Before} รายการ หลังรีเฟรชมี ${After} รายการ
    Log    ข้อความในกล่องตะกร้าหลังรีเฟรช : ${CartText}    level=INFO

    Should Be Equal As Integers    ${After}    ${Before}
    ...    msg=รีเฟรชหน้าแล้วรายการในตะกร้าเปลี่ยนจาก ${Before} เป็น ${After} รายการ

กรณี TC03_F07
    #เพิ่มอุปกรณ์ 2 ชิ้นลงตะกร้าแล้วลบทีละรายการจนว่าง (เว้นประเภท/ชื่อไว้เพื่อให้แสดงอุปกรณ์ทั้งหมด)
    [Arguments]    ${Data}

    เข้าสู่ระบบและไปหน้าค้นหาอุปกรณ์    ${Data}
    Clear Cart

    ค้นหาอุปกรณ์    ${Data}[EquipmentType]    ${Data}[EquipmentName]
    ${Available}=    Get Available Equipment Count
    Should Be True    ${Available} >= 2
    ...    msg=มีอุปกรณ์ที่เพิ่มลงตะกร้าได้เพียง ${Available} ชิ้น จึงยังทดสอบการเพิ่มหลายชิ้นไม่ได้

    # กดเพิ่ม 2 ครั้ง ชิ้นแรกเปลี่ยนเป็น "อยู่ในตะกร้าแล้ว" ครั้งที่สองจึงไปตกที่อุปกรณ์ชิ้นถัดไปเอง
    ${First}=     Click Add To Cart
    ${Second}=    Click Add To Cart
    Should Be True    ${First} and ${Second}
    ...    msg=เพิ่มอุปกรณ์ไม่ครบ 2 ชิ้น (ชิ้นแรก ${First} ชิ้นที่สอง ${Second})

    ${Added}=    เปิดตะกร้าและนับรายการ

    # ---------- ลบทีละรายการ โดยเปิดกล่องตะกร้าค้างไว้ ----------
    Remove First Cart Item
    ${AfterFirstRemove}=    Get Cart Item Count
    Remove First Cart Item
    ${AfterSecondRemove}=    Get Cart Item Count
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
# 3. ขั้นตอนย่อยของยูสเคส
# =====================================================================

เข้าสู่ระบบและไปหน้าค้นหาอุปกรณ์
    #ยูสเคสนี้ต้องเข้าสู่ระบบก่อน จึงเข้าสู่ระบบแล้วกดเข้าหน้าค้นหาอุปกรณ์
    [Arguments]    ${Data}

    Run Keyword And Ignore Error    Close Test Context
    Open Login Page

    # เผื่อหน้าเว็บเรียก confirm ของเบราว์เซอร์ ถ้าไม่ตอบไว้ก่อนสคริปต์จะค้างรอจนหมดเวลา
    Run Keyword And Ignore Error    Handle Future Dialogs    action=accept

    Input Username    ${Data}[Username]
    Input Password    ${Data}[Password]
    Keyboard Key      press    Tab

    ${Clicked}=    Click Button If Enabled    ${Btn_Login}
    Should Be True    ${Clicked}    msg=ปุ่มเข้าสู่ระบบถูกปิดใช้งาน

    # AC01-01 : หัวข้อ popup ต้องเป็น "เข้าสู่ระบบสำเร็จ"
    ${HasPopup}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Popup_Title}    visible    ${POPUP_TIMEOUT}
    ${Message}=    Set Variable    ${EMPTY}
    IF    ${HasPopup}
        ${Message}=    Get Popup Title
    END
    บันทึกผลที่ได้จริง    ${Message}
    เทียบผลจริงกับที่คาดหวัง    ${Message}    ${EXP_LOGIN_SUCCESS}

    Close Login Popup
    Open Search Equipment Page

เปิดหน้าค้นหาอุปกรณ์โดยไม่เข้าสู่ระบบ
    #เปิด context ใหม่ที่ยังไม่ได้เข้าสู่ระบบ แล้วเข้าหน้าค้นหาอุปกรณ์จากหน้าแรกของเว็บ
    Run Keyword And Ignore Error    Close Test Context

    New Context
    New Page             ${Base_URL}
    Set Viewport Size    ${VIEWPORT_WIDTH}    ${VIEWPORT_HEIGHT}

    # เผื่อหน้าเว็บเรียก confirm ของเบราว์เซอร์ ถ้าไม่ตอบไว้ก่อนสคริปต์จะค้างรอจนหมดเวลา
    Run Keyword And Ignore Error    Handle Future Dialogs    action=accept

    ${Opened}=    Run Keyword And Return Status    Open Search Equipment Page
    Should Be True    ${Opened}
    ...    msg=เข้าหน้าค้นหาอุปกรณ์โดยไม่เข้าสู่ระบบไม่ได้ ระบบอาจบังคับให้เข้าสู่ระบบก่อนตั้งแต่หน้าแรก

ค้นหาอุปกรณ์
    #เลือกประเภทอุปกรณ์ (ถ้าระบุมา) แล้วพิมพ์ชื่ออุปกรณ์ลงช่องค้นหา คืนจำนวนการ์ดที่พบ
    [Arguments]    ${Type}    ${Name}
    Select Equipment Type    ${Type}
    Input Search Equipment    ${Name}

    ${Cards}=      Get Equipment Card Count
    ${Summary}=    Get Found Count Text
    Log    ค้นหา "${Name}" แล้วพบ ${Cards} รายการ (${Summary})    level=INFO
    RETURN    ${Cards}

เปิดตะกร้าและนับรายการ
    #เปิดกล่องตะกร้าแล้วนับรายการข้างใน ถ้าเปิดไม่ได้ถือว่าตะกร้าว่าง
    ${Opened}=    Open Cart
    IF    not ${Opened}
        Log    เปิดกล่องตะกร้าไม่ได้ ถือว่าไม่มีรายการในตะกร้า    level=INFO
        RETURN    ${0}
    END
    ${Count}=    Get Cart Item Count
    RETURN    ${Count}

# =====================================================================
# 4. คีย์เวิร์ดช่วยเหลือ : บันทึกผล ตรวจผล และเก็บหลักฐาน
# =====================================================================

อ่านชื่อรายการแรกในตะกร้า
    #อ่านชื่ออุปกรณ์ของรายการแรกในกล่องตะกร้า (ต้องเปิดกล่องไว้ก่อน) ไม่มีรายการคืนค่าว่าง
    ${Found}=    Is Element Visible    ${Cart_ItemName}
    IF    not ${Found}    RETURN    ${EMPTY}
    ${Name}=    Get Text    ${Cart_ItemName}
    RETURN    ${Name}

*** Settings ***
Library           Browser
Library           Collections
Library           String
Resource          variables.robot


*** Keywords ***
#-------------------------------------------------------------------------
# Login Farmer
Open Login Page
    [Documentation]    เปิด context และหน้าเข้าสู่ระบบใหม่ (ต้องเรียก Open Test Browser ก่อน)
    New Context
    New Page                   ${Login_farmerURL}
    Set Viewport Size          ${VIEWPORT_WIDTH}    ${VIEWPORT_HEIGHT}
    Wait For Elements State    ${Text_Username}    visible    ${DEFAULT_TIMEOUT}

Input Username
    [Arguments]    ${Username}
    Fill Text    ${Text_Username}    ${Username}

Input Password
    [Arguments]    ${Password}
    Fill Text    ${Text_Password}    ${Password}

Click Verify Button
    Click    ${Btn_Verify}

#-------------------------------------------------------------------------
# คีย์เวิร์ดช่วยเหลือทั่วไป
Open Test Browser
    [Documentation]    เปิด browser process เดียวต่อชุดทดสอบ แล้วใช้ context ใหม่ในแต่ละกรณีทดสอบ
    New Browser            ${browser}    headless=${headless}
    Set Browser Timeout    ${DEFAULT_TIMEOUT}
    # ปิดภาพหน้าจออัตโนมัติ เพราะสคริปต์ถ่ายเองเมื่อเคสไม่ผ่าน และเคสที่ตั้งใจให้ล้มจะได้ภาพเปล่า ๆ ทั้งรันช้าลง
    Register Keyword To Run On Failure    None

Close Test Context
    [Documentation]    ปิด context ของกรณีทดสอบที่เพิ่งจบ ให้กรณีถัดไปเริ่มจากสถานะสะอาด
    Close Context

Close All Test Browsers
    [Documentation]    ปิดเบราว์เซอร์ทั้งหมดตอนจบชุดทดสอบ
    Close Browser    ALL

Is Element Visible
    [Documentation]    ตรวจว่า element แสดงอยู่ไหม ลด timeout ชั่วคราวไม่ให้รอครบ 30 วินาทีตอนไม่พบ
    [Arguments]    ${Selector}
    Set Browser Timeout    ${SHORT_TIMEOUT}
    ${Visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Selector}    visible
    Set Browser Timeout    ${DEFAULT_TIMEOUT}
    RETURN    ${Visible}

Click Button If Enabled
    [Documentation]    กดปุ่มเมื่อไม่ถูก disable คืน True เมื่อกดได้ (ลด timeout ไม่ให้รอครบ 30 วินาที)
    [Arguments]    ${Selector}
    Set Browser Timeout    ${SHORT_TIMEOUT}
    ${Enabled}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Selector}    enabled
    Set Browser Timeout    ${DEFAULT_TIMEOUT}

    IF    ${Enabled}
        Click    ${Selector}
    ELSE
        Log    ปุ่มถูกปิดใช้งานอยู่ (ข้อมูลยังไม่ผ่านการตรวจสอบ) จึงไม่กดปุ่ม    level=INFO
    END
    RETURN    ${Enabled}

#-------------------------------------------------------------------------
# Register Farmer
# page1
Open Register Page
    New Context
    New Page                   ${Register_farmerURL}
    Set Viewport Size          ${VIEWPORT_WIDTH}    ${VIEWPORT_HEIGHT}
    Wait For Elements State    ${Text_RUsername}    visible    ${DEFAULT_TIMEOUT}

Upload Picture
    [Arguments]    ${Picture}
    IF    '${Picture}' != '${EMPTY}'
        Upload File By Selector    ${Img}    ${TestDataDir}/${Picture}
    END

Input UsernameR
    [Arguments]    ${UsernameR}
    Fill Text    ${Text_RUsername}    ${UsernameR}

Input Email
    [Arguments]    ${Email}
    Fill Text    ${Text_REmail}    ${Email}

Input PasswordR
    [Arguments]    ${PasswordR}
    Fill Text    ${Text_RPassword}    ${PasswordR}

Input Confirmpassword
    [Arguments]    ${Confirmpassword}
    Fill Text    ${Text_RConfirmPassword}    ${Confirmpassword}

Click Next Button
    [Documentation]    กดปุ่ม "ถัดไป" คืน True เมื่อกดได้ / False เมื่อปุ่มถูกปิดใช้งาน
    ${Clicked}=    Click Button If Enabled    ${Btn_Next}
    RETURN    ${Clicked}

# page2
Click Register Button
    [Documentation]    กดปุ่ม "สมัครสมาชิก" คืน True เมื่อกดได้ / False เมื่อปุ่มถูกปิดใช้งาน
    ${Clicked}=    Click Button If Enabled    ${Btn_Register}
    RETURN    ${Clicked}

Click Back Button
    [Documentation]    กดปุ่ม "ย้อนกลับ" เพื่อกลับไปขั้นตอนที่ 1
    Click    ${Btn_Back}

Is Register Step2 Displayed
    [Documentation]    ตรวจว่าถึงหน้าที่ 2 (ข้อมูลส่วนตัว) หรือยัง ดูจากช่อง "ชื่อจริง"
    ${Displayed}=    Is Element Visible    ${Text_Name}
    RETURN    ${Displayed}

Input Firstname
    [Arguments]    ${Firstname}
    Fill Text    ${Text_Name}    ${Firstname}

Input Surname
    [Arguments]    ${Surname}
    Fill Text    ${Text_LName}    ${Surname}

Select Gender
    [Arguments]    ${Gender}
    IF    '${Gender}' == 'ชาย'
        Select Options By    ${Select_Gender}    value    male
    ELSE IF    '${Gender}' == 'หญิง'
        Select Options By    ${Select_Gender}    value    female
    ELSE
        # ไม่เลือกเพศ : ต้องเข้าช่องแล้วออกเอง ระบบจึงเตือน (select ไม่ถูกแตะอัตโนมัติเหมือน Fill Text)
        Focus    ${Select_Gender}
        Focus    ${Text_Phone}
    END

Input Birthdate
    [Arguments]    ${Daybirth}    ${Monthbirth}    ${Yearbirth}
    # กรอกทุกช่องแม้ค่าว่างเพื่อให้ระบบเตือน ปีในไฟล์ทดสอบเป็น พ.ศ. อยู่แล้วจึงกรอกตรง ๆ
    Fill Text    ${Date_Birth}    ${Daybirth}
    Fill Text    ${Date_Month}    ${Monthbirth}
    Fill Text    ${Date_Year}     ${Yearbirth}

Input Tel
    [Arguments]    ${Tel}
    Fill Text    ${Text_Phone}    ${Tel}

Input Hnum
    [Arguments]    ${Hnum}
    Fill Text    ${Text_Num}    ${Hnum}

Input Alley
    [Arguments]    ${Alley}
    Fill Text    ${Text_Alley}    ${Alley}

Input Group
    [Arguments]    ${Group}
    Fill Text    ${Text_Moo}    ${Group}

Input District
    [Arguments]    ${District}
    Fill Text    ${Text_Subdistric}    ${District}

Input Canton
    [Arguments]    ${Canton}
    Fill Text    ${Text_Distric}    ${Canton}

Input Province
    [Arguments]    ${province}
    Fill Text    ${Text_Province}    ${province}

Input Postcode
    [Arguments]    ${Postcode}
    Fill Text    ${Text_Postcode}    ${Postcode}

Get Validation Messages
    [Documentation]    คืน list ข้อความแจ้งเตือน (ไม่มีก็คืน list ว่าง) ลด timeout ชั่วคราวไม่ให้รอครบ 30 วินาทีตอนไม่พบ
    ${Messages}=    Create List

    Set Browser Timeout    ${SHORT_TIMEOUT}
    ${Status}    ${Elements}=    Run Keyword And Ignore Error    Get Elements    ${Error_Message}
    Set Browser Timeout    ${DEFAULT_TIMEOUT}

    IF    '${Status}' == 'FAIL'    RETURN    ${Messages}

    FOR    ${Element}    IN    @{Elements}
        ${Text}=    Get Text        ${Element}
        ${Text}=    Strip String    ${Text}

        # locator อาจจับได้ทั้ง element แม่และลูกที่ข้อความเดียวกัน จึงกรองข้อความซ้ำออก
        ${IsDuplicate}=    Evaluate    $Text in $Messages
        # เทียบด้วยความยาว ไม่เอาข้อความไปแทรกใน expression เพราะข้อความที่ขึ้นบรรทัดใหม่จะทำให้ IF พัง
        ${Length}=    Get Length    ${Text}
        IF    ${Length} > 0 and not ${IsDuplicate}
            Append To List    ${Messages}    ${Text}
        END
    END
    RETURN    ${Messages}

#-------------------------------------------------------------------------
# Add Cart Farmer : ไม่มีการกรอกฟอร์ม เป็นคีย์เวิร์ด "ค้นหา - กดปุ่ม - ดูตะกร้า" ล้วน ๆ
Close Login Popup
    [Documentation]    ปิด popup เข้าสู่ระบบสำเร็จ ระบบจะพาเข้าหน้าหลักเมื่อกด "ตกลง" เท่านั้น
    ${HasButton}=    Is Element Visible    ${Btn_Verify}
    IF    ${HasButton}    Run Keyword And Ignore Error    Click Verify Button

Open Search Equipment Page
    [Documentation]    เข้าหน้าค้นหาอุปกรณ์ (ต้องล็อกอินก่อน) ไม่พบปุ่มบนหน้าหลักใช้เมนูบนหัวเว็บแทน เผื่อหน้าหลักถูกปรับดีไซน์
    ${Found}=    Is Element Visible    ${Link_SearchEQ}
    IF    ${Found}
        Click    ${Link_SearchEQ}
    ELSE
        Log    ไม่พบปุ่มเข้าหน้าค้นหาบนหน้าหลัก จึงกดเมนูบนหัวเว็บแทน    level=WARN
        Wait For Elements State    ${Link_SearchEQMenu}    visible    ${DEFAULT_TIMEOUT}
        Click                      ${Link_SearchEQMenu}
    END
    Wait For Elements State    ${Text_SearchEQ}     visible    ${DEFAULT_TIMEOUT}

Select Equipment Type
    [Documentation]    เลือกประเภทอุปกรณ์จาก dropdown คืน True เมื่อกรองด้วยประเภทที่ระบุจริง ๆ
    ...
    ...                หน้าค้นหากรองด้วยประเภท "และ" ชื่ออุปกรณ์พร้อมกัน ถ้า dropdown ค้างอยู่ที่ประเภทอื่น
    ...                อุปกรณ์ที่พิมพ์ค้นหาจะไม่ขึ้นบนหน้าจอเลย ค่าว่างจึงไม่ได้แปลว่า "ไม่ต้องแตะ dropdown"
    ...                แต่แปลว่าให้เลือกตัวเลือกที่หมายถึงทุกประเภท เพื่อล้างตัวกรองของรอบก่อนออกก่อนค้นหา
    ...
    ...                หาประเภทที่ระบุไม่เจอจะเตือนใน log แทนการล้ม เพราะกรณีทดสอบสนใจผลการค้นหาไม่ใช่ตัวกรอง
    [Arguments]    ${Type}

    ${Ok}    ${Options}=    Run Keyword And Ignore Error    Get Select Options    ${Select_EQType}
    IF    '${Ok}' == 'FAIL'
        Log    ไม่พบ dropdown ประเภทอุปกรณ์ จึงข้ามการเลือกประเภท    level=WARN
        RETURN    ${False}
    END

    ${Labels}=    Evaluate    [str(o.get("label", "")).strip() for o in $Options]

    IF    '${Type}' == '${EMPTY}'
        ล้างตัวกรองประเภทอุปกรณ์    ${Labels}
        RETURN    ${False}
    END

    # lambda รับค่าผ่าน default argument เพราะ RF มองไม่เห็น $ตัวแปร ในเงื่อนไขของ comprehension
    ${Matched}=    Evaluate    next(filter(lambda l, t=$Type: l == t or t in l, $Labels), "")

    IF    '${Matched}' == '${EMPTY}'
        Log    ไม่มีประเภท "${Type}" ใน dropdown (มี ${Labels}) จึงล้างตัวกรองแล้วค้นหาจากชื่ออุปกรณ์อย่างเดียว    level=WARN
        ล้างตัวกรองประเภทอุปกรณ์    ${Labels}
        RETURN    ${False}
    END

    Select Options By    ${Select_EQType}    label    ${Matched}
    RETURN    ${True}

ล้างตัวกรองประเภทอุปกรณ์
    [Documentation]    เลือกตัวเลือกที่หมายถึง "ทุกประเภท" ใน dropdown เพื่อไม่ให้ตัวกรองบังผลการค้นหา
    ...                ไม่มีตัวเลือกแบบนั้นก็ปล่อยไว้ตามค่าเริ่มต้นของหน้า แล้วบันทึกไว้ใน log
    [Arguments]    ${Labels}
    ${All}=    Evaluate    next((l for l in $Labels if "ทั้งหมด" in l or "ทุกประเภท" in l or l == ""), None)

    IF    $All is None
        Log    ไม่มีตัวเลือก "ทุกประเภท" ใน dropdown (มี ${Labels}) จึงปล่อยตัวกรองไว้ตามค่าเริ่มต้น    level=INFO
        RETURN    ${False}
    END

    Select Options By    ${Select_EQType}    label    ${All}
    RETURN    ${True}

Input Search Equipment
    [Documentation]    พิมพ์ชื่ออุปกรณ์ลงช่องค้นหา แล้วรอให้รายการอัปเดตตามคำค้น
    [Arguments]    ${Keyword}
    Fill Text    ${Text_SearchEQ}    ${Keyword}
    # หน้าเว็บกรองรายการหลังหยุดพิมพ์ จึงต้องรอสั้น ๆ ก่อนนับผล
    Sleep    1s

Get Equipment Card Count
    [Documentation]    นับการ์ดอุปกรณ์ ต้องรอการ์ดใบแรกก่อน เพราะ Get Element Count ไม่รอ element จะได้ 0 ถ้าหน้ายังวาดไม่เสร็จ
    ${Found}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Card_EQButtons} >> nth=0    visible    ${CARD_TIMEOUT}
    IF    not ${Found}    RETURN    ${0}

    ${Count}=    Get Element Count    ${Card_EQButtons}
    RETURN    ${Count}

Get Found Count Text
    [Documentation]    อ่านข้อความสรุปผลการค้นหา เช่น "พบอุปกรณ์ทั้งหมด 1 รายการ" ใช้บันทึกลง ActualResult
    ${Found}=    Is Element Visible    ${Text_FoundCount}
    IF    not ${Found}    RETURN    ไม่พบข้อความสรุปผลการค้นหา
    ${Text}=    Get Text        ${Text_FoundCount}
    ${Text}=    Strip String    ${Text}
    RETURN    ${Text}

Get Popup Title
    [Documentation]    อ่านหัวข้อบนกล่องแจ้งเตือน SweetAlert2 ที่ระบบขึ้นมา ถ้าไม่มี popup คืนข้อความว่าง
    ${Found}=    Is Element Visible    ${Popup_Title}
    IF    not ${Found}    RETURN    ${EMPTY}

    ${Text}=    Get Text        ${Popup_Title}
    ${Text}=    Strip String    ${Text}
    RETURN    ${Text}

Get Equipment Button State
    [Documentation]    อ่านข้อความบนปุ่มการ์ดใบแรก (3 สถานะ: เพิ่มในตะกร้า / อยู่ในตะกร้าแล้ว / ไม่พร้อมให้เช่า) ไม่ตรงสถานะใดเลยคืนข้อความดิบ
    ${Found}=    Is Element Visible    ${Card_EQButtons} >> nth=0
    IF    not ${Found}    RETURN    ${EMPTY}

    ${Raw}=    Get Text        ${Card_EQButtons} >> nth=0
    ${Raw}=    Strip String    ${Raw}
    # ปุ่มมีไอคอนนำหน้า จึงมีช่องว่าง/ขึ้นบรรทัดใหม่ติดมาด้วย
    ${Raw}=    Evaluate    " ".join($Raw.split())

    # lambda รับค่าผ่าน default argument เพราะ RF มองไม่เห็น $ตัวแปร ที่อยู่ในเงื่อนไข
    ${State}=    Evaluate    next(filter(lambda s, t=$Raw: s in t, $EQ_BUTTON_STATES), $Raw)
    RETURN    ${State}

Click Add To Cart
    [Documentation]    กดปุ่ม "เพิ่มในตะกร้า" ของการ์ดใบแรก คืน True เมื่อกดได้
    ${Clicked}=    Click Button If Enabled    ${Btn_AddToCart} >> nth=0
    IF    ${Clicked}    Sleep    0.5s
    RETURN    ${Clicked}

Open Cart
    [Documentation]    กดปุ่มตะกร้ามุมขวาล่าง คืน True เมื่อกล่องเปิดขึ้นจริง
    ${HasButton}=    Is Element Visible    ${Btn_OpenCart}
    IF    not ${HasButton}    RETURN    ${False}

    Click    ${Btn_OpenCart}
    ${Opened}=    Is Element Visible    ${Cart_Modal}
    RETURN    ${Opened}

Close Cart
    [Documentation]    ปิดกล่องตะกร้า ใช้ Ignore Error เพราะบางกรณีกล่องไม่ได้เปิดอยู่
    Run Keyword And Ignore Error    Click    ${Btn_CloseCart}

Get Cart Item Count
    [Documentation]    นับรายการในตะกร้าจากปุ่มถังขยะ (หนึ่งรายการหนึ่งปุ่ม) ต้องเปิดกล่องไว้ก่อน
    ${Count}=    Get Element Count    ${Btn_RemoveFromCart}
    RETURN    ${Count}

Get Available Equipment Count
    [Documentation]    นับอุปกรณ์ที่ยังกด "เพิ่มในตะกร้า" ได้ ไม่นับชิ้นที่อยู่ในตะกร้าแล้วหรือไม่พร้อมให้เช่า
    ${Found}=    Is Element Visible    ${Btn_AddToCart} >> nth=0
    IF    not ${Found}    RETURN    ${0}
    ${Count}=    Get Element Count    ${Btn_AddToCart}
    RETURN    ${Count}

Remove First Cart Item
    [Documentation]    กดถังขยะของรายการแรกในตะกร้า ต้องเปิดกล่องตะกร้าไว้ก่อน คืน True เมื่อกดได้
    ${Clicked}=    Click Button If Enabled    ${Btn_RemoveFromCart} >> nth=0
    IF    ${Clicked}    Sleep    0.3s
    RETURN    ${Clicked}

Click Clear Cart Button
    [Documentation]    กดปุ่ม "ล้างตะกร้า" ในกล่องตะกร้า ต้องเปิดกล่องไว้ก่อน คืน True เมื่อกดได้
    ...                ตอบกล่องยืนยันของเบราว์เซอร์ไว้ล่วงหน้า เผื่อหน้าเว็บเรียก confirm ก่อนล้าง
    Run Keyword And Ignore Error    Handle Future Dialogs    action=accept
    ${Clicked}=    Click Button If Enabled    ${Btn_ClearCart}
    IF    ${Clicked}    Sleep    0.5s
    RETURN    ${Clicked}

Get Cart Text
    [Documentation]    อ่านข้อความในกล่องตะกร้า (ไม่อ่านทั้งหน้า เพราะการ์ดใต้กล่องมีชื่ออุปกรณ์เดียวกัน)
    ${Opened}=    Is Element Visible    ${Cart_Modal}
    IF    not ${Opened}    RETURN    ${EMPTY}
    ${Text}=    Get Text    ${Cart_Modal}
    RETURN    ${Text}

Clear Cart
    [Documentation]    ล้างตะกร้าให้ทุกเคสเริ่มจากว่าง ลบทีละรายการ ไม่ใช้ปุ่ม "ล้างตะกร้า" เพราะอาจมีกล่องยืนยันของเบราว์เซอร์ทำให้ค้าง
    ${Opened}=    Open Cart
    IF    not ${Opened}
        Log    เปิดกล่องตะกร้าไม่ได้ ถือว่าตะกร้าว่างอยู่แล้ว    level=INFO
        RETURN    ${0}
    END

    ${Removed}=    Set Variable    ${0}
    FOR    ${Round}    IN RANGE    20
        ${Count}=    Get Cart Item Count
        IF    ${Count} == 0    BREAK
        Click      ${Btn_RemoveFromCart} >> nth=0
        Sleep      0.3s
        ${Removed}=    Evaluate    ${Removed} + 1
    END

    Close Cart
    Log    ล้างของเดิมออกจากตะกร้า ${Removed} รายการ    level=INFO
    RETURN    ${Removed}

#-------------------------------------------------------------------------
# Booking Equipment Farmer : ฟอร์มจองอยู่ในกล่องตะกร้า ต้องเปิดกล่องไว้ก่อนจึงจะกรอกได้
Is Booking Form Displayed
    [Documentation]    ตรวจว่ากล่องตะกร้าแสดงฟอร์มจองแล้วหรือยัง ดูจากช่องวันที่เริ่มเช่า
    ${Displayed}=    Is Element Visible    ${Text_StartDate}
    RETURN    ${Displayed}

Get Calendar Month
    [Documentation]    อ่านหัวปฏิทิน (เช่น "สิงหาคม 2026") คืนเลขเดือนรวมปี (ปี*12+เดือน) ไว้เทียบกับเป้าหมาย
    ...                คืน 0 เมื่ออ่านหัวปฏิทินไม่ได้ ให้ผู้เรียกตัดสินใจเองว่าจะเลิกเลื่อน
    ${Header}=    Get Text        ${Cal_Header}
    ${Header}=    Strip String    ${Header}

    ${Parts}=    Split String    ${Header}
    ${Count}=    Get Length      ${Parts}
    IF    ${Count} < 2
        Log    อ่านหัวปฏิทินไม่ได้ (ได้ "${Header}")    level=WARN
        RETURN    ${0}
    END

    ${Month}=    Get From Dictionary    ${THAI_MONTHS}    ${Parts}[0]    default=${0}
    IF    ${Month} == 0
        Log    ไม่รู้จักชื่อเดือน "${Parts}[0]" บนหัวปฏิทิน    level=WARN
        RETURN    ${0}
    END

    ${Year}=    เทียบปีให้เป็น ค.ศ.    ${Parts}[1]
    ${Index}=   Evaluate    ${Year} * 12 + ${Month}
    RETURN    ${Index}

เทียบปีให้เป็น ค.ศ.
    [Documentation]    ทำให้ปีที่อ่านมาอยู่ในระบบเดียวกันก่อนนำไปเทียบ ปีที่มากกว่า 2400 ถือว่าเป็น พ.ศ.
    ...                เป็นจุดเดียวในโปรเจกต์ที่มีการบวกลบปี ที่อื่นใช้ค่าปีตามที่เขียนไว้ในไฟล์ทดสอบตรง ๆ
    ...                หน้าเว็บจะแสดงหัวปฏิทินเป็น ค.ศ. หรือ พ.ศ. ก็ทำงานได้เหมือนกัน
    [Arguments]    ${Year}
    ${Year}=      Convert To Integer    ${Year}
    ${Result}=    Evaluate    ${Year} - ${THAI_YEAR_OFFSET} if ${Year} > 2400 else ${Year}
    RETURN    ${Result}

Go To Calendar Month
    [Documentation]    เลื่อนปฏิทินไปยังเดือนเป้าหมาย โดยอ่านหัวปฏิทินใหม่ทุกครั้งแทนการนับจำนวนคลิก
    ...                ปฏิทินอาจเปิดที่เดือนของค่าเดิมในช่อง ไม่ใช่เดือนปัจจุบันเสมอไป
    [Arguments]    ${TargetIndex}
    FOR    ${Round}    IN RANGE    24
        ${Now}=    Get Calendar Month
        IF    ${Now} == 0            RETURN    ${False}
        IF    ${Now} == ${TargetIndex}    RETURN    ${True}

        ${Button}=    Set Variable If    ${Now} < ${TargetIndex}    ${Cal_NextMonth}    ${Cal_PrevMonth}
        Click    ${Button}
        Sleep    0.2s
    END
    Log    เลื่อนปฏิทินครบ 24 ครั้งแล้วยังไม่ถึงเดือนเป้าหมาย    level=WARN
    RETURN    ${False}

Pick Date From Calendar
    [Documentation]    เปิดปฏิทินของช่องที่ระบุแล้วคลิกเลือกวันที่เป้าหมาย
    ...                คืนค่าที่อ่านได้จากช่องเมื่อเลือกสำเร็จ / คืนข้อความบอกเหตุเมื่อเลือกไม่ได้
    ...                ระบบปิดปุ่มวันที่ผิดเงื่อนไขไว้ (disabled) การเลือกไม่ได้จึงเป็นผลลัพธ์ที่ถูกต้อง ไม่ใช่ข้อผิดพลาด
    [Arguments]    ${Field}    ${Day}    ${MonthIndex}    ${Display}

    Click    ${Field}
    ${Opened}=    Is Element Visible    ${Cal_TodayButton}
    IF    not ${Opened}    RETURN    เปิดปฏิทินของช่องนี้ไม่ได้

    Go To Calendar Month    ${MonthIndex}

    ${Enabled}=    Set Variable    xpath=//button[not(@disabled)][.//span[normalize-space(text())='${Day}']]
    ${AnyCell}=    Set Variable    xpath=//button[.//span[normalize-space(text())='${Day}']]

    ${Clickable}=    Get Element Count    ${Enabled}
    IF    ${Clickable} == 0
        ${Total}=    Get Element Count    ${AnyCell}
        RETURN    ระบบปิดวันที่ ${Display} ไม่ให้เลือก (พบปุ่มวันนี้ ${Total} ปุ่ม กดได้ 0 ปุ่ม)
    END

    Click    ${Enabled} >> nth=0
    Sleep    0.3s
    ${Value}=    Get Attribute    ${Field}    value
    RETURN    ${Value}

Input Booking Address
    [Documentation]    กรอกที่อยู่จัดส่ง กรอกทุกครั้งแม้เป็นค่าว่างเพื่อให้ระบบตรวจสอบช่องนี้
    [Arguments]    ${Address}
    Fill Text    ${Text_BookAddress}    ${Address}

Click Booking Button
    [Documentation]    กดปุ่ม "สั่งจอง" คืน True เมื่อกดได้ / False เมื่อปุ่มถูกปิดใช้งาน
    ${Clicked}=    Click Button If Enabled    ${Btn_Booking}
    IF    ${Clicked}    Sleep    0.5s
    RETURN    ${Clicked}

Is Terms Popup Shown
    [Documentation]    ตรวจว่า popup ข้อกำหนดการเช่าเด้งขึ้นมาแล้วหรือยัง ดูจากปุ่ม "ยอมรับ"
    ...                popup นี้เด้งเฉพาะตอนข้อมูลผ่านการตรวจสอบ จึงใช้เป็นตัวชี้วัดว่าฟอร์มถูกต้อง
    ${Shown}=    Is Element Visible    ${Btn_AcceptTerms}
    RETURN    ${Shown}

Accept Booking Terms
    [Documentation]    ติ๊กยอมรับข้อกำหนดแล้วกดปุ่ม "ยอมรับ" คืน True เมื่อกดปุ่มได้
    Check Checkbox    ${Check_Terms}
    ${Clicked}=    Click Button If Enabled    ${Btn_AcceptTerms}
    IF    ${Clicked}    Sleep    0.5s
    RETURN    ${Clicked}

#-------------------------------------------------------------------------
# Return Equipment Farmer : ไม่มีการกรอกฟอร์ม เป็นคีย์เวิร์ด "เปิดหน้า - กดปุ่ม - ยืนยัน - อ่าน popup" ล้วน ๆ
Open Return Equipment Page
    [Documentation]    เปิดหน้ารายการส่งคืนอุปกรณ์ ต้องเข้าสู่ระบบไว้ก่อนจึงจะเห็นรายการของตนเอง
    ...                ใช้ Go To แทนการเปิด context ใหม่ เพื่อไม่ให้เสียสถานะเข้าสู่ระบบที่เพิ่งทำไว้
    Go To                  ${Return_farmerURL}
    Wait For Load State    domcontentloaded    ${DEFAULT_TIMEOUT}
    # หน้านี้ดึงรายการจองมาแสดงหลังโหลดหน้าเสร็จ จึงรอสั้น ๆ ก่อนเริ่มนับปุ่ม
    Sleep    1s

Get Returnable Item Count
    [Documentation]    นับรายการที่อยู่ในสถานะพร้อมส่งคืน จากจำนวนปุ่ม "ส่งคืนอุปกรณ์" (หนึ่งรายการหนึ่งปุ่ม)
    ...                ต้องรอปุ่มใบแรกก่อน เพราะ Get Element Count ไม่รอ element จะได้ 0 ถ้าหน้ายังวาดไม่เสร็จ
    ${Found}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Btn_ReturnEQ} >> nth=0    visible    ${CARD_TIMEOUT}
    IF    not ${Found}    RETURN    ${0}

    ${Count}=    Get Element Count    ${Btn_ReturnEQ}
    RETURN    ${Count}

Click Return Equipment
    [Documentation]    กดปุ่ม "ส่งคืนอุปกรณ์" ของรายการแรก คืน True เมื่อกดได้
    ${Clicked}=    Click Button If Enabled    ${Btn_ReturnEQ} >> nth=0
    IF    ${Clicked}    Sleep    0.5s
    RETURN    ${Clicked}

Is Return Confirm Popup Shown
    [Documentation]    ตรวจว่า popup ยืนยันการส่งคืนเด้งขึ้นมาแล้วหรือยัง ดูจากปุ่ม "ยืนยัน"
    ...                popup นี้เด้งเฉพาะตอนรายการอยู่ในสถานะที่ส่งคืนได้ จึงใช้เป็นตัวชี้วัดว่าระบบยอมให้คืน
    ${Shown}=    Is Element Visible    ${Btn_ConfirmReturn}
    RETURN    ${Shown}

Confirm Return Equipment
    [Documentation]    กดปุ่ม "ยืนยัน" บน popup แล้วรอ popup ผลลัพธ์ คืนข้อความที่ระบบตอบกลับ
    ...                ต้องรอหัวข้อเปลี่ยนก่อน เพราะ popup ยืนยันกับ popup ผลลัพธ์ใช้ id เดียวกัน จะอ่านได้หัวข้อเดิม
    ${Before}=     Get Popup Title
    ${Clicked}=    Click Button If Enabled    ${Btn_ConfirmReturn}
    IF    not ${Clicked}    RETURN    ปุ่มยืนยันการส่งคืนถูกปิดใช้งาน ระบบไม่ให้ทำรายการ

    ${After}=    Wait For Popup Title Change    ${Before}
    RETURN    ${After}

Wait For Popup Title Change
    [Documentation]    รอจนหัวข้อบน popup เปลี่ยนไปจากค่าเดิม คืนหัวข้อใหม่
    ...                รอครบแล้วยังไม่เปลี่ยนคืนค่าเดิม ให้ผู้เรียกตัดสินเองว่าถือเป็นผลลัพธ์หรือข้อผิดพลาด
    [Arguments]    ${Previous}
    FOR    ${Round}    IN RANGE    20
        Sleep    0.3s
        ${Now}=    Get Popup Title
        IF    '${Now}' != '${Previous}'    RETURN    ${Now}
    END
    Log    รอครบ 20 รอบแล้วหัวข้อบน popup ยังเป็น "${Previous}" เหมือนเดิม    level=WARN
    RETURN    ${Previous}

Dismiss Popup
    [Documentation]    ปิด popup ด้วยปุ่ม Escape ใช้แทนการกดยกเลิก เพราะข้อความบนปุ่มยกเลิกต่างกันในแต่ละ popup
    Run Keyword And Ignore Error    Keyboard Key    press    Escape
    Sleep    0.5s

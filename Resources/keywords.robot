*** Settings ***
Library           Browser
Library           Collections
Library           String
Resource          variables.robot


*** Keywords ***
#-------------------------------------------------------------------------
# Login Farmer : เปิด browser process เดียว แล้วใช้ context ใหม่ในแต่ละกรณีทดสอบ
Open Login Browser
    New Browser            ${browser}    headless=${headless}
    Set Browser Timeout    ${DEFAULT_TIMEOUT}
    # ปิดภาพหน้าจออัตโนมัติ เพราะสคริปต์ถ่ายเองเมื่อเคสไม่ผ่าน (เก็บใน Error IMG)
    Register Keyword To Run On Failure    None

Close Login Context
    Close Context

Close All Login Browsers
    Close Browser    ALL

Open Login Page
    [Documentation]    เปิด context และหน้าเข้าสู่ระบบใหม่ (ต้องเรียก Open Login Browser ก่อน)
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
# Register Farmer : เปิด browser process เดียว แล้วใช้ context ใหม่ในแต่ละกรณีทดสอบ
Open Register Browser
    New Browser            ${browser}    headless=${headless}
    Set Browser Timeout    ${DEFAULT_TIMEOUT}
    # ปิดภาพหน้าจออัตโนมัติ เพราะสคริปต์ถ่ายเองแล้ว และเคสที่ตั้งใจให้ล้มจะได้ภาพเปล่า ๆ ทั้งรันช้าลง
    Register Keyword To Run On Failure    None

Close Register Context
    Close Context

Close All Register Browsers
    Close Browser    ALL

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
    [Documentation]    เลือกประเภทอุปกรณ์จาก dropdown ถ้าหาไม่เจอจะเตือนใน log แทนการล้ม เพราะเคสนี้สนใจการเพิ่มตะกร้าไม่ใช่ตัวกรอง
    [Arguments]    ${Type}
    IF    '${Type}' == '${EMPTY}'    RETURN    ${False}

    ${Ok}    ${Options}=    Run Keyword And Ignore Error    Get Select Options    ${Select_EQType}
    IF    '${Ok}' == 'FAIL'
        Log    ไม่พบ dropdown ประเภทอุปกรณ์ จึงข้ามการเลือกประเภท    level=WARN
        RETURN    ${False}
    END

    ${Labels}=     Evaluate    [str(o.get("label", "")).strip() for o in $Options]
    # lambda รับค่าผ่าน default argument เพราะ RF มองไม่เห็น $ตัวแปร ในเงื่อนไขของ comprehension
    ${Matched}=    Evaluate    next(filter(lambda l, t=$Type: l == t or t in l, $Labels), "")

    IF    '${Matched}' == '${EMPTY}'
        Log    ไม่มีประเภท "${Type}" ใน dropdown (มี ${Labels}) จึงค้นหาจากชื่ออุปกรณ์อย่างเดียว    level=WARN
        RETURN    ${False}
    END

    Select Options By    ${Select_EQType}    label    ${Matched}
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

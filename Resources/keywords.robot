*** Settings ***
Library           Browser
Library           Collections
Library           String
Resource          variables.robot


*** Keywords ***
Open Login Page
    New Browser    ${browser}    headless=${headless}
    New Context
    New Page    ${Login_farmerURL}

Input Username
    [Arguments]    ${Username}
    Fill Text    ${Text_Username}    ${Username}

Input Password
    [Arguments]    ${Password}
    Fill Text    ${Text_Password}    ${Password}

Click Login Button
    Click    ${Btn_Login}

Click Verify Button
    Click    ${Btn_Verify}

Close Browser Session
    Close Browser

#-------------------------------------------------------------------------
# คีย์เวิร์ดช่วยเหลือทั่วไป
Is Element Visible
    [Documentation]    ตรวจว่า element แสดงอยู่บนหน้าจอหรือไม่ โดยรอไม่เกิน ${SHORT_TIMEOUT}
    ...                ใช้แทนการ Wait ตรง ๆ เพื่อไม่ให้เสียเวลารอจนครบ timeout ปกติ (30 วินาที)
    [Arguments]    ${Selector}
    Set Browser Timeout    ${SHORT_TIMEOUT}
    ${Visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${Selector}    visible
    Set Browser Timeout    ${DEFAULT_TIMEOUT}
    RETURN    ${Visible}

Click Button If Enabled
    [Documentation]    กดปุ่มเมื่อปุ่มพร้อมใช้งานเท่านั้น
    ...                หน้าเว็บนี้จะ disable ปุ่มไว้ถ้าข้อมูลยังไม่ผ่านการตรวจสอบ
    ...                ถ้ากดทั้งที่ปุ่มถูก disable ไว้ Playwright จะรอจนครบ 30 วินาทีแล้ว timeout
    ...                คืนค่า True เมื่อกดปุ่มสำเร็จ, False เมื่อปุ่มถูกปิดใช้งาน
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
# เปิด browser process เดียว แล้วใช้ context ใหม่ในแต่ละกรณีทดสอบ
Open Register Browser
    New Browser            ${browser}    headless=${headless}
    Set Browser Timeout    ${DEFAULT_TIMEOUT}
    # ปิดการถ่ายภาพหน้าจออัตโนมัติของ Browser library
    # เพราะสคริปต์ถ่ายภาพเองอยู่แล้วเมื่อกรณีทดสอบไม่ผ่าน (เก็บไว้ในโฟลเดอร์ Error IMG)
    # ภาพอัตโนมัติจะถูกถ่ายทุกครั้งที่คีย์เวิร์ดล้ม รวมถึงตอนที่ตั้งใจให้ล้ม ทำให้ได้ภาพที่ไม่มีข้อความ error และรันช้าลง
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
    [Documentation]    กดปุ่ม "ถัดไป" คืนค่า True เมื่อกดได้ / False เมื่อปุ่มถูกปิดใช้งาน
    ${Clicked}=    Click Button If Enabled    ${Btn_Next}
    RETURN    ${Clicked}

# page2
Click Register Button
    [Documentation]    กดปุ่ม "สมัครสมาชิก" คืนค่า True เมื่อกดได้ / False เมื่อปุ่มถูกปิดใช้งาน
    ${Clicked}=    Click Button If Enabled    ${Btn_Register}
    RETURN    ${Clicked}

Is Register Step2 Displayed
    [Documentation]    ตรวจว่าระบบพาไปหน้าที่ 2 (ข้อมูลส่วนตัว) แล้วหรือยัง
    ...                ใช้ช่อง "ชื่อจริง" เป็นตัวชี้วัดว่าอยู่หน้าที่ 2
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
    # แปลงให้เป็นภาษาอังกฤษให้ตรงกับ option ของหน้า UI
    IF    '${Gender}' == 'ชาย'
        Select Options By    ${Select_Gender}    value    male
    ELSE IF    '${Gender}' == 'หญิง'
        Select Options By    ${Select_Gender}    value    female
    END

Input Birthdate
    [Arguments]    ${Daybirth}    ${Monthbirth}    ${Yearbirth}
    IF    '${Daybirth}' == '${EMPTY}'    RETURN

    Fill Text    ${Date_Birth}    ${Daybirth}
    Fill Text    ${Date_Month}    ${Monthbirth}

    # แปลง ค.ศ. เป็น พ.ศ. ตามเอกสาร test case
    # เฉพาะเมื่อข้อมูลปีเป็นตัวเลขจริง มิฉะนั้นกรอกค่าดิบเพื่อทดสอบรูปแบบที่ไม่ถูกต้อง
    ${IsNumber}=    Evaluate    "${Yearbirth}".strip().isdigit()
    IF    ${IsNumber}
        ${YearBE}=    Evaluate    int("${Yearbirth}") + 543
        Fill Text    ${Date_Year}    ${YearBE}
    ELSE
        Fill Text    ${Date_Year}    ${Yearbirth}
    END

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
    [Documentation]    คืนค่าข้อความแจ้งเตือนทุกข้อความที่แสดงอยู่บนหน้าจอ ในรูปแบบ list
    ...                ถ้าไม่มีข้อความแจ้งเตือนเลย จะคืนค่า list ว่าง
    ...
    ...                สำคัญ: ต้องลด browser timeout ชั่วคราวก่อนเรียก Get Elements
    ...                เพราะถ้าไม่พบ element Playwright จะรอจนครบ timeout ปกติ (30 วินาที) ทุกครั้ง
    ${Messages}=    Create List

    Set Browser Timeout    ${SHORT_TIMEOUT}
    ${Status}    ${Elements}=    Run Keyword And Ignore Error    Get Elements    ${Error_Message}
    Set Browser Timeout    ${DEFAULT_TIMEOUT}

    IF    '${Status}' == 'FAIL'    RETURN    ${Messages}

    FOR    ${Element}    IN    @{Elements}
        ${Text}=    Get Text        ${Element}
        ${Text}=    Strip String    ${Text}
        IF    '${Text}' != '${EMPTY}'
            Append To List    ${Messages}    ${Text}
        END
    END
    RETURN    ${Messages}

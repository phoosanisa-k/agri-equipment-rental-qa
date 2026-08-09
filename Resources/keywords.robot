*** Settings ***
Library           Browser
Resource          variables.robot

*** Keywords ***
Open Login Page
    New Browser    ${browser}    headless=False
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
# Register Farmer
# browser process ใหม่ทุก test case (167 ครั้ง) 
Open Register Browser
    New Browser    ${browser}    headless=False

Close Register Context
    Close Context

Close All Register Browsers
    Close Browser    ALL

# page1
Open Register Page
    New Context
    New Page    ${Register_farmerURL}

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
    Click    ${Btn_Next}

# page2
Input Firstname
    [Arguments]    ${Firstname}
    Fill Text    ${Text_Name}    ${Firstname}

Input Surname
    [Arguments]    ${Surname}
    Fill Text    ${Text_LName}    ${Surname}

Select Gender
    [Arguments]    ${Gender}
    # แปลงให้เป็นภาษาอังกฤษกตรงกับ option หน้า ui
    IF    '${Gender}' == 'ชาย'
        Select Options By    ${Select_Gender}    value    male
    ELSE IF    '${Gender}' == 'หญิง'
        Select Options By    ${Select_Gender}    value    female
    END

Input Birthdate
    [Arguments]    ${Daybirth}    ${Monthbirth}    ${Yearbirth}
    IF    '${Daybirth}' != '${EMPTY}'
        Fill Text    ${Date_Birth}      ${Daybirth}
        Fill Text    ${Date_Month}      ${Monthbirth}

        ${YearBE}=    Evaluate    ${Yearbirth} + 543  #แปลงให้เป็น พ.ศ ตามเอกสาร testcase
        Fill Text    ${Date_Year}    ${YearBE}
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

Get Validation Message
    Set Browser Timeout    2s
    ${status}    ${msg}=    Run Keyword And Ignore Error    Get Text    ${Error_Message}
    Set Browser Timeout    30s
    IF    '${status}' == 'FAIL'
        RETURN    ${EMPTY}
    END
    RETURN    ${msg}
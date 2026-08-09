*** Settings ***
Resource   ../Resources/keywords.robot
Library    DataDriver    file=../TestData/Data.xlsx    sheet_name=Register_Farmer

Suite Setup       Open Register Browser
Suite Teardown    Close All Register Browsers
Test Teardown     Close Register Context

Test Template    Register_Farmer

*** Test Cases ***
Register For ${TestCaseID}

*** Keywords ***
Register_Farmer
    [Arguments]
    ...    ${TestCaseID}    ${TestScanario}    ${Picture}    ${UsernameR}    ${Email}
    ...    ${PasswordR}    ${Confirmpassword}    ${Firstname}    ${Surname}    ${Gender}
    ...    ${Daybirth}    ${Monthbirth}    ${Yearbirth}    ${Tel}
    ...    ${Hnum}    ${Alley}    ${Group}    ${District}    ${Canton}    ${province}    ${Postcode}
    ...    ${ExpectedResult}    ${ActualResult}    ${ResultPF}    ${Notes}

    Log    ${TestScanario}
    Open Register Page

    # --- Step 1 ---
    Upload Picture           ${Picture}
    Input UsernameR          ${UsernameR}
    Input Email              ${Email}
    Input PasswordR          ${PasswordR}
    Input Confirmpassword    ${Confirmpassword}
    Click Next Button

    ${Step1Message}=    Get Validation Message
    IF    '${Step1Message}' != '${EMPTY}'
        Should Be Equal As Strings    ${Step1Message}    ${ExpectedResult}
    ELSE
        Input Firstname    ${Firstname}
        Input Surname      ${Surname}
        Select Gender      ${Gender}
        Input Birthdate    ${Daybirth}    ${Monthbirth}    ${Yearbirth}
        Input Tel          ${Tel}
        Input Hnum         ${Hnum}
        Input Alley        ${Alley}
        Input Group        ${Group}
        Input District     ${District}
        Input Canton       ${Canton}
        Input Province     ${province}
        Input Postcode     ${Postcode}

        ${ActualMessage}=    Get Validation Message
        Should Be Equal As Strings    ${ActualMessage}    ${ExpectedResult}
    END

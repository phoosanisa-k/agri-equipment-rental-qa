*** Settings ***
Resource   ../Resources/keywords.robot
Library    DataDriver    file=../TestData/Data.xlsx    sheet_name=Login_Farmer


Test Template    Login_Farmer

*** Test Cases ***
Login

*** Keywords ***
Login_Farmer
    [Arguments]
    ...    ${TestCase}
    ...    ${TestScenario}
    ...    ${Username}
    ...    ${Password}
    ...    ${ExpectedResult}
    ...    ${ActualResult}
    ...    ${Result}
    ...    ${Notes}

    Log    ${TestScenario}

    Open Login Page
    Input Username    ${Username}
    Input Password    ${Password}
    Click Login Button
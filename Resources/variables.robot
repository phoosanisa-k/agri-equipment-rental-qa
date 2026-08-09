*** Variables ***
${browser}    chromium
${Base_URL}           http://localhost:3000

#-------------------------------------------------------------------------
#Login Farmer Usecase
${Login_farmerURL}    ${Base_URL}/auths/login-farmer
${Text_Username}    //input[@placeholder='กรอกชื่อผู้ใช้']
${Text_Password}    //input[@placeholder='กรอกรหัสผ่าน']
${Btn_Login}        //button[@type='submit']
${Btn_Verify}       //button[contains(text(),'ตกลง')]

#-------------------------------------------------------------------------
#Register Farmer Usecase
${Register_farmerURL}    ${Base_URL}/auths/register-farmer
${TestDataDir}           ${CURDIR}/../Testdata
${Img}                      //input[@name='farmerImg']
${Text_RUsername}           //input[@name='farmerUserName']
${Text_REmail}              //input[@name='farmerEmail']
${Text_RPassword}           //input[@name='farmerPassword']
${Text_RConfirmPassword}    //input[@name='confirmPassword']

${Btn_Next}                 //button[contains(text(),'ถัดไป')]

${Text_Name}                //input[@name='farmerFName']
${Text_LName}               //input[@name='farmerLName']

${Select_Gender}            //select[@name='farmerGender']
${Select_male}              //option[@value='male']
${Select_female}            //option[@value='female']

${Date_Birth}               //input[@placeholder='วัน']
${Date_Month}               //input[@placeholder='เดือน']
${Date_Year}                //input[@placeholder='ปี พ.ศ.']
${Text_Phone}               //input[@name='farmerTel']
${Text_Num}                 //input[@name='farmerHouseNumber']
${Text_Alley}               //input[@name='farmerAlley']
${Text_Moo}                 //input[@name='farmerMoo']
${Text_Subdistric}          //input[@name='farmerSubDistrict']
${Text_Distric}             //input[@name='farmerDistrict']
${Text_Province}            //input[@name='farmerProvince']
${Text_Postcode}            //input[@name='farmerPostalCode']
${Btn_Register}             //button[contains(text(),'สมัครสมาชิก')]

${Error_Message}            css=p.text-sm.text-red-600.flex.items-center.gap-1 >> visible=true

#------------------------------------------------------------------------
# Add Cart Usecase
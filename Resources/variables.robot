*** Variables ***
${browser}    chromium
${headless}           ${False}
${DEFAULT_TIMEOUT}    30s
${SHORT_TIMEOUT}      2s
# หน้าเว็บวาดการ์ดอุปกรณ์ช้ากว่าข้อความสรุปผล จึงรอการ์ดนานกว่า ${SHORT_TIMEOUT}
${CARD_TIMEOUT}       5s
${VIEWPORT_WIDTH}     ${1440}
${VIEWPORT_HEIGHT}    ${1000}
${Base_URL}           http://localhost:3000

#-------------------------------------------------------------------------
#Login Farmer Usecase
${Login_farmerURL}    ${Base_URL}/auths/login-farmer
${Text_Username}    //input[@placeholder='กรอกชื่อผู้ใช้']
${Text_Password}    //input[@placeholder='กรอกรหัสผ่าน']
${Btn_Login}        //button[@type='submit']
${Btn_Verify}       //button[contains(text(),'ตกลง')]
# ยังไม่ทราบข้อความบนปุ่มออกจากระบบแน่ชัด จึงใช้ regex ครอบคำที่เป็นไปได้ไว้ก่อน
${Btn_Logout}       text=/ออกจากระบบ|ลงชื่อออก|logout|sign out/i

#-------------------------------------------------------------------------
#Register Farmer Usecase
${Register_farmerURL}    ${Base_URL}/auths/register-farmer
${TestDataDir}           ${CURDIR}/../TestData/img
${Img}                      //input[@name='farmerImg']
${Text_RUsername}           //input[@name='farmerUserName']
${Text_REmail}              //input[@name='farmerEmail']
${Text_RPassword}           //input[@name='farmerPassword']
${Text_RConfirmPassword}    //input[@name='confirmPassword']

${Btn_Next}                 //button[contains(text(),'ถัดไป')]
${Btn_Back}                 //button[contains(text(),'ย้อนกลับ')]

${Text_Name}                //input[@name='farmerFName']
${Text_LName}               //input[@name='farmerLName']

${Select_Gender}            //select[@name='farmerGender']

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

# จับคลาส text-red ทุกเฉด และไม่ผูกกับคลาสจัดวาง เพราะข้อความที่ไม่มีไอคอนนำหน้า (เช่น "รหัสผ่านไม่ตรงกัน") จะไม่มีคลาสเหล่านั้น
${Error_Message}            css=[class*="text-red"] >> visible=true

#------------------------------------------------------------------------
# Add Cart Usecase
# ยูสเคสนี้เข้าหน้าค้นหาด้วยการกดปุ่มบนหน้าหลัก ไม่ได้เปิดจาก URL ตรง ๆ จึงไม่มีตัวแปร URL

# ปุ่มเข้าหน้าค้นหาอุปกรณ์บนหน้าหลัก จับเฉพาะคู่สี gradient ซึ่งมีปุ่มเดียวบนหน้า เพราะคลาสทั้งชุดยาวมากและพังง่ายเมื่อแก้ดีไซน์
${Link_SearchEQ}       //a[contains(@class,'from-yellow-400') and contains(@class,'to-orange-500')]
# เมนูบนหัวเว็บ เก็บไว้เป็นทางสำรองเมื่อไม่พบปุ่มบนหน้าหลัก
${Link_SearchEQMenu}   //a[contains(text(),'ค้นหาเครื่องจักร')]

${Text_SearchEQ}       //input[@placeholder='พิมพ์ชื่ออุปกรณ์...']
# dropdown ประเภทอุปกรณ์คืออันแรกของหน้า อ้างตามลำดับแทนคลาส เพราะ dropdown บนหน้านี้ใช้คลาสชุดเดียวกันและยาวมาก
${Select_EQType}       xpath=(//select)[1]
${Text_FoundCount}     //*[contains(text(),'พบอุปกรณ์ทั้งหมด')]

# ปุ่มบนการ์ดอุปกรณ์ ข้อความเปลี่ยนตามสถานะ ใช้ข้อความแทนคลาสเพราะเป็นสิ่งที่ผู้ใช้เห็นและเป็นสิ่งที่กรณีทดสอบสนใจ
${Btn_AddToCart}       //button[contains(.,'เพิ่มในตะกร้า')]
${Btn_InCart}          //button[contains(.,'อยู่ในตะกร้าแล้ว')]
# ใช้นับจำนวนการ์ดในผลการค้นหา เพราะการ์ดหนึ่งใบมีปุ่มหนึ่งปุ่มเสมอ ไม่ว่าปุ่มจะอยู่สถานะไหน
${Card_EQButtons}      //button[contains(.,'เพิ่มในตะกร้า') or contains(.,'อยู่ในตะกร้าแล้ว') or contains(.,'ไม่พร้อมให้เช่า')]

# ข้อความบนปุ่มมีได้ 3 สถานะเท่านั้น ใช้เป็น ActualResult ได้ตรง ๆ เพราะเป็นสิ่งที่ผู้ใช้เห็นจริง ไม่ต้องแต่งประโยคสรุปเอง
${State_AddToCart}     เพิ่มในตะกร้า
${State_InCart}        อยู่ในตะกร้าแล้ว
${State_Unavailable}   ไม่พร้อมให้เช่า
# เรียง "อยู่ในตะกร้าแล้ว" ไว้ก่อน เพราะต้องเทียบสถานะที่เจาะจงกว่าก่อนเสมอ
@{EQ_BUTTON_STATES}    ${State_InCart}    ${State_AddToCart}    ${State_Unavailable}

# ปุ่มตะกร้าลอยมุมขวาล่าง จับเฉพาะคลาสที่บอกตำแหน่ง ไม่เอาคลาสสีและเอฟเฟกต์
${Btn_OpenCart}        //button[contains(@class,'fixed') and contains(@class,'bottom-6') and contains(@class,'right-6')]

# กล่องตะกร้าที่เด้งขึ้นมา ใช้ [last()] เพื่อเอา div ชั้นในสุดที่มีทั้งหัวข้อและปุ่มล้างตะกร้า จะได้เฉพาะตัวกล่อง
${Cart_Modal}          xpath=(//div[.//*[contains(text(),'สินค้าในตะกร้า')] and .//button[contains(text(),'ล้างตะกร้า')]])[last()]
# ถังขยะของแต่ละรายการ ใช้นับจำนวนรายการในตะกร้าได้ตรง ๆ เพราะหนึ่งรายการมีหนึ่งปุ่ม
${Btn_RemoveFromCart}  //button[@title='ลบออกจากตะกร้า']
# ปุ่มล้างตะกร้าทั้งใบ อยู่ในกล่องตะกร้า ต้องเปิดกล่องไว้ก่อนจึงจะกดได้
${Btn_ClearCart}       //button[contains(text(),'ล้างตะกร้า')]
${Btn_CloseCart}       //button[contains(text(),'ปิด')]
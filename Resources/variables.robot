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

# กล่องแจ้งเตือน SweetAlert2 ของระบบ หัวข้อคือข้อความหลักที่ผู้ใช้เห็น จับด้วย id ของไลบรารีจึงไม่ผูกกับข้อความ
${Popup_Title}         //h2[@id='swal2-title']
# ปุ่มบน popup ที่เด้งเมื่อผู้ใช้ที่ยังไม่เข้าสู่ระบบกดเพิ่มในตะกร้า (Alternate Flow 3.1 ของเอกสาร)
${Btn_LoginPopup}      //button[contains(text(),'เข้าสู่ระบบ')]
#------------------------------------------------------------------------
# Booking Equipment Usecase
# ฟอร์มจองอยู่ในกล่องตะกร้า ต้องมีอุปกรณ์ในตะกร้าและเปิดกล่องไว้ก่อน (Pre-Condition ของเอกสาร)
${Text_StartDate}      //input[@placeholder='เลือกวันที่เริ่มเช่า']
${Text_EndDate}        //input[@placeholder='เลือกวันที่สิ้นสุด']
${Text_BookAddress}    //textarea[@placeholder='กรอกที่อยู่เต็ม เช่น เลขที่ ซอย ถนน ตำบล อำเภอ จังหวัด รหัสไปรษณีย์']
${Btn_Booking}         //button[contains(text(),'สั่งจอง')]

# ปฏิทิน : ช่องวันที่เป็น readonly พิมพ์ไม่ได้ ต้องคลิกเลือกจากปฏิทินเท่านั้น
# ปุ่มวันที่เลือกไม่ได้จะมี disabled ทั้งวันของเดือนอื่นและวันที่ผิดเงื่อนไขของระบบ
${Cal_TodayButton}     //button[normalize-space(text())='วันนี้']
# จับปุ่มเลื่อนเดือนจาก path ของไอคอน chevron ซึ่งไม่เปลี่ยนตามคลาส Tailwind
${Cal_PrevMonth}       //button[.//path[@d='M15 19l-7-7 7-7']]
${Cal_NextMonth}       //button[.//path[@d='M9 5l7 7-7 7']]
# หัวปฏิทิน (เช่น "สิงหาคม 2026") อยู่ถัดจากปุ่มเลื่อนเดือนย้อนหลัง
${Cal_Header}          xpath=//button[.//path[@d='M15 19l-7-7 7-7']]/following-sibling::*[1]

# popup ข้อกำหนดการเช่าที่เด้งหลังกดสั่งจอง ต้องติ๊กยอมรับก่อนจึงจะจองได้
${Check_Terms}         //input[@type='checkbox']
${Btn_AcceptTerms}     //button[contains(text(),'ยอมรับ')]

# ส่วนต่างระหว่าง พ.ศ. กับ ค.ศ. ใช้ที่เดียวคือคีย์เวิร์ด "เทียบปีให้เป็น ค.ศ." ตอนอ่านหัวปฏิทิน
${THAI_YEAR_OFFSET}    ${543}

# ชื่อเดือนภาษาไทยบนหัวปฏิทิน ใช้แปลงเป็นเลขเดือนเพื่อรู้ว่าต้องเลื่อนปฏิทินไปทางไหน
&{THAI_MONTHS}
...    มกราคม=${1}       กุมภาพันธ์=${2}    มีนาคม=${3}       เมษายน=${4}
...    พฤษภาคม=${5}      มิถุนายน=${6}      กรกฎาคม=${7}      สิงหาคม=${8}
...    กันยายน=${9}      ตุลาคม=${10}       พฤศจิกายน=${11}    ธันวาคม=${12}

#------------------------------------------------------------------------
# Return Equipment Usecase
# หน้ารายการอุปกรณ์ที่ถึงกำหนดส่งคืน เข้าตรงจาก URL ได้เมื่อเข้าสู่ระบบแล้ว (Pre-Condition ของเอกสาร)
${Return_farmerURL}     ${Base_URL}/farmer/delivery

# ปุ่มส่งคืนของแต่ละรายการ ใช้นับจำนวนรายการที่อยู่ในสถานะพร้อมส่งคืนได้ด้วย เพราะหนึ่งรายการมีหนึ่งปุ่ม
# รายการที่สถานะไม่ถูกต้อง (เช่น คืนไปแล้ว) จะไม่มีปุ่มนี้ จำนวนปุ่มจึงเป็นตัวชี้วัดของ RT01-01 และ RT01-03
${Btn_ReturnEQ}         //button[contains(text(),'ส่งคืนอุปกรณ์')]
# ปุ่มยืนยันบน popup ที่เด้งหลังกดส่งคืน ระบบจะบันทึกการคืนเมื่อกดปุ่มนี้เท่านั้น
${Btn_ConfirmReturn}    //button[contains(text(),'ยืนยัน')]
# popup ผลลัพธ์ใช้ ${Popup_Title} ร่วมกับยูสเคสอื่น เพราะเป็น SweetAlert2 ตัวเดียวกัน

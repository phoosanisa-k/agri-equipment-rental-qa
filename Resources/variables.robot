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
 
# บัญชีทดสอบกลาง ทุกชุดทดสอบอ้างตัวแปรชุดนี้ เปลี่ยนบัญชีทีเดียวได้ทั้งโปรเจกต์
${TEST_FARMER_USER}    PKFarmer01
${TEST_FARMER_PASS}    PK01010101
${TEST_OWNER_USER}     marker
${TEST_OWNER_PASS}     0000000000
 
#-------------------------------------------------------------------------
#Login Farmer Usecase
${Login_farmerURL}    ${Base_URL}/auths/login-farmer
${Text_Username}    //input[@placeholder='กรอกชื่อผู้ใช้']
${Text_Password}    //input[@placeholder='กรอกรหัสผ่าน']
${Btn_Login}        //button[@type='submit']
${Btn_Verify}       //button[contains(text(),'ตกลง')]
# ปุ่มโปรไฟล์บนหัวเว็บ กดแล้วเมนูออกจากระบบจึงจะเด้งลงมา ใช้ร่วมกันทั้งฝั่ง Farmer และ Owner
${Btn_UserProfile}    //button[@type='button'][contains(.,'ชื่อผู้ใช้')]
${Btn_Logout}       //button[contains(text(),'ออกจากระบบ')]
 
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
${Btn_PopupConfirm}    //button[contains(@class,'swal2-confirm')]
# ปุ่มบน popup ที่เด้งเมื่อผู้ใช้ที่ยังไม่เข้าสู่ระบบกดเพิ่มในตะกร้า (Alternate Flow 3.1 ของเอกสาร)
${Btn_LoginPopup}      //button[contains(text(),'เข้าสู่ระบบ')]
#------------------------------------------------------------------------
# Booking Equipment Usecase
# ฟอร์มจองอยู่ในกล่องตะกร้า ต้องมีอุปกรณ์ในตะกร้าและเปิดกล่องไว้ก่อน (Pre-Condition ของเอกสาร)
${Text_StartDate}      //input[@placeholder='เลือกวันที่เริ่มเช่า']
${Text_EndDate}        //input[@placeholder='เลือกวันที่สิ้นสุด']
${Text_BookAddress}    //textarea[@placeholder='กรอกที่อยู่เต็ม เช่น เลขที่ ซอย ถนน ตำบล อำเภอ จังหวัด รหัสไปรษณีย์']
# ปุ่มมีไอคอนนำหน้า ข้อความจึงอยู่ใน element ลูก ต้องใช้ . ไม่ใช่ text() เหมือน ${Btn_AddToCart}
${Btn_Booking}         //button[contains(.,'สั่งจอง')]
# หน้า "การจองของฉัน" ที่ระบบพาไปหลังจองสำเร็จ (Expected Result ของ F-MAIN-10)
${MyBooking_farmerURL}    ${Base_URL}/farmer/bookings
 
# ปฏิทิน : ช่องวันที่เป็น readonly พิมพ์ไม่ได้ ต้องคลิกเลือกจากปฏิทินเท่านั้น
# ปุ่มวันที่เลือกไม่ได้จะมี disabled ทั้งวันของเดือนอื่นและวันที่ผิดเงื่อนไขของระบบ
# ปุ่ม "วันนี้" อยู่ท้ายกล่องปฏิทิน มีหนึ่งปุ่มต่อปฏิทินที่เปิดอยู่หนึ่งกล่อง
${Cal_TodayButton}     //button[normalize-space(text())='วันนี้']
# หน้าเว็บมีปฏิทินได้พร้อมกัน 2 กล่อง (ช่องวันเริ่ม + ช่องวันสิ้นสุด) locator ปุ่ม "วันนี้" จึงชี้ได้ 2 ตัว
# ตอนแค่อยากรู้ว่า "มีปฏิทินเปิดอยู่ไหม" ต้องใส่ nth=0 ไม่งั้น Playwright จะล้มด้วย strict mode violation
${Cal_AnyToday}        xpath=//button[normalize-space(text())='วันนี้'] >> nth=0
# จับปุ่มเลื่อนเดือนจาก path ของไอคอน chevron ซึ่งไม่เปลี่ยนตามคลาส Tailwind
# ต้องเขียน name()='path' เพราะ <path> อยู่ใน namespace ของ SVG ซึ่ง XPath บนเอกสาร HTML ไม่ match ด้วยชื่อแท็กเปล่า ๆ
${Cal_PrevMonth}       //button[.//*[name()='path'][@d='M15 19l-7-7 7-7']]
${Cal_NextMonth}       //button[.//*[name()='path'][@d='M9 5l7 7-7 7']]
# หัวปฏิทิน (เช่น "สิงหาคม 2026") อยู่ถัดจากปุ่มเลื่อนเดือนย้อนหลัง
${Cal_Header}          xpath=//button[.//*[name()='path'][@d='M15 19l-7-7 7-7']]/following-sibling::*[1]
 
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
 
#-------------------------------------------------------------------------
# Register Owner Usecase
# ฟอร์มมี 2 ขั้นตอนเหมือนฝั่ง Farmer ต่างกันที่ค่า name ของ input (owner* แทน farmer*)
# ปุ่ม "ถัดไป" / "ย้อนกลับ" / "สมัครสมาชิก" ช่องวันเกิด และ ${Error_Message}
# ใช้ตัวแปรร่วมกับฝั่ง Farmer เพราะเป็น element ชุดเดียวกันของเว็บ
${Register_ownerURL}         ${Base_URL}/auths/register-owner
${Img_Owner}                 //input[@name='ownerImg']
${Text_ROUsername}           //input[@name='ownerUserName']
${Text_ROEmail}              //input[@name='ownerEmail']
${Text_ROPassword}           //input[@name='ownerPassword']
${Text_ROConfirmPassword}    //input[@name='confirmPassword']
 
${Text_OName}                //input[@name='ownerFName']
${Text_OLName}               //input[@name='ownerLName']
${Select_OGender}            //select[@name='ownerGender']
${Text_OPhone}               //input[@name='ownerTel']
${Text_ONum}                 //input[@name='ownerHouseNumber']
${Text_OAlley}               //input[@name='ownerAlley']
${Text_OMoo}                 //input[@name='ownerMoo']
${Text_OSubdistric}          //input[@name='ownerSubDistrict']
${Text_ODistric}             //input[@name='ownerDistrict']
${Text_OProvince}            //input[@name='ownerProvince']
${Text_OPostcode}            //input[@name='ownerPostalCode']
 
#-------------------------------------------------------------------------
# Login Owner Usecase
# ช่องกรอกใช้ placeholder ชุดเดียวกับฝั่ง Farmer แต่แยกตัวแปรไว้ เผื่อหน้า Owner ถูกปรับทีหลัง
${Login_ownerURL}     ${Base_URL}/auths/login-owner
${Text_OUsername}     //input[@placeholder='กรอกชื่อผู้ใช้']
${Text_OPassword}     //input[@placeholder='กรอกรหัสผ่าน']
${Btn_OLogin}         //button[contains(text(),'เข้าสู่ระบบ')]
# ปุ่มบน popup แจ้งเข้าสู่ระบบสำเร็จของฝั่ง Owner ใช้คำว่า "ไปหน้าแรก" ไม่ใช่ "ตกลง" เหมือนฝั่ง Farmer
${Btn_OGoHome}        //button[contains(text(),'ไปหน้าแรก')]
# ปุ่มออกจากระบบใช้ ${Btn_Logout} ร่วมกับฝั่ง Farmer
 
#-------------------------------------------------------------------------
# Add Equipment Owner Usecase
# หน้ารายการอุปกรณ์ของเจ้าของ ต้องเข้าสู่ระบบเป็น Owner ก่อน แล้วกดปุ่ม "เพิ่มอุปกรณ์" ฟอร์มจึงจะเปิด
${AddEQ_ownerURL}        ${Base_URL}/owner/equipment
${Btn_AddEQ}             //button[contains(text(),'เพิ่มอุปกรณ์')]
 
${Text_EQName}           //input[@name='equipmentName']
${Text_EQDetail}         //textarea[@name='equipmentDetails']
${Text_EQPrice}          //input[@name='price']
${Select_EQStatus}       //select[@name='equipmentStatus']
${Text_EQFeature}        //input[@name='equipmentFeature']
${Text_EQAddress}        //input[@name='equipmentAddress']
${Img_EQ}                //input[@name='picture']
${Btn_SaveEQ}            //button[contains(text(),'บันทึก')]
${Btn_CancelEQ}          //button[contains(text(),'ยกเลิก')]
 
# บัญชี Owner ที่ใช้เข้าสู่ระบบก่อนเริ่มชุดทดสอบ TC03 : ใช้บัญชีทดสอบกลางที่หัวไฟล์
${OwnerUser}             ${TEST_OWNER_USER}
${OwnerPass}             ${TEST_OWNER_PASS}
 
#-------------------------------------------------------------------------
# Approve Booking Owner Usecase
# หน้านี้ไม่ได้ใช้ปุ่ม "อนุมัติ/ปฏิเสธ" แต่เป็นการเลื่อนสถานะไปทีละขั้น
# มีแท็บกรองตามสถานะ และแต่ละรายการมีปุ่ม อัปเดตเป็น "<สถานะถัดไป>" กับปุ่มยกเลิกการจอง
${ApproveBooking_ownerURL}     ${Base_URL}/owner/bookings
 
# แท็บกรองตามสถานะ : ต้องเทียบข้อความแบบตรงตัว ไม่ใช่ contains
# เพราะปุ่ม อัปเดตเป็น "รอการชำระเงิน" ก็มีคำว่า "รอการชำระเงิน" อยู่ด้วย จะจับปนกัน
# ใช้ . แทน text() เพราะแท็บอาจมีไอคอนหรือตัวเลขนับอยู่ข้างใน
${Tab_BookingPending}          //button[contains(.,'รอดำเนินการ') and not(contains(.,'อัปเดต'))]
 
# ปุ่มอัปเดตสถานะบนการ์ดรายการจอง ข้อความบนปุ่มบอกสถานะขั้นถัดไป ใช้นับรายการที่อัปเดตได้ด้วย
${Btn_UpdateBookingStatus}     //button[contains(.,'อัปเดตเป็น')]
${Btn_CancelBooking}           //button[contains(text(),'ยกเลิกการจอง')]    # TODO ยืนยันกับหน้าจริง
 
# กล่องโต้ตอบ SweetAlert2 : ปุ่ม "ยืนยัน" ต้องเทียบตรงตัว ไม่งั้นจะจับปุ่ม "ยืนยันยกเลิก" ปนมาด้วย
${Btn_ConfirmUpdate}           //button[normalize-space(text())='ยืนยัน']
${Btn_ConfirmCancelBooking}    //button[contains(text(),'ยืนยันยกเลิก')]
${Btn_DismissDialog}           //button[contains(@class,'swal2-cancel')]
${Btn_AcknowledgeDialog}       //button[normalize-space(text())='ตกลง']
# เนื้อความบนกล่องโต้ตอบ ใช้ทั้งตอนยืนยันและตอนแสดงผลลัพธ์ จึงต้องอ่านหลังกดยืนยันแล้วเท่านั้น
${Popup_DialogText}            //div[@id='swal2-html-container']
 
# บัญชีที่ใช้สร้างข้อมูลตั้งต้นของ TC04 - เติมค่าก่อนรัน
# Farmer คนที่ 1 ใช้บัญชีทดสอบกลางที่หัวไฟล์ ส่วนคนที่ 2 ใช้สร้างการจองที่ช่วงเวลาชนกัน (เคส TC04_F02)
${AB_FARMER1_USER}    ${TEST_FARMER_USER}
${AB_FARMER1_PASS}    ${TEST_FARMER_PASS}
${AB_FARMER2_USER}    ${EMPTY}
${AB_FARMER2_PASS}    ${EMPTY}
# ชื่ออุปกรณ์ที่ใช้จอง ต้องเป็นอุปกรณ์ของบัญชี Owner ที่ใช้ทดสอบ ไม่งั้นรายการจองจะไปโผล่ที่ Owner คนอื่น
${AB_EQ_NAME}         ${EMPTY}
 
#-------------------------------------------------------------------------
# System Flow Testing (F-MAIN) : ข้อมูลนำเข้าตามตารางในเอกสาร ข้อ 9.1 หน้า 125 - 142
# บัญชีที่ใช้ (F-MAIN-02, F-MAIN-03) ใช้บัญชีทดสอบกลางที่หัวไฟล์
 
# F-MAIN-06 : ต้องเป็นอุปกรณ์ของ ${TEST_OWNER_USER} ไม่งั้นรายการจองจะไปโผล่ที่ Owner คนอื่น
${FM_EQ_NAME}          รถแทรกเตอร์
 
# F-MAIN-08 : เอกสารระบุ 19/06/2569 - 23/06/2569 ซึ่งผ่านมาแล้ว ระบบจะปิดไม่ให้เลือกบนปฏิทิน
# จึงนับวันจากวันที่รันแทน โดยคงระยะเวลาเช่า 5 วันเท่าเอกสาร
${FM_START_OFFSET}     ${3}
${FM_END_OFFSET}       ${7}
${FM_BOOK_ADDRESS}     111 หมู่3 ต.หนองหาร อ.สันทราย จ.เชียงใหม่ 52214

# F-MAIN-25 - F-MAIN-27 : หน้ารับอุปกรณ์ เป็นหน้าเดียวกับหน้าส่งคืน ต่างกันที่ปุ่มบนการ์ดตามสถานะของรายการ
${Pickup_farmerURL}    ${Return_farmerURL}
${Btn_ReceiptEQ}       //button[contains(text(),'ยืนยันรับอุปกรณ์')]

# F-MAIN-31 - F-MAIN-33 : หน้ารับคืนอุปกรณ์ของเจ้าของอุปกรณ์
${Return_ownerURL}       ${Base_URL}/owner/delivery
${Btn_ConfirmReturned}   //button[contains(text(),'ยืนยันรับคืน')]
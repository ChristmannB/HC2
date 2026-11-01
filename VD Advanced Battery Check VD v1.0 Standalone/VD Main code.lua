--[[
Advanced Battery Check VD - Version 1.0 (Standalone version)
Copyright (c) 2018 Zoran Sankovic - Sankotronic (Author). All Rights Reserved. 
--]]
-- [[Battery Check Global Variables: 
	BatteryLang
	BatteryMain
	BatteryStatus
	BattertyTable
	ProductTable
	
--]]--

-- PART OF CODE FOR USERS TO EDIT AND SETUP
-- here you can set preffered language. If left empty then VD will get
-- language selected on HC2
local language = ""

-- here you can set preffered time format. find details in User Manual
local timeformat = "%H:%M %d.%m.%y"

-- setup VD icons ID (just upload icons to HC2 and setup here their ID
-- numbers. VD will set all icons even for the buttons.
local icon_update = 1007
local icon_91_100 = 1008
local icon_81_90  = 1009
local icon_51_80  = 1010
local icon_36_50  = 1011
local icon_26_35  = 1012
local icon_16_25  = 1013
local icon_1_15   = 1014
local icon_0      = 1015
local icon_dead   = 1016
local icon_error  = 1017

-- END OF CODE PART FOR USERS TO EDIT AND SETUP
-- THE CODE BELOW DOES NOT REQUIRE MODIFICATION BY THE USER
local hc=fibaro
-- VD settings
local selfId=hc:getSelfId()
local sId=tostring(selfId)
local codeVersion,tableVersion,vdVersion,chVersion="1.0","1.0","1.0","1.0"
local _name,_role="Advanced Battery Check VD","Battery"
local crt="Standalone ".._name.." version "..codeVersion.." - (c) 2018 Sankotronic"
local icn_main,delay_second=1,7
local updButton,sort_by,lng,_skip="11","battery","",5
local currency=hc:get(selfId, "IPAddress")
-- global variable names
local VirtualTableName="BatteryMain"
local BatteryTableName="BatteryTable"
local BatteryStatusName="BatteryStatus"
local ProductTableName="ProductTable"
local BatteryLangName="BatteryLang"
-- debug variables
local bsdebug=true
local crc,okc,erc,evc,xec,cnc,xcc,tmc,stc="green","lightgreen","red","orange","yellow","cyan","pink","magenta","lightgray"
-- other local settings

function logbug(color,message)
	for line in message:gmatch("[^\010\013]+")do 
	local txt=line:gsub("([\038\060\062])",
	function(c)return"&#"..string.byte(c)..";"end) 
	hc:debug(('<span style="color:%s">%s</span>'):format(color,txt))
	end 
end

function chkLang(lang,dbg)
  local ok=false local l={"en","pl","de","sv","pt","it","fr","nl","ro","br","et","lv","cn","ru","ua","dk","fi","cz","us","es","sk","hr","ba","rs","si","no","hu","bg"}
  if lang~="" and lang~=nil then 
								for i=1,#l do 
								if lang==l[i] then ok=true end 
								end 
  end
  if dbg then 
	if ok then logbug(okc,string.format("Selected language is '%s'",lang))
	else
		if lang~="" then logbug(erc,string.format("ERROR - Selected language '%s' is invalid. Will use HC default language.",lang))
		else logbug(evc,"No language selected. Will use HC default language.")
		end 
	end 
  end 
return ok
end

function chkGlobal(n,d)
	local function ab(t)
		if d then logbug(erc,string.format("ERROR - %s.",t)) end
	return false 
	end 
local g,c,a="Global variable '","' is corrupted",true
local vT=hc:getGlobalValue(n) local ok, cT=pcall(json.decode, vT)
  if vT==nil then a=ab(g..n.."' is missing.") 
  else if not ok then a=ab("JSON decode failed with error: "..cT) 
	else 	if type(cT)~="table" then a=ab(g..n.."' is not a table.")
			else
				if n==BatteryStatusName 	then if cT.version==nil 		then a=ab(g..n..c)end
				elseif n==BatteryStatusName then if cT.version==nil 		then a=ab(g..n..c)end
				elseif n==BatteryTableName 	then if cT.bat==nil 			then a=ab(g..n..c)end
				elseif n==BatteryLangName 	then if cT["en"]==nil 			then a=ab(g..n..c)end
				elseif n==ProductTableName 	then if cT.product_list==nil 	then a=ab(g..n..c)end
				end 
			end 
	end 
  end 
return a 
end

function chgVDicon(id,icn)
  icn=tonumber(icn)icn=icn or 1 id=tostring(id)id=id or tostring(hc:getSelfId())
  local HC2=Net.FHttp("127.0.0.1",11111)local pld="/api/virtualDevices/"..id local r,s,e=HC2:GET(pld)
  if tonumber(e)==0 and tonumber(s)==200 and r~=nil and r~="" then local jT=json.decode(r)jT.properties.deviceIcon=icn
    for y,row in pairs(jT.properties.rows) do 
		for x,element in pairs(row.elements)do
			if element.buttonIcon~=nil then element.buttonIcon=icn end
		end 
	end 
	r,s,e=HC2:PUT(pld,json.encode(jT))
  else logbug(erc,string.format("ERROR - Unable to change VD icons. Error: %s",e))
  end 
end

function chkVDicon(id,icn)
  if chkGlobal(VirtualTableName)then
    icn=tonumber(icn)icn=icn or 1 id=tostring(id)id=id or tostring(hc:getSelfId())
    local erm,err,ok="Icon with id [%s] does not exist. Aborting icon check","Missing VD data. Will try again",false
    local vT=json.decode(hc:getGlobalValue(VirtualTableName))logbug(evc,"Checking VD icons")
    if vT[id]~=nil then 
		if vT[id].icon[icn]~=nil then 
			local api_icn=api.get("/icons/")
			local ap_vd=api.get("/devices/"..id)
			for k,v in pairs(api_icn.virtualDevice)do 
				if vT[id].icon[icn]._id==v.id then ok=true end
			end
		if ok and vT[id].icon[icn]._id~=ap_vd.properties.deviceIcon then
			if vT[id].upd_icon==0 then vT[id].icon[icn]._id=ap_vd.properties.deviceIcon hc:setGlobal(VirtualTableName,json.encode(vT))
			else
			vT[id].upd_icon=0 hc:setGlobal(VirtualTableName,json.encode(vT))
			end 
		chgVDicon(selfId,vT[id].icon[icn]._id)
		elseif vT[id].icon[icn]._id~=ap_vd.properties.deviceIcon then
			if ap_vd.properties.deviceIcon>0 then vT[id].icon[icn]._id=ap_vd.properties.deviceIcon hc:setGlobal(VirtualTableName,json.encode(vT))
			else 
			vT[id].icon[icn]._id=1 hc:setGlobal(VirtualTableName,json.encode(vT)) chgVDicon(selfId,vT[id].icon[icn]._id)end end
		else logbug(erc,string.format(erm,icn))
		end vT[id].upd_icon=0 
	hc:setGlobal(VirtualTableName,json.encode(vT))
    else logbug(erc,err)
	end
  end 
end

function chkGlobalVar()
  local gvm,aem,gvc,chgLng="Global variable '%s' ","already exist","table version changed. Updated",false
  local _api=api.get("/settings/info")if chkLang(language,true)then lng=language else lng=_api.defaultLanguage end
  local ap_vd=api.get("/devices/"..selfId)
  if currency==nil or currency=="" then  currency="€" end
  local virtualGlobal=json.encode({[sId]={or_name=_name,us_name=ap_vd.name,roomID=ap_vd.roomID,icon={{_id=icon_update,desc="Battery update"},
    {_id=icon_91_100,desc="Battery 91-100%"},{_id=icon_81_90,desc="Battery 81-90%"},{_id=icon_51_80,desc="Battery 51-80%"},
    {_id=icon_36_50,desc="Battery 36-50%"},{_id=icon_26_35,desc="Battery 26-35%"},{_id=icon_16_25,desc="Battery 16-25%"},
    {_id=icon_1_15,desc="Battery 1-15%"},{_id=icon_0,desc="Battery 0%"},{_id=icon_dead,desc="Dead device"},{_id=icon_error,desc="Icon error"}},
    role=_role,lng=lng,time=timeformat,skip=_skip,sort=sort_by,chm="",nt=true,mailAll=false,time=timeformat,updButton=updButton,
    currency=currency,upd_icon=0,upd_flag=1,version=vdVersion}})
  local batteryLang=json.encode({
    ["en"]={title="Battery check",subTitle="Following devices need your attention:",lang="English"},
    ["pl"]={title="Poziom Naładowania Baterii",subTitle="Następujące urządzenia wymagają uwagi:",lang="Polski"},
    ["de"]={title="Batteriekontrolle",subTitle="Folgende Ger\195\164te brauchen Ihre Aufmerksamkeit:",lang="Deutsch"},
    ["sv"]={title="Batterikontroll",subTitle="F\195\182ljande enheter beh\195\182ver kontrolleras:",lang="Svenska"},
    ["pt"]={title="Verificação de baterias",subTitle="Os seguintes dispositivos precisam da sua atenção:",lang="Portugues"},
    ["it"]={title="Controllo della batteria",subTitle="I seguenti dispositivi richiedono l\226\128\153attenzione:",lang="Italiano"},
    ["fr"]={title="Verifications batteries",subTitle="Les appareils suivants ont besoin de votre attention:",lang="Francais"},
    ["nl"]={title="Batterij contr\195\180le",subTitle="Volgende apparaten hebben aandacht nodig:",lang="Nederlands"},
    ["ro"]={title="Verificare baterii",subTitle="Urmatoarele module au nevoie de verificare:",lang="Romanian"},
    ["br"]={title="Verificação de baterias",subTitle="Os seguintes dispositivos precisam da sua atenção:",lang="Portugues do Brasil"},
    ["et"]={title="Patareide kontrollimine",subTitle="Järgmised seadmed vajavad teie tähelepanu:",lang="Eesti keel"},
    ["lv"]={title="Bateriju pārbaude",subTitle="Šādām ierīcēm nepieciešama jūsu uzmanība:",lang="Latvių"},
    ["cn"]={title="电池检查",subTitle="以下设备需要您的注意:",lang="中文"},
    ["ru"]={title="Проверка батареи",subTitle="Обратите внимания на следующие устройства:",lang="Русский"},
    ["ua"]={title="Перевірка батареі",subTitle="Зверніть увагу на наступні пристрої:",lang="Українська"},
    ["dk"]={title="Batteri tjek",subTitle="F\195\184lgende enheder har brug for din opm\195\166rksomhed:",lang="Dansk"},
    ["fi"]={title="Paristot tarkistetaan",subTitle="Seuraavat laitteet tarvitsevat huomiota:",lang="Suomalainen"},
    ["cz"]={title="Kontrola baterií",subTitle="Následující zařízení vyžadují vaší pozornost:",lang="Český"},
    ["us"]={title="Battery check",subTitle="Following devices need your attention:",lang="US English"},
    ["es"]={title="Control de baterias",subTitle="Los siguientes dispositivos necesitan tu atención:",lang="Español"},
    ["sk"]={title="Kontrola batérií",subTitle="Nasledujúce zariadenia potrebujú vašu pozornosť:",lang="Slovenčina"},
    ["hr"]={title="Provjera baterija",subTitle="Sljedeći uređaji trebaju vašu pozornost:",lang="Hrvatski"},
    ["ba"]={title="Provera baterija",subTitle="Sledeći uređaji trebaju vašu pozornost:",lang="Bosanski"},
    ["rs"]={title="Tест батерија",subTitle="Потребно је обратити пажњу на следеће уређаје:",lang="Српски"},
    ["si"]={title="Preverite baterijo",subTitle="Naslednje naprave potrebujejo vašo pozornost:",lang="Slovenski"},
    ["no"]={title="Batterisjekk",subTitle="F\195\184lgende enheter trenger tilsyn:",lang="Norsk"},
    ["hu"]={title="Az elemek ellenőrzik",subTitle="A következő eszközökre van szükség a figyelmedben:",lang="Magyar"},
    ["bg"]={title="Проверка на батериите",subTitle="Следните устройства се нуждаят от вашето внимание:",lang="български"},
  })
  local statusTable=json.encode({dev={},dev_list={},dev_max=0,dev_last=0,count=0,sort=sort_by,skip={},skip_list={},skip_max=0,skip_last=0,version={code=codeVersion,table=tableVersion}})
  local battTable=json.encode({bat={["ER14250 ½AA 3.6V"]={price=0,currency=""},["CR14250 ½AA 3.0V"]={price=0,currency=""},
    ["CR123A, 3.0V"]={price=0,currency=""},["CR2450 3.0V"]={price=0,currency=""},["CR2 3.0V"]={price=0,currency=""},["AAA"]={price=0,currency=""},
    ["AA"]={price=0,currency=""},["C/LR14 1.5V"]={price=0,currency=""},["CR2032"]={price=0,currency=""},["CR1216"]={price=0,currency=""},
    ["6F22 9.0V"]={price=0,currency=""},["LiMnO2 3.0V"]={price=0,currency=""},["Rechargeable"]={price=0,currency="x"},["Unknown"]={price=0,currency="x"},["\226\157\147"]={price=0,currency="x"}},
    bat_list={"ER14250 ½AA 3.6V","CR14250 ½AA 3.0V","CR123A, 3.0V","CR2450 3.0V","CR2 3.0V","AAA","AA","C/LR14 1.5V","CR2032","CR1216","6F22 9.0V","LiMnO2 3.0V","Rechargeable","Unknown","\226\157\147"},bat_max=15,bat_last=1})
  local productTable=json.encode({
    ["1,15,15,1,16,0,3,2"]={dev_type="com.fibaro.FGPB101",dev_name="The Button",zversion="3.2",company="Fibargroup",bat_type="ER14250 ½AA 3.6V",bat_pcs=1,total_price=0},
    ["1,15,18,1,16,0,3,2"]={dev_type="com.fibaro.FGCD001",dev_name="CO Sensor",zversion="3.2",company="Fibargroup",bat_type="CR123A, 3.0V",bat_pcs=1,bat_price=0,total_price=0,currency=""},
    ["1,15,7,0,16,0,2,1"]={dev_type="com.fibaro.doorWindowSensor",dev_name="Door/Window Sensor",zversion="2.1",company="Fibargroup",bat_type="ER14250 ½AA 3.6V",bat_pcs=1,bat_price=0,total_price=0,currency=""},
    ["1,15,7,0,16,0,2,5"]={dev_type="com.fibaro.doorWindowSensor",dev_name="Door/Window Sensor",zversion="2.5",company="Fibargroup",bat_type="ER14250 ½AA 3.6V",bat_pcs=1,bat_price=0,total_price=0,currency=""},
    ["1,15,7,2,16,0,3,2"]={dev_type="com.fibaro.doorWindowSensor",dev_name="Door/Window Sensor",zversion="3.2",company="Fibargroup",bat_type="ER14250 ½AA 3.6V",bat_pcs=1,bat_price=0,total_price=0,currency=""},
    ["1,15,7,1,16,1,3,2"]={dev_type="com.fibaro.doorWindowSensor",dev_name="Door/Window Sensor",zversion="3.2",company="Fibargroup",bat_type="ER14250 ½AA 3.6V",bat_pcs=1,bat_price=0,total_price=0,currency=""},
    ["1,15,11,0,16,1,23,23"]={dev_type="com.fibaro.FGFS101",dev_name="Flood Sensor",zversion="23.23",company="Fibargroup",bat_type="CR123A, 3.0V",bat_pcs=1,bat_price=0,total_price=0,currency=""},
    ["1,15,11,0,16,1,25,25"]={dev_type="com.fibaro.FGFS101",dev_name="Flood Sensor",zversion="25.25",company="Fibargroup",bat_type="CR123A, 3.0V",bat_pcs=1,bat_price=0,total_price=0,currency=""},
    ["1,15,11,1,16,2,3,2"]={dev_type="com.fibaro.FGFS101",dev_name="Flood Sensor",zversion="3.2",company="Fibargroup",bat_type="CR123A, 3.0V",bat_pcs=1,bat_price=0,total_price=0,currency=""},
    ["1,15,16,1,16,0,3,2"]={dev_type="com.fibaro.FGKF601",dev_name="KeyFob",zversion="3.2",company="Fibargroup",bat_type="CR2450 3.0V",bat_pcs=1,bat_price=0,total_price=0,currency=""},
    ["1,15,8,0,16,1,2,8"]={dev_type="com.fibaro.FGMS001",dev_name="Motion Sensor",zversion="2.8",company="Fibargroup",bat_type="CR123A, 3.0V",bat_pcs=1,bat_price=0,total_price=0,currency=""},
    ["1,15,8,1,16,1,3,2"]={dev_type="com.fibaro.FGMS001v2",dev_name="Motion Sensor",zversion="3.2",company="Fibargroup",bat_type="CR123A, 3.0V",bat_pcs=1,bat_price=0,total_price=0,currency=""},
    ["0,134,0,2,0,100,1,7"]={dev_type="com.fibaro.motionSensor",dev_name="MS6",zversion="1.7",company="AEON Labs",bat_type="CR123A, 3.0V",bat_pcs=1,bat_price=0,total_price=0,currency=""},
    ["1,15,12,0,16,0,2,5"]={dev_type="com.fibaro.FGSS001",dev_name="Smoke Sensor",zversion="2.5",company="Fibargroup",bat_type="CR123A, 3.0V",bat_pcs=1,bat_price=0,total_price=0,currency=""},
    ["1,15,19,1,16,0,4,4"]={dev_type="com.fibaro.FGT001",dev_name="Heat controller",zversion="4.4",company="Fibargroup",bat_type="Rechargeable",bat_pcs=1,bat_price=0,total_price=0,currency=""},
    ["1,15,12,2,16,2,3,3"]={dev_type="com.fibaro.FGSS001",dev_name="Smoke Sensor",zversion="3.3",company="Fibargroup",bat_type="CR123A, 3.0V",bat_pcs=1,bat_price=0,total_price=0,currency=""},
    ["82,84,0,1,133,16,1,1"]={dev_type="com.fibaro.remoteController",dev_name="Remote controller",zversion="1.1",company="Remotec",bat_type="AAA",bat_pcs=2,bat_price=0,total_price=0,currency=""},
    ["82,84,0,1,133,16,1,2"]={dev_type="com.fibaro.remoteController",dev_name="Remote controller",zversion="1.2",company="Remotec",bat_type="AAA",bat_pcs=2,bat_price=0,total_price=0,currency=""},
    ["1,9,32,5,5,8,15,3"]={dev_type="com.fibaro.binarySwitch",dev_name="Siren",zversion="15.3",company="Vision Security",bat_type="AA",bat_pcs=4,bat_price=0,total_price=0,currency=""},
    ["0,134,0,2,0,130,1,8"]={dev_type="com.fibaro.remoteController",dev_name="WallMote",zversion="1.8",company="AEON Labs",bat_type="Rechargeable",bat_pcs=1,bat_price=0,total_price=0,currency=""},
    ["1,21,1,0,1,1,1,1"]={dev_type="com.fibaro.remoteController",dev_name="WallSwitch",zversion="1.1",company="Z-Wave.Me",bat_type="CR2032",bat_pcs=1,bat_price=0,total_price=0,currency=""},
    ["1,60,0,2,0,32,1,14"]={dev_type="com.fibaro.temperatureSensor",dev_name="Temp. Sensor",zversion="1.14",company="Philio Technology Corp",bat_type="CR123A, 3.0V",bat_pcs=1,bat_price=0,total_price=0,currency=""},
    ["2,96,128,7,16,0,2,0"]={dev_type="com.fibaro.humiditySensor",dev_name="Humidity Sensor",zversion="2.0",company="Haozee",bat_type="CR2450 3.0V",bat_pcs=1,bat_price=0,total_price=0,currency=""},
    ["0,96,1,1,0,1,1,0"]={dev_type="com.fibaro.motionSensor",dev_name="Motion Sensor",zversion="1.0",company="Everspring",bat_type="AA",bat_pcs=3,bat_price=0,total_price=0,currency=""},
    ["1,14,0,8,0,2,1,2"]={dev_type="com.fibaro.gerda",dev_name="Door Lock",zversion="1.2",company="Poly-control",bat_type="CR123A, 3.0V",bat_pcs=4,bat_price=0,total_price=0,currency=""},
    ["0,134,0,2,0,5,1,18"]={dev_type="com.fibaro.motionSensor",dev_name="Motion Sensor",zversion="1.18",company="AEON Labs",bat_type="AAA",bat_pcs=4,bat_price=0,total_price=0,currency=""},
    ["0,96,0,11,0,1,1,3"]={dev_type="com.fibaro.floodSensor",dev_name="Flood Sensor",zversion="1.3",company="Everspring",bat_type="AA",bat_pcs=3,bat_price=0,total_price=0,currency=""},
    ["0,96,0,13,0,1,1,5"]={dev_type="com.fibaro.smokeSensor",dev_name="Smoke Sensor",zversion="1.5",company="Everspring",bat_type="6F22 9.0V",bat_pcs=1,bat_price=0,total_price=0,currency=""},
    ["0,89,0,15,0,1,1,0"]={dev_type="com.fibaro.multilevelSensor",dev_name="Water Meter",zversion="1.0",company="Horstmann Controls Limited",bat_type="Unknown",bat_pcs=1,bat_price=0,total_price=0,currency=""},
    ["0,96,0,6,0,1,1,6"]={dev_type="com.fibaro.temperatureSensor",dev_name="Temp. Sensor",zversion="1.6",company="Everspring",bat_type="AA",bat_pcs=3,bat_price=0,total_price=0,currency=""},
    product_max=30,product_last=1,product_list={"1,15,15,1,16,0,3,2","1,15,18,1,16,0,3,2","1,15,7,0,16,0,2,1","1,15,7,0,16,0,2,5","1,15,7,2,16,0,3,2","1,15,7,1,16,1,3,2",
    "1,15,11,0,16,1,23,23","1,15,11,0,16,1,25,25","1,15,11,1,16,2,3,2","1,15,16,1,16,0,3,2","1,15,8,0,16,1,2,8","1,15,8,1,16,1,3,2","0,134,0,2,0,100,1,7",
    "1,15,12,0,16,0,2,5","1,15,19,1,16,0,4,4","1,15,12,2,16,2,3,3","82,84,0,1,133,16,1,1","82,84,0,1,133,16,1,2","1,9,32,5,5,8,15,3","0,134,0,2,0,130,1,8",
    "1,21,1,0,1,1,1,1","1,60,0,2,0,32,1,14","2,96,128,7,16,0,2,0","0,96,1,1,0,1,1,0","1,14,0,8,0,2,1,2","0,134,0,2,0,5,1,18","0,96,0,11,0,1,1,3",
    "0,96,0,13,0,1,1,5","0,89,0,15,0,1,1,0","0,96,0,6,0,1,1,6",}})
  local varName={
    [VirtualTableName]={value=virtualGlobal,isEnum=true,isTable=true,enumValue={"Table"}},
    [BatteryStatusName]={value=statusTable,isEnum=true,isTable=true,enumValue={"Table"}},
    [BatteryTableName]={value=battTable,isEnum=true,isTable=true,enumValue={"Table"}},
    [ProductTableName]={value=productTable,isEnum=true,isTable=true,enumValue={"Table"}},
    [BatteryLangName]={value=batteryLang,isEnum=true,isTable=true,enumValue={"Table"}}}
  for i,v in pairs(varName)do
    local function build(nam,val,enum,tbl,dbug)
      if dbug=="add"then a="creating"b="created"elseif dbug=="upd"then a="updating"b="updated"else a="recreating"b="recreated"end
    	api.put("/globalVariables/"..nam,{name=nam,value=val,isEnum=true,enumValues=enum})
      if tbl then local ok,msg=pcall(function()wT=json.decode(hc:getGlobalValue(nam))if type(wT)~="table" then error()end end)
        if not ok then logbug(erc,string.format("ERROR - "..gvm.."table '%s' was unsuccessful",nam,a))
          logbug(erc,string.format("ERROR code: %s",msg)) else logbug(okc,string.format(gvm.."%s successfully.",nam,b))end
      else if hc:getGlobalValue(nam)~=nil then logbug(okc,string.format(gvm.."%s successfully.",nam,b))else
        logbug(erc,string.format("ERROR - "..gvm.."table '%s' was unsuccessful",nam,a))
    end end end
    if hc:getGlobalValue(i)==nil then api.post("/globalVariables/",{name=i})hc:sleep(400)build(i,v.value,v.enumValue,v.isTable,"add")end
    if i==VirtualTableName then
      if chkGlobal(i)then logbug(evc,string.format(gvm..aem,i))
        local vT=json.decode(hc:getGlobalValue(i))local vd_table=json.decode(virtualGlobal)
        if vT[sId]==nil then
          vT[sId]=vd_table[sId] hc:setGlobal(i,json.encode(vT))logbug(xec,string.format("VD data added to "..gvm,i))
          if vT[sId].lng~=lng then chgLng=true end
        elseif vT[sId].version==nil or vT[sId].version~=vdVersion then
          if #vT[sId].icon==#vd_table[sId].icon then vd_table[sId].icon=vT[sId].icon end
          vd_table[sId].upd_flag=0 vT[sId]=vd_table[sId] hc:setGlobal(i,json.encode(vT))
          logbug(xec,string.format(gvm..gvc,i))if vT[sId].lng~=lng then chgLng=true end
        elseif vT[sId].us_name~=ap_vd.name or vT[sId].roomID~=ap_vd.roomID or vT[sId].lng~=lng or vT[sId].time~=timeformat or
          vT[sId].currency~=currency or vT[sId].icon[1]._id~=icon_update or vT[sId].icon[2]._id~=icon_91_100 or
          vT[sId].icon[3]._id~=icon_81_90 or vT[sId].icon[4]._id~=icon_51_80 or vT[sId].icon[5]._id~=icon_36_50 or
          vT[sId].icon[6]._id~=icon_26_35 or vT[sId].icon[7]._id~=icon_16_25 or vT[sId].icon[8]._id~=icon_1_15 or
          vT[sId].icon[9]._id~=icon_0 or vT[sId].icon[10]._id~=icon_dead or vT[sId].icon[11]._id~=icon_error then
          vT[sId].us_name=ap_vd.name vT[sId].roomID=ap_vd.roomID vT[sId].time=timeformat vT[sId].lng=lng
          if vT[sId].icon[1]._id~=icon_update then vT[sId].upd_icon=1 end
          vT[sId].time=timeformat vT[sId].currency=currency vT[sId].icon[1]._id=icon_update vT[sId].icon[2]._id=icon_91_100
          vT[sId].icon[3]._id=icon_81_90 vT[sId].icon[4]._id=icon_51_80 vT[sId].icon[5]._id=icon_36_50
          vT[sId].icon[6]._id=icon_26_35 vT[sId].icon[7]._id=icon_16_25 vT[sId].icon[8]._id=icon_1_15
          vT[sId].icon[9]._id=icon_0 vT[sId].icon[10]._id=icon_dead vT[sId].icon[11]._id=icon_error
          hc:setGlobal(i,json.encode(vT))logbug(xec,string.format("VD data updated in "..gvm,i))end
    else build(i,v.value,v.enumValue,v.isTable,"rec")end end
    if i==BatteryLangName then if chkGlobal(i)then logbug(evc,string.format(gvm..aem,i))else build(i,v.value,v.enumValue,v.isTable,"upd")end end
    if i==BatteryStatusName then if chkGlobal(i)then logbug(evc,string.format(gvm..aem,i))else build(i,v.value,v.enumValue,v.isTable,"rec")end end
    if i==BatteryTableName then if chkGlobal(i)then logbug(evc,string.format(gvm..aem,i))
      if currency~=nil and currency~="" then local bT=json.decode(hc:getGlobalValue(BatteryTableName))
        if bT.bat[bT.bat_list[1]].currency~=currency then
          for k,v in pairs(bT.bat)do v.currency=currency end hc:setGlobal(BatteryTableName,json.encode(bT))end end
    else build(i,v.value,v.enumValue,v.isTable,"upd")end end
    if i==ProductTableName then if chkGlobal(i)then logbug(evc,string.format(gvm..aem,i))else build(i,v.value,v.enumValue,v.isTable,"upd")end end
  end
  updateVar=true chkVDicon(selfId,icn_main)
  hc:call(selfId,"pressButton",updButton)
end

function updStatus()
  local ms1="ERROR - Global variable '%s' will be recreated"
  if chkGlobal(VirtualTableName,true)then
  if chkGlobal(BatteryStatusName,true)then
  if chkGlobal(BatteryTableName,true)then
  if chkGlobal(ProductTableName,true)then
  if chkGlobal(BatteryLangName,true)then
    local vT=json.decode(hc:getGlobalValue(VirtualTableName))
    if vT[sId]==nil then chkGlobalVar() vT=json.decode(hc:getGlobalValue(VirtualTableName)) else
      if vT[sId].upd_flag>0 then vT[sId].upd_flag=0 hc:setGlobal(VirtualTableName,json.encode(vT))end
      if vT[sId].upd_icon>0 then chkVDicon(selfId,icn_main)end
    end
  else logbug(erc,string.format(ms1,BatteryLangName))chkGlobalVar()end
  else logbug(erc,string.format(ms1,ProductTableName))chkGlobalVar()end
  else logbug(erc,string.format(ms1,BatteryTableName))chkGlobalVar()end
  else logbug(erc,string.format(ms1,BatteryStatusName))chkGlobalVar()end
  else logbug(erc,string.format(ms1,VirtualTableName))chkGlobalVar()end
  logbug(okc,"VD updated")hc:sleep(delay_second*1000)
end

-- MAIN CODE PART
  if not updateVar then logbug(crc,crt)chkGlobalVar()hc:sleep(500)updStatus()else updStatus()end
  
  ------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------
  
--  Button31 🔄 (Refresh)
-- Check battery VD - Update button

-- PART OF CODE FOR USERS TO EDIT AND SETUP
-- GLOBAL VARIABLES
-- get the table of device & scene ID's from global variable HomeTable. If
-- using then uncomment below line else leave it as it is!
--local jT=json.decode(fibaro:getGlobalValue("HomeTable"))

-- PUSH MESSAGES AND MOBILE DEVICE SETUP
-- define mobile devices to send push messages. Enter devices inside
-- braces separated by comma
local iosDeviceID={}
-- If no push messages then change bellow setting to false
local push   = true
-- If pushAll is set to true then user will always receive push notification
-- with status of the worst battery level
local pushAll = true
-- If no popup messages then change bellow setting to false
local popup  = false
-- If popupAll is set to true then user will always receive popup notification
-- with list of all battery devices
local popupAll = false
-- define users that will receive e-mail
local userID = {2}

-- END OF CODE PART FOR USERS TO EDIT AND SETUP
-- THE CODE BELOW DOES NOT REQUIRE MODIFICATION BY THE USER
local hc=fibaro
local selfId=hc:getSelfId()
local sId=tostring(selfId)
-- global variable names
local VirtualTableName="BatteryMain"
local BatteryTableName="BatteryTable"
local BatteryStatusName="BatteryStatus"
local ProductTableName="ProductTable"
local BatteryLangName="BatteryLang"
-- debug variables
local bsdebug,evdebug=true,false
local crc,okc,erc,evc,xec,cnc,xcc,tmc,stc="green","lightgreen","red","orange","yellow","cyan","pink","magenta","lightgray"
-- get global variables data
local vT=json.decode(hc:getGlobalValue(VirtualTableName))
local bT=json.decode(hc:getGlobalValue(BatteryTableName))
local bS=json.decode(hc:getGlobalValue(BatteryStatusName))
local bL=json.decode(hc:getGlobalValue(BatteryLangName))
local pT=json.decode(hc:getGlobalValue(ProductTableName))
local lng=vT[sId].lng
local timeformat=vT[sId].time
local cHM=os.date(timeformat)
local sy={bw_sum="\226\136\145",question='\226\157\147',single_ex="\226\157\151\239\184\143",off='\226\157\140',battery="\240\159\148\139",
  dir='\240\159\154\169',memo="\240\159\147\157",plug="\240\159\148\140",ok='\226\156\133',package="\240\159\147\166",new_sign="\240\159\134\149",
  month="\240\159\147\134",factory="\240\159\143\173",dollar_bnote="\240\159\146\181",refresh="\240\159\148\132",id_sign="\240\159\134\148",
  home='\240\159\143\160',signal="\240\159\147\182",rewind="\226\143\170",ffwd="\226\143\169",cd="\240\159\146\191",in_envelope="\240\159\147\168"}
-- some local variables
local preWarningLevel,warningLevel,replaceLevel,rechargeLevel=35,25,15,20
local eTitle,eHeader,eMessage1,eMessage2,eMessage3,eMessage4,eFlag="","","","","","",false
local pushMessage,pTitle,pMessage,pImage,pType="","","",0,"Success"
local emailMax,eTotal,currency=15,"\n--------------------------------------------------------------- "..sy.bw_sum.." : %s%s",vT[sId].currency

function logbug(color,message)for line in message:gmatch("[^\010\013]+")do local txt=line:gsub("([\038\060\062])",function(c)return"&#"..string.byte(c)..";"end) hc:debug(('<span style="color:%s">%s</span>'):format(color,txt))end end

function getIcon(sValue) 
  if(sValue>=91)then return vT[sId].icon[2]._id
  elseif(sValue>=81)then return vT[sId].icon[3]._id
  elseif(sValue>=51)then return vT[sId].icon[4]._id
  elseif(sValue>=36)then return vT[sId].icon[5]._id
  elseif(sValue>=26)then return vT[sId].icon[6]._id
  elseif(sValue>=16)then return vT[sId].icon[7]._id
  elseif(sValue>=1)then return vT[sId].icon[8]._id
  elseif(sValue==0)then return vT[sId].icon[9]._id
  else return vT[sId].icon[10]._id end
end 

function spairs(t,order)
  local keys={}for k in pairs(t)do keys[#keys+1]=k end
  if order then table.sort(keys,function(a,b)return order(t,a,b)end)else table.sort(keys)end local i=0
  return function()i=i+1 if keys[i] then return keys[i],t[keys[i]] end end
end

function getDuration(t)
  local r,dur="",os.time()-t
  local y=math.floor(dur/31536000) if y>0 then dur=dur-(y*31536000)r=y.."y, " end
  local m=math.floor(dur/2592000) if m>0 then dur=dur-(m*2592000)r=r..m.."m, " end
  local d=math.floor(dur/86400) if d>0 then dur=dur-(d*86400)r=r..d.."d" end
  if r=="" then r=sy.month.." 0d" else r=sy.month.." "..r end return r
end

function SendPush(message)
  if #iosDeviceID>0 then
    for k,v in pairs(iosDeviceID)do hc:call(v,"sendPush",message)
    if evdebug then logbug(xec,string.format("Push notification sent to mobile device '%s'",hc:getName(v)))end end
    if bsdebug then logbug(xec,"Push notifications sent to mobile devices")end
  end
end

function SendPopup(title,ctitle,body,image,typ)
  if typ==nil or typ=="" then typ="Info" end
  local jNet=api.get("/settings/network")
  local ImgUrl="http://"..jNet.ip.."/fibaro/n_vicons/User"..image..".png"
  if evdebug then logbug(cnc,"Icon path: "..ImgUrl)end
  HomeCenter.PopupService.publish({title=title,subtitle=os.date(timeformat),contentTitle=ctitle,contentBody=body,
    img=ImgUrl,type=typ,buttons={{caption="\226\156\148\239\184\142",sceneId=0}}})
  if bsdebug then logbug(tmc,"Popup notification sent directly to all devices")end
end

function sendMail(title,message)
  if #userID>0 then
    for k,v in pairs(userID)do hc:call(v,"sendEmail",title,message)
    if evdebug then logbug(xcc,"e-mail notification sent to user "..hc:getName(v))end end
  else logbug(erc,"ERROR - No users defined. Please define users to receive e-mail")end
  if bsdebug then logbug(xcc,"E-mail notification sent to users")end
end

function displayNil()
  hc:call(selfId,"setProperty","ui.Label1.value",sy.battery.." "..sy.question.."["..sy.question.."] "..sy.question.." ("..sy.question..")")
  hc:call(selfId,"setProperty","ui.Label2.value",sy.battery.." "..sy.question.." x 0 @ 0 "..vT[sId].currency)
  hc:call(selfId,"setProperty","ui.Label3.value",sy.new_sign.." "..sy.question.." - "..sy.month.." "..sy.question)
  hc:call(selfId,"setProperty","ui.Label4.value",sy.refresh.." "..cHM.." - "..sy.package.." 0/0")
  hc:call(selfId,"setProperty","ui.Label8.value",sy.package.." "..sy.question)
  hc:call(selfId,"setProperty","ui.Label10.value",sy.factory.." "..sy.question.." - "..sy.cd.." "..sy.question)
  hc:call(selfId,"setProperty","ui.Label11.value",sy.battery.." "..sy.question.." x 0 @ 0 "..vT[sId].currency)
  hc:call(selfId,"setProperty","currentIcon",vT[sId].icon[11]._id)
end

function main()
  local sort,device,sorted={},{},{}
  local push,popup="",""
  local label1,label2,label3,room="","","",""
  local p,no,n,k,et,total=0,0,0,0,1,0
  local prevNodeId,ignoreDevice=nil,false
  local arg='?interface=battery&enabled=true&visible=true'
  local dev=api.get('/devices/'..arg)
  -- Check battery devices records and remove devices that are not present in the system
  if #bS.dev_list>0 then
    if bsdebug then logbug(okc,"Checking list for deleted or reconfigured battery devices")end
    for k,v in pairs(bS.dev)do
      local api_d=api.get("/devices/"..k)
      if api_d==nil then
        if evdebug then logbug(evc,string.format("Device ID[%s] %s (%s) not found. Deleting from the list.",k,v.name,v.room))end bS.dev[k]=nil
      else if evdebug then logbug(okc,string.format("Device ID[%s] %s (%s) found OK.",k,v.name,v.room))end
      end end hc:setGlobal(BatteryStatusName,json.encode(bS))
    if bsdebug then logbug(okc,"List of battery devices checked OK.")end
  else if bsdebug then logbug(xec,"Battery devices list is empty, nothing to check.")end end
  if #dev>0 then
    if bsdebug then logbug(okc,"Getting list of battery operated devices")end
    -- start looping through devices found
    for i=1,#dev do
      if dev[i].roomID==nil or dev[i].roomID==0 then room="Unassigned" else room=hc:getRoomName(dev[i].roomID)end
      if prevNodeId~=dev[i].properties.nodeId then no=no+1
        if #bS.skip_list>0 then ignoreDevice=false for _,id in pairs(bS.skip_list)do if dev[i].id==tonumber(id) then ignoreDevice=true 
          if bsdebug then logbug(evc,string.format("Skipping device ID [%s] %s (%s)",dev[i].id,dev[i].name,hc:getRoomName(dev[i].roomID)))end
        end end end
        if not ignoreDevice then
          local level=tonumber(dev[i].properties.batteryLevel)
          if level==255 then level=0 elseif level>=100 and level<255 then level=100 end
          if dev[i].properties.dead=="true" then level=-1 end
          if pT[dev[i].properties.productInfo]==nil or pT[dev[i].properties.productInfo].bat_type==sy.question then level=-1
            if bsdebug then logbug(evc,string.format("Device [%s] %s (%s) is new product or missing battery info",dev[i].id,dev[i].name,room))end end
          if vT[sId].sort=="device" then sort[dev[i].id]=dev[i].id elseif vT[sId].sort=="room" then sort[dev[i].id]=dev[i].roomID else sort[dev[i].id]=level end
          device[dev[i].id]={id=dev[i].id,nid=dev[i].properties.nodeId,name=dev[i].name,room=room,product=dev[i].properties.productInfo,
            type=dev[i].type,ver=dev[i].properties.zwaveVersion,company=dev[i].properties.zwaveCompany,rb_last=dev[i].modified,lb_last=level,
            dead=dev[i].properties.dead}
          prevNodeId=dev[i].properties.nodeId
        else
          prevNodeId=dev[i].properties.nodeId
          if bS.dev[tostring(dev[i].id)]~=nil then bS.dev[tostring(dev[i].id)]=nil
            if evdebug then logbug(xec,string.format("Deleting ignored device [%s] %s (%s) from the list",dev[i].id,dev[i].name,dev[i].room))end end
        end
      end
    end
    if bsdebug then if vT[sId].sort=="device" then logbug(cnc,"Sorting device table with lowest device ID first")
      elseif vT[sId].sort=="room" then logbug(cnc,"Sorting device table with lowest room ID first")
      else logbug(cnc,"Sorting device table with lowest battery level first")end end
    -- sort found battery devices according to user selected sorting value
    for i,v in spairs(sort,function(t,a,b)return t[b]>t[a]end)do k=k+1
      sorted[k]={id=device[i].id,nid=device[i].nid,name=device[i].name,room=device[i].room,product=device[i].product,type=device[i].type,
        ver=device[i].ver,company=device[i].company,rb_last=device[i].rb_last,lb_last=device[i].lb_last,dead=device[i].dead}
    end bS.dev_list={} bS.dev_max=1 bS.dev_last=1 if evdebug then logbug(okc,"Updating devices table")end
    -- loop trough the sorted devices found add or update their recods
    for k,v in pairs(sorted)do local id=tostring(v.id) n=n+1
      if pT[v.product]==nil then if v.company==nil or v.company=="" then v.company=sy.question end
        pT[v.product]={dev_type=v.type,dev_name=v.name,zversion=v.ver,company=v.company,bat_type=sy.question,bat_pcs=1,bat_price=0,total_price=0,currency=""}
        if evdebug then logbug(xcc,string.format("Found new product [%s] %s (%s), Company: %s",v.id,v.name,v.room,v.company))end 
        if evdebug then logbug(xec,"Please set battery type and price with Battery Set VD")end
      end
      -- check if found device is new and add record or edit existing
      if bS.dev[id]==nil then
        local lb_prev,lb_last=v.lb_last,v.lb_last
        local rb_prev,rb_last=v.rb_last,v.rb_last
          bS.dev[id]={_id=v.id,_nid=v.nid,product=v.product,type=v.type,name=v.name,room=v.room,
            rb_prev=rb_prev,rb_last=rb_last,lb_prev=lb_prev,lb_last=lb_last}
        if evdebug then logbug(okc,string.format("Adding new device [%s] %s (%s) battery at: %s%%",id,v.name,v.room,v.lb_last))end
      else
        if bS.dev[id].lb_last>=0 then
          if bS.dev[id].lb_last>v.lb_last then bS.dev[id].lb_prev=bS.dev[id].lb_last bS.dev[id].lb_last=v.lb_last
          elseif bS.dev[id].lb_last<v.lb_last then bS.dev[id].lb_prev=bS.dev[id].lb_last bS.dev[id].lb_last=v.lb_last
            if bsdebug then logbug(okc,string.format("Battery replaced on %s",os.date(timeformat,bS.dev[id].rb_last)))end
            bS.dev[id].rb_prev=bS.dev[id].rb_last bS.dev[id].rb_last=os.time()
          end
        else bS.dev[id].lb_last=v.lb_last if v.lb_last==100 then bS.dev[id].rb_prev=bS.dev[id].rb_last bS.dev[id].rb_last=os.time()
          if bsdebug then logbug(okc,string.format("Battery replaced on %s",os.date(timeformat,bS.dev[id].rb_last)))end end
        end
          bS.dev[id].name=v.name bS.dev[id].room=v.room
        if evdebug then logbug(xec,string.format("Updating device [%s] %s (%s) battery at: %s%%",v.id,v.name,v.room,v.lb_last))end
      end
      -- check device batteries status and report
      bS.dev_list[n]=id local pi=bS.dev[id].product local bt=pT[pi].bat_type
      local emb,erb,pms="%s %s%% %s [%s] %s (%s) %s%s x %s @ %s%s\n","%s %s%% %s [%s] %s (%s) %s%s\n","%s - %s%% [%s] %s (%s)\n"
      local dur=sy.new_sign.." "..os.date(timeformat,bS.dev[id].rb_last)..getDuration(bS.dev[id].rb_last)
      if bt~="Rechargeable" then
        if v.lb_last<0 or bt==sy.question then 
          if vT[sId].nt then if k<=emailMax then eMessage1=eMessage1..string.format(emb,sy.single_ex,sy.off,dur,v.id,v.name,v.room,sy.battery,bt,pT[pi].bat_pcs,bT.bat[bt].price,bT.bat[bt].currency)
          elseif k<=(emailMax*2) then eMessage2=eMessage2..string.format(emb,sy.single_ex,sy.off,dur,v.id,v.name,v.room,sy.battery,bt,pT[pi].bat_pcs,bT.bat[bt].price,bT.bat[bt].currency)
          elseif k<=(emailMax*3) then eMessage3=eMessage3..string.format(emb,sy.single_ex,sy.off,dur,v.id,v.name,v.room,sy.battery,bt,pT[pi].bat_pcs,bT.bat[bt].price,bT.bat[bt].currency)
          else eMessage4=eMessage4..string.format(emb,sy.single_ex,sy.off,dur,v.id,v.name,v.room,sy.battery,bt,pT[pi].bat_pcs,bT.bat[bt].price,bT.bat[bt].currency)end
          total=total+(pT[pi].bat_pcs*bT.bat[bt].price)end
          if popup then pMessage=pMessage..string.format(pms,sy.single_ex,sy.off,v.id,v.name,v.room)end
          if push and p<4 then p=4 end if bsdebug then logbug(erc,string.format(pms,sy.single_ex,sy.off,v.id,v.name,v.room))end
          eFlag=true if pImage<10 then pImage=10 pType="Critical" end if eHeader=="" then eHeader=bL[lng].subTitle.."\n\n" end
        elseif v.lb_last<=replaceLevel then
          if vT[sId].nt then if k<=emailMax then eMessage1=eMessage1..string.format(emb,sy.single_ex,v.lb_last,dur,v.id,v.name,v.room,sy.battery,bt,pT[pi].bat_pcs,bT.bat[bt].price,bT.bat[bt].currency)
          elseif k<=(emailMax*2) then eMessage2=eMessage2..string.format(emb,sy.single_ex,v.lb_last,dur,v.id,v.name,v.room,sy.battery,bt,pT[pi].bat_pcs,bT.bat[bt].price,bT.bat[bt].currency)
          elseif k<=(emailMax*3) then eMessage3=eMessage3..string.format(emb,sy.single_ex,v.lb_last,dur,v.id,v.name,v.room,sy.battery,bt,pT[pi].bat_pcs,bT.bat[bt].price,bT.bat[bt].currency)
          else eMessage4=eMessage4..string.format(emb,sy.single_ex,v.lb_last,dur,v.id,v.name,v.room,sy.battery,bt,pT[pi].bat_pcs,bT.bat[bt].price,bT.bat[bt].currency)end
          total=total+(pT[pi].bat_pcs*bT.bat[bt].price)end
          if popup then pMessage=pMessage..string.format(pms,sy.single_ex,v.lb_last,v.id,v.name,v.room)end
          if push and p<3 then p=3 end if bsdebug then logbug(erc,string.format(pms,sy.single_ex,v.lb_last,v.id,v.name,v.room))end
          eFlag=true if pImage<9 then pImage=9 pType="Critical" end if eHeader=="" then eHeader=bL[lng].subTitle.."\n\n" end
        elseif v.lb_last<=warningLevel then
          if vT[sId].nt then if k<=emailMax then eMessage1=eMessage1..string.format(emb,sy.dir,v.lb_last,dur,v.id,v.name,v.room,sy.battery,bt,pT[pi].bat_pcs,bT.bat[bt].price,bT.bat[bt].currency)
          elseif k<=(emailMax*2) then eMessage2=eMessage2..string.format(emb,sy.dir,v.lb_last,dur,v.id,v.name,v.room,sy.battery,bt,pT[pi].bat_pcs,bT.bat[bt].price,bT.bat[bt].currency)
          elseif k<=(emailMax*3) then eMessage3=eMessage3..string.format(emb,sy.dir,v.lb_last,dur,v.id,v.name,v.room,sy.battery,bt,pT[pi].bat_pcs,bT.bat[bt].price,bT.bat[bt].currency)
          else eMessage4=eMessage4..string.format(emb,sy.dir,v.lb_last,dur,v.id,v.name,v.room,sy.battery,bt,pT[pi].bat_pcs,bT.bat[bt].price,bT.bat[bt].currency)end
          total=total+(pT[pi].bat_pcs*bT.bat[bt].price)end
          if popup then pMessage=pMessage..string.format(pms,sy.dir,v.lb_last,v.id,v.name,v.room)end
          if push and p<2 then p=2 end if bsdebug then logbug(evc,string.format(pms,sy.dir,v.lb_last,v.id,v.name,v.room))end
          eFlag=true if pImage<7 then pImage=7 pType="Warning" end if eHeader=="" then eHeader=bL[lng].subTitle.."\n\n" end
        elseif v.lb_last<=preWarningLevel then
          if vT[sId].nt then if k<=emailMax then eMessage1=eMessage1..string.format(emb,sy.memo,v.lb_last,dur,v.id,v.name,v.room,sy.battery,bt,pT[pi].bat_pcs,bT.bat[bt].price,bT.bat[bt].currency)
          elseif k<=(emailMax*2) then eMessage2=eMessage2..string.format(emb,sy.memo,v.lb_last,dur,v.id,v.name,v.room,sy.battery,bt,pT[pi].bat_pcs,bT.bat[bt].price,bT.bat[bt].currency)
          elseif k<=(emailMax*3) then eMessage3=eMessage3..string.format(emb,sy.memo,v.lb_last,dur,v.id,v.name,v.room,sy.battery,bt,pT[pi].bat_pcs,bT.bat[bt].price,bT.bat[bt].currency)
          else eMessage4=eMessage4..string.format(emb,sy.memo,v.lb_last,dur,v.id,v.name,v.room,sy.battery,bt,pT[pi].bat_pcs,bT.bat[bt].price,bT.bat[bt].currency)end
          total=total+(pT[pi].bat_pcs*bT.bat[bt].price)end
          if popup then pMessage=pMessage..string.format(pms,sy.memo,v.lb_last,v.id,v.name,v.room)end
          if push and p<1 then p=1 end if bsdebug then logbug(xec,string.format(pms,sy.memo,v.lb_last,v.id,v.name,v.room))end
          eFlag=true if pImage<5 then pImage=5 pType="Info" end if eHeader=="" then eHeader=bL[lng].subTitle.."\n\n" end
        else if popup and popupAll then pMessage=pMessage..string.format(pms,sy.battery,v.lb_last,v.id,v.name,v.room)
            if pImage<2 then pImage=2 end end
          if vT[sId].nt and vT[sId].mailAll then if k<=emailMax then eMessage1=eMessage1..string.format(emb,sy.battery,v.lb_last,dur,v.id,v.name,v.room,sy.battery,bt,pT[pi].bat_pcs,bT.bat[bt].price,bT.bat[bt].currency)
          elseif k<=(emailMax*2) then eMessage2=eMessage2..string.format(emb,sy.battery,v.lb_last,dur,v.id,v.name,v.room,sy.battery,bt,pT[pi].bat_pcs,bT.bat[bt].price,bT.bat[bt].currency)
          elseif k<=(emailMax*3) then eMessage3=eMessage3..string.format(emb,sy.battery,v.lb_last,dur,v.id,v.name,v.room,sy.battery,bt,pT[pi].bat_pcs,bT.bat[bt].price,bT.bat[bt].currency)
          else eMessage4=eMessage4..string.format(emb,sy.battery,v.lb_last,dur,v.id,v.name,v.room,sy.battery,bt,pT[pi].bat_pcs,bT.bat[bt].price,bT.bat[bt].currency)end end
          if bsdebug then logbug(okc,string.format(pms,sy.battery,v.lb_last,v.id,v.name,v.room))end
        end
      else
        if v.lb_last<=rechargeLevel then
          if vT[sId].nt then if k<=emailMax then eMessage1=eMessage1..string.format(erb,sy.single_ex,v.lb_last,dur,v.id,v.name,v.room,sy.plug,bt)
          elseif k<=(emailMax*2)then eMessage2=eMessage2..string.format(erb,sy.single_ex,v.lb_last,dur,v.id,v.name,v.room,sy.plug,bt)
          elseif k<(emailMax*3)then eMessage3=eMessage3..string.format(erb,sy.single_ex,v.lb_last,dur,v.id,v.name,v.room,sy.plug,bt)
          else eMessage4=eMessage4..string.format(erb,sy.single_ex,v.lb_last,dur,v.id,v.name,v.room,sy.plug,bt)end end
          if popup then pMessage=pMessage..string.format(pms,sy.single_ex,v.lb_last,v.id,v.name,v.room)end
          if push and p<3 then p=3 end if bsdebug then logbug(erc,string.format(pms,sy.single_ex,v.lb_last,v.id,v.name,v.room))end
          eFlag=true if pImage<9 then pImage=9 pType="Critical" end if eHeader=="" then eHeader=bL[lng].subTitle.."\n\n" end
        else
          if vT[sId].nt and vT[sId].mailAll then if k<=emailMax then eMessage1=eMessage1..string.format(erb,sy.plug,v.lb_last,dur,v.id,v.name,v.room,sy.plug,bt)
          elseif k<=(emailMax*2)then eMessage2=eMessage2..string.format(erb,sy.plug,v.lb_last,dur,v.id,v.name,v.room,sy.plug,bt)
          elseif k<(emailMax*3)then eMessage3=eMessage3..string.format(erb,sy.plug,v.lb_last,dur,v.id,v.name,v.room,sy.plug,bt)
          else eMessage4=eMessage4..string.format(erb,sy.plug,v.lb_last,dur,v.id,v.name,v.room,sy.plug,bt)end end
          if popup and popupAll then pMessage=pMessage..string.format(pms,sy.plug,v.lb_last,v.id,v.name,v.room) if pImage<2 then pImage=2 end end
          if bsdebug then logbug(okc,string.format(pms,sy.plug,v.lb_last,v.id,v.name,v.room))end
        end
      end
    end bS.dev_max=n
    hc:setGlobal(ProductTableName,json.encode(pT))hc:setGlobal(BatteryStatusName,json.encode(bS))
    if vT[sId].nt then
      local aP=api.get("/settings/info")eTitle=aP.hcName.." "..bL[lng].title if eHeader=="" then eHeader=eTitle.."\n\n" end
      if eFlag or vT[sId].mailAll then local tot=string.format(eTotal,string.format("%.2f",total),currency)
        if eMessage4~="" then et=4 eMessage4=eMessage4..tot elseif eMessage3~="" then et=3 eMessage3=eMessage3..tot
        elseif eMessage2~="" then et=2 eMessage2=eMessage2..tot else eMessage1=eMessage1..tot end
        if eMessage1~="" then sendMail(eTitle.." 1/"..et,eHeader..eMessage1)end
        if eMessage2~="" then hc:sleep(300)sendMail(eTitle.." 2/"..et,eHeader..eMessage2)end
        if eMessage3~="" then hc:sleep(300)sendMail(eTitle.." 3/"..et,eHeader..eMessage3)end
        if eMessage4~="" then hc:sleep(300)sendMail(eTitle.." 4/"..et,eHeader..eMessage4)end
      end
      if popup and (eFlag or popupAll) then if pImage==0 then pImage=2 end SendPopup(bL[lng].title,eTitle,pMessage,vT[sId].icon[pImage]._id,pType)end
      if push and (eFlag or pushAll) then pushMessage=sy.battery.." "..bL[lng].title.." "
        if p>=3 then pushMessage=pushMessage..sy.single_ex elseif p==2 then pushMessage=pushMessage..sy.dir
        elseif p==1 then pushMessage=pushMessage..sy.memo else pushMessage=pushMessage..sy.ok end
        SendPush(pushMessage)end
    else
      logbug(evc,"Notifications are disabled.")
    end vT[sId].chm=cHM hc:setGlobal(VirtualTableName,json.encode(vT))
    if #bS.dev_list>0 then
      local _id=bS.dev_list[bS.dev_last] local s=sy.battery local l=bS.dev[_id].lb_last.."% "
      local pi=bS.dev[_id].product local bt=pT[pi].bat_type
      if bS.dev[_id].lb_last<0 then l=sy.off.." " end if bt==sy.question then l=sy.question end
      if bt~="Rechargeable" then
        label2=sy.battery.." "..bt.." x "..pT[pi].bat_pcs.." @ "..string.format("%.2f",bT.bat[bt].price).." "..bT.bat[bt].currency
        if bS.dev[_id].lb_last<=replaceLevel then s=sy.single_ex elseif bS.dev[_id].lb_last<=warningLevel then s=sy.dir
        elseif bS.dev[_id].lb_last<=preWarningLevel then s=sy.memo end
      else label2=sy.plug.." "..bt if bS.dev[_id].lb_last<=rechargeLevel then s=sy.single_ex..sy.plug else s=sy.plug end end
      label1=string.format("%s %s%s [%s] %s (%s)",s,l,sy.package,_id,bS.dev[_id].name,bS.dev[_id].room)
      label3=string.format("%s %s - %s",sy.new_sign,os.date(timeformat,bS.dev[_id].rb_last),getDuration(bS.dev[_id].rb_last))
      hc:call(selfId,"setProperty","ui.Label1.value",label1)
      hc:call(selfId,"setProperty","ui.Label2.value",label2)
      hc:call(selfId,"setProperty","ui.Label3.value",label3)
      hc:call(selfId,"setProperty","ui.Label4.value",string.format("%s %s - %s %s/%s",sy.refresh,cHM,sy.package,bS.dev_last,bS.dev_max))
      hc:call(selfId,"setProperty","ui.Label8.value",string.format("%s %s",sy.package,pT[pi].dev_type))
      hc:call(selfId,"setProperty","ui.Label10.value",string.format("%s %s - %s %s",sy.factory,pT[pi].company,sy.cd,pT[pi].zversion))
      hc:call(selfId,"setProperty","ui.Label11.value",label2)
      if #bS.skip_list>0 then local id=bS.skip_list[bS.skip_last]
        hc:call(selfId,"setProperty","ui.Label7.value",string.format("%s [%s] %s (%s) %s/%s",sy.package,id,bS.skip[id].name,bS.skip[id].room,bS.skip_last,bS.skip_max))
      else hc:call(selfId,"setProperty","ui.Label7.value",string.format("%s [] () %s/%s",sy.package,bS.skip_last,bS.skip_max))end
      hc:call(selfId,"setProperty","currentIcon",getIcon(bS.dev[_id].lb_last))
    else displayNil()logbug(erc,"There is no battery devices to display")end
  else displayNil()logbug(erc,"There is no battery devices on this system")end
  local sortl=sy.battery.." "..sy.signal
  local note=sy.in_envelope.." " if not vT[sId].nt then note=note..sy.off else if vT[sId].mailAll then note=note..sy.battery else note=note..sy.single_ex end end
  if vT[sId].sort=="device" then sortl=sy.package.." "..sy.id_sign elseif vT[sId].sort=="room" then sortl=sy.home.." "..sy.id_sign end
  hc:call(selfId,"setProperty","ui.Label6.value",string.format("%s - %s - %s x %s",note,sortl,sy.rewind..sy.ffwd,vT[sId].skip))
end

-- MAIN CODE
main()

--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
-- Button41 🔋 📶
-- Check battery VD - Sort by battery level button

-- THE CODE BELOW DOES NOT REQUIRE MODIFICATION BY THE USER
local hc=fibaro
local selfId=hc:getSelfId()
local sId=tostring(selfId)
-- global variable names
local VirtualTableName="BatteryMain"
local BatteryStatusName="BatteryStatus"
-- debug variables
local bsdebug,evdebug=true,false
local crc,okc,erc,evc,xec,cnc,xcc,tmc,stc="green","lightgreen","red","orange","yellow","cyan","pink","magenta","lightgray"
-- get global variables data
local vT=json.decode(hc:getGlobalValue(VirtualTableName))
local bS=json.decode(hc:getGlobalValue(BatteryStatusName))
local sy={bw_sum="\226\136\145",question='\226\157\147',single_ex="\226\157\151\239\184\143",off='\226\157\140',battery="\240\159\148\139",
  dir='\240\159\154\169',memo="\240\159\147\157",plug="\240\159\148\140",ok='\226\156\133',package="\240\159\147\166",new_sign="\240\159\134\149",
  month="\240\159\147\134",factory="\240\159\143\173",dollar_bnote="\240\159\146\181",refresh="\240\159\148\132",id_sign="\240\159\134\148",
  home='\240\159\143\160',signal="\240\159\147\182",rewind="\226\143\170",ffwd="\226\143\169",cd="\240\159\146\191",in_envelope="\240\159\147\168"}

function logbug(color,message)for line in message:gmatch("[^\010\013]+")do local txt=line:gsub("([\038\060\062])",function(c)return"&#"..string.byte(c)..";"end) hc:debug(('<span style="color:%s">%s</span>'):format(color,txt))end end

function getIcon(sValue) 
  if(sValue>=91)then return vT[sId].icon[2]._id
  elseif(sValue>=81)then return vT[sId].icon[3]._id
  elseif(sValue>=51)then return vT[sId].icon[4]._id
  elseif(sValue>=36)then return vT[sId].icon[5]._id
  elseif(sValue>=26)then return vT[sId].icon[6]._id
  elseif(sValue>=16)then return vT[sId].icon[7]._id
  elseif(sValue>=1)then return vT[sId].icon[8]._id
  elseif(sValue==0)then return vT[sId].icon[9]._id
  else return vT[sId].icon[10]._id end
end 

function main()
  local _id=bS.dev_list[bS.dev_last]
  vT[sId].sort="battery"
  hc:setGlobal(VirtualTableName,json.encode(vT))
  local sortl=sy.battery.." "..sy.signal
  local note=sy.in_envelope.." " if not vT[sId].nt then note=note..sy.off else if vT[sId].mailAll then note=note..sy.battery else note=note..sy.single_ex end end
  if vT[sId].sort=="device" then sortl=sy.package.." "..sy.id_sign elseif vT[sId].sort=="room" then sortl=sy.home.." "..sy.id_sign end
  hc:call(selfId,"setProperty","ui.Label6.value",string.format("%s - %s - %s x %s",note,sortl,sy.rewind..sy.ffwd,vT[sId].skip))
  if _id~=nil then hc:call(selfId,"setProperty","currentIcon",getIcon(bS.dev[_id].lb_last))
  else hc:call(selfId,"setProperty","currentIcon",vT[sId].icon[11]._id)end
end

-- MAIN CODE
main()
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------


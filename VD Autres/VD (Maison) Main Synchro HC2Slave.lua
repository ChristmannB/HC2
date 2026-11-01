--[[
%% properties
%% events
%% globals
--]]
--=============================================================
--Scene Id25 Netatmo Battery Check  V2.1 (ajout de Netatmo Empire) - Test boucle d'attente 
--=============================================================
--Need to add to VD Id 856 the display of battery ID & name into its "Label2" 

fibaro:debug("Lancement : "..fibaro:getSourceTriggerType()) 	  	
mnduree = fibaro:getGlobal("Mduree") --en mn
hinterval = fibaro:getGlobal("Hinterval") -- en h

--fibaro:debug("Durée de la boucle 1 : ".. mnduree .."mn")
msduree = tonumber(mnduree)*60/1000   --/1000 for test
--fibaro:debug("Durée de la boucle 1 : ".. msduree .."s")
local i = 0
--fibaro:debug("i = "..i)
while true do
	if i<=tonumber(msduree)
  	then 
    fibaro:sleep(1000)
    i=tonumber(i)+1
  	  	 
	else 
    fibaro:debug("réinitialisation du compteur i à 0")
  	i=0
  --  fibaro:debug("i = "..i)
    break
    --fibaro:abort()
  	end
  --fibaro:debug("i = "..i)
  	local TpsRest= msduree-i
  	--fibaro:debug("Temps restant "..TpsRest.."s")
end  
--fibaro:debug("on est bien sorti de la boucle 1")
-----------------------seconde tempo
--fibaro:debug("Durée de la boucle 2 : ".. hinterval .."h")
hintervalm = tonumber(hinterval)*60
--fibaro:debug("Durée de la boucle 2 : ".. hintervalm .."mn")
hintervals = hinterval*0.1 --*6 pour 54s
--fibaro:debug("Deuxième tempo modifiée pour test à "..hintervals.."s")

local j = 0
--fibaro:debug("i = "..i)
while true do
	if j<=tonumber(hintervals)
  	then 
    fibaro:sleep(1000)
    j=tonumber(j)+1
  	  	 
	else 
  --  fibaro:debug("réinitialisation du compteur j à 0")
  	j=0
    --fibaro:debug("j = "..j)
    break
    --fibaro:abort()
  	end
  --fibaro:debug("i = "..i)
  	local TpsRest2= hintervals-j
  	--fibaro:debug("Temps restant "..TpsRest2.."s")
end  
fibaro:debug("on est bien sorti de la 2ème boucle")
---------------------------------------------------------
local location=""
local indoorTable=fibaro:getGlobal("NetatmoWeather")
local dataTable=json.decode(indoorTable)

local fullBatTable={}
--local ind=0 --fibaro:debug("line71 "..json.encode(batTable))
--fibaro:debug("---------------------------------------------------------------------------")
--	fibaro:debug("line73 indoorTable: "..type(indoorTabledataTable: ", "typen dataTable: "..type(dataTable))
fibaro:debug("------------Calcul niveaux batteries modules Netatmo -------------------------")
for k in pairs(dataTable) do
  if k=="netatmo"then
  	--fibaro:debug("line76, Data: "..json.encode(k))
  	--fibaro:debug("line77, type netatmo: "..type(k))
      for _,v in ipairs(dataTable[k]) do
      --local ind=ind+1 fibaro:debug("Index: "..ind)
      local batTable={} 
fibaro:debug("---------------------------------------------------------------------------")
      --  fibaro:debug(json.encode(v)) 
fibaro:debug("---------------------------------------------------------------------------")
        if     v["_id"]=="70:ee:50:12:41:2a" then location = "Langey"
        elseif v["_id"]=="70:ee:50:3f:6f:90" then location = "Saint Loup"
		elseif v["_id"]=="70:ee:50:3f:24:8a" then location = "Empire"
        end
        fibaro:debug("line89 "..location.." Main module Mac address: "..v["_id"])
      batTable.location=location
      batTable.mac=v["_id"]
fibaro:debug("---------------------------------------------------------------------------")
      --fibaro:debug("line93 batt rain "..v.rain.name..": "..v.rain.batt.."%")
      batTable.rain=v.rain.batt
fibaro:debug("---------------------------------------------------------------------------")
      --fibaro:debug("line96 batt wind "..v.wind.name..": "..v.wind.batt.."%")
      batTable.wind=v.wind.batt
fibaro:debug("---------------------------------------------------------------------------")
      --fibaro:debug("line98 batt out "..v.outm.name..": "..v.outm.batt.."%")
      batTable.out=v.outm.batt
fibaro:debug("---------------------------------------------------------------------------")
          for j,w in ipairs(v.intm)do 
            fibaro:debug("module interne: "..v.intm[i].name)
          if v.intm[j].name=="Indoor2" then
            fibaro:debug("line105 No indoor2 module")
            elseif v.intm[j].name=="Indoor3" then
            fibaro:debug("line107 No indoor3 module")
            elseif v["_id"]=="70:ee:50:3f:24:8a" then fibaro:debug("line108 No indor1 module")
			else fibaro:debug("line109 batt int "..v.intm[j].name..": "..v.intm[j].batt.."%") 
          local modInt=v.intm[j].name
            batTable.modInt=v.intm[j].batt
          end
fibaro:debug("---------------------------------------------------------------------------")
      end
--fibaro:debug("line115 "..json.encode(batTable))
      table.insert(fullBatTable,batTable)

      end
   
  end
end
fibaro:debug("---------------------------------------------------------------------------")

fibaro:debug("line124 - Full Table: "..json.encode(fullBatTable))

fibaro:debug("-------------- Alerting when battery low (Push) -----------------------------")
local minBatt=40  -- level for alerting level "Warning"
local lieu=""
local moduleLevel=0
local niveau=" Warming️ "
local popTitle="ALARME NETATMO"
local popContTitle="Niveau de batterie faible"
local img="User1011.png"

local popImage= "http://192.168.1.10/fibaro/n_vicons/User1011.png"

function popup(popBody,img)
  	HomeCenter.PopupService.publish({
	title        = popTitle,
	subtitle     = os.date("%H:%M:%S | %d.%m.%Y."),
	contentTitle = popContTitle,
	contentBody  = popBody,
	img          = "http://192.168.1.10/fibaro/n_vicons/"..img,
	type         = popType,
	buttons      = { { caption = "Disarm", sceneId = 0 },
    	             { caption = "Cancel", sceneId = 0 } }
	})
end

function alert(l,m,b)
  lowBat=minBatt*0.3 print("Line 151 - Niveau de battery très faible : :"..lowBat)
  if tonumber(b) < lowBat then niveau="Urgent" img="User1013.png"  else niveau="Attention" img="User1011.png" end
  print("Line 153 - fonction alerte Batterie Netatmo activée, niveau "..niveau.." pour "..l..", batterie "..m.." : "..b)
  popBody="Alerte Batterie Netatmo, niveau '"..niveau.."', pour "..l..", batterie "..m.." : "..b
  popup(popBody,img)
  end 
  
for _,z in ipairs(fullBatTable) do
  lieu=z.location
  if z.modInt then 
	if tonumber(z.modInt)>0 and tonumber(z.modInt)<minBatt then alert(lieu,"modInt",z.modInt) 
	print("Alert "..lieu..", modInt: "..tonumber(z.modInt)) 
	fibaro:call(856,'setProperty','ui.Label3.value',"Int "..lieu..z.modInt.."%")
	end 
  end

  if (tonumber(z.rain)>0 and tonumber(z.rain)<minBatt) then alert(lieu,"rain",tonumber(z.rain)) 
    print("Alert "..lieu..", rain: "..z.rain) 
	fibaro:call(856,'setProperty','ui.Label3.value',"Pluie "..lieu..", "..z.rain.."%") 
  end

  if (tonumber(z.wind)>0 and tonumber(z.wind)<minBatt) then alert(lieu,"wind",tonumber(z.wind)) 
	print("Alert "..lieu..", wind: "..z.wind)
	fibaro:call(856,'setProperty','ui.Label3.value',"Vent "..lieu..", "..z.modInt.."%")
  end

end


--======================================================================================================
-- VD Synchro Esclave, Main
-- main for chcking HC2 slave status (vonnected or not

--[[ all below is working for devices
local device = 698
localhost = '127.0.0.1'
local port = 11111
diag = Net.FHttp(localhost, port);
response = diag:GET("/api/devices/"..device)
result = json.decode(response);
fibaro:debug("name: "..result.name)
fibaro:debug("properties.value: "..result.properties.value)--]]--
fibaro:debug("----- Start VD HC2 slave synch -----")
local VDiD = fibaro:getSelfId()
fibaro:debug("VD id: "..VDiD)
local localhost = '127.0.0.1'
local port = 11111
diag = Net.FHttp(localhost, port);
response = diag:GET("/api/remoteGateways")
fibaro:debug("response: "..response) --.OK.
result=json.decode(response)
fibaro:debug("Result: "..json.encode(result))

fibaro:debug(result[1].name) --OK


if result[1].connected then
  fibaro:debug(result[1].name.." connectée ".."\240\159\164\168")
  fibaro:call(VDiD,"setProperty","ui.Label1.value",result[1].name.." connectée - ".."\240\159\164\168")
  fibaro:call(VDiD,"setProperty","currentIcon",1056)  
else fibaro:debug(result[1].name.." déconnectée ".."\226\157\151\239\184\143")
  fibaro:call(VDiD,"setProperty","ui.Label1.value",result[1].name.." déconnectée - ".."\226\157\151\239\184\143")
  fibaro:call(VDiD,"setProperty","currentIcon",1057)  
end
--fibaro:debug("----- End VD HC2 slave synch -----")
function pressButtonSynch()
  fibaro:call(VDiD,"pressButton",3)
 local dateAppui=os.date("*t")
  fibaro:debug("Le bouton Synchronisation a été activé le "..dateAppui['day'].."/"..dateAppui['month'].." à "..dateAppui['hour']..":"..dateAppui['moin'])
  fibaro:call(VDiD,"setProperty","ui.Label2.value",dateAppui['day'].."/"..dateAppui['month'].." à "..dateAppui['hour']..":"..dateAppui['moin'])
  end
fibaro:sleep(5000)
pressButtonSynch()
fibaro:sleep(24*60*60*1000)

--=================================================================================================================

{
"name":"Synchronize",
"type":"virtual_device",
"properties":
	{
	"deviceIcon":0,
	"categories":"[\"other\"]",
	"currentIcon":"0",
	"log":"",
	"logTemp":"",
	"mainLoop":"",
	"visible":"true",
	"rows":[
		{"type":"button",
		"elements":[{"id":1,
		"lua":false,
		"waitForResponse":true,
		"caption":"Synchronize",
		"name":"Button11",
		"empty":false,
		"msg":"
				-- create http client for controller with set IP address\n
				HC2 = Net.FHttp(\"10.1.120.10\",80)\n
				-- set login credentials for controller\n
				HC2:setBasicAuthentication(\"admin\", \"admin\")\n
				response ,status, errorCode = HC2:GET(\"/api/remoteGateways?id=1\")\n
				idTable = {}\n
				for i, ids in ipairs(json.decode(response)[\"deviceMapping\"]) do\n
				idTable[i]=ids[2]\n
				end\n
				request = json.encode({remoteGatewayId=1,synchronize=idTable})\n\n\n\n
				response ,status, errorCode = HC2:POST(\"/api/remoteGateways/synchronizeDevices\", request)\n
				fibaro:debug(status)","buttonIcon":0,"favourite":false,"main":false}]}]},
		"actions":{
					"pressButton":1,
					"setSlider":2,
					"setProperty":2}
					}



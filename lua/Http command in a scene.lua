%% killOtherInstances --to prevent other instances to run in scene
--it's "Net.FHttp" in Virtual Devices and "net.HTTPClient" in scenes, but with different parameters,
---------------------------------------------------------------------------------------
-- below a code that works in VD and scene #8 Maison (description Device (GET) ou action (POST))
--[[
--%% autostart
-- %% properties
%% events
%% globals

--]]
local HC2G_IP ="192.168.1.11"
local HC2M_IP ="127.0.0.1" -- ou  "192.168.1.10"
local HC2G_Port = 80
local HC2M_Port = 11111
   
fibaro:debug("Adresse IP de HC2-Grange : " .. HC2G_IP .. " ; " .. HC2G_Port)
fibaro:debug("Adresse IP de HC2-Maison : " .. HC2M_IP .. " ; " .. HC2M_Port)



-- Changement de libellé d'un VD via HTTP
--HC2G = net.HTTPClient(HC2G_IP,HC2G_Port)
  
--Allumer la lumière de l'appentis ID 668
-- Demonstration of HTTP code that runs in a "Scene" or in a "Virtual Device"
-- It test the availability of "Net.FHttp()" (for a VD) and alternatively
-- selects "net.HTTPClient()" (for a Scene).
local METHODE = "POST" --POST or GET
local deviceID = 748 --VD 756 -- 544 --748 --668
local IsVD = "false" -- "false" or "true"
local nameId = fibaro:getName(deviceID,"name")
local ACTION = ""
if METHODE =="GET" 
  then ACTION =""
  else
	ACTION = "turnOff" -- or "turnOff" 
  end
  
-- This function processes the data returned from the http call
-- It gets r aw data from the HTTP client and decodes that
-- into a table using the json.decode() function
fibaro:debug("L'Id du module a commander est : ".. deviceID .. " " .. nameId)
function process(responseJSON)
  if #responseJSON == 0 then
    fibaro:debug("Empty response from API. Check ID.")
    return
  end
  jsonTbl= json.decode(responseJSON)
  if jsonTbl==nil then
    fibarop:debug(" Oups... Decode is empty...")
    if #responseJSON == 0 then
      fibaro:debug("HC2 response is valid, but empty")
      return
    end
    fibaro:debug("JSON decode failed for: "..responseJSON)
    return
  end
  -- OK, we got decoded data... Now do something with it
  if METHODE == "GET" 
  then
  -- essai d'impression de la table jsonTbl donne rien...
    for k,v in ipairs(jsonTbl) do print("k: " ..k..", v: "..v) end
print("#operator: "..#jsonTbl)
   ------------------------------------------
  
  fibaro:debug("Device ID: "..jsonTbl.id)
  fibaro:debug("Device Name: "..jsonTbl.name)
  fibaro:debug("Device type: "..jsonTbl.type)
  fibaro:debug("Device ROOM: "..jsonTbl.roomID)
 --   fibaro:debug("ROOM name: "..fibaro:getName(jsonTbl.roomID, "name"))

 	if jsonTbl.enabled  then
      fibaro:debug("Device enabled = yes")
    else 
      fibaro:debug("Device enabled = no")
    end
    
 
    if jsonTbl.visible then
    fibaro:debug("Device is visible")
  	else
    fibaro:debug("Device is HIDDEN")
  	end
	
	fibaro:debug(" adresse IP "..jsonTbl.properties.ip)
    fibaro:debug(" adresse PORT "..jsonTbl.properties.port)
    fibaro:debug(" Property  icône : "..jsonTbl.properties.deviceIcon)
    fibaro:debug(" Property log : "..jsonTbl.properties.log)
	fibaro:debug(" Property LogTemp : "..jsonTbl.properties.logTemp)
    fibaro:debug(" Property current Icon : "..jsonTbl.properties.currentIcon)
    --fibaro:debug(" Property "..jsonTbl.properties.)
    --fibaro:debug(" Property ui.Lable1.value"..jsonTbl.properties.{ui.Label1.value})

  else
    fibaro:debug("Commande "..METHODE.." ".. ACTION .. " envoyée".. " à " .. deviceID .. ", " .. nameId)
  end
  
end

-- http Error handling
function httpError(err)
  fibaro:debug("HTTP call error: " .. err)
end

-- Startup of the code:
-- Generate the URL we need to call
-- For information on the API see:
-- https://developer.fibaro.com
  --if isVD == "false"
  --then 	
		if METHODE =="GET"
  		then api="/api/devices/"..deviceID 
		else api="/api/devices/"..deviceID.."/action/"..ACTION
  		end
  --else api="api/virtualDevices/"..deviceID 
  --end
-- Test availability of http library
if Net ~= nil then
  -- Code for Virtual Device
  --
  --HC2 = Net.FHttp(HC2G_IP..", "..HC2G_Port)
  HC2 = Net.FHttp(HC2M_IP..", "..HC2M_Port)
  if METHODE == "GET"
    then
  	response ,status, errorCode = HC2:GET(api) 
    else 
    response ,status, errorCode = HC2:POST(api) 
    end
  -- TODO check status, errorcode
  process(response)
else
  --Code for Scene
  -- the "Scene" implementation may seem difficult at first,
  -- but that's because it uses a nested table... And functions as
  -- parameters It actually makes sense
  --
  -- As far as I know, on 2015-06-02 this library is not fully documented,
  -- none of the lua libraries I've found implement exactly this
  -- set of parameters
  HC2 = net.HTTPClient()
  if METHODE =="GET"
	then  
     HC2 = net.HTTPClient()
	 HC2:request(
   -- "http://127.0.0.1:11111"..api,
     "http://".. HC2M_IP .. ":" .. HC2M_Port .. api,
    { success = function(resp) process(resp.data) end,
      error =  httpError,
      options = {method = "GET" }
    })
    else
  	 HC2 = net.HTTPClient()
	 HC2:request(
    "http://".. HC2M_IP .. ":" .. HC2M_Port .. api,
    { success = function(resp) process(resp.data) end,
      error =  httpError,
      options = {method = "POST" }
    })
    end
end



------------------------------------------------------------------------------------------
------------- functioning POST in a scene
 local http = net.HTTPClient()
  http:request(("http://127.0.0.1:11111/api/devices/1037/action/setThermostatSetpoint"), {
    options = {
    method = 'POST',
    headers = {
        ['Accept'] = 'application/json',
        ['Content-Type'] = 'application/json'
    },
    data = '{"args":[1,21]}'

      
  },
  success = function(response)
              local result = response.data;
              if response.status == 200 then
                  fibaro:debug(response.status)
                fibaro:debug(response.data)
              else
                  fibaro:debug(response.status)
                fibaro:debug(response.data)
              end
            end,
  error = function(err)
              fibaro:debug('[ERROR] ' .. err)

          end
  }) 
  
---------------------------------------------------------------------------------------  
   --So, here is how to add an authorization header to a HTTPClient call in a scene:

function b64encode(data)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- A sample function with a call to an API which requires authorization
function logger(msg)     
    l=net.HTTPClient({timeout=2000});     
    l:request("http://x.x.x.x:xxxx/logutil",
       {options = {method = 'POST',
                   headers = {['Authorization'] = 'Basic '..b64encode("username:password")},
                   data = json.encode(msg)},
                   success = function(status) 
                      -- Some code if all went well
                   end,
                   error = function(error)
                      -- some code if error response
                   end})  
end
------------------------------------------------------------
--id of VD changing a label
id = 105
--contecting to HC2 to get VD who you want modify
local HC2 = Net.FHttp("127.0.0.1", 11111)
payload = "/api/virtualDevices/" .. id
response, status, errorCode = HC2:GET(payload)
if tonumber(errorCode) == 0 and tonumber(status) == 200 and response ~= nil and response ~= "" then
	jsonTable = json.decode(response)
--changening caption  
  jsonTable.properties.rows[1].elements[1].caption="testazz"
--sending it back  
  local response, status, errorCode = HC2:PUT(payload, json.encode(jsonTable))

end

--After changing label, slider or button caption please refresh HC web GUI interface page and do Refresh Network data on mobile devices to make change visible! 
--------------------------------------------------------
-- changing name of a QA
local deviceID = 517 
local newName = "Whole new name"
api.put("/devices/"..deviceID,{name=newName})
-------------------------------------------------------------

--Table json du VD 756 Test pressButton
 756
Typ: virtual_device
Propriétés:
- categories
- deviceIcon
- ip
- port
- currentIcon
- log
- logTemp
- mainLoop
- ui.Label1.value
- ui.Label2.value
- visible
- rows
Actions:
- pressButton()
- setSlider()
- setProperty()

--http://192.168.1.10:80/api/devices/756
{
  "id": 756,
  "name": "Test pressButton",
  "roomID": 327,
  "type": "virtual_device",
  "visible": true,
  "enabled": true,
  "properties": {
    "categories": "[\"other\"]",
    "deviceIcon": 1001,
    "ip": "192.168.1.11",
    "port": 80,
    "currentIcon": "1001",
    "log": "",
    "logTemp": "",
    "mainLoop": "local ModeChauffeG = fibaro:getGlobal(\"ChauffeauG\")\nlocal Chauffeau_ID = 730 pour la grange\n\nlocal VDID = fibaro:getSelfId() -- obtention de l'identité de ce VD\n\tfibaro:debug(\" Le VD Chauffe-eau Grange\" .. VDID .. \" est lancé\")\n\n-- Récupération de l'adresse IP et du Port inscrit sur le module virtuel\n-- fibaro:getSelfId() retourne l'ID du module virtuel en cours\nlocal ip_VD = fibaro:get(fibaro:getSelfId(), \"IPAddress\")\nlocal port_VD = fibaro:get(fibaro:getSelfId(), \"TCPPort\")\n\nfibaro:debug(\"les valeurs IP de la HC2 à commander sont : \"..ip_VD..\" ; \"..port_VD)\n\n\nfibaro:debug(\"leprogramme est en mode \".. ModeChauffeG)\nfibaro:call(VDID,'setProperty','ui.Label1.value', ModeChauffeG)\nlocal Maintenant = os.date(\"*t\") --stocke la date et heure actuelle du système sous forme d'un tableau à l'intérieur de la variable \"Maintenant\"\n--  Affichage de la date et l'heure\n\n------- Fin du scénario ---------",
    "ui.Label1.value": "HeuresCreuses",
    "ui.Label2.value": "",
    "visible": "true",
    "rows": [
      {
        "type": "label",
        "elements": [
          {
            "id": 1,
            "lua": false,
            "waitForResponse": false,
            "caption": "Mode Chauffeau",
            "name": "Label1",
            "favourite": false,
            "main": false
          }
        ]
      },
      {
        "type": "button",
        "elements": [
          {
            "id": 2,
            "lua": false,
            "waitForResponse": false,
            "caption": "Arrêt",
            "name": "Button11",
            "empty": false,
            "msg": "GET /api/callAction?deviceID=672&name=pressButton&arg1=2 HTTP/1.1\nHost:192.168.1.11\nAuthorization: Basic YnJ1dmllcmVAb3JhbmdlLmZyOjIzNTdCY2N2NzY3Nw==\n\n",
            "buttonIcon": 1002,
            "favourite": false,
            "main": false
          }
        ]
      },
      {
        "type": "button",
        "elements": [
          {
            "id": 3,
            "lua": false,
            "waitForResponse": false,
            "caption": "H. Creuses",
            "name": "Button21",
            "empty": false,
            "msg": "GET /api/callAction?deviceID=672&name=pressButton&arg1=3 HTTP/1.1\nHost:192.168.1.11\nAuthorization: Basic YnJ1dmllcmVAb3JhbmdlLmZyOjIzNTdCY2N2NzY3Nw==\n\n",
            "buttonIcon": 1003,
            "favourite": false,
            "main": true
          },
          {
            "id": 4,
            "lua": false,
            "waitForResponse": false,
            "caption": "Marche forcée",
            "name": "Button22",
            "empty": false,
            "msg": "GET /api/callAction?deviceID=672&name=pressButton&arg1=4 HTTP/1.1\nHost:192.168.1.11\nAuthorization: Basic YnJ1dmllcmVAb3JhbmdlLmZyOjIzNTdCY2N2NzY3Nw==\n\n",
            "buttonIcon": 1004,
            "favourite": false,
            "main": false
          }
        ]
      },
      {
        "type": "label",
        "elements": [
          {
            "id": 5,
            "lua": false,
            "waitForResponse": false,
            "caption": "Mode : ",
            "name": "Label2",
            "favourite": false,
            "main": false
          }
        ]
      }
    ]
---------------------------------------------------------------------------------------------------------------
--[[  Global variables:
	
UI Definition:
1 	Label1 ->Label "Profil Choisi :" -> ID:"Label1
2 	1 Button -> Label "Présence" -> ID:"Button11 -> Lua code: fibaro:setGlobal("Profil","Présence")
		fibaro:call(784,'setProperty','ui.Label1.value', "Présence")
		fibaro:log("Sélection du profil Présence") 
3	2 Button -> Label:"Abscence -> ID:"Button21 -> Lua code: fibaro:setGlobal("Profil","Abscence")
		fibaro:call(784,'setProperty','ui.Label1.value', "Abscence")
		fibaro:log("Sélection du profil Abscence")
			-> Label:"Vacances" -> ID:"Vacances" -> ID:"Button22" Lua code:fibaro:setGlobal("Profil","Vacances")
		fibaro:call(784,'setProperty','ui.Label1.value', "Vacances")
		fibaro:log("Sélection du profil Vacances")
4 	Label2 	->Label:"Chauffeau" -> ID:"Label25	
5	Label3	->Label:"Lumières"-> ID:"Label3"
6	1 button	->Label:Manuel -> ID:"Button31 _>	Luacode:fibaro:setGlobal("Profil","Manuel")
		fibaro:call(784,'setProperty','ui.Label1.value', "Manuel")
		fibaro:log("Sélection du profil Manuel")
Main loop -> --]]--
selfID= fibaro:getSelfId()
fibaro:debug("----- Démarage du VD "..selfID.." ----")
--Vérification de l'état du chauffe-eau
local BallonG = fibaro:getValue(605, "value") -- in maison :local BallonG = fibaro:getValue(811, "value")
local EtatG 
if BallonG == "1"
  then EtatG = "En marche"
  else EtatG = "Arrêt"
  end
fibaro:debug("Etat Chauffe-eau Grange= " .. BallonG .. " soit " .. EtatG)

fibaro:call(selfID,'setProperty','ui.Label2.value', "Grange : "..EtatG)
local message=""

-- Creation de la table des lumières
local deviceList={}
deviceList=api.get("/devices/")
fibaro:debug("Total Nb devices: "..#deviceList)

local lumTable={}
for _,dev in ipairs(deviceList) do
  local light={}
  local cat = dev.properties.categories
  --fibaro:debug(cat)
    if tostring(cat)=='["lights"]' then 
      light["id"]=dev.id
      light["value"]=fibaro:getValue(light.id,"value")
      --fibaro:debug(json.encode(light))
      table.insert(lumTable,light)
    end
end
fibaro:debug("lumTable has "..#lumTable.." elements -> "..json.encode(lumTable))
-- vérification des lumières
-- Liste des interrupteurs de lumières éventuellement "On"
local index=0
for i,lum in ipairs(lumTable) do
  --fibaro:debug(i..", "..lum.id..", "..lum.value)
  if tonumber(lum.value)>0 then 
      fibaro:debug("Device id "..lum.id.." is On")
      index=tonumber(index)+1
   end
--return index  --]]--
end
	fibaro:debug("index= "..index)
	if tonumber(index) >0
	then 
			fibaro:debug("Il reste encore "..index.." lumière(s) allumée(s)")
			message="Pièce(s) allumée(s) : "
			fibaro:call(selfID, 'setProperty', 'ui.Label3.value', index.." swich(s)  ON")
			for _,t in ipairs(lumTable) do
			  local state=tonumber(fibaro:getValue(tonumber(t.id),"value"))
    			--fibaro:debug("state: "..state)
    		  local roomid=api.get("/devices/"..tonumber(t.id))["roomID"]
    			--fibaro:debug("roomID="..roomid)
    		  local piece=api.get("/rooms/"..tonumber(roomid))["name"]
        		--fibaro:debug(piece)
			  --fibaro:debug("Lum id:".. t.id ..", pièce ".. piece ..", state "..state)
			  if tonumber(state)==1 then 
      			--fibaro:debug("La pièce "..piece .." est allumée!") 
			  	message=message.. piece .."-".. t.id ..",\n "
			  end --]]
			end
			fibaro:debug(message)
			fibaro:call(selfID, 'setProperty', 'ui.Label3.value', message)

	else
			fibaro:debug("Tous les lumières sont OFF")
			message=""
			fibaro:call(selfID, 'setProperty', 'ui.Label3.value', "All Off")

	end

--======================== actions fonction du profil ==========================
profil=fibaro:getGlobal("Profil")
fibaro:debug("Profil actuel est "..profil)
if profil =="Manuel" then
  fibaro:debug("Aucune action car le profil est manuel")
elseif profil=="Présence" then
  fibaro:debug("Gestion des lumières et chauffes-eau par les occupants")
  --Mais par défaut le chauffe-eau Maison est en mode heures creuses
  fibaro:call(658, "pressButton",3) -- Maison Heures creuses
  
elseif profil=="Abscence" then
  fibaro:debug("Lumières éteintes et chauffes-eau selon état avant le départ")
  for _,t in ipairs(lumTable) do
    fibaro:call(t.id,"turnOff")
    end
  
elseif profil=="Vacances" then 
  fibaro:debug("Lumières et chauffes-eau sont à l'arrêt")
  	for _,t in ipairs(lumTable) do
    fibaro:call(t.id,"turnOff")
    end
   --	fibaro:call(658, "pressButton",2) -- QA Control WaterHeater Maison
   fibaro:call(672, "pressButton",2) -- QA Control WaterHeater Grange
end

local wait=30
fibaro:debug("Prochain test dans ".. wait .."s")
wait=wait*1000
fibaro:sleep(wait)
    
			
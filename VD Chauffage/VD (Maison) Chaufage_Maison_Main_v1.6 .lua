--[[
%% properties
%% globals
Mode_Maison
--]]

--[[version = 1.7 -- Change 'currTem + hysteresis' to 'currTemp - hysteresis' 
	version = 1.5 -- Controlling manual action to a Thermostat
	version = 1.3 -- VD working for all Modes and rooms/switches
	]]--

local version = 1.8 -- protect crash when an Id is no more exisiting 
local sceneId=7 --fibaro:getSelfId() does not work in scene

fibaro:debug("Démarrage du VD Id "..fibaro:getSelfId()..", version : "..version)
  --Contrôle du VD Chauffage
local pilotageRadiateur = "Oui" -- "Non"
local controlledVD=857
local hysteresis= 0.5
local lowTempExt= 0.5
local control1="Actif"
local control2="Pause"
local wait=1*60*1000 -- 5 minutes
local thrmstReplace={}
  thrmstReplace[4]=635 -- SàM -> Thrmst room ID 5 (Salle à Manger)
  thrmstReplace[5]=636 -- Cuisine -> Thrmst room ID 6 (Salon)
  thrmstReplace[8]=696 -- Couloir RDC -> Thrmst room ID 13 (SdB)
  thrmstReplace[9]=696 -- Escalier/Couloir1er ->Thrmst room ID 13 (SdB)
  thrmstReplace[10]=639 -- Chambre Parents -> Thrmst room ID 13 (Couloir 1er)
  thrmstReplace[11]=639 -- Chambre Bleue -> Thrmst room ID 13 (Couloir 1er)
  thrmstReplace[13]=696 -- Salle de bains -> Thrmst room ID 13 (SdB)
  --fibaro:debug("thrmstReplace"..json.encode(thrmstReplace))
local replaceThrmst={[4]=636,[5]=696,[8]=696,[9]=696,[10]=639,[11]=639,[13]=696}
  --fibaro:debug("replaceThrmst ->"..json.encode(replaceThrmst))
  
  
  externTemp=fibaro:getValue(3, "Temperature")
  if tonumber(externTemp)<=6 then lowTempExt = 0.5 else lowTempExt=0 end
  -- création de la table des switchs inversés:
  local invertedSw={}
  local invertedSw2={{id= 51,inv= 0},{id= 69,inv= 0},{id= 99,inv= 1},{id=103,inv=1},{id=111,inv=1},{id=294,inv=0},{id=315,inv=0},{id=324,inv=0},{id=503,inv=1},{id=515,inv=1},{id=706,inv=0},{id=862,inv=1}}

  invertedSw[1]={}       --SàM fenêtre
  invertedSw[1].inv=0
  invertedSw[1].id=51
  invertedSw[2]={}      --Couloir 1er Jardin
  invertedSw[2].inv=0
  invertedSw[2].id=69
  invertedSw[3]={}
  invertedSw[3].id=99   --SdB
  invertedSw[3].inv=1
  invertedSw[4]={}
  invertedSw[4].id=103  --Salon Jardin
  invertedSw[4].inv=1
  invertedSw[5]={}
  invertedSw[5].id=111  --Couloir RDC Cour
  invertedSw[5].inv=1
  invertedSw[6]={}
  invertedSw[6].id=294  --Salon Cour
  invertedSw[6].inv=0
  invertedSw[7]={}
  invertedSw[7].id=315  --Couloir 1er Escalier (Cour)
  invertedSw[7].inv=0
  invertedSw[8]={}
  invertedSw[8].id=324  --Insert
  invertedSw[8].inv=0
  invertedSw[9]={}
  invertedSw[9].id=503  --Cuisine
  invertedSw[9].inv=1
  invertedSw[10]={}
  invertedSw[10].id=515  --Parents
  invertedSw[10].inv=1
  invertedSw[11]={}
  invertedSw[11].id=706  --ancien Couloir RDC Jardin
  invertedSw[11].inv=1 
  invertedSw[11]={}
  invertedSw[11].id=862  --Couloir RDC Jardin
  invertedSw[11].inv=1 --]]
  
	--fibaro:debug("Table  des switchs inversés (inv=1)->"..json.encode(invertedSw))
	--fibaro:debug("Table2 des switchs inversés (inv=1)->"..json.encode(invertedSw2))
--===== Contrôle que la scenr 7 est lancée ===============
all_scenes = api.get("/scenes")
--fibaro:debug("All_scenes->" .. json.encode(all_scenes)) --]]--
for id = 1, #all_scenes do
    SceneID = all_scenes[id].id
  --if SceneId == "7" then
    run = api.get("/scenes/" .. SceneID) 
  
    if (run.runningInstances) ==0 then
       --fibaro:debug("ID "..SceneID.. " Scene is running OK")
    --else   
       --fibaro:debug("ID "..SceneID.. " Scene NOT running, needs to be restarted")
       if SceneID == sceneId then 
       fibaro:debug("Scene 7 relancée")
       fibaro:startScene(7) end
    end
  --end
end 

--=======================================================
controlledVD=fibaro:getSelfId()
control=fibaro:getValue(controlledVD, "ui.Label3.value")
 --control="Actif" -- to comment in running VD except Testing
fibaro:debug("VD "..controlledVD.." est "..control)
--function main() no more needed as all data created in scene 7 the 'roomDevices' table is created
if control=="Actif" then 
	--main()
  roomDevices=(fibaro:getGlobal("RoomDevices"))
  fibaro:debug("line 103; type roomDevices :" .. type(roomDevices))
  fibaro:debug("line 104; type roomDevices ->" .. roomDevices)
  roomDevices=json.decode(roomDevices)
  --fibaro:debug("line 106; type roomDevices :" .. type(roomDevices))  
  fibaro:debug("line 107; roomDevices Type: "..type(roomDevices) .. "->" .. json.encode(roomDevices))
  fibaro:debug("==== =========== Début de la gestion des radiateurs ==============")
  for _,piece in ipairs(roomDevices) do
    --if piece.id > 5 then break end -- to uncomment in running VD
    if piece.climZid then
    fibaro:debug("***** Contrôle de la pièce " .. piece.name .." id: "..piece.id .. " dans la zone: ".. piece.climZid .. " ****")--OK
    local currentZone=api.get("/panels/heating/" .. piece.climZid)
      --fibaro:debug("->"..json.encode(currentZone))
    --fibaro:debug("la consigne pour la zone " .. currentZone.id .. " est de " .. currentZone.properties.currentTemperature .."°C")
      currTemp=fibaro:getValue(piece.tempUnit, 'value')
      currCons=fibaro:getValue(piece.thrmst, 'value')
    fibaro:debug("la T° actuelle (".. piece.tempUnit .. ") est de " .. currTemp .. "°C pour une consigne Thrmst (".. piece.thrmst ..") de " .. currCons .. "°C") 
      thrmstTimestamp=tonumber(fibaro:getValue(piece.thrmst,"timestamp")) --fibaro:getValue(639, "timestamp")
      currentTimestamp=os.time()
      if thrmstTimestamp==nil  then thrmstTimestamp=currentTimestamp end  
      --fibaro:debug(thrmstTimestamp..", ".. currentTimestamp)
      if thrmstTimestamp > (currentTimestamp + 600) then 
        local delta=(thrmstTimestamp - currentTimestamp)/60
        fibaro:debug("Consigne = "..currCons .. "pour une durée de ".. delta .."mn") 
      else 
        if currCons~=currentZone.properties.currentTemperature then currCons=currentZone.properties.currentTemperature end
      end
    fibaro:debug("la consigne choisie est de " .. currCons .."°C") 
    fibaro:debug("*****contrôle de la température de la pièce ".. piece.id .. " *****")
	if fibaro:getGlobal('Mode_Maison')=="Stop" then swValueMain="turnOff"
   	elseif fibaro:getGlobal('Mode_Maison')=="Hors_Gel" then
        if (tonumber(currTemp)-hysteresis) <tonumber(fibaro:getGlobal('H_G')) then swValueMain="turnOn" else swValue="turnOff" end -- 
    elseif fibaro:getGlobal('Mode_Maison')=="Presence" then
      	if (tonumber(currTemp)-hysteresis)<(tonumber(currCons)+tonumber(lowTempExt)-2) then swValueMain="turnOn" else swValueMain="turnOff" end -- 
	elseif fibaro:getGlobal('Mode_Maison')=="Automatique" then
        if (tonumber(currTemp)-hysteresis)<(tonumber(currCons)+tonumber(lowTempExt)) then swValueMain="turnOn" else swValueMain="turnOff" end -- 
      --if tonumber(currTemp)<30 then swValueMain="turnOn" else swValueMAin="turnOff" end
    end
      --fibaro:debug("Etat du chauffage : "..swValueMain .. ", pour mode : ".. fibaro:getGlobal("Mode_Maison"))
      fibaro:debug("Pour mode : ".. fibaro:getGlobal("Mode_Maison") .. ", Etat du chauffage : ".. swValueMain)
	fibaro:debug("*****contrôle des radiateurs de la pièce ".. piece.id .. " *****")      
      pieceSwitch=piece.switch
      for _,sws in ipairs(pieceSwitch) do
      	  for _,invert in ipairs(invertedSw) do
            
            if invert.id == tonumber(sws) then 
             fibaro:debug("id: "..invert.id..", inv: "..invert.inv)
            	if invert.inv ==1 then 
            		if swValueMain=="turnOn" 
                	then swValue="turnOff"
                    else swValue="turnOn" 
                	end
                elseif invert.inv==0 then
                	if swValueMain=="turnOn" 
                	then swValue="turnOn"
                    else swValue="turnOff" 
                	end
                end
            end
          end
        if fibaro:getGlobal("Mode_Maison")=="Presence" then pilotageRadiateur="Non" else pilotageRadiateur="Oui" end
        if pilotageRadiateur == "Oui" then fibaro:call(sws,swValue) else fibaro:debug("--------> les radiateurs sont en mode manuel <--------") end -- to coment when testing VD
        if fibaro:getValue(sws,"value") then
        fibaro:debug("Radiateur "..sws .." est " .. swValue .. ", " .. fibaro:getValue(sws,"value"))
        else fibaro:debug ("Radiateur "..sws.." n'existe plus") end
      end
      fibaro:debug("************************ Pièce suivante *************************")
    else 
      fibaro:debug("La pièce " .. piece.name .." Id: ".. piece.id .. " n'est pas contrôllée")
      fibaro:debug("************************ Pièce suivante *******************")    end
  end

 fibaro:debug("\n".."-------------------------- end of 'Actif' state ----------------------------") 
else
  fibaro:debug("********** Attendre réactivation du VD par la scène 7 **********")
  fibaro:sleep(10000)
end
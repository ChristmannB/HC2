--[[
%% properties
%% globals
Mode_Maison
--]]

--[[
version = 1.4 -- Controlling manual action to a Thermostat
version = 1.3 -- VD working for all Modes and rooms/switches
]]--

local version = 1.5 -- Controlling VD thmrst  
local sceneId=37 --fibaro:getSelfId() does not work in scene

fibaro:debug("Démarrage du VD Id "..fibaro:getSelfId()..", version : "..version)
local modeMaison=fibaro:getGlobal("Mode_Maison")
fibaro:debug("Mode Maison : ".. modeMaison)
--Contrôle du VD Chauffage
local pilotageRadiateur = "Non" -- "Oui" -- not used??
local controlledVD=fibaro:getSelfId() --i.e. 781
local VDid=fibaro:getSelfId()
local hysteresis=0.2
local lowTempExt=0.5
local control1="Actif"
local control2="Pause"
local wait=5*60*1000 -- 5 minutes
local allDevices=api.get("/devices")
local thrmstReplace={} -- to be updated for HC2 Grange
  thrmstReplace[5] =581 -- Cuisine-> Salle à Manger
  thrmstReplace[8] =601 -- Salon G -> Chambre RDC
  thrmstReplace[10]=597 -- Salle à manger -> Salon
  thrmstReplace[13]=584 -- Chambre 1er ->  SdB
  thrmstReplace[14]=584 -- Salle de Jeux -> Salle de bain 
  thrmstReplace[16]=584 -- Salle de bains -> Chambre 1er 
  thrmstReplace[25]=597 -- Chambre RDC ->
  thrmstReplace[26]=594 -- WC -> SdB 1er
	--fibaro:debug("Type thrmstReplace "..type(thrmstReplace))
	--fibaro:debug("thrmstReplace"..json.encode(thrmstReplace))

  
  externTemp=fibaro:getValue(782, "Temperature")
  if tonumber(externTemp)<=6 then lowTempExt = 0.5 else lowTempExt=0 end
fibaro:debug("TempExt: " .. externTemp .. "°C" .. ", Coef Tem ext: " ..lowTempExt) 
  -- création de la table des switchs inversés: --non utilisée dans la grange
  local invertedSw={}
  --invertedSw=json.decode({{"id"= 51,"inv"= 0},{"id"= 69,"inv"= 0},{"id"= 99,"inv"= 1}})
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
  invertedSw[11].id=706  --Couloir RDC Jardin
  invertedSw[11].inv=0 --]]
	--fibaro:debug("Table des switchs inversés (inv=1)->"..json.encode(invertedSw))

--controlledVD=fibaro:getSelfId() -- redundant with line 21
control=fibaro:getValue(controlledVD, "ui.Label3.value")
 --control="Actif" -- to comment in running VD except Testing
fibaro:debug("VD "..controlledVD.." est "..control)
--function main() no more needed as all data created in scene 7 the 'roomDevices' table is created
if control=="Actif" then 
fibaro:debug("=============== Recherche de VD type Climate ================")
 for _,vd in ipairs(allDevices) do
  --fibaro:debug("->"..json.encode(vd))  
  if vd.visible and vd.type=="virtual_device" then 
    local cat=json.decode(fibaro:getValue(vd.id, "categories"))[1]
    --fibaro:debug("Catégorie: ".. cat) --json.decode(cat)[1])
    if cat=="climate" then
   --if vd.properties.categories[1] =="climate" then --cat=="climate" then--   then
    fibaro:debug(" Room ".. vd.roomID .. ": VD id " .. vd.id .. ", " .. vd.name .. " à la catégorie Climate")
    	if fibaro:getGlobal("Mode_Maison")=="Automatique" then 
        fibaro:debug("le VD" .. vd.id .. " est passé en mode Automatique")
        fibaro:call(vd.id, "pressButton",9)
        else 
    	fibaro:debug("les VD Climate sont autonomes")
        end
    --else 
    --fibaro:debug("Pas de module virtuel")
  	end --if cat
  end --if vd.visible
 end -- for _,vd
  
fibaro:debug("============================================")
	
  --main()
  roomDevices=(fibaro:getGlobal("RoomDevices"))
  --fibaro:debug("line 84; type roomDevices :" .. type(roomDevices))
  roomDevices=json.decode(roomDevices)
  --fibaro:debug("line 86; type roomDevices :" .. type(roomDevices))  
  fibaro:debug("line 87; roomDevices Type: "..type(roomDevices) .. "->" .. json.encode(roomDevices))
fibaro:debug("=============== Début de la gestion des radiateurs ==============")
  for _,piece in ipairs(roomDevices) do
    --if piece.id > 5 then break end -- to uncomment in running VD
    if piece.climZid then
    fibaro:debug("***** Contrôle de la pièce " .. piece.name .." id: "..piece.id .. " dans la zone: ".. piece.climZid .. " ****")--OK
    local currentZone=api.get("/panels/heating/" .. piece.climZid)
      --fibaro:debug("->"..json.encode(currentZone))
    --fibaro:debug("la consigne pour la zone " .. currentZone.id .. " est de " .. currentZone.properties.currentTemperature .."°C")
      currTemp=fibaro:getValue(piece.tempUnit, 'value')
      currCons=fibaro:getValue(piece.thrmst, 'value')
    fibaro:debug("la T° actuelle est de " .. currTemp .. "°C pour une consigne Thrmst de " .. currCons .. "°C") 
      if currCons~=currentZone.properties.currentTemperature then currCons=currentZone.properties.currentTemperature end
    --fibaro:debug("la consigne choisie est de " .. currCons .."°C") 
    fibaro:debug("*****contrôle de la température de la pièce ".. piece.id .. " *****")
	if fibaro:getGlobal('Mode_Maison')=="Stop" then swValueMain="turnOff"
   	elseif fibaro:getGlobal('Mode_Maison')=="Hors_Gel" then
        if (tonumber(currTemp)-hysteresis) <tonumber(fibaro:getGlobal('H_G')+hysteresis) then swValueMain="turnOn" else swValue="turnOff" end -- 
    elseif fibaro:getGlobal('Mode_Maison')=="Presence" then
      	if (tonumber(currTemp)-hysteresis)<(tonumber(currCons)+tonumber(lowTempExt)-2+hysteresis) then swValueMain="turnOn" else swValueMain="turnOff" end -- 
	elseif fibaro:getGlobal('Mode_Maison')=="Automatique" then
        if (tonumber(currTemp)-hysteresis)<(tonumber(currCons)+tonumber(lowTempExt)+hysteresis) then swValueMain="turnOn" else swValueMain="turnOff" end -- 
      --if tonumber(currTemp)<30 then swValueMain="turnOn" else swValueMAin="turnOff" end
    end
      fibaro:debug("Etat du chauffage : "..swValueMain .. ", pour mode : ".. fibaro:getGlobal("Mode_Maison"))
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
            else swValue="turnOff" --adde because no inverted Switch
            end
          end
        fibaro:debug("Radiateur "..sws .." est " .. swValue)
      end
      fibaro:debug("************************ Pièce suivante *************************")
    else 
      fibaro:debug("La pièce " .. piece.name .." Id: ".. piece.id .. " n'est pas contrôllée")
      fibaro:debug("************************ Pièce suivante *******************")    end
  end
 fibaro:debug("\n".."-------------------------- end of 'Actif' state ----------------------------") 
else
  fibaro:debug("********** Attendre réactivation du VD par la scène ".. sceneId .. " **********")
  fibaro:sleep(10000)
end
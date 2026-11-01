--[[
%% properties
%% events
%% globals
--]]
--[[ mise à jour le 13/06/2025 --27/05/2025 -- 9 juillet 2021 --1er mai 2020 --2 avril 2018
version = "1.7-1" -- Version Grange -- the scene is correcly managing RoomDevices and VD
version = 1.6 -- add hYsterisis and Global Variable 'RoomDevices'
version = 1.5 -- Contrôle des radiateur OK y compris inversé
version = 1.4 --  this version allos control of radiator switches but inverted are an issue
version = 1.3 -- Now adding climate zone ID to roomDevices 
version = 1.2 -- controlling ext VD for label3 ans setInterval 
version = 1.1 -- get OK the Climate modules for each room with replacement ID
]]--
-------------------------------------------
fibaro:call(781,'setProperty','ui.Label3.value',"Actif")
local version = "1.7-1" -- Version Grange -- the scene is correcly managing RoomDevices and VD
local sceneId=37 --fibaro:getSelfId() does not work in scene
  fibaro:debug("Démarrage de la scène Id "..sceneId..", version : "..version)
fibaro:debug("Mode_Maison : "..fibaro:getGlobal("Mode_Maison"))
local crc,okc,erc,evc,xec,cnc,xcc,tmc,stc="green","lightgreen","red","orange","yellow","cyan","pink","magenta","lightgray"
function logbug(color,message)
  for line in message:gmatch("[^\010\013]+")do 
    local txt=line:gsub("([\038\060\062])",
      function(c)
        return"&#"..string.byte(c)..";"
      end				) 
    fibaro:debug(('<span style="color:%s">%s</span>'):format(color,txt))
  end 
end

fibaro:debug("=========== Création des variable Globales ===========")
local gvm,aem,gvc,chgLng="Global variable '%s' ","already exist","table version changed. Updated",false
local VirtualTableName="RoomDevices"
local virtualGlobal=json.encode({{switch={51,324},climZid=94,name="Salle_à_manger",id=4,thrmst=637,tempUnit=638
}})
local varName={
    [VirtualTableName]={value=virtualGlobal,isEnum=true,isTable=true,enumValue={"Table"}}
			}
for i,v in pairs(varName)do
	local function build(nam,val,enum,tbl,dbug)
      if dbug=="add"then a="creating"b="created"elseif dbug=="upd"then a="updating"b="updated"else a="recreating"b="recreated"end
    	api.put("/globalVariables/"..nam,{name=nam,value=val,isEnum=true,enumValues=enum})
      if tbl then 
    	local ok,msg=pcall(
      function()wT=json.decode(fibaro:getGlobalValue(nam))
        if type(wT)~="table" then error()end 
      end)
        if not ok then logbug(erc,string.format("ERROR - "..gvm.."table '%s' was unsuccessful",nam,a))
          logbug(erc,string.format("ERROR code: %s",msg)) else logbug(okc,string.format(gvm.."%s successfully.",nam,b))end
      else if fibaro:getGlobalValue(nam)~=nil then logbug(okc,string.format(gvm.."%s successfully.",nam,b))else
        logbug(erc,string.format("ERROR - "..gvm.."table '%s' was unsuccessful",nam,a))
    end end end
 if fibaro:getGlobalValue(i)==nil then api.post("/globalVariables/",{name=i})fibaro:sleep(400)build(i,v.value,v.enumValue,v.isTable,"add")end
end
local roomDevices=fibaro:getGlobal("RoomDevices")
--fibaro:debug("Line 55; roomDevices->"..roomDevices)

-------------------------------------------
 fibaro:debug("************** Contrôle du VD Chauffage **************")
local controlledVD=781
local hysteresis=0.2
local lowTempExt=0.5
local control1="Actif"
local control2="Pause"
local wait=3*60*1000 -- 5 minutes
local control=fibaro:getValue(controlledVD, "ui.Label3.value")
fibaro:debug("Etat du VD lu : "..control)

function timeSetting()
  --if control=="Pause" then control="Actif"
  if control==control2 or control=="" then control=control1
    fibaro:debug("Etat changé en : "..control)
    fibaro:call(controlledVD,'setProperty','ui.Label3.value',control)
    --fibaro:call(781,'setProperty','ui.Label3.value',"Actif") -- to comment for a running VD
    fibaro:sleep(10000) -- 20 s too much
    control=control2
    fibaro:call(controlledVD,'setProperty','ui.Label3.value',control)
    --fibaro:call(781,'setProperty','ui.Label3.value',"Stop")
    fibaro:debug("Etat ramené à : "..control)
  elseif control==control1 then
    control=control2
   	fibaro:call(controlledVD,'setProperty','ui.Label3.value',control)
  end
  fibaro:debug("Etat final : ".. control)
setTimeout(timeSetting,wait) -- to be uncommented in running scene
end
timeSetting()  -- to comment in order to test main()
setTimeout(timeSetting,wait)-- to comment in order to test main()

function main()
  local defaultSwitch=592 --Fenêtre Salle de Jeux
  local Maintenant = os.date("*t") --stocke la date et l'heure actuelle du système sous forme d'un tableau à l'intérieur de la variable "Maintenant"
  --  Affichage de la date et l'heure
  fibaro:debug("il est maintenant ".. Maintenant['hour'].."h"..Maintenant['min'].."min"..", le "..Maintenant['day'].."/"..Maintenant['month'].."/"..Maintenant['year'])
  -- Utilisation de l'écart de température extérieure avec la variable globale "Isolation" 
  local Temp_Ext = 7 -- if imposssible to get Variable H_G
 
  
  fibaro:debug("--================== Fonctions générales =======================")
    
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
  
  fibaro:debug("thrmstReplace"..json.encode(thrmstReplace))

  fibaro:debug("=============== Recherche de VD type Climate ================")
 for _,vd in ipairs(allDevices)do
    if vd.visible and vd.type=="virtual_device" and vd.properties.categories[1] =="climate" and tonumber(vd.roomID)<26 then
    --fibaro:getValue(674, "categories")
      fibaro:debug(" Room ".. vd.roomID .. ": VD id " .. vd.id .. ", " .. vd.name .. " à la catégorie Climate")
    	if fibaro:getGlobal("Mode_Maison")=="Automatique" then 
        fibaro:debug("le VD" .. vd.id .. " est passé en mode Automatique")
        fibaro:call(vd.id, "pressButton",9)
        else 
    	fibaro:debug("les VD Climate sont activés")
        end
    end
 end
  
fibaro:debug("============================================")


  local externTemp=fibaro:getValue(782, "Temperature") -- YR
  if tonumber(externTemp)<=6 then lowTempExt = 0.5 else lowTempExt=0 end
  fibaro:debug("TempExt: " .. externTemp .. "°C" .. ", Coef Tem ext: " ..lowTempExt) 
  -- création de la table des switchs inversés:
  local invertedSw={} -- to be updated for HC2 Grange may not be usefull
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

  fibaro:debug("======== Création d'une table des modules impliqués =========")
  local sectionsMaison={5,6} -- just to know which rooms to use
  local roomIds={}
  local rooms= api.get("/rooms")
    for _,v in ipairs(rooms) do
      --fibaro:debug("room Id: "..v.id..", name: "..v.name.." Section id:"..v.sectionID)
      if v.sectionID ==5 or v.sectionID == 6 then
          table.insert(roomIds,v.id) 
      end
    end
  --fibaro:debug("Rooms Ids "..json.encode(roomIds))  
  --fibaro:debug("Nombre de pièces concernées est de "..#roomIds)
  local roomDevices={}
  for _,r in pairs(roomIds) do
    --fibaro:debug(r)
    local moduleTable = api.get("/rooms/"..r)
--    fibaro:debug("Line 169 moduleTable ->"..json.encode(moduleTable))
    newId=r
    newName=moduleTable.name
    newTempUnit=moduleTable.defaultSensors.temperature
    newThrmst=moduleTable.defaultThermostat
    if newTempUnit==0 and newThrmst==0 then fibaro:debug("Room Id ".. r .." skipped")
     else
      if newThrmst==0 then newThrmst=thrmstReplace[r] end
      fibaro:debug(newName .. ", " .. moduleTable.id .. ", T°: " .. newTempUnit ..", Thrmst: " .. newThrmst)
      
      local roomData={}
      roomData.id=newId
      roomData.tempUnit=newTempUnit
      roomData.thrmst=newThrmst
      roomData.name=newName
      if 
      newThrmst~=0 or newTempUnit~=0 
      then table.insert(roomDevices,roomData)
      end
    end  
  end
  --fibaro:debug("roomDevices ->"..json.encode(roomDevices)) -- manque la SdB Grange
  fibaro:debug("--------------------------- Getting switches for the room --------------------")
  fibaro:debug("nombre de pièces gérées = "..#roomDevices)
  for k,rmdev in ipairs(roomDevices) do
    --fibaro:debug("rmdev id "..rmdev.id.."-> "..json.encode(rmdev)) --OK
    --fibaro:debug("Pièce "..rmdev.name..", id "..rmdev.id..", T° sensor: "..rmdev.tempUnit..", Thrmst: "..rmdev.thrmst)  --OK
    local roomModules={}
      for _,sw in ipairs(allDevices) do
      if sw.id then 
        if sw.visible and sw.roomID==rmdev.id and (sw.type=="com.fibaro.binarySwitch" or sw.type=="com.fibaro.multilevelSwitch")then 
        --fibaro:debug("categories: " .. json.encode(sw))
          --fibaro:debug("categories: " .. sw.properties.categories[1])
          if sw.properties.categories[1]=="climate" then 
            --  fibaro:debug("line 148; Switch pour pièce "..rmdev.id.." a pour id: "..sw.id..", "..sw.name.." et pour état: "..fibaro:getValue(sw.id,'value'))
              table.insert(roomModules,sw.id) end
          end
      else
      sw.id=defaultSwitch
      fibaro:debug('No modules for this room, replaced by SW Salle de Jeux'..sw.id)
      table.insert(roomModules,sw.id) 
      end
   end
    --fibaro:debug("Switch(s) pour pièce "..rmdev.id.." ->"..json.encode(roomModules))
      for _,dev in ipairs(roomDevices) do
        if dev.id==rmdev.id then dev.switch=roomModules
        --fibaro:debug("roomDevices "..rmdev.id.."->"..json.encode(roomDevices))
        end
      end
  end
    --fibaro:debug("roomDevices ->"..json.encode(roomDevices))
  for _,rM in ipairs(roomDevices) do
	  if rM.switch[1]==nil then rM.switch[1]=0 end  --need to check if fibao:call(0,"value","turnOff") fonctionne  
  end
   fibaro:debug("roomDevices ->"..json.encode(roomDevices))
  
  fibaro:debug("=============== Recherche de la zone de consigne actuelle ==============")
	local climateZoneTable=api.get("/panels/heating")
  --fibaro:debug("climateZoneTable ->"..json.encode(climateZoneTable))
  for _,tab in ipairs(climateZoneTable) do
    --fibaro:debug("\n".."tab.id: "..tab.id) --OK
    --if tab.id > 7 then break end -- to comment when running live
    local currentZone=api.get("/panels/heating/"..tab.id)
    --fibaro:debug("currentZone"..json.encode(currentZone)) --OK
    --fibaro:debug("\n".."------ fin du json.decode(currentZone) -----") --ok
    --fibaro:debug("id: "..currentZone.id..", Nom: "..currentZone.name ..", Rooms: ".. json.encode(currentZone.properties.rooms))
    roomList=currentZone.properties.rooms --{8}--
     for _,ro in ipairs(roomList) do
       for i,dv in ipairs(roomDevices) do
         if dv.id==ro then roomDevices[i].climZid=tab.id end
       end
     end
     
  end
  fibaro:debug("line246; roomDevices->"..json.encode(roomDevices))
  fibaro:debug("Type roomDevices :"..type(roomDevices))
  fibaro:setGlobal("RoomDevices",json.encode(roomDevices))
  fibaro:debug("line249; RoomDevices ->"..fibaro:getGlobal("RoomDevices"))
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
 fibaro:debug("=============== fin de la fonction main() ==============")
end --function main()
main() 
fibaro:debug('-------------------------------- Fin du scénario -------------------')





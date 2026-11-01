--[[
%% properties
%% events
%% globals
683, CentralSceneEvent 1 HeldDown
lights
--]]

fibaro:debug("---------- Début du scénario HC2 Grange -------")
-- Déclaration des modules
 	local IDL1 = 679 --EX 660 -- LED Cuisine
  	local IDL2 = 681 --EX 662 -- LED SàM
  	local IDL3 = 652 -- Plafonnier Salon
  	local IDL4 = 668 -- Appentis
	local IDL5 = 654 -- LED Escalier salon
 	local IDL6 = 664 -- Plafonnier Ch RDC
  	local IDL7 = 666 -- Ventilo Ch RDC
    local IDL8 = 644 -- LED Salle de jeux
    local IDL9 = 642 -- Ch 1er étage
--Télécommande 
--local NumScene = fibaro:getValue(683, "CentralSceneEvent")
--683 CentralSceneEvent 4 Pressed2fibaro:debug("Neuméro de scène : " .. NumScene)

-- Etat eu lancement

 	local L1 = fibaro:getValue(IDL1,"value") -- LED Cuisine
  	local L2 = fibaro:getValue(IDL2,"value") -- LED SàM
  	local L3 = fibaro:getValue(IDL3,"value") -- Plafonnier Salon
  	local L4 = fibaro:getValue(IDL4,"value") -- Appentis
	local L5 = fibaro:getValue(IDL5,"value") -- LED Escalier salon
 	local L6 = fibaro:getValue(IDL6,"value") -- Plafonnier Ch RDC
  	local L7 = fibaro:getValue(IDL7,"value") -- Ventilo Ch RDC
    local L8 = fibaro:getValue(IDL8,"value") -- LED Salle de jeux
    local L9 = fibaro:getValue(642,"Value") -- Ch 1er étage

-- fibaro:debug("Modules à éteindre (1) : " ..  "Cuisine = ".. L1 .. ", SàM = ".. L2 .. ", Salon = ".. L3 .. " & " .. L5 .." plus Ventilo = ".. L7.. ", Ch RDC = ".. L6 .. ", Appenti = ".. L4 .. ", Salle de jeux = " .. L8 .. ", Chambre 1er = ".. L9 .. "Fin")
--fibaro:debug("Modules à éteindre (1) : " .. " CH &er étage = " .. L9) 
  
local Action = fibaro:getGlobal("LightsG")
fibaro:debug("Action demandée " .. Action..", soit : ")
if (tonumber(Action) == 2)
  then fibaro:debug("Extinction de toutes les lumières")
  elseif (tonumber(Action) == 1)
then fibaro:debug("Allumage toutes les lumières")
    else fibaro:debug("Etat des lumières")
  end
if (tonumber(Action) == 2) 
  then
  fibaro:debug("Extinctions des modules IDL1 à IDL9")
  fibaro:call(IDL1, "turnOff")
  fibaro:call(IDL2, "turnOff")
  fibaro:call(IDL3, "turnOff")
  fibaro:call(IDL4, "turnOff")
  fibaro:call(IDL5, "turnOff")
  fibaro:call(IDL6, "turnOff")
  fibaro:call(IDL7, "turnOff")
  fibaro:call(IDL8, "turnOff")
  fibaro:call(642, "turnOff")

--  OPbtentio du résultat
fibaro:sleep(5000)
   	L1 = fibaro:getValue(IDL1,"value")
  	L2 = fibaro:getValue(IDL2,"value")
  	L3 = fibaro:getValue(IDL3,"value")
  	L4 = fibaro:getValue(IDL4,"value")
	L5 = fibaro:getValue(IDL5,"value")
 	L6 = fibaro:getValue(IDL6,"value")
  	L7 = fibaro:getValue(IDL7,"value")
    L8 = fibaro:getValue(IDL8,"value")
    L9 = fibaro:getValue(642,"Value")

  --
  
  fibaro:debug("-----------Tous les circuits de lumière à l'arrêt ----------")
  --
--fibaro:debug("Modules éteints (0) : Cuisine = " .. L1 .. ", SàM = " .. L2 .. ", Salon = " .. L3 .. " & " .. L5 .. ", Appentis = " .. L4 .. ", Ch RDC = " .. L6 .." & Ventilo = " .. L7 .. " Salle de jeux = " .. L8 .. " Cahmbre 1er = " .. L9 )
fibaro:debug("LED SàM = " .. L2)
	elseif (tonumber(Action) == 1)
then
  fibaro:debug("Extinctions des modules IDL1 à IDL9")
  fibaro:call(IDL1, "turnOn")
  fibaro:call(IDL2, "turnOn")
  fibaro:call(IDL3, "turnOn")
  fibaro:call(IDL4, "turnOn")
  fibaro:call(IDL5, "turnOn")
  fibaro:call(IDL6, "turnOn") 
  --fibaro:call(IDL7, "turnOn") -- ventilo Ch 1er
  fibaro:call(IDL8, "turnOn")
  fibaro:call(642, "turnOn")
    
--fibaro:debug("Etat des lumières (1 : allumée) : Cuisine = "..L1 ..", SàM = "..L2 ..", Salon = "..L3 .." & " .. L5 ..", Appentis = "..L4..", Ch RDC = "..L6.." & Ventilo = "..L7 .. " Salle de jeux = " .. L8 .." Chambre 1er = " .. L9)

    fibaro:debug("-----------Tous les circuits de lumière àllumés ----------")
  --
--fibaro:debug("Modules éteints (0) : Cuisine = "..L1 ..", SàM = "..L2 ..", Salon = "..L3 .." & " .. L5 ..", Appentis = "..L4..", Ch RDC = "..L6.." & Ventilo = "..L7 .. " Salle de jeux = " .. L8 .." Cambrer 1er = ".. L9)
--fibaro:debug("Modules éteints (0) : Ch 1er " .. L9) 
 end   

fibaro:debug("-------------------Fin du Sénario --------------------")------------")

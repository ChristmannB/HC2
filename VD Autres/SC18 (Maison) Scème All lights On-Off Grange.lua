--[[
%% properties
%% events
%% globals
lights
--]]

fibaro:debug("---------- Début du scénario HC2 Maison -------")
-- Déclaration des modules
 	local IDL1 = 749 -- LED Cuisine 679 ex 660
  	local IDL2 = 750 -- LED SàM 681 ex 662
  	local IDL3 = 742 -- Plafonnier Salon 652
  	local IDL4 = 748 -- LED Appentis 668
	local IDL5 = 743 -- LED Escalier salon 654
 	local IDL6 = 746 -- Plafonnier Ch RDC 664
 	local IDL7 = 747 -- Ventilo Ch RDC 666
    local IDL8 = 740 -- LED Salle de jeux 644
    local IDL9 = 739 -- LED Ch 1er étage 642
    --local IDL10 = 582 -- LED Sale de jeux 644 


local Action = fibaro:getGlobal("LightsG")
fibaro:debug("Action demandée " .. Action..", soit : ")
if (tonumber(Action) == 2)
  then fibaro:debug("Extinction de toutes les lumières")
--  else fibaro:debug("Etat des lumières")
--  end
 	local L1 = fibaro:getValue(IDL1,"value") -- LED Cuisine
  	local L2 = fibaro:getValue(IDL2,"value") -- LED SàM
  	local L3 = fibaro:getValue(IDL3,"value") -- Plafonnier Salon
  	local L4 = fibaro:getValue(IDL4,"value") -- Appentis
	local L5 = fibaro:getValue(IDL5,"value") -- LED Escalier salon
 	local L6 = fibaro:getValue(IDL6,"value") -- Plafonnier Ch RDC
  	local L7 = fibaro:getValue(IDL7,"value") -- Ventilo Ch RDC
    local L8 = fibaro:getValue(IDL8,"value") -- LED Salle de jeux
    local L9 = fibaro:getValue(IDL9,"value") -- Ch 1er étage
fibaro:debug("Modules à éteindre (1) : " .. "Cuisine = " .. L1 .. ", SàM = " .. L2 .. ", Salon = " .. L3 .. " & " .. L5 .. " & Ventilo = " .. L7 .. ", Ch RDC = " .. L6 .. ", Appenti = " .. L4 .. ", Chambre 1er = " .. L9 .. ".")
  
--if (tonumber(Action) == 2) 
--  then
  fibaro:debug("Extinctions des modules L1/" .. IDL1 .. ", L2/".. IDL2 .. ", L3/".. IDL3 .. ", L4/".. IDL4..", L5/".. IDL5 .. ", L6/".. IDL6 .. ", L7/".. IDL7 .. ", L8/".. IDL8 .. ", L9/".. IDL9)
  fibaro:call(IDL1, "turnOff")
  fibaro:call(IDL2, "turnOff")
  fibaro:call(IDL3, "turnOff")
  fibaro:call(IDL4, "turnOff")
  fibaro:call(IDL5, "turnOff")
  fibaro:call(IDL6, "turnOff")
  fibaro:call(IDL7, "turnOff")
  fibaro:call(IDL8, "turnOff")
  fibaro:call(IDL9, "turnOff")
  fibaro:debug("-----------Tous les circuits de lumière à l'arrêt ----------")

elseif (tonumber(Action) == 1)
then
  fibaro:debug("Extinctions des modules L1/" .. IDL1 .. ", L2/".. IDL2 .. ", L3/".. IDL3 .. ", L4/".. IDL4..", L5/".. IDL5 .. ", L6/".. IDL6 .. ", L7/".. IDL7 .. ", L8/".. IDL8 .. ", L9/".. IDL9)
  fibaro:call(IDL1, "turnOn")
  fibaro:call(IDL2, "turnOn")
  fibaro:call(IDL3, "turnOn")
  fibaro:call(IDL4, "turnOn")
  fibaro:call(IDL5, "turnOn")
  fibaro:call(IDL6, "turnOn")
  fibaro:call(IDL7, "turnOn")
  fibaro:call(IDL8, "turnOn")
  fibaro:call(IDL9, "turnOn")
  
end  
--  Obtentio du résultat
fibaro:sleep(5000)
   	L1 = fibaro:getValue(IDL1,"value")
  	L2 = fibaro:getValue(IDL2,"value")
  	L3 = fibaro:getValue(IDL3,"value")
  	L4 = fibaro:getValue(IDL4,"value")
	L5 = fibaro:getValue(IDL5,"value")
 	L6 = fibaro:getValue(IDL6,"value")
  	L7 = fibaro:getValue(IDL7,"value")
    L8 = fibaro:getValue(IDL8,"value")
    L9 = fibaro:getValue(IDL9,"Value")

  fibaro:debug("-----------Tous les circuits de lumière allumés ----------")
--fibaro:debug("Modules éteints (0) : Ch 1er = "..L11 ..", SdJ = "..L22 ..", Salon = "..L33 .." & "..L88 ..", Ch RDC = "..L44 ..", SàM = "..L55 ..", Cuisine = "..L66 .." & Appenti = ".. L7 .."." )
--fibaro:debug("Modules éteints (0) : Ch 1er = ".. L1 ..", SdJ = ".. L2 ..", Salon = ".. L3 .." & " .. L8 ..", Ch RDC = " .. L4 .. ", SàM = " .. L5 .. ", Cuisine = " .. L6 .. ", Appenti = " .. L7)
--fibaro:debug("Modules éteins (0) : " .. "Cuisine = " .. L1 .. ", SàM = " .. L2 .. ", Salon = " .. L3 .. " & " .. L5 .. " & Ventilo = " .. L7 .. ", Ch RDC = " .. L6 .. ", Appenti = " .. L4 .. ", Chambre 1er = " .. L9 .. ".")

--	else
--fibaro:debug("Etat des lumières (1 : allumée) : Ch 1er = " .. L1 .. ", SdJ = " .. L2 ..", Salon = "..L3 .." & "..L8 ..", Ch RDC = "..L4 ..", SàM = "..L5 ..", Cuisine = "..L6 .." & Appenti = "..L7 .."." )
--fibaro:debug("Etat des lumières - éteintes (0) - Allumées (1) : " .. "Cuisine = " .. L1 .. ", SàM = " .. L2 .. ", Salon = " .. L3 .. " & " .. L5 .. " & Ventilo = " .. L7 .. ", Ch RDC = " .. L6 .. ", Appenti = " .. L4 .. ", Chambre 1er = " .. L9 .. ".")

    
--    end
fibaro:debug("-------------------Fin du Sénario --------------------")
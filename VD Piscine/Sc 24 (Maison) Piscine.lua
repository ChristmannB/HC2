--[[
%% properties
%% events
%% globals
%% killOtherInstances
piscine
Hinterval
Mduree
hStart
--]]
local i = 0
local Temp = fibaro:getValue(644, "ui.Label1.value")
  fibaro:debug("les valeurs du module extérieur Netatmo sont : " .. Temp .. "°C")
Temp = string.sub(Temp, 1, 2) -- (Temp, 5, 7)
  fibaro:debug("la valeur Temp Ext sans décimale est de " .. Temp .."°C")
local Weather = fibaro:getValue(3, "Temperature")
  fibaro:debug("YR Weather donne une température extérieure de " .. Weather .. "°C")
  
local pompe = 563 -- devra être changé pour un FGS-222
local gestion = fibaro:getGlobal("piscine")
fibaro:debug("Le scenario du moteur de la piscine est mode : " .. gestion)
local Maintenant = os.date("*t") --stocke la date et heure actuelle du système sous forme d'un tableau à l'intérieur de la variable "Maintenant"
--  Affichage de la date et l'heure
fibaro:debug("il est maintenant ".. Maintenant['hour'].."h"..Maintenant['min'].."min"..", le "..Maintenant['day'].."/"..Maintenant['month'].."/"..Maintenant['year'])

local hInterval = fibaro:getGlobal("Hinterval") -- nombre d'heure entre 2 départs du moteur
----------------------------- TEST ---------------------
--hInterval = 1/60 -- ligne à activer tour tester le cycle automatique
-- penser à modifier le VD pour une valeur hInteral de 1/60h et Mduree 1mn
--------------------------------------------------------
local interval = tonumber(hInterval)*60*60*1000 -- nombre d'heure entre 2 départs du moteur en ms
local mDuree =  fibaro:getGlobal("Mduree") -- nombre de minutes de fonctionnement du moteur
----------------------------- TEST ---------------------
   -- mDuree = 1 -- ligne à activer tour tester le cycle automatique
--------------------------------------------------------
local duree = tonumber(mDuree)*60*1000 -- nombre de ms de fonctionnement du moteur
local Hstart = fibaro:getGlobal("hStart")  -- Heure de début du cycle
--local H = (24-tonumber(Hstart)) / tonumber(hInterval) -- Nombre de cycles dans l'interval
local H = (24) / tonumber(hInterval) -- Nombre de cycles dans l'interval
H = string.format("%f",tonumber(H)) -- partie entière de H
fibaro:debug("Nombre d'heure entre 2 départs de la pompe = " .. hInterval .. "h")
fibaro:debug("Nombre de minutes en secondes de fonctionnement du moteur = " .. mDuree)
fibaro:debug("Nombre de cycles dans la journée = " .. string.format("%f",tonumber(H)))
fibaro:debug("L'heure de départ des cycles est : " .. tonumber(Hstart) .. "h")
fibaro:debug("A l'instant la valeur numérique de l'heure est : " .. tonumber(Maintenant['hour']))

  if gestion == "Arret"
    then
    fibaro:call(pompe, "turnOff")
    fibaro:debug("A Le moteur ID 563 est a l'état " .. fibaro:get(pompe,"value"))
    	
  	elseif  gestion == "Marche"
    	then fibaro:call(pompe, "turnOn")
    	fibaro:debug("B Le moteur ID 563 est a l'état " .. fibaro:get(pompe,"value"))
    		elseif gestion == "Auto" --permet le démarrage du scénario automatique
  				then -- condition de basse ou haute température
  			if (tonumber(Temp) <2 or tonumber(Temp)>30 or tonumber(Weather) <2)
    			then fibaro:call(pompe, "turnOn")
			-- elseif tonumber(Maintenant['hour']) > tonumber(Hstart) -- permet de détecter l'heure de démarrage 
    		--	then
				else
    				fibaro:call(pompe, "turnOn")

    				fibaro:sleep(1500)
    				fibaro:debug("C1 Le moteur ID 563 est a l'état " .. fibaro:get(pompe,"value"))
      				fibaro:debug("Pompe en route pour " .. mDuree .."mn")
				    fibaro:sleep(duree)
    				fibaro:call(pompe, "turnOff")
    				fibaro:sleep(1500)
    				fibaro:debug("C2 Le moteur ID 563 est a l'état " .. fibaro:get(pompe,"value"))
    				
    				fibaro:debug("Attente de " .. (tonumber(hInterval)*60) .. " mn pour prochain cycle") 
   					    				fibaro:sleep(interval)

   -- i=i+1
   -- 	if i > H
   --   	then fibaro:abort()
   			end 
	
  else
    		fibaro:abort()
		end
  --end
fibaro:sleep(2000) 
fibaro:debug("D Le moteur ID 563 est a l'état " .. fibaro:get(pompe,"value"))
fibaro:debug("-------------------fin de cycle---------------")


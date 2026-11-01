--[[
	--%% autostart
	-- %% properties
	%% events
	%% globals
	--]]
-- mise à jour le 6 août 2023 V3.4 -- 9 juillet 2021 --1er mai 2020 --2 avril 2018
-- Utilisation de l'heure et de la date 
local Maintenant = os.date("*t") --stocke la date et heure actuelle du système sous forme d'un tableau à l'intérieur de la variable "Maintenant"
--  Affichage de la date et l'heure
fibaro:debug("il est maintenant ".. Maintenant['hour'].."h"..Maintenant['min'].."min"..", le "..Maintenant['day'].."/"..Maintenant['month'].."/"..Maintenant['year'])
-- Utilisation de l'écart de température extérieure avec la variable globale "Isolation" 
local Temp_Ext = 7 --
-- local TempNetatmoExt = 394 -- capteur de température via module externe Netatmo 
--fibaro:debug("temperature extérieure Netatmo est : "..fibaro:getValue(TempNetatmoExt,"value").."°C")

--if tonumber(fibaro:getValue(TempNetatmoExt,'value')) < tonumber(Temp_Ext)
if tonumber(fibaro:getValue(3, "Temperature")) < tonumber(Temp_Ext)
  
then Isolation = 0.5
  else Isolation = 0
  end
fibaro:debug("Le coéficient Isolation est à ".. Isolation .."°C") 

--  Affichage du mode de chauffage
	local Val = fibaro:getGlobal('Mode_Maison') 
fibaro:debug('Le chauffage est en mode : '..Val)

-- Calcul de la consigne de chauffage
	local ConsigneG = fibaro:getGlobal('H_G')
	local Consigne = tonumber(ConsigneG) + tonumber(Isolation)
fibaro:debug('La consigne de température minimale est de '.. Consigne .. '°C')
	
-- Définition des commutateurs et capteurs utilisés par zone
	 
	
local Zone0 = 'Salle à manger ou Cuisine'
	local SW01 = 51 -- Radiateur jardin - Qubino inversé
	local Temp01 = 638 -- SRT321
	local Consigne0 = 637
	local SW02 = 503 -- Radiateur cour - On = Hors_Gel 
	local Temp02 = 346 -- module détecteur de fumée

local Zone10 = 'Couloir RDC'
    local SW11 = 706 -- radiateur Porte jardin Qubino inversé
	local SW12 = 111 -- Fibaro radiateur excalier du RDC cour (diode+) 
	local Temp10 = 237 -- température mesurée dans le couloir RDC SRT321
	local Temp11 = 647 -- Température du détecteur de Mvt
	local Consigne10 = 236 -- SRT321

local Zone50 = "Couloir 1er"
	local SW51 = 69 -- radiateur coté jardin - Qubino inversé
	local SW52 = 315 -- radiateur coté escalier - Qubino inversé
	local Temp50 = 640 -- SRT321
	local Temp51 = 653 -- module détecteur de fumée 
	local Consigne50 = 630 -- SRT321
	
local Zone20 = 'Chambre des Parents'
	local SW21 = 515 -- Radiateur jardin - Qubino inversé 
	local Temp20 = 32 -- SRT321 T°
	local Consigne20 = 31 -- SRT311 Thrmst 

local Zone30 = 'Salle de bains de la maison'
	local SW31 = 99 -- Radiateur cour
	local Temp30 = 700 -- -- T° Z-TRM3
	local Consigne30 = 700 -- Z-TRM3

local Zone40  = "Salon"
	local SW41 = 294 -- Radiateur coté cour - Qubino inversé
	local SW42 = 103 -- Radiateur coté jardin - On = Stop
	local Temp40 = 636 -- SRT321
	--local Temp41 = 397 -- module intérieur Netatmo du Salon
    local Consigne40 = 635 --SRT321

local Zone60 = "Salle de bains Grange"
    local Consigne60 = 725 -- SRT321 GATEWAY
  	local Temp60 = 726 -- SRT321 GATEWAY
  	local SW61 = 731
-- Affichage de la température de consigneNN
	fibaro:debug('Consigne '.. Val ..' pour la Maison is : '.. Consigne ..'°C')
-- Mesure de la température de la pièce NN et Affichage de la température de la pièce NN
		fibaro:debug('Température de la SàM SRT321 : ' .. fibaro:getValue(Temp01, 'value') .. '°C')
		fibaro:debug('Température de la Cuisine Détecteur de fumée : ' .. fibaro:getValue(Temp02, 'value') .. '°C')
		fibaro:debug('Température du Couloir RDC : ' .. fibaro:getValue(Temp10, 'value') .. '°C') 
		fibaro:debug('Température du Couloir RDC Détecteur de Mvt : ' .. fibaro:getValue(Temp11, 'value') .. '°C') 
		fibaro:debug('Température de la Chambre des parents : ' .. fibaro:getValue(Temp20, 'value') .. '°C')
		fibaro:debug('Température de la Salle de bains : ' .. fibaro:getValue(Temp30, 'value') .. '°C')
		fibaro:debug('Température SRT321 du Salon : ' .. fibaro:getValue(Temp40, 'value') .. '°C')
	--	fibaro:debug('Température Netatmo du Salon : ' .. fibaro:getValue(Temp41, 'value') .. '°C')
		fibaro:debug('Température du Couloir 1er SRT 321 : ' .. fibaro:getValue(Temp50, 'value') .. '°C')
		fibaro:debug('Température du Couloir 1er Détecteur de fumée : ' .. fibaro:getValue(Temp51, 'value') .. '°C')
		fibaro:debug('Température de la Salle de bains de la grange : ' .. fibaro:getValue(Temp60, 'value') .. '°C')
	
-- ACtion requises

if (Val=='Hors_Gel') 
	then 

    -- Mise en mode Hors Gel des radiateurs de la cuisine, Sale de bain maison 
--
fibaro:call(SW01,'turnOff')  --Salle à Manger (Diode+)		
fibaro:call(SW02,'turnOn') --Cuisine (Diode-)
fibaro:call(SW11,'turnOff') --Porte Jardin
fibaro:call(SW12,'turnOn') --Porte cour et escalier  
fibaro:call(SW21,"turnOff") --Chambre des parents (Diode+)
fibaro:call(SW31,'turnOn') --SdB 1er maison (Diode-)
fibaro:call(SW41,'turnOn')  --Salon 1 (Diode+)

fibaro:call(SW51,"turnOff") --Couloir 1er Escalier (Diode-)
fibaro:call(SW52,"turnOff") --Couloir 1er Fenêtre (Diode-)
--fibaro:call(580, "turnOff") -- fil pilote OFF
fibaro:call(SW61, "setValue", "20") -- Hors Gel
--fibaro:getValue(580, "value")
--fibaro:getValue(580, "remoteGatewayId")--??
fibaro:sleep(1000)

fibaro:debug('Switch Salle à manger ' .. SW01 .. ' is :' .. fibaro:getValue(SW01, 'value'))
fibaro:debug('Switch Cuisine ' .. SW02 .. ' is :' .. fibaro:getValue(SW02, 'value'))
fibaro:debug('Switch Couloir RDC Jardin ' .. SW11 .. ' is :' .. fibaro:getValue(SW11, 'value'))
fibaro:debug('Switch Couloir RDC Cour ' .. SW12 .. ' is :' .. fibaro:getValue(SW12, 'value'))
fibaro:debug('Switch SdB Maison ' .. SW31 .. ' is :' .. fibaro:getValue(SW31, 'value'))
fibaro:debug('Radiateur Salon ' .. SW41 .. ' coté Jardin is : ' .. fibaro:getValue(SW42, 'value'))
fibaro:debug('Switch 1 Couloir 1er escalier ' .. SW52 .. ' is : ' .. fibaro:getValue(69, 'value'))
fibaro:debug('Switch 2 Couloir 1er fenêtre ' .. SW51 .. ' is : ' .. fibaro:getValue(315, 'value'))

fibaro:sleep(1000)
fibaro:debug('Switch Chambre Parent ' .. SW21 .. ' is : ' .. fibaro:getValue(SW21, 'value'))
fibaro:debug('Switch Salle de Bains 1er Grange ' .. SW61 .. ' is : ' .. fibaro:getValue(580, "value"))

else fibaro:debug('------------------- Le chauffage n\'est pas dans le bon mode -------------------')
    
end  

fibaro:sleep(1000)

fibaro:debug('Switch Salle à manger ' .. SW01 .. ' is :' .. fibaro:getValue(SW01, 'value'))
fibaro:debug('Switch Cuisine ' .. SW02 .. ' is :' .. fibaro:getValue(SW02, 'value'))
fibaro:debug('Switch Couloir RDC Jardin ' .. SW11 .. ' is :' .. fibaro:getValue(SW11, 'value'))
fibaro:debug('Switch Couloir RDC Cour ' .. SW12 .. ' is :' .. fibaro:getValue(SW12, 'value'))
fibaro:debug('Switch SdB Maison ' .. SW31 .. ' is :' .. fibaro:getValue(SW31, 'value'))
fibaro:debug('Radiateur Salon ' .. SW41 .. ' coté Jardin is : ' .. fibaro:getValue(SW42, 'value'))
fibaro:debug('Switch 1 Couloir 1er escalier ' .. SW52 .. ' is : ' .. fibaro:getValue(69, 'value'))
fibaro:debug('Switch 2 Couloir 1er fenêtre ' .. SW51 .. ' is : ' .. fibaro:getValue(315, 'value'))

fibaro:sleep(1000)
fibaro:debug('Switch Chambre Parent ' .. SW21 .. ' is : ' .. fibaro:getValue(SW21, 'value'))
fibaro:debug('Switch Salle de Bains 1er Grange ' .. SW61 .. ' is : ' .. fibaro:getValue(SW61, "value"))


  fibaro:debug('-------------------------------- Fin du scénario -------------------')
	fibaro:abort()











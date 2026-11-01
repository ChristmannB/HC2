--[[
--%% autostart
%% properties
%% events
%% globals

--]]

----------------Mode Automatique V3 ------------------au 04/03/2023
-- Chambre Parent + Salle à manger + Cuisine + SdB en Mode Panneau Chauffage
-- Gestion de leur switchs selon leur consigne donné par le panneau

fibaro:debug('------------- Début du scénario ---------------')
-- Utilisation de l'heure et de la date
local Maintenant = os.date("*t") --stocke la date et heure actuelle du système sous forme d'un tableau à l'intérieur de la variable "Maintenant"
--  Affichage de la date et l'heure
fibaro:debug("il est maintenant ".. Maintenant['hour'].."h"..Maintenant['min'].."min"..", le "..Maintenant['day'].."/"..Maintenant['month'].."/"..Maintenant['year'])

--- déclaration des fonctions utilisées
function test(x,y)
	a=x+y
  	return a
 	end

function FindPattern(text, pattern, start)
   return string.sub(text, string.find(text, pattern, start))
end

-- Utilisation de l'écart de température extérieure avec la variable globale "Isolation" 
local Temp_Ext = 6 -- Etait à 7°C avant le 25/09/2018 (Salon trop chaud)
fibaro:debug("La temperature de changement du coéfficient Isolation est : "..Temp_Ext .."°C")


----Lecture du module Ext Netatmo ok au 3/03/2023
local ModNetatmo_0 = 643
local ModNetatmo_Ext = 644
local ModNetatmo_Int = 645
local TempNetatmo = fibaro:getValue(ModNetatmo_Ext, "ui.Label1.value")	
fibaro:debug("les valeurs du module Netatmo de la SàM sont : " .. TempNetatmo.. "°C")

---- Le module est vivant
			TempNetatmo = string.sub(TempNetatmo, 5, 7)
			TempNetatmo = FindPattern(TempNetatmo, "%d+")
fibaro:debug("TempNetatmo : " .. (TempNetatmo))

--			TempNetatmoEnt = string.sub(TempNetatmo, 5, 6)
--			TempNetatmoEnt = FindPattern(TempNetatmoEnt, "%d+")
--fibaro:debug("TempNetatmoEnt : " .. tonumber(TempNetatmoEnt))
			--TempNetatmoDec = string.sub(TempNetatmo, 7, 8)
			--TempNetatmoDec = FindPattern(TempNetatmoDec, "%d+")
			--TempNetatmoDec= tonumber(TempNetatmoDec)/10
--fibaro:debug("TempNetatmoDec : " .. tonumber(TempNetatmoDec)/10)
--TempNetatmo = tostring(TempNetamoEnt) .."."..tostring(TempNetatmoDec) --- cette ligne est à tester 
  		fibaro:debug("la valeur Temp Netatmo Ext sélectionnée est de " .. TempNetatmo .."°C")

--TempNetatmoSaM = "-"

---- Lecture du Plugin YR Weather
YR_ID = 3
Temp_Ext_Mesure = fibaro:getValue(3, "Temperature")--fibaro:getValue(Netatmo_EXT, "logTemp", "Value")
fibaro:debug("Température extérieure YR Weather lue : ".. Temp_Ext_Mesure .."°C")
if ((tonumber(Temp_Ext_Mesure) < Temp_Ext) or (tonumber(TempNetatmo) < Temp_Ext))   
  then Isolation = 0.5 -- remis à 0 le 3/12/2017 - 1 avant de changer les fenêtres
  else Isolation = 0
  end
fibaro:debug("Le coéficient Isolation est à ".. Isolation .."°C")

-- Paramètre d'hystéresis
local Hysteresis = 0.2
fibaro:debug("La valeur de l'hystérésisis est de : "..Hysteresis .. " °C")

-----------------Niveau minimal pour les piles des SRT321 --------------
local BLevel = 20 --- niveau minimal des batteries avant basculement
fibaro:debug("Niveau minimal pour les batteries " .. BLevel)

-----------------Recherche du mode de fonctionnement------------------
local Val = fibaro:getGlobal('Mode_Maison')
fibaro:debug("\n---le mode de fonctionnement est " .. Val .. "---")
---- Scénario global
if (Val=='Automatique') 
then 


--------------- Zone 0 Cuisine & Salle à Manger ----------------- 

---- Changement de THRMST si piles trop basses --------------------
local Zone0 = 'Salle à manger ou Cuisine'
fibaro:debug("\n----- Contrôle de la zone 0 SàM et Cuisine ------\n")
local Consigne0 = 637 -- SRT321 SàM
local Temp0 = 638 -- Temp_Salle à manger
local Temp1 = 346 -- Temp_Smoke_Detector_Cuisine
local BatTemp1 = 344 -- module Smoke detector principal
local SW1 = 51 --Quibino std Fenêtre SàM - diode+
local SW2 = 503 -- Ex 59 Qubino std Cuisine - diode- 

-- SàM batteries SRT321 
local ValB_001 = fibaro:getValue(Consigne0, "batteryLevel")
fibaro:debug("Niveau batterie du module  Thrmst SàM" .. Consigne0 .. " est " .. ValB_001 )
-- Cuisine batterie Détecteur de fumée
local ValB_011 = fibaro:getValue(BatTemp1, "batteryLevel")
fibaro:debug("Niveau batterie du module fumée Cuisine " .. BatTemp1 .. " est " .. ValB_011 )

--------------- Zone 0 Cuisine & Salle à Manger ----------------- 

---- lecture module Netatmo SaM -------
local ModNetatmo_0 = 643
local ModNetatmo_Ext = 644
local ModNetatmo_Int = 645
local TempNetatmoSaM = fibaro:getValue(ModNetatmo_0, "ui.Label1.value")	
fibaro:debug("les valeurs du Netatmo de la SàM sont : " .. TempNetatmoSaM .. "°C")
		  --TempNetatmoSalon = string.sub(TempNetatmoSalon, 5, 7)
		  	TempNetatmoSaM = string.sub(TempNetatmoSaM, 5, 9)
		  --TempNetatmoSaM = FindPattern(TempNetatmoSaM, "%d+") -- cette ligne devrait supprimer la décimale 
  		fibaro:debug("la valeur Temp Netatmo SàM avec une décimale est de " .. TempNetatmoSaM .."°C")

---- contrôle du fonctionnement du VD netatmo SaM
if pcall(test,TempNetamoSaM,0)
then 
fibaro:debug( "c'est un nombre")
else 
fibaro:debug( "c'est un texte")
TempNetatmo = 20

end

fibaro:debug("T° ".. TempNetatmoSaM)

---- modification du module de contrôle en fonction de l'état des piles ------

if (tonumber(ValB_001) > tonumber(BLevel))
  then 
  fibaro:debug("Batterie Thrmst OK  -")
  fibaro:debug("-----")
  	Val_1 = fibaro:getValue(Consigne0,"value") -- consigne Thermostat SAM + cuisine
  	Val_2 = fibaro:getValue(Temp0,'value') -- Temp SAM

  if (tonumber(ValB_011) <  tonumber(BLevel))  
	then 
    fibaro:debug("  then batterie fumée KO   --") 
  	Temp1 = Temp0
  	else 
    fibaro:debug("  else batterie fumée OK   --")
  	Temp1 = Temp1 --346 
  	end
  fibaro:debug("l'ID pour la valeur Temp1 est " .. Temp1)
else 
  fibaro:debug("else batterie Thrmst KO   --") 
  --- changement de consigne selon le profil
  local  TypeControl = fibaro:getGlobal("Profil")
  fibaro:debug("Profil " .. TypeControl)
  if TypeControl == "Présence"
  	then
     	Consigne0 = 31 -- Thrmst de la chambre des parents
	    fibaro:debug("l'ID pour la valeur Consigne0 est " .. Consigne0)
  		Val_1 = fibaro:getValue(Consigne0,"value") -- consigne Thermostat Ch parents 
		Val_2 = fibaro:getValue(Temp0,'value') -- Temp SAM
  	else
  	Val_1 = fibaro:getGlobal("H_G")  
  	Val_2 = TempNetatmoSaM
  	end 
end
fibaro:debug("La consigne sélectionnée est " .. Val_1 .. "°C")
fibaro:debug("La température de la SàM sélectionnée est "..Val_2.."°C")

---- Paramètres des radiateurs SaM --------
 		fibaro:debug('-- Contrôle des radiateurs de la zone 0 : ' .. Zone0 .. ' --')

	--Val_1 = fibaro:getValue(Consigne0,"value") -- consigne Thermostat SAM + cuisine
	--Val_2 = fibaro:getValue(Temp0,'value') -- Temp SAM
  	Val_3 = fibaro:getValue(SW1,'value') -- Switch SAM
  	Val_4 = fibaro:getValue(SW2,'value') -- Switch Cuisine
	Val_5 = fibaro:getValue(Temp1,'value') -- Temp Cuisine 

--local	zone = ("Zone0"..Zone0) Salle à manger + Cuisine
--     	fibaro:debug("Consigne SRT " .. Zone0 .. " est : " .. Val_1 .. "°C")

  local ConsZone0 = (tonumber (Val_1) + tonumber(Isolation)) -- ajouté le 31/02/2010 pour contrôle
  fibaro:debug("Consigne corrigée pour " .. Zone0 .. " est de " .. ConsZone0 .."°C") 
    	fibaro:debug("Température de la Salle à manger est : ".. Val_2 .."°C")
  		fibaro:debug("Température de la cuisine est : "..Val_5 .."°C")

---- Télécommande de la Salle à Manger -- le 23/03/2018 Ajout d'un hystérésis de température
    if (tonumber (Val_2)- tonumber(Hysteresis)) < (tonumber (Val_1) + tonumber(Isolation)) -- 28/01/2020 : Ajout tomumber sur Isolation
        then 
        fibaro:call(SW1, "turnOff")
        --fibaro:call(59, "turnOff")
          elseif (tonumber (Val_2) +  tonumber(Hysteresis)) > (tonumber (Val_1) + tonumber(Isolation)) 
          then fibaro:call(SW1, "turnOn")
          --fibaro:call(59, "turnOn")
            end
---- Télécommande de la Cuisine
	if (tonumber (Val_5)- tonumber(Hysteresis)) < (tonumber (Val_1) + tonumber(Isolation))
        then 
        --fibaro:call(51, "turnOff")
        fibaro:call(SW2, "turnOff")
          elseif (tonumber (Val_5) - tonumber(Hysteresis)) > (tonumber (Val_1) + tonumber(Isolation)) 
          then --fibaro:call(51, "turnOn")
          fibaro:call(SW2, "turnOn")
            end  
 
---- Résultats 
  	Val_3 = fibaro:getValue(SW1,'value') -- Switch SAM
  	Val_4 = fibaro:getValue(SW2,'value') -- Switch Cuisine
		fibaro:debug("Switch 1 ".. SW1 .. " Salle à manger est maintenant : " .. Val_3)
		fibaro:debug("Switch 2 ".. SW2 .. " Cuisine est maintenant : " .. Val_4)

-------------------------- Zone 10 Couloir RDC ------------------------------------

---- Paramètres Zone10 Couloir RDC
local Zone10 = 'Couloir RDC'
local Consigne10  = 236 -- RS321 thermostat,
--  local Consigne10  = 637 -- Salle à manger,
local Temp10 =  237 -- RS321 Thrmst Couloir RDC
--local Temp10 =  647 --température mesurée dans le couloir RDC (FIB Motion Sensor)
local SW11 = 507 -- QUBINO EX CUISINE  : radiateur Porte jardin Ex 17 WallPlug RDC
local SW12 = 111 -- QUBINO Porte Cour 
  --local	zone = ("Zone10"..Zone10) Couloir RDC
  		fibaro:debug('\n--------- Contrôle de la zone : '..Zone10 ..' ---------\n')
	    Val_11 = fibaro:getValue(Consigne10, 'value') 
        Val_12 = fibaro:getValue(Temp10, 'value')
		--Val_13 = fibaro:getValue(SW11, 'value')
		--Val_14 = fibaro:getValue(SW12, 'value')

    	fibaro:debug("Consigne "..Zone10 .." est : "..Val_11 .."°C")
  		fibaro:debug("Température "..Zone10 .." est : "..Val_12 .."°C")
    local ConsZone10 = (tonumber (Val_11) + tonumber(Isolation)) -- ajouté le 31/02/1010 pour contrôle
  		fibaro:debug("Consigne corrigée pour " .. Zone10 .. " est de " .. ConsZone10 .."°C") 

---- Contrôle des radiateurs    	
  		  		if tonumber (Val_12) < tonumber (Val_11) 
       	then 
			fibaro:call(SW11,'turnOff') -- maintenant Qubino + diode HG
			fibaro:call(SW12,'turnOff')
--		elseif (tonumber (Val_12)- tonumber(Hysteresis)) > (tonumber (Val_11) + tonumber(Isolation)) 
		elseif (tonumber (Val_12)) > (tonumber (Val_11) + tonumber(Isolation)) --07/05/2020
          then  
			fibaro:call(SW11,'turnOn')
			fibaro:call(SW12,'turnOn')
		end

---- Résultats
    Val_13 = fibaro:getValue(SW11, 'value')
    Val_14 = fibaro:getValue(SW12, 'value')
		fibaro:debug("Switch ID " .. SW11 .. " Couloir RDC jardin " ..Zone10 .." est : "..fibaro:getValue(SW11, 'value'))
		fibaro:debug("Switch ID " .. SW12 .. " Couloir RDC cour " ..Zone10 .." est : "..Val_14)

------------------------------- Zone 20 Chambre des Parents ---------------------------------
    
---- Paramètres Zone20 Chambre Parents
local Zone20 = 'Chambre des Parents'
local Consigne20 = 31
local SW21  = 515
local SW22 = 0
local Temp20 = 32
  		fibaro:debug('\n--------- Contrôle de la zone 20 : ' .. Zone20 .. ' ----------\n')
  Val_21 = fibaro:getValue(Consigne20,"value")
  Val_22 = fibaro:getValue(Temp20,'value')
  --Val_23 = fibaro:getValue(SW21,'value')
  --Val_24 = fibaro:getValue(SW22,'value')

  --local	zone = ("Zone20"..Zone20) Chambre Parent
    	fibaro:debug("Consigne "..Zone20 .." est : "..Val_21 .."°C")
  		fibaro:debug("Température "..Zone20 .." est : "..Val_22 .."°C")  
  
  local ConsZone20 = (tonumber (Val_21) + tonumber(Isolation)) -- ajouté le 31/02/1010 pour contrôle
  fibaro:debug("La consigne corrigé de " .. Zone20 .. " utilisée est de " .. ConsZone20 .."°C") 

---- Télécomande de la Chambre des Parents
  if (tonumber (Val_22) -  tonumber(Hysteresis)) < (tonumber (Val_21) + tonumber(Isolation))
        then 
        fibaro:call(SW21, "turnOff")
        --fibaro:call(nn, "turnOff")
--          elseif (tonumber (Val_22) +  tonumber(Hysteresis)) > (tonumber (Val_21) + tonumber(Isolation))
          elseif (tonumber (Val_22) ) > (tonumber (Val_21) + tonumber(Isolation)) --07/05/2020
          then 
          fibaro:call(SW21, "turnOn")
          --fibaro:call(nn, "turnon")
            end

---- Résultats
    Val_23 = fibaro:getValue(SW21,'value')
		fibaro:debug("Switch 1 ID " .. SW21 .. " de " .. Zone20 .. " est : " .. Val_23)
		--fibaro:debug("Switch 2 " ..Zone20 .." est : "..Val_24)

----------------------------- Zone 30 Salle de bains --------------------------------------------

---- Paramètres Zone30 SdB -- Consigne et Temp = SdB
local Zone30 = 'Salle de bains de la maison'
local Consigne30 = 641 -- SRT321 Thermostat SdB
local Temp30 = 642 -- SRT321 Thermostat SdB
local SW31 = 99 -- interrupteur radiateur SdB à Diode (inversé)

  		fibaro:debug('\n----------- Contrôle de la zone : '..Zone30 ..' -----------\n')
  Val_31 = fibaro:getValue(Consigne30,"value")
  Val_32 = fibaro:getValue(Temp30,'value')
  fibaro:debug( "la lecture de la t° SdB est de " .. fibaro:getValue(Temp30,'value') .. "°C")

---- Contrôle du niveau des batteries du SRT321 de la SdB 
local ValB_30 = fibaro:getValue(Consigne30, "batteryLowNotification")
--fibaro:debug("Alerte batterie du module Thrmst SdB " .. Consigne30 .. " est " .. ValB_30 )
local ValB_31 = fibaro:getValue(Consigne30, "batteryLevel")
fibaro:debug("Niveau batterie du module Thrmst Couloir 1er " .. Consigne30 .. " est " .. ValB_31 )

if tonumber(ValB_31) < 20  -- Niveau bas est normalement inférieur à 20
	then fibaro:debug("then") 
  	Temp30 = 640 -- Temp50 SRT321 Couloir 1er
  	else fibaro:debug("else")
  	Temp30 = Temp30 
  	end
fibaro:debug("l'ID pour la valeur Temp30 est " .. Temp30)

---- Chix des paramètres finaux
  Val_32 = fibaro:getValue(Temp30,'value')
  fibaro:debug( "la lecture de la t° SdB est de " .. fibaro:getValue(Temp30,'value') .. "°C")
    	fibaro:debug("Consigne "..Zone30 .." est : "..Val_31 .."°C")
  		fibaro:debug("Température "..Zone30 .." est : "..Val_32 .."°C")
local consZone30 = (tonumber (Val_31) + tonumber(Isolation))
  fibaro:debug("La consigne corrigée du " .. Zone30 .. " est de " ..consZone30 .. "°C")

---- Télécommande de la Salle de Bains
  if (tonumber (Val_32) - tonumber(Hysteresis)) < (tonumber (Val_31) + tonumber(Isolation))
        then 
        fibaro:call(SW31, "turnOff")
        --fibaro:call(SW32, "turnOff")
         --elseif (tonumber (Val_32) + tonumber(Hysteresis)) > (tonumber (Val_31) + tonumber(Isolation)) 
          elseif (tonumber (Val_32)) > (tonumber (Val_31) + tonumber(Isolation))  --07/05/2020
          then  
          fibaro:call(SW31, "turnOn")
          --fibaro:call(SW32, "turnOn")
          end

---- Résultats
  Val_33 = fibaro:getValue(SW31,'value')
		fibaro:debug("Switch 1 ID ".. SW31 .." de la " ..Zone30 .." est : "..Val_33)
		-- fibaro:debug("Switch 2 ID " ..SW32 .. " de " ..Zone30 .." est : "..Val_34)

-------------------------Zone 40 Salon ----------------------------------------------------------
---- Paramètres Zone 40 Salon
local Zone40 = "Salon"
local Consigne40 = 635 -- Thrmst Salon
local Temp40 = 636 -- Salon
--  	local Consigne40 = 637 -- Salle à manger
--		local Temp40 = 638 -- Salle à manger
local SW41 = 294 
local SW42 = 103 
  		fibaro:debug('\n---------- Contrôle de la zone : '..Zone40 ..' -------------\n')

  Val_41 = fibaro:getValue(Consigne40, 'value')  
  Val_42 = fibaro:getValue(Temp40, 'value')
  Val_43 = fibaro:getValue(SW41, 'value')
  Val_44 = fibaro:getValue(SW42, 'value')
  
    	fibaro:debug("Consigne du "..Zone40 .." est : "..Val_41 .."°C")
    	fibaro:debug("Température SRT321 du "..Zone40 .." est : "..Val_42 .."°C")

---- lecture module Netatmo Salon
---- Lecture du module Salon Netatmo ok au 3/03/2023
local ModNetatmo_0 = 643   --Salle à Manger
local ModNetatmo_Ext = 644 --Jardin
local ModNetatmo_Int = 645 --Salon
local TempNetatmoSalon = fibaro:getValue(ModNetatmo_Int, "ui.Label1.value")	
fibaro:debug("les valeurs du module Netatmo de la SàM sont : " .. TempNetatmoSalon.. "°C")

			TempNetatmoSalon = string.sub(TempNetatmoSalon, 5, 9)
			--TempNetatmoSalon = FindPattern(TempNetatmoSalon, "%d+") -- cette ligne devrait supprimer la décimale
fibaro:debug("TempNetatmo Salon : " .. (TempNetatmoSalon))

--			TempNetatmoSalonEnt = string.sub(TempNetatmoSalon, 5, 6)
--			TempNetatmoSalonEnt = FindPattern(TempNetatmoSalonEnt, "%d+")
--fibaro:debug("TempNetatmoSalonEnt : " .. tonumber(TempNetatmoSalonEnt))
			--TempNetatmoSalonDec = string.sub(TempNetatmoSalon, 7, 8)
			--TempNetatmoSalonDec = FindPattern(TempNetatmoSalonDec, "%d+")
			--TempNetatmoSalonDec= tonumber(TempNetatmoSalonDec)/10
--fibaro:debug("TempNetatmoSalonDec : " .. tonumber(TempNetatmoSalonDec)/10)
--TempNetatmo = (tonumber(TempNetamoSalonEnt) + tonumber(TempNetatmoSalonDec)) -- cette ligne ne fonctioone pas 
  		fibaro:debug("la valeur Temp Netatmo Salon sélectionnée est de " .. TempNetatmoSalon .."°C")

---- contrôle du fonctionnement du VD netatmo Salon

if pcall(test,TempNetamoSalon,0)
then 
fibaro:debug( "c'est un nombre")
else 
fibaro:debug( "c'est un texte")
TempNetatmoSalon = 20

end

fibaro:debug("T° Salon ".. TempNetatmoSalon.. "°C")


---- Télécommande radiateurs Salon  
  local consZone40 = (tonumber (Val_41) + tonumber(Isolation))
  --fibaro:debug("la consigne corrigée pour " .. Zone40 .. " est de " consZone40 .. "°C")
--  local ConsZone0 = (tonumber (Val_1) + tonumber(Isolation)) -- ajouté le 31/02/1010 pour contrôle
  fibaro:debug("La consigne corrigée pour " .. Zone40 .. " est de " .. consZone40 .."°C") 
--if (tonumber (TempNetatmoSalon) - tonumber(Hysteresis)) < (tonumber (Val_41) + tonumber(Isolation)) -- 
 
if (tonumber (Val_42) - tonumber(Hysteresis)) < (tonumber (Val_41) + tonumber(Isolation)) -- fonctionne sur zone 40
  	then 
        fibaro:call(SW42, "turnOff")
    if (tonumber(Val_42)+ 1.5 ) > (tonumber(Val_41) + tonumber(Isolation))
		then 
		  fibaro:call(SW41, "turnOn")
		  else
        fibaro:call(SW41, "turnOff")
			end
    
        fibaro:call(SW41, "turnOff")

  		elseif (tonumber (Val_42)) > (tonumber (Val_41) + tonumber(Isolation)) -- 07/05/2020 Hystéresis changée de 0.5 à 0.2 le 17/02/2020
          then  
          fibaro:call(SW42, "turnOn")
          fibaro:call(SW41, "turnOn")
          end

-- Résultats  
  Val_43 = fibaro:getValue(SW41, 'value')
  Val_44 = fibaro:getValue(SW42, 'value')

  	  	fibaro:debug("Switch 1 ID "..SW41.." du "..Zone40 .." est : "..Val_43)
		fibaro:debug("Switch 2 ID "..SW42.." du " ..Zone40 .." est : "..Val_44)

-------------------------------Zone 50 Couloir 1er & escalier --------------------------------------

---- Paramètres Zone 50 Couloir 1er (Zone Escalier) (Supresssion WallPlug ID49 08/01/2017)
local Zone50 = "Couloir 1er"
local Consigne50 = 639
local SW51 = 315 
local SW52 = 69
local Temp50 = 640  
  --local	zone = ("Zone'50"..Zone50) Couloir 1er
fibaro:debug('\n---------- Contrôle de la zone : '..Zone50 ..' ----------------\n')
  Val_51 = fibaro:getValue(Consigne50,"value")
  Val_52 = fibaro:getValue(Temp50,'value')
  --  Val_55 = fibaro:getValue(116, 'value')
    	fibaro:debug("Consigne "..Zone50 .." est : ".. Val_51 .."°C")
  		fibaro:debug("Température "..Zone50 .." est : ".. Val_52 .."°C")
  local consZone50 = (tonumber (Val_51) + tonumber(Isolation))
  fibaro:debug("La consigne corrigée de ".. Zone50 .. " est de : " .. consZone50 .. "°C") 

---- Contrôle du niveau des batteries du SRT321 du couloir 1er 
	local ValB_50 = fibaro:getValue(Consigne50, "batteryLowNotification")
	--fibaro:debug("Alerte batterie du module Thrmst Couloir 1er " .. Consigne50 .. " est " .. ValB_50 )
	local ValB_51 = fibaro:getValue(Consigne50, "batteryLevel")
	fibaro:debug("Niveau batterie du module Thrmst Couloir 1er " .. Consigne50 .. " est " .. ValB_51 )

if tonumber(ValB_51) < 20  -- Niveau bas est normalement inférieur à 20
	then fibaro:debug("then") 
  	Temp50 = 32
  	else fibaro:debug("else")
  	Temp50 = Temp50 --640 
  	end
fibaro:debug("l'ID pour la valeur Temp50 est " .. Temp50)

---- Télécomande radiateurs Couloir 1er
  if (tonumber (Val_52) - tonumber(Hysteresis)) < tonumber (consZone50)
    then    
        fibaro:call(SW51, "turnOff")
        fibaro:call(SW52, "turnOff")
    	--fibaro:call(116, "turnOn")
--          elseif (tonumber (Val_52) - tonumber(Hysteresis)) > (tonumber (consZone50)) 
          elseif (tonumber (Val_52)) > (tonumber (consZone50)) -- 07/05/2020 
          then  
          fibaro:call(SW51, "turnOn")
          fibaro:call(SW52, "turnOn")
    	  --fibaro:call(116, "turnOff")
            end

---- Résultats
  Val_53 = fibaro:getValue(SW51,'value') -- changé l'AN179 ID282 par Qubino le 13/05/2018
  Val_54 = fibaro:getValue(SW52,'value')

		fibaro:debug("Switch 1 ID " .. SW51 .. " du " .. Zone50 .." est : ".. Val_53)
		fibaro:debug("Switch 2 ID " .. SW52 .. " du " .. Zone50 .." est : ".. Val_54)
  	    --fibaro:debug("Switch 3 ID " .. SW53 .. " du " .. Zone50 .." est : ".. Val_55)

--------------------- Zone Grange ------------------------------------------------------
  fibaro:debug('\n----------- Grange -----------\n')

---- Gestion température de la SdB 1er Grange
---- Paramètres SdB
  local Zone60 = "Salle de bains Grange"
  local Consigne60 = 573 --594 --262
  local Temp60 = 574 --595 --263
  local SW60 = 580 --607 --275

  Val_61 = fibaro:getValue(Consigne60,"value") --consigne
  Val_62 = fibaro:getValue(Temp60,"value") --température

  fibaro:debug('La consigne pour ' .. Zone60 .. ' est de '.. Val_61.."°C")
  fibaro:debug('Température SdB Grange est de '.. Val_62.."°C")
local consZone60 = (tonumber(Val_61) + tonumber(Isolation))
  fibaro:debug('La consigne corrigée de ' .. Zone60 .. ' est de '.. consZone60 .."°C")

---- Contrôle du radiateur de la SdB  
  if tonumber(Val_62 - tonumber(Hysteresis)) < (tonumber(Val_61) + tonumber(Isolation)) --7
    then fibaro:call(SW60, "turnOn") -- fibaro:call(275, "setValue", 99)
    	 -- fibaro:call(264, "turnOn")	c'était temporaire pendant travaux de la SdB 
--    elseif (tonumber (Val_62) + tonumber(Hysteresis)) > (tonumber (Val_61) + Isolation) 
    elseif (tonumber (Val_62)) > (tonumber (Val_61) + Isolation) -- 07/05/2020
          then 
    		fibaro:call(SW60, "setValue", 20)  
   	 	 	-- fibaro:call(264, "turnOff") c'était temporaire pendant travaux de la SdB
    		  end
fibaro:debug("Le fil pilot SdB Grange ID " .. SW60 .. " est à la valeur : ".. fibaro:getValue(SW60, "value"))
----fin de boucle

else 
fibaro:debug('Le chauffage n\'est pas dans le bon mode ')
 	     
end  

fibaro:debug('       ----------- Fin du Sénario ---------- ')


fibaro:abort()

--[[
%% properties
%% events
%% globals
--]]
-------------scène de test -------------------------

-- Utilisation de l'heure et de la date
local Maintenant = os.date("*t") --stocke la date et heure actuelle du système sous forme d'un tableau à l'intérieur de la variable "Maintenant"
fibaro:debug("il est maintenant ".. Maintenant['hour'].."h"..Maintenant['min'].."min"..", le "..Maintenant['day'].."/"..Maintenant['month'].."/"..Maintenant['year'])

---- déclaration des fonctions utilisées
function test(x,y) -- permet de vérifier que x est un nombre
	a=x+y
  	return a
 	end

function FindPattern(text, pattern, start) -- permet d'extraire tous les chiffres avec le "patern" %d+
   return string.sub(text, string.find(text, pattern, start))
end

----Lecture du module Ext Netatmo ok au 3/03/2023
local ModNetatmo_0 = 643
local ModNetatmo_Ext = 644
local ModNetatmo_Int = 645
local TempNetatmo = fibaro:getValue(ModNetatmo_Ext, "ui.Label1.value")	
fibaro:debug("les valeurs du module Netatmo de la SàM sont : " .. TempNetatmo.. "°C")

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

-------------------------------------------
local BLevel = 20 --- niveau minimal des batteries avant basculement
fibaro:debug("Niveau minimel pour les batteries " .. BLevel)

----------Changement de THRMST si piles trop basses
--------------- Zone 0 Cuisine & Salle à Manger ----------------- 
local Zone0 = 'Salle à manger ou Cuisine'
fibaro:debug("----- Contrôle des modules Zwave ------")
local Consigne0 = 637 -- SRT321 SàM
local Temp0 = 638 -- Temp_Salle à manger
local Temp1 = 346 -- Temp_Smoke_Detector_Cuisine
local BatTemp1 = 344 -- module Smoke detector principal
local SW1 = 51 --Quibino std Fenêtre SàM - diode+
local SW2 = 503 -- Ex 59 Qubino std Cuisine - diode- 

-- SàM
local ValB_000 = fibaro:getValue(Consigne0, "batteryLowNotification")
--fibaro:debug("Alerte batterie du module Thrmst SàM " .. Consigne0 .. " est " .. ValB_000 )
local ValB_001 = fibaro:getValue(Consigne0, "batteryLevel")
fibaro:debug("Niveau batterie du module  Thrmst SàM" .. Consigne0 .. " est " .. ValB_001 )
-- Cuisine
local ValB_010 = fibaro:getValue(Temp1, "batteryLowNotification")
--fibaro:debug("Alerte batterie du module fumée Cuisine " .. Temp1 .. " est " .. ValB_010 )
local ValB_011 = fibaro:getValue(BatTemp1, "batteryLevel")
fibaro:debug("Niveau batterie du module fumée Cuisine " .. BatTemp1 .. " est " .. ValB_011 )

------- lecture module Netatmo SàM -------
local ModNetatmo_0 = 643
local ModNetatmo_Ext = 644
local ModNetatmo_Int = 645
local TempNetatmoSaM = fibaro:getValue(ModNetatmo_0, "ui.Label1.value")	
fibaro:debug("les valeurs du module Netatmo de la SàM sont : " .. TempNetatmoSaM .. "°C")
		  --TempNetatmoSalon = string.sub(TempNetatmoSalon, 5, 7)
		  	TempNetatmoSaM = string.sub(TempNetatmoSaM, 5, 9)
		  --TempNetatmoSaM = FindPattern(TempNetatmoSaM, "%d+") -- cette ligne devrait supprimer la décimale 
  		fibaro:debug("la valeur Temp Netatmo SàM avec une décimale est de " .. TempNetatmoSaM .."°C")


----------contrôle du fonctionnement du VD netatmo SaM

if pcall(test,TempNetamoSaM,0)
then 
fibaro:debug( "c'est un nombre")
else 
fibaro:debug( "c'est un texte")
TempNetatmo = 20
end

fibaro:debug("T° ".. TempNetatmoSaM)

------- modification du module de contrôle en fonction de l'état des piles ------

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
  --- changement de consigne
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

------------Contrôle des radiateurs --------
 		fibaro:debug('-- Contrôle de la zone 0 : ' .. Zone0 .. ' --')

--  	Val_1 = fibaro:getValue(Consigne0,"value") -- consigne Thermostat SAM + cuisine
--  	Val_2 = fibaro:getValue(Temp0,'value') -- Temp SAM
  	Val_3 = fibaro:getValue(SW1,'value') -- Switch SAM
  	Val_4 = fibaro:getValue(SW2,'value') -- Switch Cuisine
	Val_5 = fibaro:getValue(Temp1,'value') -- Temp Cuisine
  --local	zone = ("Zone0"..Zone0) Salle à manger + Cuisine
     	fibaro:debug("Consigne SRT " .. Zone0 .. " est : " .. Val_1 .. "°C")
  local ConsZone0 = (tonumber (Val_1)) -- + tonumber(Isolation)) -- ajouté le 31/02/2010 pour contrôle
  fibaro:debug("Consigne corrigée pour " .. Zone0 .. " est de " .. ConsZone0 .."°C") 
    	fibaro:debug("Température de la Salle à manger est : ".. Val_2 .."°C")
  		fibaro:debug("Température de la cuisine est : "..Val_5 .."°C")

---- Télécomande de la Salle à Manger + Cuisine 
	-- code à remettre 
  
---- Télécomande de la Cuisine
	-- code à remettre
  
  	Val_3 = fibaro:getValue(SW1,'value') -- Switch SAM
  	Val_4 = fibaro:getValue(SW2,'value') -- Switch Cuisine
		fibaro:debug("Switch 1 ".. SW1 .. " Salle à manger est : " .. Val_3)
		fibaro:debug("Switch 2 ".. SW2 .. " Cuisine est : " .. Val_4)
		
		
----------------Zone 40 Salon ----------------------------------
----Lecture du module Salon Netatmo ok au 3/03/2023
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

--TempNetatmoSalon = "-"

----------contrôle du fonctionnement du VD netatmo Salon

if pcall(test,TempNetamoSalon,0)
then 
fibaro:debug( "c'est un nombre")
else 
fibaro:debug( "c'est un texte")
TempNetatmoSalon = 20
end

fibaro:debug("T° Salon ".. TempNetatmoSalon.. "°C")

----------------Zone 50 Couloir 1er ----------------------------
local Zone50 = "Couloir 1er"
fibaro:debug("-----------Contrôle de la zone " .. Zone50 .. " --------------------------") 
local Consigne50 = 639
local SW51 = 315 -- Ex 282
local SW52 = 69
local Temp50 = 640  

fibaro:debug('-- Contrôle de la zone : '.. Zone50 ..' --')

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

-----------------------------------------
fibaro:debug('-- Fin du scénario --')
--fibaro:abort()


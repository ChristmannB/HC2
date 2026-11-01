--[[
%% properties
%% events
%% globals
--]]
-- Scémario V3.4 d'arrêt de tous les switchs mise à jour le 08/08/2023
-- Utilisation de l'heure et de la date
local Maintenant = os.date("*t") --stocke la date et heure actuelle du système sous forme d'un tableau à l'intérieur de la variable "Maintenant"
--  Affichage de la date et l'heure
fibaro:debug("il est maintenant ".. Maintenant['hour'].."h"..Maintenant['min'].."min"..", le "..Maintenant['day'].."/"..Maintenant['month'].."/"..Maintenant['year'])

-- Affchage du mode de chauffage - mise à jour le 2 avril 2018
local Val = fibaro:getGlobal('Mode_Maison')
local SW01  = 51 --Quibino Fenêtre SàM inversé
local SW02  = 503 --Qubino Cuisine Diode  
local SW11 = 706 -- Couloir RDC Porte jardin -- inversé 
local SW12 = 111 -- Couloir RDC Cour
local SW21 = 515 -- Chambre des parents -- inversé
local SW31 = 99 -- SdB Maison Diode 
local SW41 = 294 -- Salon Cour -- inversé
local SW42 = 103 -- Salon Jardin
local SW51 = 315 -- Couloir 1er Qubino + diode  -- inversé
local SW52 = 69 -- Couloir 1er Diode -- inversé
local SW61 = 731 -- Fil pilote SdB Grange


 
fibaro:debug('-- Début du scénario --')
fibaro:debug('Le chauffage est en mode : '..Val)


if (Val=='STOP') 
	then 

-- Switchs directs -- il n'y en a plus

-- Switchs inversés
fibaro:call(SW01, "turnOff") -- SAM (diode+)
  Val_01 = fibaro:getValue(SW01, 'value') -- Switch SAM
		fibaro:debug("Switch 1 ID "..SW01 .." Salle à manger est : " .. Val_01)
fibaro:call(SW02, "turnOn") -- CUISINE (diode-)
  Val_02 = fibaro:getValue(SW02, 'value') -- Switch Cuisine (Inversé)
		fibaro:debug("Switch 2 ID "..SW02 .." Cuisine est : " .. Val_02)
fibaro:call(SW11, "turnOff") -- COULOIR RDC JARDIN (Qubino + diode)
  Val_11 = fibaro:getValue(SW11, 'value') -- Couloir RDC Jardin Qubino + diode-
		fibaro:debug("Switch 2 ID "..SW11 .." Couloir RDC Jardin est : "..Val_11)
fibaro:call(SW12, "turnOn") -- COULOIR RDC COUR (diode+)
  Val_12 = fibaro:getValue(SW12, 'value') -- Couloir RDC Cour
		fibaro:debug("Switch 1 ID "..SW12 .." Couloir RDC Cour est : "..Val_12)
fibaro:call(SW21, "turnOff") -- CHAMBRE PARENT (diode+)
  Val_21 = fibaro:getValue(SW21, 'value') -- Chambre Parents
		fibaro:debug("Switch 1 ID "..SW21 .." Chambre Parents est : "..Val_21)
fibaro:call(SW31, "turnOn") -- SdB MAISON (diode+)
  Val_31 = fibaro:getValue(SW31, 'value') -- SdB Maison (Inversé)
		fibaro:debug("Switch 1 ID "..SW31 .." SdB Mainson est : "..Val_31)
fibaro:call(SW41, "turnOff") -- SALON 1 (diode+)
  Val_41 = fibaro:getValue(SW41, 'value') -- Salon Cour
  		fibaro:debug("Switch 1 ID "..SW41 .." Salon Cour est : "..Val_41)
fibaro:call(SW42, "turnOn") -- SALON 2 (diode+)
  Val_42 = fibaro:getValue(SW42, 'value') -- Salon Jardin
  		fibaro:debug("Switch 1 ID "..SW42 .." Salon Jardin est : "..Val_42)
fibaro:call(SW51, "turnOff") -- COULOIR 1er JARDIN (diode+)
  Val_51 = fibaro:getValue(SW51, 'value') -- Salon Cour
  		fibaro:debug("Switch 1 ID "..SW51 .." Couloir 1er Jardin est : "..Val_51)
fibaro:call(SW52, "turnOff") -- COULOIR 1er Cour
  Val_52 = fibaro:getValue(SW52, 'value') -- Couloir Escalier RDC (inversé))
		fibaro:debug("Switch 2 ID "..SW52 .." Couloir 1er Cour est : "..Val_52)

-- Fils pilotes

fibaro:call(SW61, "turnOff") --chauffage SdB Grange FIL PILOTE
fibaro:sleep(2000)
Val_61 = fibaro:getValue(SW61, 'value') -- SdB Grange Diode (Inversé)
  		fibaro:debug("Switch 1 ID "..SW61 .." SdB Grange est : "..Val_61)
  
  else fibaro:debug('------------------- Le chauffage n\'est pas dans le bon mode -------------------')
    
end  


fibaro:debug('-- Fin du scénario --')
-- fibaro:abort()
--[[
%% autostart
%% properties
%% events
%% globals

--]]
----------------Mode Automatique---------------------------------------------
--Scène ID 12
-- Utilisation de l'heure et de la date
local Maintenant = os.date("*t") --stocke la date et heure actuelle du système sous forme d'un tableau à l'intérieur de la variable "Maintenant"
--  Affichage de la date et l'heure
fibaro:debug("il est maintenant ".. Maintenant['hour'].."h"..Maintenant['min'].."min"..", le "..Maintenant['day'].."/"..Maintenant['month'].."/"..Maintenant['year'])
-- Utilisation de l'écart de température extérieure avec la variable globale "Isolation" 
local Temp_Ext = 6 -- Condition supprimée car Netatmo plus installé -- Etait à 7°C avant le 25/09/2018 (Salon trop chaud)
--fibaro:debug("La temperature de référence est : "..Temp_Ext .."°C")
--fibaro:debug("La temperature extérieure Netatmo est : "..fibaro:getValue(394,"value").."°C")
--if tonumber(fibaro:getValue(394,'value')) < Temp_Ext
--  then Isolation = 0 -- Mis à 0 pour l'Insert - était à 0.5 le 31/03/2018 - 1 avant de changer les fenêtres
--  else Isolation = 0
--  end
--fibaro:debug("Le coéficient Isolation est à ".. Isolation .."°C")
-- Chambre Parent + Salle à manger + Cuisine + SdB en Mode Panneau Chauffage
-- Gestion de leur switch selon leur consigne donné par le panneau
local Val = fibaro:getGlobal('Mode_Maison')
local Val_4 = 1 -- écart de température pour avoir priorité sur l'électrique
-- Paramètre Zone0
local Zone0 = 'Salle à manger '
--local Consigne0 = 28 -- SRT321 SàM
local SW1 = 324 --Fibaro isolé
local Temp0 = 123 -- Temp_Salle à manger

-- Affichage des différents acteurs
fibaro:debug('-- Début du scénario  pour Insert --')
fibaro:debug('Le chauffage est en mode : '..Val)
fibaro:debug("l'écart de température de priorité de l'insert est de : "..Val_4.."°C")

-- Scénario
if (Val=='Automatique') 
  then 

	fibaro:debug('-- Contrôle de la zone : '..Zone0 ..' --')

  	Val_1 = fibaro:getValue(637,"value") -- consigne Thermostat SAM + cuisine
  	Val_2 = fibaro:getValue(638,'value') -- Temp SAM
  	
  fibaro:debug("Consigne "..Zone0 .." est : ".. Val_1 .."°C")
  fibaro:debug("Température de la Salle à manger est : ".. Val_2 .."°C")
  -- Télécomande de l'insert de la Salle à Manger 
local Val_5 = (tonumber (Val_1)  + tonumber(Val_4)) --+ tonumber(Isolation)
fibaro:debug("Consigne de comparaison "..Val_5 .."°C")
--  fibaro:debug("--test 0--")
    if tonumber (Val_2) < tonumber (Val_5) -- + tonumber(Isolation) + tonumber(Val_4))
    then 
--  fibaro:debug("--test 1--")
     fibaro:call(SW1, "turnOn")
        
          elseif tonumber (Val_2)  > tonumber (Val_5) --+ tonumber(Isolation) + tonumber(Val_4)) 
          then fibaro:call(SW1, "turnOff")
 --   fibaro:debug("--test 2--")
          end
  Val_3 = fibaro:getValue(SW1,'value') -- Switch Insert
  fibaro:debug("Le switch de l'Insert est à : "..Val_3)
--fin de boucle
else fibaro:debug('Le chauffage n\'est pas dans le bon mode ')
  	-- fibaro:call(324, "turnOff")    
end  
fibaro:debug('-- Fin du scénario --')
fibaro:abort()

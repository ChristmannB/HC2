--[[
--%% autostart
%% properties
%% events
%% globals

--]]
----------------Scène de test---------------------------------------------
-- Utilisation de l'heure et de la date
local Maintenant = os.date("*t") --stocke la date et heure actuelle du système sous forme d'un tableau à l'intérieur de la variable "Maintenant"
--  Affichage de la date et l'heure
fibaro:debug("il est maintenant ".. Maintenant['hour'].."h"..Maintenant['min'].."min"..", le "..Maintenant['day'].."/"..Maintenant['month'].."/"..Maintenant['year'])
--fibaro:debug("Température extérieure Netatmo : "..fibaro:getValue(84,"value").."°C")
 
-- Utilisation de l'écart de température extérieure avec la variable globale "Isolation" 
local Temp_Ext = 7

YR_ID = 3
Temp_Ext_Mesure = fibaro:getValue(3, "Temperature")--fibaro:getValue(Netatmo_EXT, "logTemp", "Value")
fibaro:debug("Température extérieure Netatmo lue : ".. Temp_Ext_Mesure .."°C")
if (tonumber(Temp_Ext_Mesure) < Temp_Ext)   
  then Isolation = 1 -- remis à 0 le 3/12/2017 - 1 avant de changer les fenêtres
  else Isolation = 0
  end
fibaro:debug("Le coéficient Isolation est à ".. Isolation .."°C")
-- Chambre Parent + Salle à manger + Cuisine + SdB en Mode Panneau Chauffage
-- Gestion de leur switch selon leur consigne donné par le panneau
local Val = fibaro:getGlobal('Mode_Maison')

-- Contrôle d'ouveture des portes Supprimé en ligne 108 le 23/03/2018 pour problème avec un capteur ancien
local Porte_C = "--" --18-12-2016
local Porte_J = "--" --14-01-2018
--if tonumber(fibaro:getValue(290,"value")) == 0 --18-12-2016
  --	then Porte_J = "fermée" --18-12-2016
  	--else Porte_J = "ouverte" --18-12-2016
  	--end --18-12-2016
--if tonumber(fibaro:getValue(305,"value")) == 0 --17-01-2018
  --	then Porte_C = "fermée" --17-01-2018
  	--else Porte_C = "ouverte" --17-01-2018
  	--end --14-01-2018
--fibaro:debug("La porte d'entrée côté jardin est "..Porte_J .." & celle côté cour est "..Porte_C)
-- fibaro:debug("La porte d'entrée côté cour est "..Porte_C) -- .." & celle côté cour est "..Porte_C)
-- Affichage des différents acteurs
fibaro:debug('-- Début du scénario --')
fibaro:debug('Le chauffage est en mode : '..Val)
	-- Gestion température de la SdB 1er Grange
  Val_61 = fibaro:getValue(262,"value") --consigne
  Val_62 = fibaro:getValue(263,"value") --température
  fibaro:debug('-------- Grange ----------')
  fibaro:debug('La consigne SdB Grange est de '.. Val_61.."°C")
  fibaro:debug('Température SdB Grange est de '.. Val_62.."°C")
 -- fibaro:debug('Dernière mise à jour est de '.. fibaro:getValue(271, "lastUpdate"))
 -- fibaro:debug('Consommation énergétique '.. fibaro:getValue(271, "energy"))
 -- fibaro:debug('température DS18B20 '.. fibaro:getValue(271, "temperatureValue"))
  fibaro:debug('Noeud mort ? '.. fibaro:getValue(271, "dead"))
 -- fibaro:debug('Réactiver le Noeud mort ? '.. fibaro:getValue(271, "wakeUpDeadDevice"))
  fibaro:debug('Configuré ? '.. fibaro:getValue(271, "configured"))
 -- fibaro:debug('Mode d utilisation '.. fibaro:getValue(271, "currentMode")) 
 -- fibaro:debug('Puissance '.. fibaro:getValue(271, "power")) 

  if tonumber (Val_62) < (tonumber(Val_61) + Isolation) --7
    then fibaro:call(271, "setValue", 0) -- fibaro:call(275, "setValue", 99)
    	 -- fibaro:call(264, "turnOn")	c'était temporaire pendant travaux de la SdB 
    elseif (tonumber (Val_62)+ 0.5) > (tonumber (Val_61) + Isolation) 
          then 
    		fibaro:call(271, "setValue", 0)  -- fibaro:call(275, "setValue", 9) -- fibaro:call(254,"turnOn")
   	 	 	-- fibaro:call(264, "turnOff") c'était temporaire pendant travaux de la SdB
  end
   fibaro:debug('Le Fil pilote 271 de la SdB Grange a la valeur '.. fibaro:getValue(271,"value"))
 -- fibaro:debug('Le Fil pilote 271 de la SdB Grange est en mode '.. fibaro:getValue(275,"currentMode"))
 -- fibaro:debug('Le switch 264 de la SdB Grange est '.. fibaro:getValue(264,"value")) -- Temporaire
 -- fibaro:debug('La consigne de la SdB_Grange est de '..fibaro:getValue(262,"value"))
--fin de boucle
    
  	     
fibaro:debug('-- Fin du scénario --')
fibaro:abort()


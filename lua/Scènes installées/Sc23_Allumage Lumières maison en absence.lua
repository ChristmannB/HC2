--[[
%% properties
%% events
%% globals
Abscence
%% value
544 
--]]
-- FGS-212 ID 544 = couloir RDC danbs tableau électrique de la cuisine 
local Present = fibaro:getGlobalValue("Abscence") -- le scrip ne fonctionne que si nous sommes abscents
fibaro:debug( "Abscence est " .. Present)
if fibaro:getGlobalValue("Abscence") == "OUI" then
local Maintenant = os.date("*t") --stocke la date et heure actuelle du système sous forme d'un tableau à l'intérieur de la variable "Maintenant"
--  Affichage de la date et l'heure
fibaro:debug("il est maintenant ".. Maintenant['hour'].."h"..Maintenant['min'].."min"..", le "..Maintenant['day'].."/"..Maintenant['month'].."/"..Maintenant['year'])
local FGS212 = 544
fibaro:debug("Le couloir est en état ".. fibaro:getValue(FGS212, "value"))
local Start_Matin = 6 -- en heure : début de l'allumage
local End_Matin = 9 -- fin de l'allumage
local Start_Soir = 16
local End_Soir = 21

if ( Maintenant['hour'] < 21 or Maintenant['hour'] > 16) 
        then fibaro:call(FGS212,"turnOn")
			else fibaro:call(FGS212,"turnOff")
				end    		
  if ( Maintenant['hour'] < 6 or Maintenant['hour'] > 9)			
       	then fibaro:call(FGS212,"turnOn")
			else fibaro:call(FGS212,"turnOff")
                 end
  fibaro:sleep(5000)
  fibaro:debug("Le couloir est en état ".. fibaro:getValue(FGS212, "value"))

else 
   fibaro:debug("Pas de changement du FGS-212 ") --.. " du couloir RDC qui est : " .. fibaro:getValue(FGS212, "value"))
    fibaro:abort()
  end

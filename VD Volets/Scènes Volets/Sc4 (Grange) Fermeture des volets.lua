--[[
%% events
%% properties
--commande
%% globals
--]]

--Global Variable 'commande' : 0 = Stop, 1= UP, 2 = DOWN
local Action = fibaro:getGlobal('commande')
fibaro:debug('Action requise '.. Action)

local TxtAction
if(tonumber(Action) == 0)
  then 
TxtAction = "Arrêter"
  elseif  (tonumber(Action) == 1) 
  	then TxtAction = "Ouvrir"
		elseif (tonumber(Action) == 2) 
  			then TxtAction = "Fermer"
  else TxtAction = "Repos"
  end
  fibaro:debug("Action demandée : " .. TxtAction)

-- déclaration des Switchs utilisés
--FGS-2222 ID 655
local SW1 = 656
local SW2 = 658

fibaro:debug('------------- Etats initiaux des switchs ---------------')
local PositionS1 = fibaro:getValue(SW1,"value")
local PositionS2 = fibaro:getValue(SW2,"value")
 
fibaro:debug('Position commande S1 : ' .. PositionS1)
fibaro:debug('Position commande S2 : ' .. PositionS2)

fibaro:debug('------------- Début du scénario ---------------')

fibaro:debug('--------RàZ des switchs & Vérification des switchs après RàZ -----------')
fibaro:call(SW1, "turnOff")
fibaro:call(SW2, "turnOff")

local PositionS111 = fibaro:getValue(SW1,"value")
local PositionS222 = fibaro:getValue(SW2,"value")
fibaro:debug('Position commandes ' .. PositionS111 .. ", " .. PositionS222)

fibaro:debug('------------- Commande Fermeture des volets ---------------') 
--if (tonumber('commande') == 2)
  --then
	fibaro:call(SW2, 'turnOn')
	fibaro:debug('SW2 est à ', fibaro:getValue(SW2,"value"))
  fibaro:sleep(500)
  	fibaro:call(SW2, 'turnOff')
	fibaro:debug('SW2 est de nouveau à ', fibaro:getValue(SW2,"value"))
  --end
fibaro:debug('---------------fin du scénario---------------')
fibaro:abort()  

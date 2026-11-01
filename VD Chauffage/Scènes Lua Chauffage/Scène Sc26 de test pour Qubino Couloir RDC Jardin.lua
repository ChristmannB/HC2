--[[
--%% autostart
%% properties
%% events
%% globals

--]]
--Essai de mise en route du quibino inversé
local SW11 = 706
local StateSW11 = fibaro:getValue(SW11,"value")
fibaro:debug("Etat initial du Switch ".. SW11 .. " est " .. fibaro:getValue(SW11,"value"))

fibaro:debug("Changement d'état OFF")
fibaro:call(SW11,'turnOff')
fibaro:debug("Nouvel Etat du Switch ".. SW11 .. " est " .. fibaro:getValue(SW11,"value"))

fibaro:debug("Attentede 5s")
fibaro:debug("Changement d'état On")
fibaro:call(SW11,'turnOn')
fibaro:debug("Nouvel Etat du Switch ".. SW11 .. " est " .. fibaro:getValue(SW11,"value"))

fibaro:debug("Fin de la scène")


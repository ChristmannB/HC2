--[[
%% properties
%% events
%% globals
Chauffeau
--]]
local mode = fibaro:getGlobal("Chauffeau")
fibaro:debug("le mode du chauffe-eau est en " .. mode)
 if mode == "Stop"
  then fibaro:call(672, "pressButton", "2")
  --fibaro:sleep(2000)
  elseif mode == "Marche"
  --fibaro:sleep(2000)
  then fibaro:call(672, "pressButton", "4")
  else --if mode == "HeuresCreuses"
  fibaro:call(672, "pressButton", "3")
  --fibaro:sleep(2000)
  end
fibaro:sleep(2000)
--fibaro:call(672, "pressButton", "")


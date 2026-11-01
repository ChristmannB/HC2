--[[
%% autostart
%% globals
--]]

-- LUA Script for dead nodes handling V1.0.1
-- Copyright Â© 2013 Jean-christophe Vermandé

fibaro:debug("HC2 start script at " .. os.date());

-- check script instance count in memory
if (fibaro:countScenes() > 1) then
  fibaro:abort();
  fibaro:debug("Script already running.");
end

-- SETTINGS

-- Debug true or false (output information in HC2 debug window)
local debug = true;
-- User ID (email used to notify)
local userID = 2;
-- List of nodes you want to check
local nodes = {17,51,69,99,103,111,294,315,507,324,503,515};  -- liste des modules Switch ONLY OK bc le 24/05/2020
-- Interval between polling
local repeatTime = (24*2*30*60*1000)--(30*60*1000); -- soit 30 minutes changé pour 24h 

-- DO NOT EDIT THE CODE BELOW (except to suit your needs) --

local lookFor = function()
  local id, status, dtLog;
  for i = 1, #nodes do
    id = nodes[i];
    status = fibaro:getValue(id, 'dead');
    dtLog = os.date();
    if status == "1" then
      -- dead node found
      local name = fibaro:getName(id);
      local room = fibaro:getRoomNameByDeviceID(id);
      local message = dtLog .. " [status] device (" .. name .. " ID#" .. id .. " in room [" .. room .. "]) is flagged as dead node." 
      if debug then fibaro:debug(message) end
      -- try to wakeUp device
      fibaro:wakeUpDeadDevice(id);
      -- send mail
      fibaro:call(userID, "sendEmail", "Dead Nodes", message);
    end
  end
end

-- START ENGINE LOOP PROCESS
while true do
  lookFor();
  fibaro:sleep(repeatTime);
end

--[[
v 1.0.1 (06-2013)
	Implement new getRoomName / getRoomNameByDeviceID from 3.552+
v 1.0.0 (01-2013)
	First stable release
--]]

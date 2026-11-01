-- Virtual Device : Heating Override
-- Version        : 1.3
-- Date Created   : 19-Nov-2016
-- Last Changed   : 25-Feb-2017
-- HC Version     : Home Center 2 v4.110
-- Created By     : Dave Harrison

-- Revision History
-- ----------------

-- 1.1 01-Jan-17	Add retrieval of current temperature
-- 1.2 22-Jan-17  Handle situation where VD has not been assigned to a room
-- 1.3 25-Feb-17	Day/Week Up/Down buttons

--=============================================
-- MainLoop
--=============================================

--=============================================
-- Declarations
--=============================================
local selfId = fibaro:getSelfId()
local currentMode = ""
local newMode = ""
local currentZone = ""
local currentPanelName = ""
local currentPanelId = 0
local panelTemp = 0
local panelEndTimestamp = 0
local panelRooms = {}
local tempTimeLabel = ""
local overridenTempOrTime = false
local labelTemp = 0
local labelEndTimestamp = 0
local currentTemps = ""
local tempUnit = ""
local currentTimestamp = os.time()
local delaySeconds = 60

if (not HC2) then
  HC2 = Net.FHttp("127.0.0.1", 11111)
end

--=============================================
-- Functions
--=============================================
-- getDefaultZone
-----------------
-- Return the Heating Panel Name and Id that is used
-- to control the heating for the selected room

function getDefaultZone(roomId)

	-- Get the Heating Panels
	local response ,status, errorCode = HC2:GET("/api/panels/heating")
	
	if (status == "200") then
		local panels = json.decode(response)
		
		-- For each panel/zone, get the panel details, and check if the selected room is
		-- controlled by the heating panel. If so, then return the details.
		for panelKey, panelValue in pairs(panels) do
			
			response ,status, errorCode = HC2:GET("/api/panels/heating/" .. panelValue.id)
			
			if (status == "200") then
			  local panel = json.decode(response)
				
			  local rooms = panel.properties.rooms
			  
			  -- Check to see if the current room is one of the values controlled
			  -- by this heating panel
			  for roomKey, roomValue in pairs(rooms) do
			    if (roomValue == roomId) then
			      return panel.name, panel.id
			    end
			  end
			end
		end
		
		-- Not found, so return the first panel
		return panels[1].name, panels[1].id
	end
	
	-- Unable to retrieve the Heating Panel
	return "Heating Panel Not Found", 0
end

-- getPanelNameAndId
--------------------
-- Return the Heating Panel Name and Id from the Zone
-- Format of the zone is NNNNNNNNNNNNN (DDD)
-- where NNNNNNNNNNNNN is the Heating Panel Name
-- and DDD is the Panel Id

function getPanelNameAndId(zone)

	local zoneName = ""
	local zoneId = 0
	
	-- The zone contains the Panel Name and Id in parentheses
	if (zone ~= nil and zone ~= "") then
		local start, finish = string.find(zone, "%(%d+%)")
		
		zoneName = string.sub(zone, 1, start - 2) -- There is a space before the '('
		zoneId = string.sub(zone, start + 1, finish - 1)
	end

	return zoneName, zoneId
end

-- getPanelDetails
------------------
-- Return the mode (Auto, Manual, Vacation) for the selected panel
-- As well as the override temperature and manual End Time

function getPanelDetails(panelId)

	local mode = ""
	local temp = 0
	local timestamp = 0
	local endTimestamp = 0
	local rooms = {}
	
	local currentDay = os.date("%A"):lower()  -- monday, tuesday etc
	local currentMinutes = os.date("%H") * 60 + os.date("%M")
	local periods = {"morning", "day", "evening", "night"}
	
	-- Determine if the panel is current under manual or vacation control
	if (panelId ~= 0) then
		
		-- Get the panel details
		local response, status, errorCode = HC2:GET("/api/panels/heating/" .. panelId)
		
		if (status == "200") then
		  local panel = json.decode(response)
		  
		  rooms = panel.properties.rooms
			
			if (panel.properties.vacationTemperature > 0) then
				mode = "Vacation"
				temp = panel.properties.vacationTemperature
			else
				if (panel.properties.handTemperature > 0
				and panel.properties.handTimestamp > currentTimestamp) then
					mode = "Manual"
					temp = panel.properties.handTemperature
					endTimestamp = panel.properties.handTimestamp
				else
					
					-- Otherwise we're in Auto mode
					-- We'll need to get the temperature and end time from the schedule
					mode = "Auto"
					local endDateTime = os.date("*t")
					local scheduleToday = panel.properties[currentDay]
					
					-- If the night starts after midnight, then add on 24 hours
					if (scheduleToday.night.hour < scheduleToday.evening.hour) then
						scheduleToday.night.hour = scheduleToday.night.hour + 24
					end
					
					-- If we're before the morning period, then get the previous day's night
					if (currentMinutes < scheduleToday.morning.hour * 60 + scheduleToday.morning.minute) then

						endDateTime.hour = scheduleToday.morning.hour
						endDateTime.min = scheduleToday.morning.minute
						endDateTime.sec = 0
						
						local yesterday = os.date("%A", os.time() - 24*60*60):lower()
						scheduleToday = panel.properties[yesterday]
						temp = scheduleToday.night.temperature
						
					else
						
						-- If we're after then night period, then return that
						if (currentMinutes >= scheduleToday.night.hour * 60 + scheduleToday.night.minute) then 
							temp = scheduleToday.night.temperature
							
							-- The End Time is tomorrow's morning time
							local tomorrow = os.date("%A", currentTimestamp + 24*60*60):lower()
							scheduleToday = panel.properties[tomorrow]
							
							endDateTime.hour = scheduleToday.morning.hour
							endDateTime.min = scheduleToday.morning.minute
							endDateTime.sec = 0
							
							-- Set the date to tomorrow's date
							local tomorrowDateTime = os.date("*t", currentTimestamp+24*60*60)
							endDateTime.day = tomorrowDateTime.day
							endDateTime.month = tomorrowDateTime.month
							endDateTime.year = tomorrowDateTime.year

						else
					
							-- Otherwise find out which period of the day we're in
							-- and return the temperature for that period
							for i, value in ipairs(periods) do
								if (currentMinutes < scheduleToday[value].hour * 60 + scheduleToday[value].minute) then
									temp = scheduleToday[periods[i - 1]].temperature

									endDateTime.hour = scheduleToday[periods[i]].hour
									endDateTime.min = scheduleToday[periods[i]].minute
									endDateTime.sec = 0

									break
								end
							end
						end
					end
					
					-- Convert the Date/Time to a timestamp for Auto mode
					endTimestamp = os.time(endDateTime)
				end
			end
		end
	end
	
	return mode, temp, endTimestamp, rooms
end

-- getTemperatureUnit
---------------------
-- Return the temperature unit from the system settings

function getTemperatureUnit()

	-- Default to °C just in case the api call fails
	local tempUnit = "°C"
	
	-- Get the Temperature Unit
	local response ,status, errorCode = HC2:GET("/api/settings/info/")
	local info = json.decode(response)
	
	if (status == "200") then
		tempUnit = "°" .. info.temperatureUnit
	else
		fibaro:debug("Unable to get the temperature unit")
	end
	
	return tempUnit
end

-- formatTempTime
-----------------
-- Format the Temperature and Time into a string so that
-- we can output to a label

function formatTempTime(override, temp, endTimestamp)

	local label = ""
	
	if (override) then
		label = "* "
	end
	
	label = label .. temp .. tempUnit
	
	if (endTimestamp > 0) then
		local duration = math.ceil((endTimestamp - currentTimestamp) / 60)
	
		local days = math.floor(duration / (24*60))
		local hours = math.floor((duration - days*24*60) / 60)
		local minutes = math.floor(duration - days*24*60 - hours*60)
		
--		label = label .. " for "
		label = label .. " pour "
		
		if (days > 0) then
			label = label .. string.format("%d", days) .. "d "
		end
		
		if (hours > 0 or days > 0) then
			label = label .. string.format("%d", hours) .. "h "
		end
		
		label = label .. string.format("%d", minutes) .. "m"
		
		--label = label .. " until " .. os.date("%H:%M", endTimestamp)
		label = label .. " jusqu'à " .. os.date("%H:%M", endTimestamp)
		-- Only output the date if more than 24 hours from now
		if (endTimestamp >= currentTimestamp + 24*60*60) then
			label = label .. " " .. os.date("%A %d/%m/%Y", endTimestamp)
		end
	end
	
	return label
end

-- deformatTempTime
-------------------
-- Extract the temperature, duration and end time and date
-- from the Temp/Time label

function deformatTempTime(tempTime)
	local override = false
	local temp = 0
	local endTimestamp = 0
	local endTime = ""
	local endDate = ""
	local pos = 1
	
	-- Has the temperature or time been overridden?
	if (tempTimeLabel:sub(pos,1) == "*") then
		override = true
		pos = pos + 1
	end
	
	-- Find the temperature = the first number
	local start, finish = tempTime:find("%d+", pos)
	
	if (start ~= nil) then
		temp = tonumber(tempTime:sub(start, finish))
		pos = finish + 1
	end
	
	-- Find the End Time
	start, finish = tempTime:find("%d+:%d+", pos)
	if (start ~= nil) then
		endTime = tempTime:sub(start, finish)
	end
	
	-- Find the End Date
	start, finish = tempTime:find("%d+/%d+/%d+", pos)
	if (start ~= nil) then
		endDate = tempTime:sub(start, finish)
	end
	
	-- Convert the date and time to a timestamp
	if (endTime ~= nil and endTime ~= "") then
		
		-- Assume that the End Time is today
		local dateTime = os.date("*t")
		dateTime.hour = tonumber(endTime:sub(1,2))
		dateTime.min = tonumber(endTime:sub(4,5))
		dateTime.sec = 0

		-- Do we have a date?
		if (endDate ~= nil and endDate ~= "") then
			dateTime.day = tonumber(endDate:sub(1,2))
			dateTime.month = tonumber(endDate:sub(4,5))
			dateTime.year = tonumber(endDate:sub(7,10))
		end
		
		endTimestamp = os.time(dateTime)
		
		-- If the timestamp is less than the current timestamp, then add on a day
		if (endTimestamp < currentTimestamp) then
			endTimestamp = endTimestamp + 24*60*60
		end
	end
	
	return override, temp, endTimestamp
end

-- getRoomTemperatures
----------------------
-- Get the temperatures of the rooms that the current zone has been assigned to

function getRoomTemperatures(rooms)
	
	local roomTemps = ""
	
		-- For each room, get the default temperature sensor
		for roomKey, roomValue in pairs(rooms) do
			
			local response ,status, errorCode = HC2:GET("/api/rooms/" .. roomValue)
			
			if (status == "200") then
			  local room = json.decode(response)
				
				if (room ~= nil) then
			  	local tempSensorId = room.defaultSensors.temperature
			  	
			  	-- Get the current value of the room's temperature sensor
			  	if (tempSensorId ~= nil) then
			  		response ,status, errorCode = HC2:GET("/api/devices/" .. tempSensorId)
			  		if (status == "200") then
			  			local tempSensor = json.decode(response)
			  			
			  			if (tempSensor ~= nil) then
			  				local temperature = tempSensor.properties.value
			  				
			  				-- Add the temperature to the return string
			  				if (temperature ~= nil) then
			  					-- First space is a non-breaking space (0xA0)
			  					roomTemps = roomTemps .. room.name .. " " .. temperature .. tempUnit .. " "
			  				end
			  			end
			  		end
			  	end
			  end
			end
		end
	
	return roomTemps
end

--=============================================
-- Main
--=============================================

-- Have a mode and zone already been selected?
currentMode = fibaro:get(selfId, "ui.modeLabel.value")
currentZone = fibaro:get(selfId, "ui.zoneLabel.value")

-- Get the current Panel Name and Id from the zone description
currentPanelName, currentPanelId = getPanelNameAndId(currentZone)

-- If no current zone, then default it based on the room that the
-- virtual device is located in
if (currentZone == "" or currentZone == nil) then 
	-- Get the Current Room
	local currentRoom = fibaro:getRoomID(selfId)

	currentPanelName, currentPanelId = getDefaultZone(currentRoom)
	
	if (currentPanelId ~= 0) then
		currentZone = currentPanelName .. " (" ..currentPanelId .. ")"
	end
end

-- Get the current values from the Temp/Time label which may have been overridden
tempTimeLabel = fibaro:get(selfId, "ui.tempTimeLabel.value")
overridenTempOrTime, labelTemp, labelEndTimestamp = deformatTempTime(tempTimeLabel)

tempUnit = getTemperatureUnit()

-- Get the current values from the Heating Panel
newMode, panelTemp, panelEndTimestamp, panelRooms = getPanelDetails(currentPanelId)

-- If the temperature or time has been overridden, then don't update the label
-- with the current panel information
if (not overridenTempOrTime) then
	labelTemp = panelTemp
	labelEndTimestamp = panelEndTimestamp
end

tempTimeLabel = formatTempTime(overridenTempOrTime, labelTemp, labelEndTimestamp)

-- If the mode has been overridden, then don't overwrite it with the actual mode
if (currentMode:sub(1,1) ~= "*") then
	currentMode = newMode
end

-- Get the current temperature of the rooms controlled by this zone
currentTemps = getRoomTemperatures(panelRooms)

-- Set Labels and Sliders
fibaro:call(selfId, "setProperty", "ui.modeLabel.value", currentMode)
fibaro:call(selfId, "setProperty", "ui.zoneLabel.value", currentZone)
fibaro:call(selfId, "setProperty", "ui.tempTimeLabel.value", tempTimeLabel)
fibaro:call(selfId, "setProperty", "ui.currentTempLabel.value", currentTemps)

-- Sleep for a few seconds so that the main loop doesn't run too often
fibaro:sleep(delaySeconds * 1000)


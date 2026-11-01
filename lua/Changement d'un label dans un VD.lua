 --do you wish update value(ID) or label?

--value - yes, you can

--label - no (legally)

--image.thumb.png.1597cd3b7ea2f12b5f9684631e9720ea.png

 

--the dirty trick here 

local selfId = fibaro:getSelfId();
--contecting to HC2 to get VD who you want modify
local HC2 = Net.FHttp("127.0.0.1", 11111)
payload = "/api/virtualDevices/" .. selfId
response, status, errorCode = HC2:GET(payload)
if tonumber(errorCode) == 0 and 
  tonumber(status) == 200 and 
  response ~= nil and 
  response ~= "" then
	jsonTable = json.decode(response)
	--changening caption  
  	jsonTable.properties.rows[1].elements[1].caption="testazz"
	--sending it back  
  	local response, status, errorCode = HC2:PUT(payload, json.encode(jsonTable))

end


--[[
  UPLOAD ICON TO HC2
]]--
function uploadIcon(login, pass, rawIcon)
  fibaro:debug("---");
  fibaro:debug("Uploading icon to HC2...");
  tcp = Net.FTcpSocket("localhost", 80);
  if (not tcp) then
    fibaro:debug("TCP CONNECTING WITH HC2 ERROR!");
    return nil;
  end
  boundary = "WebKitFormBoundaryEy7xZuy1Trv7QrDe";
  enter = "\r\n";
  content = 
    "------" .. boundary .. enter ..
    "Content-Disposition: form-data; name=\"type\"" .. enter ..
    enter ..
    "virtualDevice" .. enter ..
    "------" .. boundary .. enter ..
    "Content-Disposition: form-data; name=\"icon0\"; filename=\"icon.png\"" .. enter ..
    "Content-Type: image/png" .. enter ..
    enter ..
    rawIcon .. enter ..
    "------" .. boundary .. "--" .. enter;
  tcp:write("POST /api/icons HTTP/1.1" .. enter);
  tcp:write("Host: localhost" .. enter);
  tcp:write("Content-Length: " .. string.len(content) .. enter);
  tcp:write("Authorization: Basic " .. encode(USER..":"..PASSWORD) .. enter);
  tcp:write("Content-Type: multipart/form-data; boundary=----" .. boundary .. enter .. enter);
  --fibaro:debug("Sending " .. #content .. " content bytes..." .. enter);
  s = 0; for i = 1, #content do
    b, e = tcp:write(string.char(string.byte(content, i)));
    s = s + b;
  end
  status, err = tcp:read();
  tcp:disconnect();
  fibaro:debug("Sended " .. s .. " content bytes with result [" .. err .. "].");
  -- if answer is wrong
  if (tonumber(err)>0) then
    return nil;
  end
  -- finishing
  fibaro:debug("---");
  fibaro:debug("ICON SUCESSFULLY UPLOADED!");
  return 0;
end
--But Net.FTcpSocket does not work from a scene....
--Create button in VD which does what you need, a press-it from scene ;) I would create change Icon button in VD, put icon path to global variable, press buttin, VD gets path from global, set global to nil, put icon to hc2, change VD icon.
--You can also create queue :)

-- nouvelle version
-----------------------------------
--- mHome ------------------------
-----------------------------------

local http="jonnylarsson.se"
local Link_ICON = {
  	AN_ON = "/JL/png/clear.png",
   	AN_OFF = "/JL/png/clear.png"

}
USER = "Kythuat@kimsontien.com"
PASSWORD = "Chotronniemvui1"
--------------------------------------------------------------
----- Lock Code ---------------------------------------------
-----------------------------------------------------------
function encode(data) local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'; return ((data:gsub('.', function(x) local r,b='',x:byte() for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end return r; end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x) if (#x < 6) then return '' end local c=0 for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end return b:sub(c+1,c+1) end)..({ '', '==', '=' })[#data%3+1]) end 
function random(nums) local i,r;r="";for i=1,nums do r=r..tostring(math.random(0,9)); end; return r; end
function checkSum(t) local i,b,c;c=0; for i = 1, #t do b = string.byte(t, i); if (c==0) then c = b; else c = bxor(c, b); end if (i>100) then break; end end return c; end
function bxor(a, b) local x,i,r;r=0; for i = 0, 31 do x = a / 2 + b / 2; if (x~=math.floor(x)) then r = r + 2^i; end a = math.floor(a / 2); b = math.floor(b / 2); end return r; end

function uploadIcon(login, pass, rawIcon)
  fibaro:debug("---");
  fibaro:debug("Uploading icon to HC2...");
  tcp = Net.FTcpSocket("localhost", 80);
  if (not tcp) then
    fibaro:debug("TCP CONNECTING WITH HC2 ERROR!");
    return nil;
  end
  boundary = "WebKitFormBoundary3ZD59n5AN4R94fws";
  enter = "\r\n";
  content = 
    "------" .. boundary .. enter ..
    "Content-Disposition: form-data; name=\"type\"" .. enter ..
    enter ..
    "virtualDevice" .. enter ..
    "------" .. boundary .. enter ..
    "Content-Disposition: form-data; name=\"redirect\"" .. enter ..
	enter ..
  	"fibaro/en/devices/icons.html?id=257&type=virtualDevice"..enter ..
	"------" .. boundary .. enter ..
    "Content-Disposition: form-data; name=\"icon0\"; filename=\"iconnhan.png\"" .. enter ..
    "Content-Type: image/png" .. enter ..
    enter ..
    rawIcon .. enter ..
    "------" .. boundary .. "--" .. enter;
  tcp:write("POST /api/icons HTTP/1.1" .. enter);
  tcp:write("Host: localhost" .. enter);
  tcp:write("Content-Length: " .. string.len(content) .. enter);
  tcp:write("Authorization: Basic " .. encode(USER..":"..PASSWORD) .. enter);
  tcp:write("Content-Type: multipart/form-data; boundary=----" .. boundary .. enter .. enter);
   s = 0; for i = 1, #content do
    b, e = tcp:write(string.char(string.byte(content, i)));
    s = s + b;
  end
  status, err = tcp:read();
  fibaro:debug(status..","..err)
  fibaro:debug("Sended " .. s .. " content bytes with result [" .. err .. "].");
  -- if answer is wrong
  if (tonumber(err)>0) then
    return nil;
  end
  -- finishing
  fibaro:debug("---");
  fibaro:debug("ICON SUCESSFULLY UPLOADED!");
  return 0;
end

function getIconId(tcp, rawIcon)
  -- grab icons list from api
  response, status, errorCode = tcp:GET("/api/icons");
  if (tonumber(status)~=200) then
    return nil;
  else
    -- decode text to json object
    jsonTable = json.decode("[" .. response .. "]");
    -- look at device
    iconsArray = jsonTable[1].virtualDevice;
    -- check all icons
    for iconIndex, iconData in pairs(iconsArray) do
      if (iconData.id>=1000) then
        -- grab icon from HC2
        r, s, e = tcp:GET("/fibaro/n_vicons/" .. iconData.iconName .. ".png");
        if (s=="200" and e==0) then
          --fibaro:debug('  Icon [' .. iconData.id .. '][' .. iconData.iconName .. '][' .. string.len(r) .. ' bytes]');
          if (string.len(r)==string.len(rawIcon)) then
            if (checkSum(r)==checkSum(rawIcon)) then
              --fibaro:debug("FOUND [" .. iconData.id .. "]!");
              return iconData.id;
            end
          end
        end
      end
    end
  end
  return 0;
end

local i=0;
for key,value in pairs(Link_ICON) do
  	fibaro:debug(key)
  	fibaro:debug(value)
  	tcpSERVER = Net.FHttp(http, 80); 
	icon=tcpSERVER:GET(value);
	--Upload Icon
	uploadIcon(USER, PASSWORD, icon);
	-- Get ID for fist ICON 
  	if (i==0) then
    	i=1;
		tcpHC2 = Net.FHttp("localhost", 80);
		tcpHC2:setBasicAuthentication(USER, PASSWORD);
		id = getIconId(tcpHC2, icon);
		fibaro:debug(id) 
  	end
  	fibaro:sleep(1000)
end

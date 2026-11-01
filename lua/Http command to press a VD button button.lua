"http://192.168.1.246/api/callAction?deviceID=ID&name=pressButton&arg1=But1"
"http://username:password@xxx.xxx.xxx.xxx/api/callAction?deviceID=ID&name=pressButton&arg1=But1"

--lua : fibaro:call(ID, "pressButton", But1)

--
CE QUI EST CI-DESSOUS MARCGE DEPUIS HC2 MAISON ET VD 670 HC2 GRANGE ne pas oublier d'inclure 2 lignes vide en fin de string
--Appui sur bouton "ALLUMER TOUT"
GET /api/callAction?deviceID=670&name=pressButton&arg1=4 HTTP/1/1 --
Host:192.168.1.11
Authorization: Basic YnJ1dmllcmVAb3JhbmdlLmZyOjIzNTdCY2N2NzY3Nw==


--Attention, il ne faut pas oublier les 2 lignes vides sous Authorization ci-dessus!

--Appui sur bouton "ETEINDRE TOUT"
GET /api/callAction?deviceID=670&name=pressButton&arg1=2 HTTP/1.1
Host:192.168.1.11
Authorization: Basic YnJ1dmllcmVAb3JhbmdlLmZyOjIzNTdCY2N2NzY3Nw==


--
Dans Firefox les chaines suivantes fonctionnent :
Extinction des lumières:
http://192.168.1.11/api/callAction?deviceID=670&name=pressButton&arg1=2
Allumage des lumières :
http://192.168.1.11/api/callAction?deviceID=670&name=pressButton&arg1=4

local thisdevice = fibaro:getSelfId()
local ip_module = fibaro:get(fibaro:getSelfId(), "IPAddress")
local port = fibaro:get(fibaro:getSelfId(), "TCPPort")
local timeOut = 5 * 1000;

   local vdConn = Net.FTcpSocket(ipAddr, tcpPort);
   local bytes, retc = vdConn:write("A");
   if retc > 0 then
        if retc == 2 then
             fibaro:debug( "Connection to ".. ipAddr ..":"
                  ..tcpPort .." not established");
          else
           fibaro:debug( "Write failed: "..retc);
          end;
       else
        fibaro:debug( "Write complete, sent: "..bytes.." bytes");
        vdConn:setReadTimeout(timeOut);
      local resp, retc = vdConn:read();
        if retc > 0 then
             if retc == 1 then
                  fibaro:debug( "Request timed out");
               else
                  fibaro:debug( "Read complete: "..retc.." - "..resp);
               end;
          else
         fibaro:debug( "Read complete, received: "..resp);
          end;
      end;
   vdConn:disconnect(); 
-----------------
Net.FTcpSocket:disconnect()
---------------------


-- Guest deraaij

  --  Guest deraaij

--Posted January 13, 2013

--Hi all,

--Just to share for those who did not figure it out already, the following http commands work with the beta version:

--Devices:

ID = device ID

name = action

arg1 = (e.g. value dimmer)

http:///api/callAction?deviceID=4&name=turnOff

http:///api/callAction?deviceID=7&name=setValue&arg1=39

Virtual Devices

ID = device ID

arg1 = button ID

arg2 = slider value (only for slider)

http:///api/callAction?deviceID=ID&name=pressButton&arg1=2

http:///api/callAction?deviceID=ID&name=setSlider&arg1=8&arg2=30

Notification

ID = Device (Iphone, e-mail et cetera)

arg1 = Notification template

http:///api/callActiondeviceID=9&name=sendDefinedPushNotification&arg1=1

Arm/Disarm devices

arg1 = 1 - Armed

arg1 = 0 - Disarmed

http:///api/callAction?deviceID=51&&name=setArmed&arg1=0

Scene

ID = SceneID

http:///api/sceneControl?id=14&action=start

http:///api/sceneControl?id=14&action=stop

Get json status from api:

http:///api/rooms

http:///api/scenes

http:///api/devices

http:///api/devices?id=316 # Specific value of a device

http:///api/virtualDevices

http:///api/globalVariables

http:///api/weather

http:///api/sections

http:///api/users

http:///api/energy/now-3600/now/single/devices/power/58

Updates used by mobile:

http:///api/mobile/interface/refreshStates?last=3058

Reboot:

Post --> http:///api/settings/reboot



------------------------------------------


HC2 version 4 has a new primitive for timing: setTimeout() with arguments "function" and "time in ms". I's available in scenes, but it's not in Virtual Devices. Here's an example, starting from a script based on sleep:

ID=207

fibaro:sleep(1000)

fibaro:call(ID, "turnOn")

fibaro:sleep(2000)

fibaro:call(ID, "turnOff")

The semantics of "setTimeout" are different. It means "Schedule this function to run after this time interval has elapsed".

So the first argument is a function. Defining a function is easy: wrap the actual command you want to run in "function() .. end".

In the next script I've put the on/off code in functions, and scheduled them... but there are two pitfalls. One: don't use () after the first argument (that would make it a "function call" instead of a function). Two: because the timers in this script start at the same time, the second timer has to be 1000 + 2000 = 3000 to be equivalent to the first example.

ID=207

function lightOn()
  fibaro:call(ID, "turnOn")
end

function lightOff()
  fibaro:call(ID, "turnOff")
end

setTimeout(lightOn, 1000)

setTimeout(lightOff, 3000)

There's something important here and it's easy to miss. You see in setTimeout we refer to "lightOn". You think that is a function call? Sure? It isn't: it's a variable bound to a function, not a function *call*. A function *call* would be like this: "lightOn()". If you put the "()" like you are used to do... the script won't work. When the script arrives at the setTimeout call, it immediately executes the function call. So add "()" to lightOn and the light will switch on immediately, instead of after a 1 second delay. And after one second, you get a mysterious "LUA error: attempt to call a nil value". That's setTimeout barking at you: "Hey, where's the function you want me to call after time out?". Please note that if you can't use "()" then you also can't have parameters. So "lightOn(ID)" isn't going to work either. I'll write about that later.

Maybe you don't like the idea of the two functions being scheduled at the same time, maybe you want to see the second timer at "2000" in your script. Then you can refactor it like this. The first timer is OK. But the second timer should start in the function of the first timer, so they are "chained". When I do this, I change the name of the first function from lightOn to lightOnOff because that is what it will do. Then at the end of it, I put the second setTimeout, that was at the bottom, and change the time to 2000. Like this:

ID=207

function lightOnOff()
  fibaro:call(ID, "turnOn")
  setTimeout(lightOff, 2000)
end

function lightOff()
  fibaro:call(ID, "turnOff")
end

setTimeout(lightOnOff, 1000)

Lua supports anonymous functions, and that can make a good solution for simple things... But I think this often gets hard to read. I put this example in anonymous form. And I payed attention to the indentation. But you still have to go through the text a few times to decode the pieces. On the other hand, it's valid and concise.

setTimeout(
  function() 
    fibaro:call(ID, "turnOn")
    setTimeout(
      function()
        fibaro:call(ID, "turnOff")
      end
      , 2000)
  end
  , 1000)

But don't give up on this anonymous-function-thing. You'll need it if you want to use parameters with setTimeout. Remember I said you cant put parenthesis after the function name in setTimeout? I'll offer two solutions to work around this. First, you can wrap the function in "function()" <CODE HERE> "end". That defines an anonymous function, which contains the statements and the parameters you want:

my_ID=207

function lightOnOff(id)
  fibaro:call(id, "turnOn")
  setTimeout(function() lightOff(my_ID) end, 2000)
end

function lightOff(id)
  fibaro:call(id, "turnOff")
end

setTimeout(function() lightOnOff(my_ID) end, 1000)

The second solution is the real "functional programming" stuff. Can you design a function, that *makes* a function for you that does the right thing and can be called from setTimeout? That's what's happening here. Functions are "first class citizens" and can be passed around and can be used as variables. This is the same example, but this time the argument for setTimeout is created inside a function, makeLightOnOff(id). This works because, well, if you're not used to functional programming, this might blow your head off, functions in lua are "closures". That means, they capture the local variables from the context *outside* the function (I'm talking about "id").

my_ID = 207

function makeLightOnOff(id)
  return function()
    fibaro:call(id, "turnOn")
    setTimeout(
      function()
        fibaro:call(id, "turnOff")
      end,
      2000)
  end
end

my_on_off=makeLightOnOff(my_ID)

setTimeout(my_on_off, 1000)


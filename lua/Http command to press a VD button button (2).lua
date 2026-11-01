"http://192.168.1.246/api/callAction?deviceID=ID&name=pressButton&arg1=But1"
"http://username:password@xxx.xxx.xxx.xxx/api/callAction?deviceID=ID&name=pressButton&arg1=But1"

lua : fibaro:call(ID, "pressButton", But1)

--ID is the VD Id number
--But1 is the numeber of the button. 

-- Ce qui ci-dessous ne semble pas marcher
POST /api/service/callAction?deviceID=670&name=pressButton HTTP/1.1
Host: 192.168.1.11
Authorization: Basic YnJ1dmllcmVAb3JhbmdlLmZyOjIzNTdCY2N2NzY3Nw==
Content-Length: 11

{"args":[But1]}
--
MAIS CE QUI EST CI-DESSOUS MARCGE DEPUIS HC2 MAISON ET VD 670 HC2 GRANGE ne pas oublier d'inclure 2 lignes vide en fin de string
--Appui sur bouton "ALLUMER TOUT"
GET /api/callAction?deviceID=670&name=pressButton&arg1=4 HTTP/1/1 --
Host:192.168.1.11
Authorization: Basic YnJ1dmllcmVAb3JhbmdlLmZyOjIzNTdCY2N2NzY3Nw==


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

Net.FTcpSocket:disconnect()



 Guest deraaij

    Guest deraaij

Posted January 13, 2013

Hi all,

Just to share for those who did not figure it out already, the following http commands work with the beta version:

Devices:

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
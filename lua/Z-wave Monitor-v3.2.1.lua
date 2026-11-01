--========================== USER CONFIGURABLE PARAMETERS ===============================
--------------------------------- v3.0 ---------------------------------------------------------------------
gVar = true              -- Create and use global predefined variable (to keep history)
logRate = 1      -- Time rate in minutes to log Z-wave activity.
time2monitor = 6     -- Time-slot in hours to monitor z-wave traffic. 
                         -- After that time, table and chart will be displayed on debug window.
                         -- 0 hours disables auto ending. User needs to stop the monitoring.
markId={"|644|","Cyan"}  -- Follow up devcies list and font color at monitor view.
                         -- Same color will be in use in table view. Please keep same format.
deadOnTop={true,"maroon"}-- Display DEAD devices on top of the list at monitor view. Dead device font color.
chartHeight = 100        -- Chart height in percents (%). Chart's default height fits debug window.
chartWidth = 100         -- Chart width in percents (%). Chart's default width expands according to number of samples.
topDev2disp =6           -- Number of most active devices to display on devices chart.
topScene2disp= 10        -- Number of most active scenes to display on scenes chart.
darkSkinMode = false     -- Charts display skin mode. Set false for light (white) skin.
dev2review={true,"|470|509|804"}-- Actual device's reading values chart over the monitoring time.
userDev={true,"|169|"} -- Devices and scenes IDs to generate specific chart. Please write underscore before scene ID |_531|  
stackedChart=true        -- stacked devices and scenes line chart, lines do not overlap because they are cumulative at each point.
flag_debug=false 			 -- to set debug
viewer_sceneId=322		-- sceneId for the viewer z-wave
-----------------------------------------------------------------------------------------------------------------
--========================== Please do not change parameters below ===============================================
jD={sample={},rptNum=0,nackNum=0;rptDev=0,nackDev=0;topDev={zMin=os.time(),zMax=0,zAvg=0,inId=0,inTotal=0,id=0,total=0,sTotal=0,sId=0},deadBuffer="",inUse=false,sTotal=0,total=0,devNum=0,sampleStartTime=os.time(),sampleEndTime=os.time()}
jN={};gVarName= "zwave_"..sceneId
if darkSkinMode then skinColor="black" else skinColor = "white" end
lastRefresh = tonumber(api.get("/refreshStates")["last"])
jD.sample[1]={sTotal=0,total=0,lTime=os.time()-os.date("*t").sec,lRate=logRate,sum=0,dead="",cpu1=0,cpu2=0}
cpuLoad={0,0,0,0};zwaveMonitor=true;tmpStr="";relVer="v3.2.1"
function findNameRoom(dId,idLoc)
 if flag_debug then fibaro.debug("zwave_monitor", "findNameRoom") end
  local dType="devices"
  if dId:find("_") then dType = "scenes";dId=string.gsub(dId,"_","") end
  local idFormat={"", "<sup>"..dId.."</sup><small>@</small>"}
  if idLoc == 1  then idFormat={"", " @ "} end
  if idLoc == 2 then idFormat={dId..":", "</sup><small>@</small>"} end
  if api.get("/"..dType.."/"..dId)["roomID"] == 0 then return idFormat[1]..api.get("/"..dType.."/"..dId)["name"]..idFormat[2].."Unassigned" end
  return idFormat[1]..api.get("/"..dType.."/"..dId)["name"]..idFormat[2]..api.get("/rooms/"..api.get("/"..dType.."/"..dId)["roomID"])["name"] 
end -- function =======================================================================
function str2disp(ref,comp,refStr,compStr)
if flag_debug then fibaro.debug("zwave_monitor", "str2disp") end 
  if ref==comp then refStr=compStr end
  return refStr end -- function ==================================================================
-- Fonction pour afficher une table de manière récursive
function printTable(t, indent, txt)
    indent = indent or 0
    local indentation = string.rep("  ", indent)  -- Ajouter des espaces pour l'indentation
	print(txt)
    for key, value in pairs(t) do
        if type(value) == "table" then
            print(indentation .. key .. ":")
            printTable(value, indent + 1)  -- Appel récursif pour les sous-tables
        else
            print(indentation .. key .. ": " .. tostring(value))
        end
    end
end -- function ==================================================================
function sampleCpu(retRes)
if flag_debug then fibaro.debug("zwave_monitor", "sampleCpu") end
local i, cpuField, cpuDiag = 0, {"user", "system", "nice", "name"}, {}


   x=os.time();repeat 
  cpuDiag[1]=api.get("/diagnostics");fibaro.sleep(900);cpuDiag[2]=api.get("/diagnostics")
  until not (json.encode(cpuDiag[2])..json.encode(cpuDiag[1])):find("NaN")  and os.time()-x < 15


-- Assurez-vous que les données existent et que les valeurs sont des nombres
if cpuDiag[1] and cpuDiag[2] then
  if flag_debug then fibaro.debug("zwave_monitor", "#cpuDiag[1].cpuLoad: " .. #cpuDiag[1].cpuLoad) end
  for i =1,#cpuDiag[1].cpuLoad do 
	if cpuDiag[1].cpuLoad[i] and cpuDiag[2].cpuLoad[i] then
		local pIdle=cpuDiag[1].cpuLoad[i].idle     
		local lIdle=cpuDiag[2].cpuLoad[i].idle 
	if flag_debug then	fibaro.debug("zwave_monitor", "sampleCpu: i= " .. i .. " pIdle: " .. pIdle .. " lIdle: " .. lIdle) end
	    
 
		  for j=1,3 do 
			  local pVal=cpuDiag[1].cpuLoad[i][cpuField[j]]
			  local lVal=cpuDiag[2].cpuLoad[i][cpuField[j]] 
		if flag_debug then  fibaro.debug("zwave_monitor", "sampleCpu:  i= " .. i .. "  j = " .. j .. " pVal: " .. pVal .. " lVal: " .. lVal) end
			  cpuDiag[1].cpuLoad[i][cpuField[j]] = math.max(math.min(math.ceil((lVal - pVal) / ((lVal+lIdle) - (lVal+pIdle))*100),100),0)
			if flag_debug then fibaro.debug("zwave_monitor", "sampleCpu: cpu.name = " .. cpuDiag[1].cpuLoad[i][cpuField[4]] .. " : cpuDiag[1].cpuLoad["..i.."][cpuField["..j.."]]: " .. cpuDiag[1].cpuLoad[i][cpuField[j]]) end
		  end
	end
	cpuLoad[i]=cpuLoad[i]+math.max(math.min(cpuDiag[1].cpuLoad[i].user + cpuDiag[1].cpuLoad[i].nice + cpuDiag[1].cpuLoad[i].system,100),0)
  end
else
	 fibaro.debug("zwave_monitor", "Erreur lors de la récupération des diagnostics.")
	 return math.floor(cpuLoad[1]/cpuLoad[3]*10)/10, math.floor(cpuLoad[2]/cpuLoad[3]*10)/10, 100-cpuDiag[2].memory.free
   
end
-- cpuLoad[3]= cpuLoad[3]+1   -- je ne sais pas pourquoi le +1 ? 
if flag_debug then fibaro.debug("zwave_monitor", "sampleCpu: cpuLoad[1] = " .. cpuLoad[1] .. " : cpuLoad[2] = "..cpuLoad[2].."  cpuLoad[3] = "..cpuLoad[3] .."  cpuLoad[4] = "..cpuLoad[4]) end
if retRes then return math.floor(cpuLoad[1]/cpuLoad[3]*10)/10, math.floor(cpuLoad[2]/cpuLoad[3]*10)/10, 100-cpuDiag[2].memory.free end

end -- function ==================================================================
function checkOnScreen(pattern,delMsg)
if flag_debug then fibaro.debug("zwave_monitor", "checkOnScreen") end
  local dMsg=api.get("/scenes/" .. sceneId .. "/debugMessages") 
     if delMsg or (json.encode(dMsg):len()>75000 and  not json.encode(dMsg):find(pattern)) then api.delete("/scenes/" .. sceneId .. "/debugMessages") end
     if json.encode(dMsg):find(pattern) then return true end
  return false end -- function ==================================================================
function insBlank(bNum,rColor)
if flag_debug then fibaro.debug("zwave_monitor", "insBlank") end
  local blank,fColor="","<font color=black>"
  if rColor then fColor="<font color="..rColor..">" end
  for i=1,bNum do blank = blank.."~" end
  return fColor..blank.."</font>" end -- function ==================================================================
function findRoom(jK,dId)
if flag_debug then fibaro.debug("zwave_monitor", "findRoom") end
  local dType="devices"
  if dId:find("_") then dType = "scenes" end
  if api.get("/"..dType.."/"..jK[dId].id)["roomID"] == 0 then return api.get("/"..dType.."/"..jK[dId].id)["name"].."@Unassigned" end
  return api.get("/"..dType.."/"..jK[dId].id)["name"].."@"..api.get("/rooms/"..api.get("/"..dType.."/"..jK[dId].id)["roomID"])["name"] 
end -- function =======================================================================
function resChart(jK)
if flag_debug then fibaro.debug("zwave_monitor", "resChart") end
 if not dev2review[1] then zChart={" "} return zChart end
 local zChart={}
for DevResChart in string.gmatch(string.gsub(dev2review[2],"|"," "),"%d+")  do 
 if not jK[DevResChart] then goto zNext end; if #jK[DevResChart].resSum ==0 then goto zNext end 
 zChart[#zChart+1]="\n"
 local lOffset,xStep,xOffset,yOffset,_polyLine,rStep = 8,math.max(9*chartWidth/100,math.floor(400/#jK.sample)),50,-50,"",0
 local cHeight,cWidth,hRead,rAvg,rMin,rMax = 260*chartHeight/100,#jK[DevResChart].resSum*xStep+50,0,0,os.time(),0
 local rAncorY,legendW,fColor,_circle,propName,propType=cHeight-55,250,{"IndianRed","cadetblue"},"",{},1
 xStep = math.max(9*chartWidth/100,math.floor(400/#jK[DevResChart].resSum));cWidth=#jK[DevResChart].resSum*xStep+50
 zoomSize=math.min(1,545/cWidth)
 zChart[#zChart+1]="<html><pre><font color=sandybrown><font size=3>ZKG: "..jK[DevResChart].id ..'-'..findRoom(jK,DevResChart) .." results </font></font><font color=yellowgreen>"..os.date("%c  -  ",jK.sampleStartTime)..os.date("%c",jK.sample[1].lTime).."</font><br>"
 zChart[#zChart+1]='<style>.zoom'..DevResChart..':hover{transform: scale('..zoomSize..',1)} </style>'
 zChart[#zChart+1]='<svg class="zoom'..DevResChart..'" height="'..cHeight..'" width="'..cWidth+legendW ..'" fill="dimgrey" fillclass="graph">'
 zChart[#zChart+1]='<rect x="0" y="0" width="'..cWidth+legendW ..'" height="'..cHeight..'"style="fill:'..skinColor..';stroke:dimgrey;stroke-width:1;opacity:1"/>'
 zChart[#zChart+1]='<line x1="45" x2="'..cWidth  ..'" y1="12" y2="12" style="stroke-dasharray:5,5;stroke:dimgray;stroke-width:0.5"/>'
 zChart[#zChart+1]='<line x1="45" x2="'..cWidth ..'" y1="'..cHeight*.23+2 ..'" y2="'..cHeight*.23+2 ..'" style="stroke-dasharray:5,5;stroke:dimgray;stroke-width:0.5"/>'
 zChart[#zChart+1]='<line x1="45" x2="'..cWidth  ..'" y1="'..cHeight*.41 ..'" y2="'..cHeight*.41 ..'" style="stroke-dasharray:5,5;stroke:dimgray;stroke-width:0.5"/>' 
 zChart[#zChart+1]='<line x1="45" x2="'..cWidth  ..'" y1="'..cHeight*.6 ..'" y2="'..cHeight*.6 ..'" style="stroke-dasharray:5,5;stroke:dimgray;stroke-width:0.5"/>' 
 zChart[#zChart+1]='<line x1="45" x2="'..cWidth  ..'" y1="'..cHeight-55 ..'" y2="'..cHeight-55 ..'" style="stroke-dasharray:5,5;stroke:dimgray;stroke-width:0.5"/>'
 for i=1,#jK[DevResChart].resSum do 
     if i==1 then propName[#propName+1]= jK[DevResChart].typeSum[i] end
    if not json.encode(propName):find(jK[DevResChart].typeSum[i]) then propName[#propName+1]= jK[DevResChart].typeSum[i];propType=propType+1 end
     if tonumber(os.date("%H",jK[DevResChart].tResSum[i-1])) - tonumber(os.date("%H",jK[DevResChart].tResSum[i]))>22 or i==1 then
         zChart[#zChart+1]='<text font-size="'..math.min(13,10*chartWidth/100) ..'px" fill="blue" font-weight="bold" x="'..cHeight+yOffset+2 ..'" y="'..-50-(i-1)*xStep..'" style="transform:rotate(90deg)";>'..os.date("%d-%b",jK[DevResChart].tResSum[i])..'</text>'
     elseif i>2 and os.date("%H",jK[DevResChart].tResSum[i]) == os.date("%H",jK[DevResChart].tResSum[i-1]) then
          if  os.date("%M",jK[DevResChart].tResSum[i]) == os.date("%M",jK[DevResChart].tResSum[i-1]) then
             zChart[#zChart+1]='<text font-size="'..math.min(12,9*chartWidth/100) ..'px" fill="dimgrey" x="'..cHeight+yOffset+2 ..'" y="'..-50-(i-1)*xStep..'" style="transform:rotate(90deg)";>'..os.date("     :%S",jK[DevResChart].tResSum[i])..'</text>'
        else zChart[#zChart+1]='<text font-size="'..math.min(12,9*chartWidth/100) ..'px" fill="dimgrey" x="'..cHeight+yOffset+2 ..'" y="'..-50-(i-1)*xStep..'" style="transform:rotate(90deg)";>'..os.date("  :%M:%S",jK[DevResChart].tResSum[i])..'</text>' end
     else zChart[#zChart+1]='<text font-weight="bold" font-size="'..math.min(12,9*chartWidth/100) ..'px" fill="dimgrey" x="'..cHeight+yOffset+2 ..'" y="'..-50-(i-1)*xStep..'" style="transform:rotate(90deg)";>'..os.date("%H:%M:%S",jK[DevResChart].tResSum[i])..'</text><line x1="'..xOffset+xStep*(i-1)..'" x2="'..xOffset+xStep*(i-1)..'" y1="'..cHeight-53 ..'" y2="12" style="stroke-dasharray:8,4;stroke:dimgrey;stroke-width:.8"/>'    
     end
 end
 for j=1, propType do
    if j>2 then break end
    hRead=0;rAvg=0;rMax=0;rMin=os.time(); _polyLine ="";_circle="";totalRes=0
    for i=1,#jK[DevResChart].resSum do  
      if propName[j]==jK[DevResChart].typeSum[i] then totalRes=totalRes+1
         hRead=math.max(hRead,jK[DevResChart].resSum[i]);rAvg=rAvg+jK[DevResChart].resSum[i];rMin=math.ceil(math.min(rMin,jK[DevResChart].resSum[i])*10)/10;rMax=math.ceil(math.max(rMax,jK[DevResChart].resSum[i])*10)/10
      end
    end
    rAvg=math.ceil(rAvg/totalRes*10)/10;hRead=math.max(1,math.ceil(hRead*1.01));rStep = (rAncorY-12)/hRead
    zChart[#zChart+1]='<text font-size="10px" fill="'..fColor[j]..'" x="'..(cWidth-20)*(j-1)+xOffset-2- tostring(hRead):len()*lOffset ..'" y="15">'..hRead..'</text>'
    zChart[#zChart+1]='<text font-size="10px" fill="'..fColor[j]..'" x="'..(cWidth-20)*(j-1)+xOffset-2- tostring(math.floor(hRead*.75)):len()*lOffset ..'" y="'..cHeight*.23+4 ..'">'..math.floor(hRead*.75)..'</text>'
    zChart[#zChart+1]='<text font-size="10px" fill="'..fColor[j]..'" x="'..(cWidth-20)*(j-1)+xOffset-2- tostring(math.floor(hRead*.5)):len()*lOffset ..'" y="'..cHeight*.41+2 ..'">'..math.floor(hRead*.5)..'</text>' 
    zChart[#zChart+1]='<text font-size="10px" fill="'..fColor[j]..'" x="'..(cWidth-20)*(j-1)+xOffset-2- tostring(math.floor(hRead*.25)):len()*lOffset ..'" y="'..cHeight*.6+2 ..'">'.. math.floor(hRead*.25)..'</text>' 
    zChart[#zChart+1]='<text font-size="10px" fill="'..fColor[j]..'" x="'..(cWidth-20)*(j-1)+xOffset-6-lOffset ..'" y="'..cHeight-53 ..'">0</text>'
    zChart[#zChart+1]='<text fill="'..fColor[j]..'"  x="'..cHeight-(propName[j]):len()*lOffset ..'" y="'..-10-(cWidth+30)*(j-1) ..'" style="transform:rotate(90deg)";>'..propName[j]..'</text>'
    for i=1,#jK[DevResChart].resSum do 
      if propName[j] ==  jK[DevResChart].typeSum[i] then
         _polyLine = _polyLine .." "..xOffset+xStep*(i-1)..","..rAncorY -math.floor(jK[DevResChart].resSum[i]*rStep) 
         _circle = _circle .." "..'<circle cx="'..xOffset+xStep*(i-1)..'" cy="'..rAncorY -math.floor(jK[DevResChart].resSum[i]*rStep)..'" r="2.4" fill="'..fColor[j]..'" />'
      end
    end 
if j==1 then zChart[#zChart+1]='<text font-weight="bold" fill="'..fColor[j]..'" x="'..cWidth+40 ..'" y="15";>'..jK[DevResChart].id ..'-'..findRoom(jK,DevResChart) .. '</text>' end
 zChart[#zChart+1]='<text fill="'..fColor[j]..'" x="'..cWidth+50 ..'" y="'..45+45*(j-1)..'";>'..propName[j]..' readings #'..totalRes..'</text>'.._circle..'<polyline points="'.._polyLine..'" style="fill:none;stroke-width:.7;stroke-dasharray:5,5;stroke:'..fColor[j]..';" />'
 zChart[#zChart+1]='<text fill="'..fColor[j]..'" x="'..cWidth+50 ..'" y="'..60+45*(j-1)..'";>'..rMin..' > '..rAvg..' < ' ..rMax.. '</text>'
end
 zChart[#zChart+1]='</pre></svg><br><br></html>'
::zNext::
end -- for nDev
  return zChart
end -- function =======================================================================
function dispTopDev(jK,devType)
if flag_debug then fibaro.debug("zwave_monitor", "dispTopDev") end
 local xStep,xOffset,yOffset,polyLine,rStep = math.max(9*chartWidth/100,math.floor(400/#jK.sample)),30,-50,"",0
 local zChart,cHeight,cWidth,hRead = {'\n'},260*chartHeight/100,#jK.sample*xStep+50,0
 local rAncorY,legendW,devEvents,topDevNum=cHeight-55,250,0,topDev2disp
 local cHeader ={["scenes"]=" top scenese",["devices"]=" top devices",["user"]=" user selected device(s)"}
  if devType == "user" and not userDev[1] then zChart={" "} return zChart end
 if devType == "scenes" then topDevNum=topScene2disp end
 if devType == "scenes" then jK.devRank={}
    for i,j in pairs(jK) do
       if i:find("_") then local maxEvents,mScene=0,nil
         for i2,j2 in pairs(jK) do
             if i2:find("_") and not json.encode(jK.devRank):find(i2) then
                if jK[i2]["total"]>maxEvents then maxEvents=jK[i2]["total"];mScene=i2 end
             end
         end
         if mScene then jK.devRank[#jK.devRank+1]=mScene end
      end
    end
 end
 if devType=="user" then topDevNum=0;jK.devRank={}
    for i in string.gmatch(string.gsub(userDev[2],"|"," "),"[_]?%d+")  do 
        if jK[i] then topDevNum=topDevNum+1;jK.devRank[#jK.devRank+1]=i end
     end
 end  
 topDevNum=math.max(math.min(topDevNum,#jK.devRank))
 if topDevNum == 0 then zChart={" "} return zChart end
 if topDevNum > 19 then cHeight=(260+(topDevNum-19)*13)*chartHeight/100;rAncorY=cHeight-55 end
 zChart[#zChart+1]="<pre><font color=sandybrown><font size=3>ZKG: "..topDevNum..cHeader[devType].." </font></font><font color=yellowgreen>"..os.date("%c  -  ",jK.sampleStartTime)..os.date("%c",jK.sample[1].lTime).."</font><br>"
 zChart[#zChart+1]='<svg height="'..cHeight..'" width="'..cWidth+legendW ..'" fill="dimgrey" fillclass="graph">'
 zChart[#zChart+1]='<rect x="0" y="0" width="'..cWidth+legendW ..'" height="'..cHeight..'"style="fill:'..skinColor..';stroke:dimgrey;stroke-width:1;opacity:1"/>'
 for i=1,#jK.sample do 
     if tonumber(os.date("%H",jK.sampleStartTime+jK.sample[1].lRate*(i-1)*60)) - tonumber(os.date("%H",jK.sampleStartTime+jK.sample[1].lRate*i*60))>22 or i==1 then
         zChart[#zChart+1]='<text font-size="'..math.min(13,10*chartWidth/100) ..'px" fill="blue" font-weight="bold" x="'..cHeight+yOffset+2 ..'" y="'..-33-(i-1)*xStep..'" style="transform:rotate(90deg)";>'..os.date("%d-%b",jK.sampleStartTime+jK.sample[1].lRate*i*60)..'</text>'
     elseif i>2 and os.date("%H",jK.sampleStartTime+jK.sample[1].lRate*i*60) == os.date("%H",jK.sampleStartTime+jK.sample[1].lRate*(i-1)*60) then
         zChart[#zChart+1]='<text font-size="'..math.min(12,9*chartWidth/100) ..'px" x="'..cHeight+yOffset+2 ..'" y="'..-33-(i-1)*xStep..'" style="transform:rotate(90deg)";>'..os.date("  :%M",jK.sampleStartTime+jK.sample[1].lRate*i*60)..'</text>'
     else zChart[#zChart+1]='<text font-weight="bold" font-size="'..math.min(12,9*chartWidth/100) ..'px" x="'..cHeight+yOffset+2 ..'" y="'..-33-(i-1)*xStep..'" style="transform:rotate(90deg)";>'..os.date("%H:%M",jK.sampleStartTime+jK.sample[1].lRate*i*60)..'</text><line x1="'..xOffset+5+xStep*(i-1)..'" x2="'..xOffset+5+xStep*(i-1)..'" y1="'..cHeight-53 ..'" y2="12" style="stroke-dasharray:8,4;stroke:dimgrey;stroke-width:.8"/>'    
     end
     for j=1,topDevNum do
         if not jK[jK.devRank[j]].slotSum[i] then jK[jK.devRank[j]].slotSum[i]=0 end
         if stackedChart then devEvents=devEvents+jK[jK.devRank[j]].slotSum[i] 
         else hRead=math.max(hRead,jK[jK.devRank[j]].slotSum[i]) end 
     end
     if stackedChart then  hRead=math.max(hRead,devEvents);devEvents=0 end 
 end -- for i=1,#jK.sample do 
 rStep = (rAncorY-12)/hRead
 zChart[#zChart+1]='<text x="12" y="15">'..hRead..'</text><line x1="35" x2="'..cWidth -30 ..'" y1="12" y2="12" style="stroke-dasharray:5,5;stroke:dimgray;stroke-width:0.5"/><text x="'..cWidth -20 ..'" y="15">'..hRead..'</text>'
 zChart[#zChart+1]='<text x="12" y="'..cHeight*.23 ..'">'..hRead- math.floor(hRead/4)..'</text><line x1="35" x2="'..cWidth - 25 ..'" y1="'..cHeight*.23+2 ..'" y2="'..cHeight*.23+2 ..'" style="stroke-dasharray:5,5;stroke:dimgray;stroke-width:0.5"/><text x="'..cWidth -20 ..'" y="'..cHeight*.23+2 ..'">'..hRead- math.floor(hRead/4)..'</text>'
 zChart[#zChart+1]='<text x="12" y="'..cHeight*.41 ..'">'..hRead- math.floor(hRead/2)..'</text><line x1="35" x2="'..cWidth - 25 ..'" y1="'..cHeight*.41 ..'" y2="'..cHeight*.41 ..'" style="stroke-dasharray:5,5;stroke:dimgray;stroke-width:0.5"/><text x="'..cWidth -20 ..'" y="'..cHeight*.41+2 ..'">'..hRead- math.floor(hRead/2)..'</text>'
 zChart[#zChart+1]='<text x="12" y="'..cHeight*.6 ..'">'.. math.floor(hRead/4)..'</text><line x1="35" x2="'..cWidth - 25 ..'" y1="'..cHeight*.6 ..'" y2="'..cHeight*.6 ..'" style="stroke-dasharray:5,5;stroke:dimgray;stroke-width:0.5"/><text x="'..cWidth -20 ..'" y="'..cHeight*.6 ..'">'..math.floor(hRead/4)..'</text>'
 zChart[#zChart+1]='<text x="12" y="'..cHeight-53 ..'">0</text><line x1="35" x2="'..cWidth - 20 ..'" y1="'..cHeight-55 ..'" y2="'..cHeight-55 ..'" style="stroke-dasharray:5,5;stroke:dimgray;stroke-width:0.5"/><text x="'..cWidth -20 ..'" y="'..cHeight-53 ..'">0</text>'
 zChart[#zChart+1]='<text fill="dimgray"  x="85" y="-1" style="transform:rotate(90deg)";>events</text>'
 for j=topDevNum,1,-1 do 
   polyLine="";_rgb="#"..string.format("%02X%02X%02X",math.random(0,200),math.random(0,200),math.random(0,200))
   for i=1,#jK.sample do devEvents = 0
      if stackedChart then
         for i2=topDevNum,j,-1 do devEvents=devEvents + jK[jK.devRank[i2]].slotSum[i] end
      else devEvents= jK[jK.devRank[j]].slotSum[i] end
      polyLine = polyLine .." "..xOffset+5+xStep*(i-1)..","..rAncorY -math.floor(devEvents*rStep)
   end --for i=1,#jK.sample do 
   zChart[#zChart+1]='<a class="bold-line" xlink:href="#0"><text fill="'.._rgb..'" x="'..cWidth+15 ..'" y="'..13*j..'";>'..jK[jK.devRank[j]].id ..'-'..findRoom(jK,jK.devRank[j]) .. '</text><polyline points="'..polyLine..'" style="fill:none;stroke:'.._rgb..';" /></a>'
 end --for j=topDevNum,1,-1 do 
  zChart[#zChart+1]='</pre></svg><br><br>'
 return zChart
end -- function =======================================================================
function dispChart(jK)
if flag_debug then fibaro.debug("zwave_monitor", "dispChart") end
 local xStep,xOffset,yOffset,polyLine,rStep,rAncorY = math.max(9*chartWidth/100,math.floor(450/#jK.sample)),30,-50,{scene="",ram="",cpu1="",cpu2="",event=""},0,185
 local zChart,cHeight,cWidth,lRead,hRead = {'\n<pre>'},260*chartHeight/100,#jK.sample*xStep+50,jK.sample[1].sum,jK.sample[1].sum
 local rAncorY,labelXcolor,legendW=cHeight-55,"?",250
 local cpu,ram ={{avg=0,max=0,min=100},{avg=0,max=0,min=100}},{avg=0,max=0,min=100}
 if topDevNum == 0 then zChart={" "} return zChart end
  zChart[#zChart+1]="<font color=sandybrown><font size=3>ZKG (zwavecardiogram) Chart:  </font></font><font color=yellowgreen>"..os.date("%c  -  ",jK.sampleStartTime)..os.date("%c",jK.sample[1].lTime).."</font><br>"
 zChart[#zChart+1]='<svg height="'..cHeight..'" width="'..cWidth+legendW ..'" fill="dimgrey" fillclass="graph">'
 zChart[#zChart+1]='<rect x="0" y="0" width="'..cWidth+legendW ..'" height="'..cHeight..'"style="fill:'..skinColor..';stroke:dimgrey;stroke-width:1;opacity:1"/>'--</g>'
 if json.encode(jK.sample):find("NaN") then 
  k=json.encode(jK.sample):gsub("NaN","25")
  jK.sample= json.decode(k)
 end
  for i=1,#jK.sample do 
    lRead=math.min(lRead,jK.sample[i].sum,jK.sample[i].sSum)
    hRead=math.max(hRead,jK.sample[i].sum,jK.sample[i].sSum)
    for j=1,2 do
     cpu[j].avg=cpu[j].avg+jK.sample[i]["cpu"..j]
     cpu[j].min=math.min(cpu[j].min,jK.sample[i]["cpu"..j])
     cpu[j].max=math.max(cpu[j].max,jK.sample[i]["cpu"..j])
    end
    ram.avg=ram.avg+jK.sample[i].ram;ram.min=math.min(ram.min,jK.sample[i].ram);ram.max=math.max(ram.max,jK.sample[i].ram)
    if jK.sample[i].dead:len()>1 then --or (i<#jK.sample and jK.sample[i+1].dead ~=0) then
      labelXcolor="red" 
      zChart[#zChart+1]='<text font-size="'..math.min(12,10*chartWidth/100) ..'px" fill="red" font-weight="bold" x="3" y="'..-31-(i-1)*xStep..'" style="transform:rotate(90deg)";>'..jK.sample[i].dead..'</text>'
    else labelXcolor="?" end
    if tonumber(os.date("%H",jK.sampleStartTime+jK.sample[1].lRate*(i-1)*60)) - tonumber(os.date("%H",jK.sampleStartTime+jK.sample[1].lRate*i*60))>22 or i==1 then
       zChart[#zChart+1]='<text font-size="'..math.min(13,10*chartWidth/100) ..'px" fill="'..labelXcolor:gsub("?","blue")..'" font-weight="bold" x="'..cHeight+yOffset+2 ..'" y="'..-33-(i-1)*xStep..'" style="transform:rotate(90deg)";>'..os.date("%d-%b",jK.sampleStartTime+jK.sample[1].lRate*i*60)..'</text>'
    elseif i>2 and os.date("%H",jK.sampleStartTime+jK.sample[1].lRate*i*60) == os.date("%H",jK.sampleStartTime+jK.sample[1].lRate*(i-1)*60) then
      zChart[#zChart+1]='<text font-size="'..math.min(12,9*chartWidth/100) ..'px" fill="'..labelXcolor:gsub("?","dimgrey")..'" x="'..cHeight+yOffset+2 ..'" y="'..-33-(i-1)*xStep..'" style="transform:rotate(90deg)";>'..os.date("  :%M",jK.sampleStartTime+jK.sample[1].lRate*i*60)..'</text>'
    else
      zChart[#zChart+1]='<text font-size="'..math.min(12,9*chartWidth/100) ..'px" fill="'..labelXcolor:gsub("?","dimgrey")..'" font-weight="bold" x="'..cHeight+yOffset+2 ..'" y="'..-33-(i-1)*xStep..'" style="transform:rotate(90deg)";>'..os.date("%H:%M",jK.sampleStartTime+jK.sample[1].lRate*i*60)..'</text><line x1="'..xOffset+5+xStep*(i-1)..'" x2="'..xOffset+5+xStep*(i-1)..'" y1="'..cHeight-53 ..'" y2="12" style="stroke-dasharray:8,4;stroke:dimgrey;stroke-width:.8"/>'    
    end
  end
 for j=1,2 do cpu[j].avg=math.ceil(cpu[j].avg/#jK.sample) end
 ram.avg=math.ceil(ram.avg/#jK.sample)
 lRead=math.ceil(lRead*.8); rStep = (rAncorY-12)/(hRead - lRead)
 zChart[#zChart+1]='<text x="12" y="15">'..hRead..'</text><line x1="35" x2="'..cWidth -30 ..'" y1="12" y2="12" style="stroke-dasharray:5,5;stroke:dimgray;stroke-width:0.5"/><text x="'..cWidth -20 ..'" y="15">100%</text>'
 zChart[#zChart+1]='<text x="12" y="'..cHeight*.23 ..'">'..hRead- math.floor((hRead-lRead)/4)..'</text><line x1="35" x2="'..cWidth - 25 ..'" y1="'..cHeight*.23+2 ..'" y2="'..cHeight*.23+2 ..'" style="stroke-dasharray:5,5;stroke:dimgray;stroke-width:0.5"/><text x="'..cWidth -20 ..'" y="'..cHeight*.23+2 ..'">75%</text>'
 zChart[#zChart+1]='<text x="12" y="'..cHeight*.41 ..'">'..hRead- math.floor((hRead-lRead)/2)..'</text><line x1="35" x2="'..cWidth - 25 ..'" y1="'..cHeight*.41 ..'" y2="'..cHeight*.41 ..'" style="stroke-dasharray:5,5;stroke:dimgray;stroke-width:0.5"/><text x="'..cWidth -20 ..'" y="'..cHeight*.41+2 ..'">50%</text>'
 zChart[#zChart+1]='<text x="12" y="'..cHeight*.6 ..'">'..lRead+ math.floor((hRead-lRead)/4)..'</text><line x1="35" x2="'..cWidth - 25 ..'" y1="'..cHeight*.6 ..'" y2="'..cHeight*.6 ..'" style="stroke-dasharray:5,5;stroke:dimgray;stroke-width:0.5"/><text x="'..cWidth -20 ..'" y="'..cHeight*.6 ..'">25%</text>'
 zChart[#zChart+1]='<text x="12" y="'..cHeight-53 ..'">'..lRead ..'</text><line x1="35" x2="'..cWidth - 20 ..'" y1="'..cHeight-55 ..'" y2="'..cHeight-55 ..'" style="stroke-dasharray:5,5;stroke:dimgray;stroke-width:0.5"/><text x="'..cWidth -20 ..'" y="'..cHeight-53 ..'">0%</text>'
 zChart[#zChart+1]='<text fill="dimgray"  x="80" y="-3" style="transform:rotate(90deg)";>events</text>'
 for i=1,#jK.sample do 
     polyLine.ram = polyLine.ram .." "..xOffset+5+xStep*(i-1)..","..rAncorY - math.floor(jK.sample[i].ram)*(rAncorY-12)/100
     polyLine.cpu1 = polyLine.cpu1 .." "..xOffset+6+xStep*(i-1)..","..rAncorY - math.floor(jK.sample[i].cpu1)*(rAncorY-12)/100
     polyLine.cpu2 = polyLine.cpu2 .." "..xOffset+4+xStep*(i-1)..","..rAncorY - math.floor(jK.sample[i].cpu2)*(rAncorY-12)/100
     polyLine.scene = polyLine.scene .." "..xOffset+5+xStep*(i-1)..","..rAncorY - math.floor(jK.sample[i].sSum-lRead)*rStep
     polyLine.event = polyLine.event .." "..xOffset+5+xStep*(i-1)..","..rAncorY - math.floor(jK.sample[i].sum-lRead)*rStep
 end
 zChart[#zChart+1]='<a class="bold-line" xlink:href="#0"><text fill="brown" x="'..cWidth+15 ..'" y="60";>RAM  '..ram.min..'% > ' .. ram.avg..'% < '..ram.max..'%</text><polyline points="'..polyLine.ram..'" style="fill:none;stroke:brown;" /></a>'
 zChart[#zChart+1]='<a class="bold-line" xlink:href="#0"><text fill="blue" x="'..cWidth+15 ..'" y="30";>CPU1 '..cpu[1].min..'% > ' .. cpu[1].avg..'% < '..cpu[1].max..'%</text><polyline points="'..polyLine.cpu1..'" style="fill:none;stroke:blue;" /></a>'
 zChart[#zChart+1]='<a class="bold-line" xlink:href="#0"><text fill="violet" x="'..cWidth+15 ..'" y="45";>CPU2 '..cpu[2].min..'% > ' .. cpu[2].avg..'% < '..cpu[2].max.. '%</text><<polyline points="'..polyLine.cpu2..'" style="fill:none;stroke:violet;" /></a>'
 zChart[#zChart+1]='<a class="bold-line" xlink:href="#0"><text fill="red" x="'..cWidth+15 ..'" y="15";>Z-wave events='..jK.total..'</text><polyline points="'..polyLine.event..'" style="fill:none;stroke:red;" /></a>'
 zChart[#zChart+1]='<a class="bold-line" xlink:href="#0"><text fill="grey" x="'..cWidth+15 ..'" y="75";>Triggered Scenes='..jK.sTotal..'</text><polyline points="'..polyLine.scene..'" style="fill:none;stroke:grey;" />'..
    '<text fill="grey" x="'..cWidth+15 ..'" y="90";>Top scene:'..jK.topDev.sId..'-' .. api.get("/scenes/"..jK.topDev.sId)..'</text></a>'
 zChart[#zChart+1]='</svg>'
 return zChart
end -- function =======================================================================
function logData(maxId,jK)
if flag_debug then fibaro.debug("zwave_monitor", "logData") end
  local fColor=""
  if markId[1]:find(maxId["id"]) then fColor = "<font color="..markId[2]..">" end
  if json.encode(maxId):find("dead") then fColor = "<font color=red>" end
  zBuffer[#zBuffer+1]="<tr>" 
for l = 1,hSize do local found=false
    for k,s in pairs(maxId) do
        if zBuffer[l]:find(" "..k.." ") and not k:find("Sum") then --("slotSum"):find(k)  then
           if  zBuffer[l]:find("total %%") then zBuffer[#zBuffer+1]="<td>"..fColor.. math.ceil(s/jK.total*1000)/10 .."%</td>"
           elseif zBuffer[l]:find(" id ") then zBuffer[#zBuffer+1]="<td class='tooltip'> "..fColor .. s .. " <span class='tooltiptext'> "..fibaro.getName(tonumber(s)).." @ "..fibaro.getRoomNameByDeviceID(tonumber(s)).." </span></td>"
           elseif zBuffer[l]:find(" rpt ") then zBuffer[#zBuffer+1]="<td> <font color=gold>" .. s .. " </td>"
           elseif zBuffer[l]:find(" nack ") then zBuffer[#zBuffer+1]="<td> <font color=red>" .. s .. " </td>"
           else zBuffer[#zBuffer+1]="<td>"..fColor..s.."</td>" end
           found = true end --if zBuffer[l]:find(" "..k.." ") then
    end -- for k,s in pairs(j) do
    if not found then zBuffer[#zBuffer+1]="<td></td>" end
 end
 zBuffer[#zBuffer+1]="<td class=txtLeft>   "..fColor..fibaro.getName(tonumber(maxId["id"])).." @ "..fibaro.getRoomNameByDeviceID(tonumber(maxId["id"])).."</td>" 
 zBuffer[#zBuffer+1]="</tr>"
end -- function =======================================================================
function sortData(jK)   
if flag_debug then fibaro.debug("zwave_monitor", "sortData") end
 local fCount =0
  jK.devRank={}
  for i,_ in pairs(jK) do fCount = fCount+1 end
    for j=1,fCount do local maxZtraffic=0;maxId = nil
      for k,l in pairs(jK) do
          if type(l) == "table" and l["rank"] == 0 then
             maxZtraffic = math.max(maxZtraffic,l["total"])
             if maxZtraffic == l["total"] then maxId = tostring(k) end
          end
      end
      if maxId then  
         jK[maxId]["rank"] = j
         logData(jK[maxId],jK) 
         jK.devRank[#jK.devRank+1]=tostring(maxId)
      end
    end -- for j=1,fCount do
 zBuffer[#zBuffer+1]="</table>"
end -- function =======================================================================
function setTableHtmlStyle()
if flag_debug then fibaro.debug("zwave_monitor", "setTableHtmlStyle") end
 return "<style> .bold-line:hover{stroke-width:3.5;font-weight:bold;font-style:italic;}"..
  ".tooltip {border:1px solid grey;position:relative; border-radius:0px; padding:1px; text-align:left; font-weight:bold; font-family:monospace; font-size:11px;display:table-cell;}"..
  ".tooltip .tooltiptext {visibility: hidden; width: auto;background-color: black;font-weight: bold;color:yellow;text-align: left;border-radius: 0px; padding: 14px 1;"..     
  "position: absolute;z-index: 1;top: -10px;left: 100%;}"..
  " .tooltip:hover .tooltiptext {visibility: visible;} .txtLeft {text-align: left;}" ..
  " th {border-collapse: collapse;padding: 2px;border: 2px solid dimgray;font-size: 106%;font-weight: normal;}"..
  " td {padding: 0px;border: 1px solid dimgray;} th, td {text-align: center}tr:nth-child(even) {background-color: #161616;} tr:hover {background-color:#001a33;}</style>" -- table {width:70%;}</style>"
end -- function =======================================================================
function setHeader(jK,tCaption) 
if flag_debug then fibaro.debug("zwave_monitor", "setHeader") end
  zBuffer = {}
  zBuffer[1] =setTableHtmlStyle().."<h><font size=3>"..tCaption.."</font><font color=yellowgreen> (event/".. math.ceil((jK.sampleEndTime-jK.sampleStartTime)/jK.total*10)/10 .. "s)</font></h>"
  zBuffer[1]=zBuffer[1] .. "<table><tr><th><font color=yellowgreen> id </th>";zBuffer[#zBuffer+1]="<th><font color=yellowgreen> total # </th>";zBuffer[#zBuffer+1]="<th><font color=yellowgreen> total % </font></th>"
  for i,j in pairs(jK) do
    if type(j) == "table" and i ~= "sample" and i~= "topDev" then
      for k,s in pairs(j) do
         if not json.encode(zBuffer):find(" "..k.." ") and not k:find("rank") and not k:find("Sum") then 
            if ("deadReason"):find(k) or k:find("nack") then zBuffer[#zBuffer+1] = "<th><font color=red> "..k.." </th>" 
            elseif ("rpt"):find(k) then zBuffer[#zBuffer+1] = "<th><font color=gold> "..k.." </th>" 
            else zBuffer[#zBuffer+1] = "<th><font color=Khaki> "..k.." </th>" 
            end
         end 
      end
    end
  end
hSize=#zBuffer
zBuffer[#zBuffer+1] = "<th class=txtLeft><font color=yellowgreen>  Device description </th>"--</tr>"
end -- function =======================================================================
function dispInfo(jK)
if flag_debug then fibaro.debug("zwave_monitor", "dispInfo") end
  local mStr,zTotal,zMax,sceneVer= "",0,0,{[true]="<font color=yellow>Z-wave Monitor "..relVer.."</font>",[false]="<font color=yellow>Z-wave Viewer "..relVer.."</font>"}
  fibaro.sleep(700)
  if #jK.sample> 1 then jK.sample[#jK.sample] = nil end
  
  local localTime=jK.sample[1].lTime 
  if jK.sample[1].lTime < jK.sampleStartTime then localTime = os.time() end
  setHeader(jK,"<font color=sandybrown>" ..api.get("/settings/info/")["hcName"].. " ("..api.get("/settings/info/")["serialNumber"].. ") Z-wave traffic report.</font>")
  sortData(jK)
  if jK.deadBuffer:len() > 10 then mStr="<br>Dead device(s)  = <b>"..jK.deadBuffer:gsub("!","") .. "</b>" end
  zBuffer[#zBuffer+1]="<font color=lightblue><font size=2>Elapsed  time    = <font color=wheat>" .. ("%03s"):format(math.floor((localTime- jK.sampleStartTime)/3600)) .. os.date("!:%M:%S",localTime - jK.sampleStartTime).. os.date("</font>   [ %b %d %H:%M  -  ",jK.sampleStartTime)..os.date("%b %d %H:%M ]",localTime)..
  "<br>Sample log rate  = <font color=wheat>"..jK.sample[1].lRate .."</font> minutes. Total samples <font color=wheat>"..#jK.sample.."</font>"..
  "<br>Z-wave  events   = <font color=wheat>"..jK.total.."</font> on <font color=wheat>"..jK.devNum .."</font> devices."..
  "<br>Average traffic  = <font color=wheat>"..math.ceil((localTime-jK.sampleStartTime)/jK.total*10)/10 .. "</font> sec." ..
  "<br>Z-traffic range  = <font color=wheat>"..jK.topDev.zMin.. "</font> - <font color=wheat>"..jK.topDev.zMax.. "</font> sec." .. 
  "<br>Repeat / Report  = <font color=wheat>"..jK.rptNum.."<sup>("..math.floor(jK.rptNum/jK.total*1000)/10 .."%)</sup></font> on <font color=wheat>"..jK.rptDev .."</font> devices."
  if jK.nackNum>0 then zBuffer[#zBuffer+1]="<br><font color=red>Transfer Failed  = "..jK.nackNum.."</font> on <font color=red>"..jK.nackDev .."</font> devices." end
  zBuffer[#zBuffer+1]=mStr .."</font></font>"
  api.delete("/scenes/" .. sceneId .. "/debugMessages")
  mStr = '<a class="bold-line" href="api/scenes/'.. viewer_sceneId ..'/execute" onclick="fibaro.scene(execute,'.. viewer_sceneId ..'); return false;"><div class="Button1_0 ng-binding" style="margin: 10px 0px 0px 270px; color:lightblue;">start viewer Z-wave</div></a><br>'
  mStr = mStr .. '<a class="bold-line" href="#" onclick="fibaro.scene(execute,'.. sceneId ..'); return false;"><div class="Button1_0 ng-binding" style="margin: 10px 0px 0px 270px; color:lightblue;">Refresh</div></a><br><br> </pre>'
  if zwaveMonitor then  
	mStr = '<a class="bold-line" href="api/scenes/'.. viewer_sceneId ..'/execute" onclick="fibaro.scene(execute,'.. viewer_sceneId ..'); return false;"><div class="Button1_0 ng-binding" style="margin: 10px 0px 0px 270px; color:lightblue;">start viewer Z-wave</div></a><br>'
	mStr = mStr .. '<a class="bold-line" href="#" onclick="fibaro.scene(execute'.. sceneId ..'); return false;"><div class="Button1_0 ng-binding" style="margin: 10px 0px 0px 185px; color:lightblue;">Refresh</div></a>'..
     '<a class="bold-line" href="#" onclick="fibaro.scene(kill,'.. sceneId ..']); return false;"><div class="Button1_0 ng-binding" style="margin: 10px 0px 0px 105px; color:lightblue;">Back</div></a><br><br> </pre>' 
  end
 if zwaveMonitor and jD.sample[1].lTime - jD.sampleStartTime >= time2monitor*3600 then   
	mStr ='<br><a class="bold-line" href="api/scenes/'.. viewer_sceneId ..'/execute" onclick="fibaro.scene(execute,'.. viewer_sceneId ..'); return false;"><div class="Button1_0 ng-binding" style="margin: 10px 0px 0px 270px; color:lightblue;">start viewer Z-wave</div></a><br>'
	mStr = mStr .. "<font color=yellowgreen><font size=3>Please use Z-wave Viewer to review additional data. <br>Global variable is </font><font color=wheat>"..gVarName.."</font>" 
   if not gVar then 
    mStr ="<br><font color=orangered><font size=3>To remind you:<br>Global variable is not defined therefore displayed data could not be restored!</font></font>" 
   end
 end
 if #jK.sample >2 then 
  fibaro.debug("zwave_monitor",sceneVer[zwaveMonitor].."<pre>"..table.concat(zBuffer)..'<br><br></pre>' .. table.concat(dispTopDev(jK,"devices")) .. table.concat(dispTopDev(jK,"scenes")) .. table.concat(dispTopDev(jK,"user"))..table.concat(resChart(jK))..table.concat(dispChart(jK))..mStr)
  else
  zBuffer[#zBuffer+1]="<br><font color=pink><font size=2>No sufficient data to generate ZKG chart... please wait for additional ".. 3- #jK.sample.." cycles.</font></font>"
  fibaro.debug("zwave_monitor",sceneVer[zwaveMonitor].."<pre>"..table.concat(zBuffer)..'<br>' ..mStr)  
 end
end -- function =======================================================================
function isGlobal(gName, gData,isEnum,setDefault,prtMsg)
if flag_debug then fibaro.debug("zwave_monitor", "isGlobal") end
if flag_debug then fibaro.debug("zwave_monitor", "isGlobal: gName:" ..gName .." gData:" .. gData .. " isEnum:" .. tostring(isEnum) .. " prtMsg: " .. prtMsg) end
  local gExist = fibaro.getGlobalVariable(gName)
  local gType = {[true]="predefined",[false]=""}
  if gExist == nil then
   if flag_debug then fibaro.debug("zwave_monitor", "isGlobal: if gExist == nil") end
    api.post("/globalVariables",{name=gVarName})
    local gTable = '{"name":"'..gName..'","value":"Created","readOnly":false,"isEnum":'..tostring(isEnum)..',"enumValues":["Created"]}'
    local gTable = '{"name":"'..gName..'","value":"Created","isEnum":'..tostring(isEnum)..',"enumValues":["Created"]}'
    api.put("/globalVariables/"..gVarName,{name=gVarName,value="Created",isEnum=isEnum, enumValues={"Created",}})
   if flag_debug then fibaro.debug("zwave_monitor","<font color=red>"..prtMsg .. "Created new "..gType[isEnum] .. " global variable </font><font color=wheat>"..gName.."</font>") end 
   --..'</span><span style="color:red">'..' with default value </span><span style="color:yellow">'..tostring(_globVarDefault)..'</span>') end;
    fibaro.setGlobalVariable(gName, gData)
  else
	 if flag_debug then fibaro.debug("zwave_monitor", "isGlobal: if gExist == nil:  else")	end
     if fibaro.getGlobalVariable(gName):len()<100 then
	 if flag_debug then fibaro.debug("zwave_monitor", "isGlobal: if gExist == nil: else : len()<100") end
       fibaro.setGlobalVariable(gName,gData)
     end
	if flag_debug then	fibaro.debug("zwave_monitor", "isGlobal: json.decode: json.decode(fibaro.getGlobalVariable(gName)) ") end
        if type(fibaro.getGlobalVariable(gName)) ~= "table" then 
	if flag_debug then	fibaro.debug("zwave_monitor", "isGlobal: json.decode") end
		setDefault=true end  
    -- if type(jRef) ~= "table" then setDefault=true end
     fibaro.debug("zwave_monitor","<font color=yellowgreen>".. prtMsg .. gType[isEnum] .. " global </font><font color=wheat><font size=2> \""..gVarName.."\" </font></font><font color=yellowgreen> variable is in use.</font>")
  end
  if setDefault then 
	if flag_debug then fibaro.debug("zwave_monitor", "isGlobal: setDefault : gName: " .. gName .. " gData: " .. gData) end
	fibaro.setGlobalVariable(gName, gData) 
	if flag_debug then fibaro.debug("zwave_monitor", "isGlobal: fibaro.getGlobalVariable(gName) " .. fibaro.getGlobalVariable(gName)) end
	end
end -- function ==================================================================

function lastState()
if flag_debug then fibaro.debug("zwave_monitor", "lastState") end
  local i,v,deadId,fColor,lState,mStr,idStr=0,0,"",{"<font color=tan>","<font color=wheat>"},{},"",""
  local notZwave = "lastWorkingRouteResponseTimestamp useTemplate armed sunsetHour sunriseHour neighborListResponseTimestamp lastBreached icon"
  while true do
    mStr="";sampleCpu(false)
    for k =1,25 do
      repeat
    --    if fibaro.countScenes()==2 then break end
        lState = api.get("/refreshStates?last=" .. lastRefresh) 
      until lState
    --  if fibaro.countScenes()==2 then break end
      lastRefresh = lState.last
      for i, v in pairs(lState.events) do
        if v.type  == "DevicePropertyUpdatedEvent" 
          and not notZwave:find(v.data.property)
          and not json.encode(api.get("/devices/" .. v.data.id)["type"]):find("com.fibaro.zwaveDevice")
          and json.encode(api.get("/devices/" .. v.data.id)["interfaces"]):find("zwave") then
              jN[api.get("/devices/" .. v.data.id)["properties"]["nodeId"]]=os.time()
              jD.total = jD.total+1
              dev = v.data; tblId = tostring(dev.id)
              if not jD[tblId] then jD[tblId]={["total"]=0,slotSum={0},resSum={},tResSum={},typeSum={},["id"]=dev.id ,["rank"]=0};jD.devNum=jD.devNum+1 end
              if not jD[tblId].slotSum[#jD.sample] then 
                for l=#jD[tblId].slotSum+1,#jD.sample do jD[tblId].slotSum[l]=0 end
              end
              if type(dev.newValue) == "number" then jD[tblId].resSum[#jD[tblId].resSum+1]=dev.newValue;jD[tblId].tResSum[#jD[tblId].tResSum+1]= os.time();jD[tblId].typeSum[#jD[tblId].typeSum+1]= dev.property end
              jD[tblId]["total"]=jD[tblId]["total"] + 1;jD[tblId].slotSum[#jD.sample]=jD[tblId].slotSum[#jD.sample]+ 1
              if jD[tblId].slotSum[#jD.sample]>jD.topDev.inTotal then jD.topDev.inId=dev.id;jD.topDev.inTotal=jD[tblId].slotSum[#jD.sample] end
              if jD[tblId]["total"]>jD.topDev.total then jD.topDev.id = dev.id;jD.topDev.total=jD[tblId]["total"] end
               if not jD[tblId][dev.property] then jD[tblId][dev.property] = 0 end 
              jD[tblId][dev.property] = jD[tblId][dev.property] + 1 
              if dev.property:find("parameters") then dev.newValue = json.encode(dev.newValue) end
              idStr = "<sub>#".. jD[tblId].slotSum[#jD.sample].."/"..jD[tblId]["total"] .."</sub>" .. fibaro.getName(tonumber(dev.id)) .. "<sup>" .. dev.id ..  "</sup><small>@</small>" .. fibaro.getRoomNameByDeviceID(tonumber(dev.id)).. "("..tostring(dev.newValue).."<sup> ".. dev.property.."</sup>)</font> "
              if dev.property:find("deadReason") then
                 if not deadId:find(dev.id) then deadId = deadId .. dev.id .. " " end
                 if not deadOnTop[1] then  mStr = mStr .. "<font color=LightCoral>" .. idStr .. "</font>" end
                 if not jD.deadBuffer:find(dev.id.."!") then
                     if dev.newValue == "" then dev.newValue="wakeUp" end
                     jD.deadBuffer = jD.deadBuffer.."<font color="..deadOnTop[2]..">".. fibaro.getName(tonumber(dev.id)) .. "<sup>" .. dev.id ..  "!</sup><small>@</small>" .. fibaro.getRoomNameByDeviceID(tonumber(dev.id)).. "("..tostring(dev.newValue).."<sup> ".. dev.property.."</sup>)</font> " 
                 end 
              elseif ("dead"):find(dev.property) then mStr = mStr.."<font color="..deadOnTop[2]..">" .. idStr .. "</font>"
              elseif markId[1]:find(dev.id) then mStr = mStr.."<font color="..markId[2]..">" .. idStr .. "</font>"
              elseif jD.topDev.id == dev.id then mStr = mStr.."<font color=Orchid>" .. idStr.."</font>"
              elseif jD.topDev.inId == dev.id then mStr = mStr.."<font color=cadetblue>" .. idStr.."</font>"
              else mStr = mStr..fColor[(jD.total % 2) + 1]..idStr.."</font>"
              end
          elseif v.type=="SceneRunningInstancesEvent" and v.data.runningInstances >0 then
                 tblId = "_"..tostring(v.data.id)
                 if not jD[tblId] then jD[tblId]={["total"]=0,slotSum={0},["id"]=v.data.id} end
                 if not jD[tblId].slotSum[#jD.sample] then 
                    for l=#jD[tblId].slotSum+1,#jD.sample do jD[tblId].slotSum[l]=0 end
                 jD[tblId].slotSum[#jD.sample]=0 end
                 jD[tblId].slotSum[#jD.sample]=jD[tblId].slotSum[#jD.sample]+1
                 jD[tblId]["total"] = jD[tblId]["total"]+1
                 jD.sTotal=jD.sTotal+1
                 if jD[tblId]["total"] > jD.topDev.sTotal then jD.topDev.sId = v.data.id;jD.topDev.sTotal=jD[tblId]["total"] end
          end -- if v.type  ==
        end --for i, v in pairs(lState.changes)--------------------------------
        for i, v in pairs(lState.changes) do
            tblId = tostring(v.id)
            if not json.encode(api.get("/devices/" .. v.id)["type"]):find("com.fibaro.zwaveDevice")
             and json.encode(api.get("/devices/" .. v.id)["interfaces"]):find("zwave") then
                 if v.log and v.log:find("transfer") and not v.value then -- and not v.value then
                    if not jN[api.get("/devices/" .. v.id)["properties"]["nodeId"]] or os.time() - jN[api.get("/devices/" .. v.id)["properties"]["nodeId"]]>15 then
                      jD.total = jD.total+1;jD.rptNum=jD.rptNum+1
                      if not jD[tblId] then jD[tblId]={["total"]=0,slotSum={0},resSum={},tResSum={},typeSum={},["id"]=v.id ,["rank"]=0};jD.devNum=jD.devNum+1 end
                      if not jD[tblId].slotSum[#jD.sample] then 
                         for l=#jD[tblId].slotSum+1,#jD.sample do jD[tblId].slotSum[l]=0 end
                      end
                      jD[tblId]["total"]=jD[tblId]["total"] + 1;jD[tblId].slotSum[#jD.sample]=jD[tblId].slotSum[#jD.sample]+ 1
                      tmpStr = "rpt";if v.log:find("failed") then tmpStr="nack" end
                      if not jD[tblId][tmpStr] then jD[tblId][tmpStr] = 0;jD.rptDev=jD.rptDev+1
                         if tmpStr == "nack" then jD.nackDev=jD.nackDev+1 end end
                      jD[tblId][tmpStr] = jD[tblId][tmpStr] + 1 
                      idStr = "<sub>#".. jD[tblId].slotSum[#jD.sample].."/"..jD[tblId]["total"] .."</sub>" .. findNameRoom(tblId).. "("..v.log.."<sup> "..tmpStr.."</sup>)</font> "
                      if v.log:find("failed") then rptColor="<font color=firebrick>";jD.nackNum=jD.nackNum+1 else rptColor="<font color=dimgrey>" end
                       mStr = mStr .. rptColor.. idStr.."</font> " --end
                   end
                end
            end --  if not json.encode(api.get("/devices/" .. v.id)
        end -- for i, v in pairs(lState.changes) do 
    end -- for k=1,
    if os.time() - jD.sample[1].lTime >= logRate*60 then -- Log results
      jD.topDev.zMin = math.ceil(math.min(jD.topDev.zMin,(os.time() - jD.sample[1].lTime )/(jD.total-jD.sample[1].total))*10)/10
      if jD.total>jD.sample[1].total then jD.topDev.zMax = math.ceil(math.max(jD.topDev.zMax,(os.time() - jD.sample[1].lTime )/(jD.total-jD.sample[1].total))*10)/10 end
      jD.sample[1].lTime=os.time()-os.date("*t").sec
      jD.sample[#jD.sample].sum = jD.total-jD.sample[1].total
      jD.sample[1].total = jD.total
      jD.sample[#jD.sample].sSum= jD.sTotal-jD.sample[1].sTotal
      jD.sample[1].sTotal = jD.sTotal
      jD.topDev.inTotal = 0
      jD.sample[#jD.sample].dead = deadId; deadId="" 
      jD.sample[#jD.sample].cpu1,jD.sample[#jD.sample].cpu2,jD.sample[#jD.sample].ram = sampleCpu(true)
      cpuLoad[1],cpuLoad[2],cpuLoad[3] = 0,0,0
	  mStr = mStr .. '<br><a class="bold-line" href="api/scenes/'.. sceneId ..'/kill" onclick="fibaro.scene(kill,'.. sceneId ..'); return false;"><font size=3>&#128190</font><font color=PaleTurquoise> Click to Stop Monitor Z-wave</font></a>'
      mStr = mStr .. "<br><font size=3>&#128190</font><font color=PaleTurquoise> Logging Z-wave data[<font color=LightCoral>"..#jD.sample.."</font>] <font size=4>&#10227</font><sup>"..logRate.."</sup></font> "
      jD.sample[#jD.sample+1]={}
    end  
    if deadOnTop[1] and jD.deadBuffer:len()>20 then mStr = jD.deadBuffer:gsub("!","") .."<br>" .. mStr end
    if mStr:len() > 10 and not checkOnScreen("Z-wave traffic",false) then
       fibaro.debug("zwave_monitor",'<font color=yellowgreen><font size=3>&#9203</font>' .. ("%3d"):format(math.floor((os.time() - jD.sampleStartTime)/3600)) .. os.date("!:%M:%S",os.time() - jD.sampleStartTime) ..str2disp(time2monitor,0,"<font size=2>/</font>"..string.format("%3d",math.floor(time2monitor)) .. os.date(":%M:%S",(time2monitor- math.floor(time2monitor))*3600),"")..
          insBlank(2) .. jD.total..' events<font size=2>/</font>'..jD.devNum..' devices'..insBlank(2)..
           'event<font size=2>/</font>'.. math.ceil((os.time()-jD.sampleStartTime)/jD.total*10)/10 ..'s'..insBlank(2)..'<a class="bold-line" href="api/scenes/'.. viewer_sceneId ..'/execute" onclick="fibaro.scene(execute,'.. viewer_sceneId ..'); return false;">Click Start for viewer Z-wave <font size=4>&#9638<font size=5>&#128480</font></font></a><br>'..
           mStr .. "<span style=text-align:center>")
    elseif checkOnScreen("Z-wave traffic",false) then -- and fibaro.countScenes()==2 then
            dispInfo(json.decode(json.encode(jD)))
    end
   jD.sampleEndTime = os.time() 
   if gVar then fibaro.setGlobalVariable(gVarName, json.encode(jD)) end
   if jD.sample[1].lTime - jD.sampleStartTime >= time2monitor*3600 and time2monitor ~=0 then 
      dispInfo(json.decode(json.encode(jD)));
	  return  end   
  end --while true do
end -- end of function lastState()  
--============================= Scene's main =================================== 
--if fibaro.countScenes() == 1 then  -- no longer available in HC3
if flag_debug then fibaro.debug("zwave_monitor", "Scene's main") end
  if gVar then api.delete("/scenes/" .. sceneId .. "/debugMessages") 
     isGlobal(gVarName,json.encode(jD),true,false,"<font color=lightblue>Z-wave monitoring has started ".. str2disp(time2monitor,0,"for next <font size=2>"..string.format("%3d",math.floor(time2monitor)) .. os.date(":%M:%S",(time2monitor- math.floor(time2monitor))*3600) .."</font> hour(s).","").." </font><br>")
    if flag_debug then fibaro.debug("zwave_monitor", "Scene's main : before json.decode : gVarName: " .. gVarName .. " value gVarName: " ..fibaro.getGlobalVariable(gVarName) ) end
	-- jK = json.decode(fibaro.getGlobalVariable(gVarName))
	local jK_temp = fibaro.getGlobalVariable(gVarName)
	local jK = json.decode(jK_temp)
	-- Accéder à la valeur du champ "total"
    if jK and jK.total then
      if flag_debug then fibaro.debug("zwave_monitor", "Scene main : after json.decode : La valeur de 'total' est : " .. jK.total) end
		 if jK.total > 1000 and jK.inUse then
			fibaro.sleep(1000); api.delete("/scenes/" .. sceneId .. "/debugMessages") 
			fibaro.debug("zwave_monitor","<font size=2><font color=orangered>Please pay attention:<br>Global variable <font color=wheat>".. gVarName .. "</font> contains previous data of <font color=wheat>"..jK.total .."</font> Z wave events.</font></font>"..
			  "<br><font color=pink> For data backup, please see example below:</font></font></font>"..
			  "<br></font><font color=wheat>fibaro.setGlobalVariable(<font color=yellowgreen>\"<i>new_global_variable</i>\"</font>,fibaro.getGlobalVariable(\"<font color=yellowgreen>"..gVarName.."\"</font>))</font>"..
			  "<br><font color=pink>To proceed press continue...</font>"..
			  '<a class="bold-line" href="#" onclick="fibaro.scene(execute,'.. sceneId ..'); return false;"><div class="Button1_0 ng-binding" style="margin: 10px 0px 0px 280px;color:lightblue;">Continue</div></a>') 
			jK.inUse=false
			fibaro.setGlobalVariable(gVarName, json.encode(jK)) 
		 end
    end
  else fibaro.debug("zwave_monitor","<font color=lightblue>Z-wave monitoring has started ".. str2disp(time2monitor,0,"for next <font size=2>"..string.format("%3d",math.floor(time2monitor)) .. os.date(":%M:%S",(time2monitor- math.floor(time2monitor))*3600) .."</font> hour(s).","").." </font><font color=red><font size=3> local json table is in use</font></font>") 
  end
  jD.inUse=true 
  lastState() 
--elseif fibaro.countScenes()==2 then api.delete("/scenes/" .. sceneId .. "/debugMessages") 
-- if flag_debug then fibaro.debug("zwave_monitor","<font color=yellowgreen><font size=2>Please wait while generating Z-wave traffic detailed report....</font></font>") end
--  x=os.time();while not checkOnScreen("Average traffic",false) and os.time()-x < 25 do end
--  if os.time()-x >= 25 then api.delete("/scenes/" .. sceneId .. "/debugMessages")
--    if fibaro.countScenes() == 1 then fibaro.debug("zwave_monitor","<font color=pink>Somethinng went wrong! Please RESTART the scene.</font>") 
--    else fibaro.debug("zwave_monitor","<font color=pink>Somethinng went wrong! Please repeat last action.</font>") 
--    end 
--  end fibaro:abort() 
--else  fibaro:abort() end
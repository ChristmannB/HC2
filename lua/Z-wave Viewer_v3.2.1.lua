--=========================== USER CONFIGURABLE PARAMETERS ===============================
--------------------------------- v3.0 ------------------------------------------------
gVarName = "zwave_318"   -- Global variable name, which contains Z-wave traffic data
chartHeight = 100        -- Chart height in percents (%). Charts' default height fits debug window.
chartWidth = 100         -- Chart width in percents (%). Charts' default width expands according to number of samples.
topDev2disp =20           -- Number of most active devices to display on devices chart.
topScene2disp= 5         -- Number of most active scenes to display on scenes chart.
darkSkinMode = true     -- Charts display skin mode. Set false for light (white) skin.
dev2review={true,"|800|509|804"}-- Chart for device reading values over the monitoring time.
userDev={true,"|169|"} -- Devices and scenes IDs to generate specific chart. Please write underscore before scene ID |_531|  
stackedChart=true        -- stacked line chart, lines do not overlap because they are cumulative at each point.
flag_debug=false 			 -- to set debug
----------------------------------------------------------------------------------------------------------------------
--========================== Please do not change parameters below ===================================================
markId={"",""};zwaveMonitor=false;relVer="v3.2.1"
if darkSkinMode then skinColor="black" else skinColor = "white" end
function findRoom(jK,dId)
  local dType="devices"
  if dId:find("_") then dType = "scenes" end
  if api.get("/"..dType.."/"..jK[dId].id)["roomID"] == 0 then return api.get("/"..dType.."/"..jK[dId].id)["name"].."@Unassigned" end
  return api.get("/"..dType.."/"..jK[dId].id)["name"].."@"..api.get("/rooms/"..api.get("/"..dType.."/"..jK[dId].id)["roomID"])["name"] 
end -- function =======================================================================
function resChart(jK)
 if not dev2review[1] then zChart={" "} return zChart end
 local zChart={}
for DevResChart in string.gmatch(string.gsub(dev2review[2],"|"," "),"%d+")  do 
   if not jK[DevResChart] then goto zNext end;-- if not jK[DevResChart].resSum then goto zNext end
   if  #jK[DevResChart].resSum ==0 then goto zNext end 
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
      if propName[j]==jK[DevResChart].typeSum[i] then 
         totalRes=totalRes+1
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
end -- for DevResChart in 
return zChart
end -- function =======================================================================
function dispTopDev(jK,devType)
 local xStep,xOffset,yOffset,polyLine,rStep = math.max(9*chartWidth/100,math.floor(400/#jK.sample)),30,-50,"",0
 local zChart,cHeight,cWidth,hRead = {'\n'},260*chartHeight/100,#jK.sample*xStep+50,0
 local rAncorY,legendW,devEvents,topDevNum=cHeight-55,250,0,topDev2disp
 local cHeader ={["scenes"]=" top scenese",["devices"]=" top devices",["user"]=" user selected device(s)"}
 if devType == "user" and not userDev[1] then zChart={" "} return zChart end
 if devType == "scenes" then topDevNum=topScene2disp end
 if devType == "scenes" then
    jK.devRank={}
    for i,j in pairs(jK) do
       if i:find("_") then  local maxEvents,mScene=0,nil
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
 zChart[#zChart+1]='<text fill="dimgray"  x="85" y="-1" style="transform:rotate(90deg)";>events</text><br>'
 for j=topDevNum,1,-1 do 
   polyLine="";_rgb="#"..string.format("%02X%02X%02X",math.random(0,200),math.random(0,200),math.random(0,200))
   for i=1,#jK.sample do devEvents = 0
      if stackedChart then
         for i2=topDevNum,j,-1 do devEvents=devEvents + jK[jK.devRank[i2]].slotSum[i] end
      else devEvents= jK[jK.devRank[j]].slotSum[i] end
      polyLine = polyLine .." "..xOffset+5+xStep*(i-1)..","..rAncorY -math.floor(devEvents*rStep)
   end --for i=1,#jK.sample do 
   zChart[#zChart+1]='<a class="bold-line" xlink:href="#0"><text fill="'.._rgb..'" x="'..cWidth+15 ..'" y="'..13*j..'";>'..jK[jK.devRank[j]].id ..'-'..findRoom(jK,jK.devRank[j]) .. '</text><polyline points="'..polyLine..'" style="fill:none;stroke:'.._rgb..';" /></a><br>'
 end --for j=topDevNum,1,-1 do 
  zChart[#zChart+1]='</pre></svg><br><br>'
 return zChart
end -- function =======================================================================
function dispChart(jK)
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
 zChart[#zChart+1]='<text fill="dimgray"  x="80" y="-3" style="transform:rotate(90deg)";>events</text><br>'
 for i=1,#jK.sample do 
     polyLine.ram = polyLine.ram .." "..xOffset+5+xStep*(i-1)..","..rAncorY - math.floor(jK.sample[i].ram)*(rAncorY-12)/100
     polyLine.cpu1 = polyLine.cpu1 .." "..xOffset+6+xStep*(i-1)..","..rAncorY - math.floor(jK.sample[i].cpu1)*(rAncorY-12)/100
     polyLine.cpu2 = polyLine.cpu2 .." "..xOffset+4+xStep*(i-1)..","..rAncorY - math.floor(jK.sample[i].cpu2)*(rAncorY-12)/100
     polyLine.scene = polyLine.scene .." "..xOffset+5+xStep*(i-1)..","..rAncorY - math.floor(jK.sample[i].sSum-lRead)*rStep
     polyLine.event = polyLine.event .." "..xOffset+5+xStep*(i-1)..","..rAncorY - math.floor(jK.sample[i].sum-lRead)*rStep
 end
 if flag_debug then printTable(jK.topDev, 1, "jK.topDev") end
 
 zChart[#zChart+1]='<a class="bold-line" xlink:href="#0"><text fill="brown" x="'..cWidth+15 ..'" y="60";>RAM  '..ram.min..'% > ' .. ram.avg..'% < '..ram.max..'%</text><polyline points="'..polyLine.ram..'" style="fill:none;stroke:brown;" /></a><br>'
 zChart[#zChart+1]='<a class="bold-line" xlink:href="#0"><text fill="blue" x="'..cWidth+15 ..'" y="30";>CPU1 '..cpu[1].min..'% > ' .. cpu[1].avg..'% < '..cpu[1].max..'%</text><polyline points="'..polyLine.cpu1..'" style="fill:none;stroke:blue;" /></a><br>'
 zChart[#zChart+1]='<a class="bold-line" xlink:href="#0"><text fill="violet" x="'..cWidth+15 ..'" y="45";>CPU2 '..cpu[2].min..'% > ' .. cpu[2].avg..'% < '..cpu[2].max.. '%</text><<polyline points="'..polyLine.cpu2..'" style="fill:none;stroke:violet;" /></a><br>'
 zChart[#zChart+1]='<a class="bold-line" xlink:href="#0"><text fill="red" x="'..cWidth+15 ..'" y="15";>Z-wave events='..jK.total..'</text><polyline points="'..polyLine.event..'" style="fill:none;stroke:red;" /></a><br>'
 zChart[#zChart+1]='<a class="bold-line" xlink:href="#0"><text fill="grey" x="'..cWidth+15 ..'" y="75";>Triggered Scenes='..jK.sTotal..'</text><polyline points="'..polyLine.scene..'" style="fill:none;stroke:grey;" /><br>'..
    '<text fill="grey" x="'..cWidth+15 ..'" y="90";>Top scene:'..jK.topDev.sId..'-' .. api.get("/scenes/"..jK.topDev.sId)..'</text></a><br>'
 zChart[#zChart+1]='</svg>'
 return zChart
end -- function =======================================================================
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

function logData(maxId,jK)
  local fColor=""
   if markId[1]:find(maxId["id"]) then fColor = "<font color="..markId[2]..">" end
--   if markRoom[1] and markRoom[2]:find(fibaro.getRoomNameByDeviceID(tonumber(maxId["id"]))) then fColor ="<font color=cadetblue>" end 
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
           found = true
        end --if zBuffer[l]:find(" "..k.." ") then
    end -- for k,s in pairs(j) do
    if not found then zBuffer[#zBuffer+1]="<td></td>" end
 end
 zBuffer[#zBuffer+1]="<td class=txtLeft>   "..fColor..fibaro.getName(tonumber(maxId["id"])).." @ "..fibaro.getRoomNameByDeviceID(tonumber(maxId["id"])).."</td>" 
 zBuffer[#zBuffer+1]="</tr>"
end -- function =======================================================================
function sortData(jK)   
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
 return "<style> .bold-line:hover{stroke-width:3.5;font-weight:bold;font-style:italic;}"..
  ".tooltip {border:1px solid grey;position:relative; border-radius:0px; padding:1px; text-align:left; font-weight:bold; font-family:monospace; font-size:11px;display:table-cell;}"..
  ".tooltip .tooltiptext {visibility: hidden; width: auto;background-color: black;font-weight: bold;color:yellow;text-align: left;border-radius: 0px; padding: 14px 1;"..     
  "position: absolute;z-index: 1;top: -10px;left: 100%;}"..
  " .tooltip:hover .tooltiptext {visibility: visible;} .txtLeft {text-align: left;}" ..
  " th {border-collapse: collapse;padding: 2px;border: 2px solid dimgray;font-size: 106%;font-weight: normal;}"..
  " td {padding: 0px;border: 1px solid dimgray;} th, td {text-align: center}tr:nth-child(even) {background-color: #161616;} tr:hover {background-color:#001a33;}</style>" -- table {width:70%;}</style>"
end -- function =======================================================================
function setHeader(jK,tCaption) 
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
  local mStr,zTotal,zMax,sceneVer= "",0,0,{[true]="<font color=yellow>Z-wave Monitor "..relVer.."</font>",[false]="<font color=yellow>Z-wave Viewer "..relVer.."</font>"}
  fibaro.sleep(700)
  if #jK.sample> 1 then jK.sample[#jK.sample] = nil end
  local localTime=jK.sample[1].lTime 
  if jK.sample[1].lTime < jK.sampleStartTime then localTime = os.time() end
  setHeader(jK,"<font color=sandybrown>" ..api.get("/settings/info/")["hcName"].. " ("..api.get("/settings/info/")["serialNumber"].. ") Z-wave traffic report.</font>")
  sortData(jK)
  if jK.deadBuffer:len() > 10 then mStr="<br>Dead device(s)  = <b>"..jK.deadBuffer:gsub("!","") .. "</b>" end
  zBuffer[#zBuffer+1]="<font color=lightblue><font size=2>Elapsed  time   = <font color=wheat>" .. ("%03s"):format(math.floor((localTime- jK.sampleStartTime)/3600)) .. os.date("!:%M:%S",localTime - jK.sampleStartTime).. os.date("</font>   [ %b %d %H:%M  -  ",jK.sampleStartTime)..os.date("%b %d %H:%M ]",localTime)..
  "<br>Sample log rate = <font color=wheat>" ..jK.sample[1].lRate .."</font> minutes. Total samples <font color=wheat>"..#jK.sample.."</font>"..
  "<br>Z-wave  events  = <font color=wheat>" ..jK.total.."</font> on <font color=wheat>"..jK.devNum .."</font> devices."..
  "<br>Average traffic = <font color=wheat>" .. math.ceil((localTime-jK.sampleStartTime)/jK.total*10)/10 .. "</font> sec." ..
  "<br>Z-traffic range = <font color=wheat>" .. jK.topDev.zMin.. "</font> - <font color=wheat>"..jK.topDev.zMax.. "</font> sec." .. --mStr .."</font></font>"
 "<br>Repeat / Report  = <font color=wheat>"..jK.rptNum.."<sup>("..math.floor(jK.rptNum/jK.total*1000)/10 .."%)</sup></font> on <font color=wheat>"..jK.rptDev .."</font> devices."
  if jK.nackNum>0 then zBuffer[#zBuffer+1]="<br><font color=red>Transfer Failed  = "..jK.nackNum.."</font> on <font color=red>"..jK.nackDev .."</font> devices." end
  zBuffer[#zBuffer+1]=mStr .."</font></font>"
  api.delete("/scenes/" .. sceneId .. "/debugMessages")
  mStr = '<a class="bold-line" href="api/scenes/'.. sceneId ..'/execute" onclick=""><div class="Button1_0 ng-binding" style="margin: 10px 0px 0px 270px; color:lightblue;">Refresh</div></a><br> </pre>'
  if zwaveMonitor then  mStr = '<a class="bold-line" href="api/scenes/'.. sceneId ..'/execute" onclick=""><div class="Button1_0 ng-binding" style="margin: 10px 0px 0px 185px; color:lightblue;">Refresh</div></a>'..
     '<a class="bold-line" href="#" href="api/scenes/'.. sceneId ..'/kill" onclick=""><div class="Button1_0 ng-binding" style="margin: 10px 0px 0px 105px; color:lightblue;">Back</div></a><br> </pre>' 
  end
  if zwaveMonitor and jD.sample[1].lTime - jD.sampleStartTime >= time2monitor*3600 then
    mStr ="<br><font color=yellowgreen><font size=3>Please use Z-wave Viewer to review additional data. <br>Global variable is </font><font color=wheat>"..gVarName.."</font>" 
   if not gVar then 
    mStr ="<br><font color=orangered><font size=3>To remind you:<br>Global variable is not defined therefore displayed data could not be restored!</font></font>" 
   end
 end
 if #jK.sample >1 then 
  fibaro.debug("Viewer_Zwave",sceneVer[zwaveMonitor].."<pre>"..table.concat(zBuffer)..'<br><br></pre>' .. table.concat(dispTopDev(jK,"devices")) .. table.concat(dispTopDev(jK,"scenes")) .. table.concat(dispTopDev(jK,"user"))..table.concat(resChart(jK))..table.concat(dispChart(jK))..mStr)
  else
  zBuffer[#zBuffer+1]="<br><font color=pink><font size=2>No sufficient data to generate ZKG chart... please wait for additional ".. 2- #jK.sample.." cycles.</font></font>"
  fibaro.debug("Viewer_Zwave",sceneVer[zwaveMonitor].."<pre>"..table.concat(zBuffer)..'<br>' ..mStr)
 end
end -- function =======================================================================
--============================= Scene's main =================================== 
api.delete("/scenes/" .. sceneId .. "/debugMessages")
if fibaro.getGlobalVariable(gVarName) ~=nil then
    if fibaro.getGlobalVariable(gVarName):len()< 100 then
       fibaro.debug("Viewer_Zwave","<font color=red>Improper variable<pre><font color = pink><font size=3px>"..gVarName.."</font> variable does not contain Zwave monitor data... <br>Please re-run Zwave Monitor or use appropriate variable. <br>Scene Aborted.</font>")
       fibaro.abort()
     end
   if json.decode(fibaro.getGlobalVariable(gVarName))["sample"] then
      fibaro.debug("Viewer_Zwave","<font color=yellowgreen><font size=2>Please wait while generating Z-wave traffic detailed report....</font></font>")  
      dispInfo(json.decode(fibaro.getGlobalVariable(gVarName)))
   else fibaro.debug("Viewer_Zwave","<font color=red><font size=3>Warning! Data in <font color=wheat>\"" .. gVarName.."\" </font>variable is not valid.</font></font>")  
   end
else
   fibaro.debug("Viewer_Zwave","<font color=red><font size=3>Warning! Global variable <font color=wheat>\"" .. gVarName.."\"</font> not found!</font></font>")
end  

--[[ UI Definition:
1 	Label1 ->Label "Profil Choisi :" -> ID:"Label1
2 	1 Button -> Label "Présence" -> ID:"Button11 -> Lua code: fibaro:setGlobal("Profil","Présence")
		fibaro:call(657,'setProperty','ui.Label1.value', "Présence")
		fibaro:log("Sélection du profil Présence") 
3	2 Button -> Label:"Abscence -> ID:"Button21 -> Lua code: fibaro:setGlobal("Profil","Abscence")
		fibaro:call(657,'setProperty','ui.Label1.value', "Abscence")
		fibaro:log("Sélection du profil Abscence")
			-> Label:"Vacances" -> ID:"Vacances" -> ID:"Button22" Lua code:fibaro:setGlobal("Profil","Vacances")
		fibaro:call(657,'setProperty','ui.Label1.value', "Vacances")
		fibaro:log("Sélection du profil Vacances")
4 	Label2 	->Label:"Chauffeau" -> ID:"Label25	
5	Label3	->Label:"Lumières"-> ID:"Label3"
6	1 button	->Label:Manuel -> ID:"Button31 _>	Luacode:fibaro:setGlobal("Profil","Manuel")
		fibaro:call(657,'setProperty','ui.Label1.value', "Manuel")
		fibaro:log("Sélection du profil Manuel")
Main loop -> --]]--
	selfID= fibaro:getSelfId()
fibaro:debug("----- Démarage du VD "..selfID.." ----")
--Vérification de l'état du chauffe-eau
local BallonM = fibaro:getValue(558, "value")
local BallonG = fibaro:getValue(811, "value")
local EtatM 
if BallonM == "1"
  then EtatM = "En marche"
  else EtatM = "Arrêt"
  end
local EtatG 
if BallonG == "1"
  then EtatG = "En marche"
  else EtatG = "Arrêt"
  end
  fibaro:debug("Etat Chauffe-eau Maison= " .. BallonM .. " soit " .. EtatM)
  fibaro:debug("Etat Chauffe-eau Grange= " .. BallonG .. " soit " .. EtatG)


  fibaro:call(selfID,'setProperty','ui.Label2.value', "Maison : "..EtatM..",\n Grange : "..EtatG)
-- creattion de la table des lumières
local message=""
local lumTable={}
lumTable[1]={}
lumTable[1].id=599
lumTable[1].name="Cave maison"
--fibaro:debug(json.encode(lumTable))
lumTable[2]={}    
lumTable[2].id=554
lumTable[2].name="Grenier maison"
--fibaro:debug(json.encode(lumTable))
lumTable[3]={}
lumTable[3].id=544
lumTable[3].name="Couloir RDC"
--fibaro:debug(json.encode(lumTable))
lumTable[4]={}    
lumTable[4].id=820
lumTable[4].name="LED Ch1er"
--fibaro:debug(json.encode(lumTable))
lumTable[5]={}
lumTable[5].id=821
lumTable[5].name="LED SdJ"
--fibaro:debug(json.encode(lumTable))
lumTable[6]={}
lumTable[6].id=823
lumTable[6].name="Plafonnier Salon"
--fibaro:debug(json.encode(lumTable))
lumTable[7]={}
lumTable[7].id=824
lumTable[7].name="LED escalier Salon"
--fibaro:debug(json.encode(lumTable))
lumTable[8]={}
lumTable[8].id=825
lumTable[8].name="Plafonnier Ch RDC"
--fibaro:debug(json.encode(lumTable))
lumTable[9]={}
lumTable[9].id=826
lumTable[9].name="Ventilo Grange"
--fibaro:debug(json.encode(lumTable))
lumTable[10]={}
lumTable[10].id=827
lumTable[10].name="Plafonnier Ch RDC"
--fibaro:debug(json.encode(lumTable))
lumTable[11]={}
lumTable[11].id=828
lumTable[11].name="LED Cuisine"
--fibaro:debug(json.encode(lumTable))
lumTable[12]={}
lumTable[12].id=829
lumTable[12].name="LED SàM"
--fibaro:debug(json.encode(lumTable))
lumTable[13]={}
lumTable[13].id=830
lumTable[13].name="LED meuble Cuisine"
--fibaro:debug(json.encode(lumTable))
  
--fibaro:debug("lumTable->"..json.encode(lumTable))
-- vérification des lumières
-- Liste des interrupteurs de lumières éventuellement "On"
SW1 = fibaro:getValue(599, "value") -- Cave maison
SW2 = fibaro:getValue(554, "value") -- Grenier maison
SW3 = fibaro:getValue(544, "value") -- Couloir RDC maison
SW4 = fibaro:getValue(820, "value") -- LED Chambre 1er
SW5 = fibaro:getValue(821, "value") -- LED Salle de jeux 
SW6 = fibaro:getValue(823, "value") -- Plafonnier Salon
SW7 = fibaro:getValue(824, "value") -- LED escalier Salon
SW8 = fibaro:getValue(827, "value") -- LED Appentis 
SW9 = fibaro:getValue(828, "value") -- LED Cuisine
SW10 = fibaro:getValue(829, "value") -- LED SàM
SW11 = fibaro:getValue(825, "value") -- Plafonnier Ch RDC
SW12 = fibaro:getValue(830, "value") -- LED meuble Cuisine 
SW13 = fibaro:getValue(826, "value") -- Ventilo Grange

if  (SW1 == "1") or
    (SW2 == "1") or
    (SW3 == "1") or
    (SW4 == "1") or
    (SW5 == "1") or
    (SW6 == "1") or
    (SW7 == "1") or
    (SW8 == "1") or
    (SW9 == "1") or 
    (SW10 == "1") or 
    (SW11 == "1") or 
    (SW12 == "1") or
  	(SW13 == "1")
  then 
  		fibaro:debug("Il reste encore une lumière allumée")
   		message="Pièce(s) allumée(s) : "
  		fibaro:call(selfID, 'setProperty', 'ui.Label3.value', "1 swich ou + ON")
        for _,t in ipairs(lumTable) do
          local state=tonumber(fibaro:getValue(t.id,"value"))
          --fibaro:debug("id:".. t.id ..", pièce ".. t.name..", state "..state)
          if state==1 then fibaro:debug("pièce "..t.name .." est allumée!") 
          message=message.. t.name ..", "
          end
        end
        fibaro:debug(message)
        fibaro:call(selfID, 'setProperty', 'ui.Label3.value', message)

  else
  		fibaro:debug("Tous les lumières sont OFF")
  		message=""
  		fibaro:call(selfID, 'setProperty', 'ui.Label3.value', "All Off")
   --fibaro:debug("Liste : " .. SW1 .. ", " .. SW2 .. ", " .. SW3 .. ", " .. SW4 .. ", " .. SW5 .. ", " .. SW6 .. ", " .. SW7 .. ", " .. SW8.. ", " .. SW9 .. ", " .. SW10 ..", "..SW11..", "..SW12..", "..SW13)


  end
fibaro:debug("Liste : " .. SW1 .. ", " .. SW2 .. ", " .. SW3 .. ", " .. SW4 .. ", " .. SW5 .. ", " .. SW6 .. ", " .. SW7 .. ", " .. SW8.. ", " .. SW9 .. ", " .. SW10 ..", "..SW11..", "..SW12..", "..SW13)

--======================== actions fonction du profil ==========================
profil=fibaro:getGlobal("Profil")
fibaro:debug("Profil actuel est "..profil)
if profil =="Manuel" then
  fibaro:debug("Aucune action car le profil est manuel")
elseif profil=="Présence" then
  fibaro:debug("Gestion des lumières et chauffes-eau par les occupants")
  --Mais par défaut le chauffe-eau Maison est en mode heures creuses
  fibaro:call(658, "pressButton",3) -- Maison Heures creuses
  
elseif profil=="Abscence" then
  fibaro:debug("Lumières éteintes et chauffes-eau selon état avant le départ")
  for _,t in ipairs(lumTable) do
    fibaro:call(t.id,"turnOff")
    end
  
elseif profil="Vacances" then 
  fibaro:debug("Lumières et chauffes-eau sont à l'arrêt")
  	for _,t in ipairs(lumTable) do
    fibaro:call(t.id,"turnOff")
    end
   fibaro:call(658, "pressButton",2) -- Maison
   fibaro:call(756, "pressButton",2) -- Grange
end

local wait=5
fibaro:debug("Prochain test dans ".. wait .."s")
wait=wait*1000
fibaro:sleep(wait)
    
			
--[[
--%% autostart
%% properties
%% events
%% globals

--]]

----------------Mode Automatique MàJ 06/08/2023---------------------------------------------
-- Chambre Parent + Salle à manger + Cuisine + SdB en Mode Panneau Chauffage
-- Gestion de leur switchs selon leur consigne donné par le panneau

fibaro:debug('------------- Début du scénario v3.4 ---------------')
-- Utilisation de l'heure et de la date
local Maintenant = os.date("*t") --stocke la date et heure actuelle du système sous forme d'un tableau à l'intérieur de la variable "Maintenant"
--  Affichage de la date et l'heure
fibaro:debug("il est maintenant ".. Maintenant['hour'].."h"..Maintenant['min'].."min"..", le "..Maintenant['day'].."/"..Maintenant['month'].."/"..Maintenant['year'])
-- Utilisation de l'écart de température extérieure avec la variable globale "Isolation" 
local Temp_Ext = 6 -- Etait à 7°C avant le 25/09/2018 (Salon trop chaud)
fibaro:debug("La temperature de changement du coéfficient Isolation est : "..Temp_Ext .."°C")


----Lecture du module Ext Netatmo
local stationNo = 1
local wT=json.decode(fibaro:getGlobalValue("NetatmoWeather"))
TempNetatmo = wT.netatmo[1].outm.temp
local TempNetatmoExt = fibaro:getValue(644, "ui.Label1.value")
fibaro:debug("les valeurs du module extérieur Netatmo sont : " .. TempNetatmoExt .. "°C")
fibaro:debug("la valeur Temp Ext avec décimale est de " .. TempNetatmo .."°C")
-- contrôle du fonctionnement du module Netatmo
local OutDoorModuleState = wT.netatmo[1].outm.fail
fibaro:debug("Module HS la valeur suivante est à 1 : " .. OutDoorModuleState)
if tonumber(OutDoorModuleState) > 0
  then TempNetatmo = 20
end

fibaro:debug("T° Netatmo Ext sélectionnée " .. TempNetatmo .."°C")
----Lecture du plugin YR
YR_ID = 3
Temp_Ext_Mesure = fibaro:getValue(3, "Temperature")--fibaro:getValue(Netatmo_EXT, "logTemp", "Value")
fibaro:debug("Température extérieure YR Weather lue : ".. Temp_Ext_Mesure .."°C")
if ((tonumber(Temp_Ext_Mesure) < Temp_Ext) or (tonumber(TempNetatmo) < Temp_Ext))   
  then Isolation = 0.3 -- avant 1/3/2023 :0.5 -- remis à 0 le 3/12/2017 - 1 avant de changer les fenêtres
  else Isolation = 0
  end
fibaro:debug("Le coéficient Isolation est à ".. Isolation .."°C")

local Hysteresis = 0.2
fibaro:debug("La valeur de l'hystérésisis est de : "..Hysteresis .. " °C")
-----------------Recherche du mode de fonctionnement------------------
local Val = fibaro:getGlobal('Mode_Maison')
fibaro:debug("le mode de fonctionnement est " .. Val)
-- Scénario
if (Val=='Automatique') 
then 

----------Changement de THRMST si piles trop basses ---------------------------------------------------------------
local BLevel = 20 --- niveau minimal des batteries avant basculement
fibaro:debug("Niveau minimel pour les batteries " .. BLevel)

------------------------------

  
  --------------- Zone 0 Cuisine & Salle à Manger ----------------- 
local Zone0 = 'Salle à manger ou Cuisine'
fibaro:debug("----- Contrôle des modules Zwave ------")
fibaro:debug("-----      Salle à manger        ------")
local Consigne0 = 637 -- SRT321 SàM
local Temp0 = 638 -- Temp_Salle à manger
local Temp1 = 346 -- Temp_Smoke_Detector_Cuisine
local BatTemp1 = 344 -- module Smoke detector principal
local SW1 = 51 --Quibino std Fenêtre SàM - diode+ -- fonctionnement inversé au 24/07/2023
local SW2 = 503 -- Ex 59 Qubino std Cuisine - diode- 

-- SàM batteries SRT321
local ValB_001 = fibaro:getValue(Consigne0, "batteryLevel")
fibaro:debug("Niveau batterie du module  Thrmst SàM" .. Consigne0 .. " est " .. ValB_001 )
-- Cuisine batterie Détecteur de fumée
local ValB_011 = fibaro:getValue(BatTemp1, "batteryLevel")
fibaro:debug("Niveau batterie du module fumée Cuisine " .. BatTemp1 .. " est " .. ValB_011 )

--  fibaro:debug("la Température du SRT321 est de ".. fibaro:getValue(Temp0) .. "°C") 
--  fibaro:debug("la Température du Smoke Detector est de ".. fibaro:getValue(Temp1) .. "°C") 

  ------- lecture module Netatmo SaM -------
local ModNetatmo_0 = 716
--local ModNetatmo_Ext = 644
--local ModNetatmo_Int = 645
  
local TempNetatmoMain = fibaro:getValue(ModNetatmo_0, "ui.Label1.value")	
fibaro:debug("les valeurs du module Netatmo de la SàM sont : " .. TempNetatmoMain )
--		  	TempNetatmoMain = string.sub(TempNetatmoMain, 2, 9)
--  		fibaro:debug("la valeur Temp Netatmo SàM avec une décimale est de " .. TempNetatmoMain .."°C")

  ----contrôle du fonctionnement du VD netatmo SaM -- 
fibaro:debug("----------contrôle du fonctionnement du VD Netatmo SàM----------")
local MainNetatmoFail = wT.netatmo[1].fail
  if (tonumber(MainNetatmoFail)) > 1
    then 
    fibaro:debug("Si la valeure suivante est > 0, Module HS : " .. MainNetatmoFail)
    TempNetatmoSaM = 20  -- peut-être pas la bonne valeur...
      fibaro:debug("Température sélrectionnpour la SaM est : " .. TempNetatmoSaM .."°C")
	else
      TempNetatmoSaM = wT.netatmo[1].temp
      fibaro:debug("Température sélectionnée pour la SaM est : " .. TempNetatmoSaM .."°C")

    end
  
  fibaro:debug("T° Netatmo SàM " .. TempNetatmoSaM .. "°C\n")


  ------- modification du module de contrôle en fonction de l'état des piles ------

if (tonumber(ValB_001) > tonumber(BLevel))
  then 
  fibaro:debug("Batteries Thrmst OK ")
  fibaro:debug("-----")
  	Val_1 = fibaro:getValue(Consigne0,"value") -- consigne Thermostat SAM + cuisine
  	Val_2 = fibaro:getValue(Temp0,'value') -- Temp SAM

  if (tonumber(ValB_011) <  tonumber(BLevel))  
	then 
    fibaro:debug("  Batterie fumée KO   --") 
  	Temp1 = Temp0
  	else 
    fibaro:debug("  Batterie fumée OK   --")
  	Temp1 = Temp1 --346 
  	end
  fibaro:debug("l'ID pour la valeur Temp1 est " .. Temp1)
else 
  fibaro:debug("Batteries Thrmst KO   --") 
  --- changement de consigne selon le profil
  local  TypeControl = fibaro:getGlobal("Profil")
  fibaro:debug("Profil " .. TypeControl)
  if TypeControl == "Présence"
  	then
     	Consigne0 = Consigne20 -- Id31 Thrmst de la chambre des parents
	    fibaro:debug("l'ID pour la valeur Consigne0 est " .. Consigne20)
  		Val_1 = fibaro:getValue(Consigne0,"value") -- consigne Thermostat Ch parents 
		Val_2 = fibaro:getValue(Temp1,'value') -- Temp SAM
  	else
  	Val_1 = fibaro:getGlobal("H_G")  
  	Val_2 = TempNetatmoSaM
  	end 
end
fibaro:debug("La consigne sélectionnée est " .. Val_1 .. "°C")
fibaro:debug("La température de la SàM sélectionnée est "..Val_2.."°C")
------------Contrôle des radiateurs --------
fibaro:debug("-----                    ------")
fibaro:debug('-- Contrôle de la zone 0 : ' .. Zone0 .. ' --')

--  	Val_1 = fibaro:getValue(Consigne0,"value") -- consigne Thermostat SAM + cuisine
--  	Val_2 = fibaro:getValue(Temp0,'value') -- Temp SAM
  	Val_3 = fibaro:getValue(SW1,'value') -- Switch SAM
  	Val_4 = fibaro:getValue(SW2,'value') -- Switch Cuisine
	Val_5 = fibaro:getValue(Temp1,'value') -- Temp Cuisine 

--local	zone = ("Zone0"..Zone0) Salle à manger + Cuisine
--     	fibaro:debug("Consigne SRT " .. Zone0 .. " est : " .. Val_1 .. "°C")

  local ConsZone0 = (tonumber (Val_1) + tonumber(Isolation)) -- ajouté le 31/02/2010 pour contrôle
  fibaro:debug("Consigne corrigée pour " .. Zone0 .. " est de " .. ConsZone0 .."°C") 
    	fibaro:debug("Température de la Salle à manger est : ".. Val_2 .."°C")
  		fibaro:debug("Température de la cuisine est : "..Val_5 .."°C")

  -- Télécommande de la Salle à Manger 
  -- le 23/03/2018 Ajout d'un hystérésis de température
    if (tonumber (Val_2)- tonumber(Hysteresis)) < (tonumber (Val_1) + tonumber(Isolation)) -- 28/01/2020 : Ajout tomumber sur Isolation
        then 
        fibaro:call(SW1, "turnOn")
        --fibaro:call(59, "turnOff")
          elseif (tonumber (Val_2) +  tonumber(Hysteresis)) > (tonumber (Val_1) + tonumber(Isolation)) 
          then fibaro:call(SW1, "turnOff")
          --fibaro:call(59, "turnOn")
            end
-- Télécommande de la Cuisine
	if (tonumber (Val_5)- tonumber(Hysteresis)) < (tonumber (Val_1) + tonumber(Isolation))
        then 
        --fibaro:call(51, "turnOff")
        fibaro:call(SW2, "turnOff")
          elseif (tonumber (Val_5) - tonumber(Hysteresis)) > (tonumber (Val_1) + tonumber(Isolation)) 
          then --fibaro:call(51, "turnOn")
          fibaro:call(SW2, "turnOn")
            end  
  
  	Val_3 = fibaro:getValue(SW1,'value') -- Switch SAM
  	Val_4 = fibaro:getValue(SW2,'value') -- Switch Cuisine
		fibaro:debug("Switch 1 ".. SW1 .. " Salle à manger est maintenant : " .. Val_3)
		fibaro:debug("Switch 2 ".. SW2 .. " Cuisine est maintenant : " .. Val_4)

  -- Paramètres Zone10 Couloir RDC
local Zone10 = 'Couloir RDC'
local Consigne10  = 236 -- RS321 thermostat,
--  local Consigne10  = 637 -- Salle à manger,
local Temp10 =  237 -- RS321 Thrmst Couloir RDC
--local Temp10 =  647 --température mesurée dans le couloir RDC (FIB Motion Sensor)
local SW11 = 706 -- QUBINO EX CUISINE ON/OFF inversé 23/07/2023 : radiateur Porte jardin Ex 17 WallPlug RDC
local SW12 = 111 -- QUBINO Porte Cour 
  --local	zone = ("Zone10"..Zone10) Couloir RDC
  		fibaro:debug('-- Contrôle de la zone : '..Zone10 ..' --')
	    Val_11 = fibaro:getValue(Consigne10, 'value') 
        Val_12 = fibaro:getValue(Temp10, 'value')
--    	Val_13 = fibaro:getValue(SW11, 'value')
--    	Val_14 = fibaro:getValue(SW12, 'value')

  --local	zone = ("Zone10"..Zone10) Couloir RDC
    	fibaro:debug("Consigne "..Zone10 .." est : "..Val_11 .."°C")
  		fibaro:debug("Température "..Zone10 .." est : "..Val_12 .."°C")
    local ConsZone10 = (tonumber (Val_11) + tonumber(Isolation)) -- ajouté le 31/02/1010 pour contrôle
  		fibaro:debug("Consigne corrigée pour " .. Zone10 .. " est de " .. ConsZone10 .."°C") 
    	
  		  		if tonumber (Val_12) < tonumber (Val_11) 
       	then 
			fibaro:call(SW11,'turnOn') -- maintenant Qubino + diode HG ON/OFF inversés 23/07/2023
			fibaro:call(SW12,'turnOff')
    		fibaro:call(706,'turnoff')
--		elseif (tonumber (Val_12)- tonumber(Hysteresis)) > (tonumber (Val_11) + tonumber(Isolation)) 
		elseif (tonumber (Val_12)) > (tonumber (Val_11) + tonumber(Isolation)) --07/05/2020
          then  
			fibaro:call(SW11,'turnOff') --ON/OFF inversés 23/07/2023
			fibaro:call(SW12,'turnOn')
    		fibaro:call(706,'turnOff')
		end
	--end
    Val_13 = fibaro:getValue(SW11, 'value')
    Val_14 = fibaro:getValue(SW12, 'value')
		fibaro:debug("Switch ID " .. SW11 .. " " .. Zone10 .. " côté jardin  est : " .. Val_13)
		fibaro:debug("Switch ID " .. SW12 .. " " .. Zone10 .. " côté cour est : ".. Val_14)
    
-- Paramètres Zone20 Chambre Parents
local Zone20 = 'Chambre des Parents'
local Consigne20 = 31
local SW21  = 515
local SW22 = 0
local Temp20 = 32
  fibaro:debug('----------------------------------------')
  fibaro:debug('-- Contrôle de la zone 20 : ' .. Zone20 .. ' --')
  Val_21 = fibaro:getValue(Consigne20,"value")
  Val_22 = fibaro:getValue(Temp20,'value')
--  Val_23 = fibaro:getValue(SW21,'value')
  --Val_24 = fibaro:getValue(SW22,'value')

  --local	zone = ("Zone20"..Zone20) Chambre Parent
    	fibaro:debug("Consigne "..Zone20 .." est : "..Val_21 .."°C")
  		fibaro:debug("Température "..Zone20 .." est : "..Val_22 .."°C")  
  
  local ConsZone20 = (tonumber (Val_21) + tonumber(Isolation)) -- ajouté le 31/02/1010 pour contrôle
  fibaro:debug("La consigne corrigé de " .. Zone20 .. " utilisée est de " .. ConsZone20 .."°C") 

-- Télécommande de la Chambre des Parents
  if (tonumber (Val_22) -  tonumber(Hysteresis)) < (tonumber (Val_21) + tonumber(Isolation))
        then 
        fibaro:call(SW21, "turnOn") -- Qubino ON/OFF inversé
        --fibaro:call(nn, "turnOff")
--          elseif (tonumber (Val_22) +  tonumber(Hysteresis)) > (tonumber (Val_21) + tonumber(Isolation))
          elseif (tonumber (Val_22) ) > (tonumber (Val_21) + tonumber(Isolation)) --07/05/2020
          then 
          fibaro:call(SW21, "turnOff")
          --fibaro:call(nn, "turnon")
            end
    Val_23 = fibaro:getValue(SW21,'value')
		fibaro:debug("Switch 1 ID " .. SW21 .. " de " .. Zone20 .. " est : " .. Val_23)
		--fibaro:debug("Switch 2 " ..Zone20 .." est : "..Val_24)

  -- Paramètres Zone30 SdB -- Consigne et Temp = SdB
local Zone30 = 'Salle de bains de la maison'
local Consigne30 = 696 --Z-TRM3 -- 641 ex SRT321 -- Thermostat SdB
local Temp30 = 700 -- 642 ex SRT321 -- le 122 DISPARU AVEC VERS 3.620!
local SW31 = 99 -- interrupteur radiateur SdB à Diode 
 --fibaro:getValue(696, "targetLevel")
  --local	zone = ("Zone'30"..Zone30) Salle de Bains
  		fibaro:debug('--              \n-- Contrôle de la zone : '..Zone30 ..' --')
  Val_31 = fibaro:getValue(Consigne30,"targetLevel")
  Val_32 = fibaro:getValue(Temp30,'value')
  fibaro:debug( "la lecture de la t° SdB est de " .. Val_32 .. "°C")
--  Val_32 = 17
  --Val_33 = fibaro:getValue(SW31,'value')
  --Val_34 = fibaro:getValue(NN,'value')

  --local	zone = ("Zone30"..Zone30) SdB
    	fibaro:debug("Consigne de la "..Zone30 .." est : "..Val_31 .."°C")
  		fibaro:debug("Température de la "..Zone30 .." est : "..Val_32 .."°C")
local consZone30 = (tonumber (Val_31) + tonumber(Isolation))
  fibaro:debug("La consigne corrigée du " .. Zone30 .. " est de " ..consZone30 .. "°C")

  
  -- Télécommande de la Salle de Bains
  if (tonumber (Val_32) - tonumber(Hysteresis)) < (tonumber (Val_31) + tonumber(Isolation))
        then 
        fibaro:call(SW31, "turnOff")
        --fibaro:call(SW32, "turnOff")
--          elseif (tonumber (Val_32) + tonumber(Hysteresis)) > (tonumber (Val_31) + tonumber(Isolation)) 
          elseif (tonumber (Val_32)) > (tonumber (Val_31) + tonumber(Isolation))  --07/05/2020
          then  
          fibaro:call(SW31, "turnOn")
          --fibaro:call(SW32, "turnOn")
          end
  Val_33 = fibaro:getValue(SW31,'value')
		fibaro:debug("Switch 1 ID ".. SW31 .." de la " ..Zone30 .." est : "..Val_33)
		-- fibaro:debug("Switch 2 ID " ..SW32 .. " de " ..Zone30 .." est : "..Val_34)

-- Paramètres Zone 40 Salon
local Zone40 = "Salon"
local Consigne40 = 635 -- Thrmst Salon
local Temp40 = 636 -- T° SRT321 Salon
--  	local Consigne40 = 637 -- Salle à manger
--		local Temp40 = 638 -- Salle à manger
local SW41 = 294 -- côté cour Qubino inversé
local SW42 = 103 -- côté jardin
  		fibaro:debug('-----------------------------------------')
		fibaro:debug('-- Contrôle de la zone : '..Zone40 ..' --')

 
  Val_41 = fibaro:getValue(Consigne40, 'value')  
  Val_42 = fibaro:getValue(Temp40, 'value')
  Val_43 = fibaro:getValue(SW41, 'value')
  Val_44 = fibaro:getValue(SW42, 'value')
   
----Lecture du module Int Netatmo Salon
local stationNo = 1
local wT=json.decode(fibaro:getGlobalValue("NetatmoWeather"))
TempNetatmoSalon = wT.netatmo[1].intm[1].temp
local TempNetatmoInt = fibaro:getValue(718, "ui.Label1.value")
  
fibaro:debug("les valeurs du module Salon Netatmo sont : " .. TempNetatmoSalon .. "°C")
fibaro:debug("la valeur Temp Int  est : " .. TempNetatmoInt .."°C")
-- contrôle du fonctionnement du module Netatmo
local InDoorModuleState = wT.netatmo[1].intm[1].fail
fibaro:debug("Module HS si la valeur suivante est à 1 : " .. InDoorModuleState)
if tonumber(InDoorModuleState) > 1
  then 
    TempNetatmoSalon = Val_42
end

 ------- modification du module de contrôle en fonction de l'état des piles Salon Zone 40------
-- Salon batteries SRT321
local ValB_040 = fibaro:getValue(Consigne40, "batteryLevel")
fibaro:debug("Niveau batterie du module  Thrmst Salon" .. Consigne40 .. " est " .. ValB_040 )

if (tonumber(ValB_040) > tonumber(BLevel))
  then 
  fibaro:debug("Batterie Thrmst OK  -")
  fibaro:debug("-----")
  	Val_41 = fibaro:getValue(Consigne40,"value") -- consigne Thermostat Salon
  	Val_42 = fibaro:getValue(Temp40,'value') -- Temp Salon
	fibaro:debug("l'ID pour la valeur Temp40 est " .. Temp40)
else 
  fibaro:debug("else batterie Thrmst KO   --") 
  --- changement de consigne selon le profil
  local  TypeControl = fibaro:getGlobal("Profil")
  fibaro:debug("Profil : " .. TypeControl)
  if TypeControl == "Présence"
  	then
     	Consign40 = Consigne20 -- Thrmst de la chambre des parents
	    fibaro:debug("l'ID pour la valeur Consigne40 est " .. Consigne20)
  		Val_41 = fibaro:getValue(Consigne20,"value") -- consigne Thermostat Ch parents 
		Val_42 = TempNetatmoSalon -- Temp Salon
  	else
  	Val_1 = fibaro:getGlobal("H_G")  
 -- 	Val_42 = TempNetatmoSalon
  	end 
	 	Val_42 = TempNetatmoSalon
  	
end
  
--------------------------------------  

  fibaro:debug("Consigne du "..Zone40 .." est : "..Val_41 .."°C")
    	fibaro:debug("Température choisie du "..Zone40 .." est : "..Val_42 .."°C")
  --Télécommande Salon - 
  local consZone40 = (tonumber (Val_41) + tonumber(Isolation))
  --fibaro:debug("la consigne corrigée pour " .. Zone40 .. " est de " consZone40 .. "°C")
--  local ConsZone0 = (tonumber (Val_41) + tonumber(Isolation)) -- ajouté le 31/02/1010 pour contrôle
  fibaro:debug("La consigne corrigée pour " .. Zone40 .. " est de " .. consZone40 .."°C") 
--if (tonumber (TempNetatmoSalon) - tonumber(Hysteresis)) < (tonumber (Val_41) + tonumber(Isolation)) -- 
 
if (tonumber (Val_42) - tonumber(Hysteresis)) < (tonumber (Val_41) + tonumber(Isolation)) -- fonctionne sur zone 40
--  if (tonumber (TempNetatmoSalon) - tonumber(Hysteresis)) < (tonumber (Val_41) + tonumber(Isolation)) 
  	then 
        fibaro:call(SW42, "turnOff")
   -- if (tonumber(TempNetatmoSalon)+ 1.5 ) > (tonumber(Val_41) + tonumber(Isolation))
	--	then 
		--  fibaro:call(SW41, "turnOn")
		  --else
        --fibaro:call(SW41, "turnOff")
			--end
    
        fibaro:call(SW41, "turnOn")
    	fibaro:call(294, "turnOn") -- ajouté car la ligne du dessus ne marche plus
  
  elseif (tonumber (TempNetatmoSalon)) > (tonumber (Val_41) + tonumber(Isolation)) -- 07/05/2020 Hystéresis changée de 0.5 à 0.2 le 17/02/2020
          then  
    fibaro:debug("La T° du Salon est supérieure à la consigne")
          fibaro:call(SW42, "turnOn")
          fibaro:call(SW41, "turnOff")
    	  fibaro:call(294, "turnOff") -- ajouté car la ligne du dessus ne marche plus
          end
  
  Val_43 = fibaro:getValue(SW41, 'value')
  Val_44 = fibaro:getValue(SW42, 'value')

  	  	fibaro:debug("Switch 1 Cour ID "..SW41.." du "..Zone40 .." est : "..Val_43)
		fibaro:debug("Switch 2 Jardin ID "..SW42.." du " ..Zone40 .." est : "..Val_44)

-- Paramètres Zone 50 Couloir 1er (Zone Escalier) (Supresssion WallPlug ID49 08/01/2017)
local Zone50 = "Couloir 1er"
local Consigne50 = 639
local SW51 = 315 --  Qubino à fonctionnement inversé (Paramètre 63=1)
local SW52 = 69 -- QUBINO  à fonctionnement inversé (paramètre 63 = 1)
local Temp50 = 640  

fibaro:debug('-- Contrôle de la zone : '..Zone50 ..' --')
  Val_51 = fibaro:getValue(Consigne50,"value")
  Val_52 = fibaro:getValue(Temp50,'value')
  --  Val_55 = fibaro:getValue(116, 'value')
    	fibaro:debug("Consigne "..Zone50 .." est : ".. Val_51 .."°C")
  		fibaro:debug("Température "..Zone50 .." est : ".. Val_52 .."°C")
  local consZone50 = (tonumber (Val_51) + tonumber(Isolation))
  fibaro:debug("La consigne corrigée de ".. Zone50 .. " est de : " .. consZone50 .. "°C") 

  -- Télécommande Couloir 1er
  if (tonumber (Val_52) - tonumber(Hysteresis)) < tonumber (consZone50)
    then    
        fibaro:call(SW51, "turnOn")
        fibaro:call(SW52, "turnOn")
    	--fibaro:call(116, "turnOn")
--          elseif (tonumber (Val_52) - tonumber(Hysteresis)) > (tonumber (consZone50)) 
          elseif (tonumber (Val_52)) > (tonumber (consZone50)) -- 07/05/2020 
          then  
          fibaro:call(SW51, "turnOff")
          fibaro:call(SW52, "turnOff")
    	  --fibaro:call(116, "turnOff")
            end
  Val_53 = fibaro:getValue(SW51,'value') 
  Val_54 = fibaro:getValue(SW52,'value')

		fibaro:debug("Switch 1 ID " .. SW51 .. " du " .. Zone50 .." est : ".. Val_53)
		fibaro:debug("Switch 2 ID " .. SW52 .. " du " .. Zone50 .." est : ".. Val_54)
  	  --fibaro:debug("Switch 3 ID " .. SW53 .. " du " .. Zone50 .." est : ".. Val_55)

------------ Gestion température de la SdB 1er Grange -------------------
  local Zone60 = "Salle de bains Grange"
  local Consigne60 = 725 --573 --594 --262
  local Temp60 = 752 --574 --595 --263
  local SW60 = 705 -- 580 --607 --275
 -- local SW61 = 264
  Val_61 = fibaro:getValue(Consigne60,"value") --consigne
  Val_62 = fibaro:getValue(Temp60,"value") --température

  fibaro:debug('-------- SdB Grange ----------')
  fibaro:debug('La consigne pour ' .. Zone60 .. ' est de '.. Val_61.."°C")
  fibaro:debug('Température SdB Grange est de '.. Val_62.."°C")
local consZone60 = (tonumber(Val_61) + tonumber(Isolation))
  fibaro:debug('La consigne corrigée de ' .. Zone60 .. ' est de '.. consZone60 .."°C")
  
  if tonumber(Val_62 - tonumber(Hysteresis)) < (tonumber(Val_61) + tonumber(Isolation)) --7
    then fibaro:call(SW60, "turnOn") -- fibaro:call(275, "setValue", 99)
    	 -- fibaro:call(264, "turnOn")	c'était temporaire pendant travaux de la SdB 
--    elseif (tonumber (Val_62) + tonumber(Hysteresis)) > (tonumber (Val_61) + Isolation) 
    elseif (tonumber (Val_62)) > (tonumber (Val_61) + Isolation) -- 07/05/2020
          then 
    		fibaro:call(SW60, "setValue", 20)  -- fibaro:call(275, "setValue", 9) -- fibaro:call(254,"turnOn")
   	 	 	-- fibaro:call(264, "turnOff") c'était temporaire pendant travaux de la SdB
    		fibaro:debug("Le fil pilot SdB Grange est à ".. fibaro:getValue(SW60, "value"))
  end
--fibaro:debug('Le Fil pilote ID '.. SW60 ..' de la SdB Grange a la valeur '.. fibaro:getValue(SW60,"value"))
  -- fibaro:debug('Le Fil pilote 275 de la SdB Grange est en mode '.. fibaro:getValue(607,"currentMode"))
   --fibaro:debug('Le switch ID ' .. SW61 .. ' de la SdB Grange est '.. fibaro:getValue(SW61,"value")) -- Temporaire
 --  fibaro:debug('La consigne de la SdB_Grange est de '..fibaro:getValue(262,"value"))
--fin de boucle
else 
fibaro:debug('Le chauffage n\'est pas dans le bon mode ')
    
  	     
end  

fibaro:debug('       ----------- Fin du Sénario ----------                          ')

fibaro:abort()



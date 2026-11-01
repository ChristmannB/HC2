--[[
%% autostart
-- %% properties
%% events
%% globals
--]]
------------------------- PRESENCE -------------------

-- consigne de température en °C
local Consigne1 = fibaro:getGlobal('In_House')
local Consigne2 = Consigne1 - 3
local Consigne3 = Consigne1 + 1
--Consigne3 = tonumber(Consigne1) + 1

--  Affichage du mode de chauffage
local Val = fibaro:getGlobal('Mode_Maison') 
fibaro:debug('Le chauffage est en mode : '..Val)

-- Affichage de la température de consigne présence
fibaro:debug('Consigne1 '..Val ..' is :'..Consigne1 ..'°C')
fibaro:debug('Consigne2 '..Val ..' is :'..Consigne2 ..'°C')
fibaro:debug('Consigne3 '..Val ..' is :'..Consigne3 ..' C')

-- lecture des températures
--local Zone00 = 'Salle à Manger'
local Temp00 = fibaro:getValue(29, 'value')
--local Zone01 = 'Cuisine'
local Temp01 = fibaro:getValue(96, 'value')
--local Zone10 = 'Couloir RDC'
local Temp10 = fibaro:getValue(90, 'value') 
--local Zone20 = 'Chambre des Parents'
local Temp20 = fibaro:getValue(32, 'value')
--local Zone30 = 'Salle de bains'
local Temp30 = fibaro:getValue(35, 'value')
--local Zone40 = 'Salon'
--local Temp40 = fibaro:getValue(nn, 'value')
--local Zone50 = 'Couloir 1er'
local Temp50 = fibaro:getValue(47, 'value')
--Affichage des valeurs
fibaro:debug('Température Salle à manger : '.. Temp00 .."°C")  
fibaro:debug('Température Cuisine : '.. Temp01 .."°C")
fibaro:debug('Température Couloir RDC : '.. Temp10 .."°C") 
fibaro:debug('Température Chambre des parents : '.. Temp20 .."°C")
fibaro:debug('Température Salle de bain : '.. Temp30 .."°C")  
--fibaro:debug('Température Salon : '.. Temp40 .."°C")
fibaro:debug('Température Couloir 1er : '.. Temp50 .."°C")


-- boucle
if (Val=='Presence') 
  then fibaro:debug('Le mode est correct') -- Salle à manger
		if tonumber (Temp00) < tonumber (Consigne1)
    	then fibaro:call(51, 'turnOn')
    	else fibaro:call(51, 'turnOff')
    	end
  fibaro:debug('Switch S à M 51 est : '.. fibaro:getValue(51, 'value'))
  
  		if tonumber (Temp01) < tonumber (Consigne1)
    	then fibaro:call(59, 'turnOff')
    	else fibaro:call(59, 'turnOn')
    	end
  fibaro:debug('Switch Cuisine 59 est : '.. fibaro:getValue(59, 'value')) 
  
  		if tonumber (Temp10) < tonumber (Consigne2)
    	then fibaro:call(17, 'turnOn')
             fibaro:call(111, 'turnOn')
    	else fibaro:call(17, 'turnOff')
             fibaro:call(111, 'turnOff')
    	end
  fibaro:debug('Switch Couloir RDC 111 est : '.. fibaro:getValue(111, 'value')) 
  fibaro:debug('Switch Couloir Escalier RDC est : '.. fibaro:getValue(17, 'value'))
  
  		if tonumber (Temp20) < tonumber (Consigne1)
    	then fibaro:call(65, 'turnOn')
    	else fibaro:call(65, 'turnOff')
    	end
  fibaro:debug('Switch Chambre parents 65 est : '.. fibaro:getValue(65, 'value')) 
  
   		if tonumber (Temp30) < tonumber (Consigne1)
    	then fibaro:call(99, 'turnOn')
--    	     fibaro:call(nn, 'turnOff')
    	else fibaro:call(99, 'turnOff')
--             fibaro:call(nn, 'turnOn')
    	end
  fibaro:debug('Switch SdB 99 est '.. fibaro:getValue(99, 'value'))
  
 -- fibaro:debug('Switch Coumoir 1er 69 est : '.. fibaro:getValue(69, 'value')) 
--  fibaro:debug('Switch Couloir 1er 49 est : '.. fibaro:getValue(49, 'value')) 
   		if tonumber (Temp50) < tonumber (Consigne2)
    	then fibaro:call(69, 'turnOff')
    		 fibaro:call(49, 'turnOn')  
    	else fibaro:call(65, 'turnOn')
    		 fibaro:call(49, 'turnOff')
  		end
	fibaro:debug('Switch Couloir 1er 69 est : '.. fibaro:getValue(69, 'value')) 
	fibaro:debug('Switch Couloir 1er 49 est : '.. fibaro:getValue(49, 'value')) 

  else fibaro:debug('Le chauffage n\'est pas dans le bon mode ')
  end  
  
fibaro:debug('Fin du scénario')
fibaro:abort()

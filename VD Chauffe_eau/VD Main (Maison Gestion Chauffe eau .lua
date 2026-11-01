local ModeChauffe = fibaro:getGlobal("Chauffeau")
ModeChauffe="Marche" --ajouté pour forcer la mode marche
local Chauffeau_ID = 558
-- local Node_2ID = nn
-- local VD_ID = 672 
local VDID = fibaro:getSelfId() -- obtention de l'identité de ce VD
	fibaro:debug(" Le VD Chauffe-eau " .. VDID .. " est lancé")

local Etat_Node1
--local Etat_Node2
local i = 0
fibaro:debug("les Machines sont en mode ".. fibaro:getGlobal("Chauffeau"))--ModeChauffe)
-- Affichage du label1 & 2
-- fibaro:call(VDID,'setProperty','ui.Label1.value', ModeChauffe)
-- fibaro:call(VDID,'setProperty','ui.Label2.value', ModeChauffe)
-- Utilisation de l'heure et de la date
local Maintenant = os.date("*t") --stocke la date et heure actuelle du système sous forme d'un tableau à l'intérieur de la variable "Maintenant"
--  Affichage de la date et l'heure
fibaro:debug("il est maintenant ".. Maintenant['hour'].."h"..Maintenant['min'].."min"..", le "..Maintenant['day'].."/"..Maintenant['month'].."/"..Maintenant['year'])
local hstart= fibaro:getGlobal("Hstart")
local hend= fibaro:getGlobal("Hend")
fibaro:debug("Début : "..hstart..", Fin : "..hend)
if (ModeChauffe == 'Stop')
										
  then fibaro:call(Chauffeau_ID,"turnOff") -- Ballon MAISON
  	   						-- Affichage du label1
	 fibaro:call(VDID,'setProperty','ui.Label1.value', ModeChauffe)
  
    elseif (ModeChauffe == "Marche")
	
      then fibaro:call(Chauffeau_ID,"turnOn")
  	     --fibaro:call(Node_2ID,"turnOn")
							-- Affichage du label1
	-- fibaro:call(VDID,'setProperty','ui.Label1.value', ModeChauffe)
     fibaro:call(VDID,'setProperty','ui.Label1.value', ModeChauffe)
    		
	elseif (ModeChauffe == "HeuresCreuses") 
    		then 
										-- Affichage du label1 et du label2
 							fibaro:call(VDID,'setProperty','ui.Label1.value', ModeChauffe)
							-- fibaro:call(VDID,'setProperty','ui.Label2.value', ModeChauffe)
  			--if ( Maintenant['hour'] < 8 or Maintenant['hour'] > 22)
  			if ( Maintenant['hour'] <= tonumber(hend) or Maintenant['hour'] >= tonumber(hstart))
            	then fibaro:call(Chauffeau_ID,"turnOn")
    fibaro:debug("Début: "..hstart.." - "..Maintenant['hour'].." - "..hend)
    				 
    		  	 	 --fibaro:call(Node_2ID,"turnOn")
    			else fibaro:call(Chauffeau_ID,"turnOff")
    				  
      				 --fibaro:call(Node_2ID,"turnOff")
										-- Affichage du label1
										--fibaro:call(VDID,'setProperty','ui.Label1.value', ModeChauffe)
                end
end

if (tonumber(fibaro:getValue(Chauffeau_ID,"value")) == 0)
then Etat_Node1 = 'Arrêt' --'Off'
else Etat_Node1 = 'Marche' --'On'
end
fibaro:debug("Switch " .. Chauffeau_ID .. " is : " .. Etat_Node1) 

--if (tonumber(fibaro:getValue(Chauffeau_ID,"value")) == 0) 
--then Etat_Node2 = 'Off'
--else Etat_Node2 = 'On'
--end
--fibaro:debug("Switch " .. Node_2ID .. " is : ".. Etat_Node2)

  
i=i+1 -- Compteur d'occurance

fibaro:debug("Le chauffeau de la MAISON est en mode ".. Etat_Node1)  
--fibaro:debug("La machine " .. Node_2ID ..  " est en mode "..fibaro:getValue(Node_2ID,"value"))
--fibaro:debug("L'état de machine " .. Node_2ID ..  "est : ".. Etat_Node2)
fibaro:debug("le BALLON ESt en mode ".. ModeChauffe)
			-- Affichage du label1 & label2
fibaro:sleep(1500)
			fibaro:call(VDID,'setProperty','ui.Label1.value', ModeChauffe)
--			fibaro:call(VDID,'setProperty','ui.Label2.value', ModeChauffe)
			fibaro:debug("le label1 est à "..fibaro:getValue(VDID,"ui.Label1.value"))
--			fibaro:debug("le label2 est à "..fibaro:getValue(VDID,"ui.Label2.value"))
fibaro:sleep(180000) -- tempo optimale 180000
if i>1
then fibaro:abort()
end
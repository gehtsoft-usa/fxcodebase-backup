-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72859

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("All In Level Calculator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);


	indicator.parameters:addGroup("Calculation");
   indicator.parameters:addInteger("NumberOfLevels", "Number Of Sub Levels", "", 4, 1, 4);	
    indicator.parameters:addInteger("Stop", "Last line Stop Level (in pips) ", "", 10, 0, 1000000);	  
 
	
  
   indicator.parameters:addGroup( " Line Style");
   for i=1, 6, 1 do
   AddStyle(i) 
   end
 
end


function AddStyle(id) 

    
	
	if id== 1 then
	indicator.parameters:addGroup("First Line");	 
    indicator.parameters:addColor("Label"..id, "Label Color", "", core.COLOR_LABEL); 
    indicator.parameters:addInteger("Size"..id, "Font Size", "", 10);
   
    indicator.parameters:addColor("Color"..id, "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Width"..id, "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style"..id, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style"..id, core.FLAG_LINE_STYLE);
	
	elseif id== 2 then
	indicator.parameters:addGroup("Last Line");		 
    indicator.parameters:addColor("Label"..id, "Label Color", "", core.COLOR_LABEL); 
    indicator.parameters:addInteger("Size"..id, "Font Size", "", 10);
   
    indicator.parameters:addColor("Color"..id, "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Width"..id, "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style"..id, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style"..id, core.FLAG_LINE_STYLE);
	else
	
	indicator.parameters:addGroup(id-2 .. ". Line");		 
    indicator.parameters:addColor("Label"..id, "Label Color", "", core.COLOR_LABEL); 
    indicator.parameters:addInteger("Size"..id, "Font Size", "", 10);
   
    indicator.parameters:addColor("Color"..id, "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Width"..id, "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style"..id, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style"..id, core.FLAG_LINE_STYLE);
	
	end
end
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

local db;
local pattern = "([^;]*);([^;]*)";
local Level1, Level2;
local LotSize={1, 10, 100, 1000, 10000, 100000 };
local Label={};
local Size={};
local Color={}; 
local Width={}; 
local Style={}; 
local Shift={};
local PipCost;
local NumberOfLevels;
local Stop;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    NumberOfLevels=instance.parameters.NumberOfLevels+2;
	Stop=instance.parameters.Stop;

    Level1=0
	Level2=0  	
	 

    if   (nameOnly) then
        return;
    end
    
	
	for i=1, NumberOfLevels, 1 do 
	
 
		 Label[i]=instance.parameters:getColor("Label" .. i);
		 Size[i]=instance.parameters:getInteger("Size" .. i);
		 Color[i]=instance.parameters:getColor("Color" .. i);
		 Width[i]=instance.parameters:getInteger("Width" .. i);
		 Style[i]=instance.parameters:getInteger("Style" .. i); 
	end
	
	 
    source = instance.source;
    first=source:first();
	
	PipCost   = core.host:findTable("offers"):find("Instrument", source:instrument()).PipCost;	
		
 
    instance:ownerDrawn(true);
	
	require("storagedb");
    db = storagedb.get_db(name);	
	

	    core.host:execute("addCommand", 1, "Select First Level");		
	    core.host:execute("addCommand", 2, "Select Last Level");			
		 core.host:execute("setTimer", 10, 1);	
end

function AsyncOperationFinished(cookie, success, message)


    if cookie== 1 then
	local Level, Date = string.match(message, pattern, 0);	
	db:put("Level1" , tostring(Level));  	
    elseif cookie== 2 then
	local Level, Date = string.match(message, pattern, 0);	
	db:put("Level2" , tostring(Level)); 	 
	else
		
		Level1= db:get ("Level1", 0);
		Level2= db:get ("Level2", 0);			
    end
   
	
end	



-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 
function Update(period)   

 
end




local init = false;
 
function Draw(stage, context)
 
	  if stage~= 2 
	  or Level1==0
	  or Level2==0   
	  then
	  return;
	  end
	
        if not init then
         
            init = true;
			
			
				for i= 1, NumberOfLevels, 1 do
				context:createPen (i, context:convertPenStyle (Style[i]), context:pointsToPixels (Width[i]), Color[i])
				  context:createFont (10+i, "Arial", context:pointsToPixels (Size[i]), context:pointsToPixels (Size[i]), 0);
				end
			
        end
		
	 
  	 ValueInDolars=0;  
	
    for i= 1, NumberOfLevels, 1 do
    
		if i==1 then
		
		ValueInDolars= PipCost * LotSize[i]  * ( math.abs(Level1- Level2)/source:pipSize() +Stop) ;
		ValueInDolars=win32.formatNumber(ValueInDolars, false, 0)
		
		visible, y = context:pointOfPrice (Level1)
		
		context:drawLine (i, context:left (), y, context:right (), y);
		
		width, height = context:measureText (i, "First" , 0);
		context:drawText (i, "First", Label[i], -1, context:right ()-width , y-height,context:right () , y, 0)
		
		width, height = context:measureText (i, tostring(LotSize[i]) .." "  .." " .. "Lots "  .. ValueInDolars .. " Risk" , 0);
		context:drawText (i, tostring(LotSize[i]) .." "  .." " .. "Lots "  .. ValueInDolars .. " Risk", Label[i], -1, context:left () , y-height,context:left () +width , y, 0)
		
	

		elseif i~=  2 then
		

		
		Delta=(Level1-Level2)/(NumberOfLevels-1);
		
		    ValueInDolars= PipCost * LotSize[i-1]  * ( math.abs(Level1- Level2)/source:pipSize() +Stop) ;	
		    ValueInDolars=win32.formatNumber(ValueInDolars, false, 0)	
		    visible, y = context:pointOfPrice (Level1-(Delta *( i-2)))	
		
			context:drawLine (i, context:left (), y, context:right (), y);
	
			width, height = context:measureText (i, i -2 .."." , 0);
			context:drawText (i, tostring((i -2) .."."), Label[i], -1, context:right ()-width , y-height,context:right () , y, 0)
	
		width, height = context:measureText (i, tostring(LotSize[i-1])  .." "  .." " .. "Lots "  .. ValueInDolars .. " Risk" , 0);
		context:drawText (i, tostring(LotSize[i-1])  .." " .." " .. "Lots "  .. ValueInDolars .. " Risk", Label[i], -1, context:left () , y-height,context:left () +width , y, 0)	
		end

	
	end
	
	
		i=2
		
		ValueInDolars= PipCost * LotSize[i+NumberOfLevels-2]  * ( math.abs(Level1- Level2)/source:pipSize() +Stop) ;	
		ValueInDolars=win32.formatNumber(ValueInDolars, false, 0)	
		visible, y = context:pointOfPrice (Level2)	
		context:drawLine (i, context:left (), y, context:right (), y);
		
		width, height = context:measureText (i, "Last" , 0);
		context:drawText (i,  "Last" , Label[i], -1, context:right ()-width , y-height,context:right () , y, 0)

		width, height = context:measureText (i, tostring(LotSize[i+NumberOfLevels-2])  .." " .. "Lots "  .. ValueInDolars .. " Risk" , 0);
		context:drawText (i, tostring(LotSize[i+NumberOfLevels-2])   .." " .. "Lots "  .. ValueInDolars .. " Risk", Label[i], -1, context:left () , y-height,context:left () +width , y, 0)
	
	
 

end		
 
--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+
  
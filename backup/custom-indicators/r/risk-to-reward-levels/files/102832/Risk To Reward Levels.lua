
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62786

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Risk To Reward Levels");
    indicator:description("Risk To Reward Levels");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Side", "Buy or Sell", "", "Buy");
	indicator.parameters:addStringAlternative("Side", "Buy", "Buy" , "Buy");
    indicator.parameters:addStringAlternative("Side", "Sell", "Sell" , "Sell");
	
 	indicator.parameters:addString("Model", "Pips or Dollars", "", "Pips");
	indicator.parameters:addStringAlternative("Model", "Pips", "" , "Pips");
    indicator.parameters:addStringAlternative("Model", "Dollars", "" , "Dollars");

	 
	indicator.parameters:addInteger("PipsAtRisk", "Value/Pips at Risk", "Value/Pips at Risk", 100,0,10000);	
	indicator.parameters:addDouble("Level", "Entry Order Level (0 or Value)", "Entry Order", 0);
		
	indicator.parameters:addGroup("Levels");
	indicator.parameters:addDouble("Level1", "1. Level", "", 1);
	indicator.parameters:addDouble("Level2", "2. Level", "", 2);
	indicator.parameters:addDouble("Level3", "3. Level", "", 3);
	indicator.parameters:addDouble("Level4", "4. Level", "", 4);
	indicator.parameters:addDouble("Level5", "5. Level", "", 5);
	indicator.parameters:addDouble("Level6", "6. Level", "", 6);
	indicator.parameters:addDouble("Level7", "7. Level", "", 7);
	indicator.parameters:addDouble("Level8", "8. Level", "", 8);
	indicator.parameters:addDouble("Level9", "9. Level", "", 9);
	indicator.parameters:addDouble("Level10", "10. Level", "", 10);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Entry", "Entry", "Entry", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Stop", "Stop", "Stop", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Levels", "Levels", "Levels", core.rgb(255, 255, 0));
	indicator.parameters:addColor("Label", "Label", "Label", core.rgb(0, 0, 0));
	indicator.parameters:addInteger("Size", "Font Size", "Font Size", 15);
 	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Side; 
local Level;
local iLevel={};

local Model;
local PipsAtRisk;
  
local font;
local name;
local first;
local source = nil;
local PipCost;
local Size; 

--local size=0;

-- Routine
function Prepare(nameOnly)  

    
	Size = instance.parameters.Size;
	
    Side = instance.parameters.Side; 
	
	iLevel[1] = instance.parameters.Level1;
	iLevel[2] = instance.parameters.Level2;
    iLevel[3] = instance.parameters.Level3;
    iLevel[4] = instance.parameters.Level4;	
	iLevel[5] = instance.parameters.Level5;
	iLevel[6] = instance.parameters.Level6;
	iLevel[7] = instance.parameters.Level7;
	iLevel[8] = instance.parameters.Level8;
	iLevel[9] = instance.parameters.Level9;
	iLevel[10] = instance.parameters.Level10;
   
    Level = instance.parameters.Level;    	
	Model = instance.parameters.Model;
	PipsAtRisk = instance.parameters.PipsAtRisk;	

	
    source = instance.source;
    first = source:first();
	
	

		
	name = profile:id() .. "(" .. source:name() ..") ";
	instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	PipCost   = core.host:findTable("offers"):find("Instrument", source:instrument()).PipCost;
	
	font = core.host:execute("createFont", "Arial", Size, true, false);
	 
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


  if period < source:size()-1 then
  return;
  end
  
  
 core.host:execute ("removeAll")
 
   local price=0;
     if Level==0 then	
	 price=source[period];
	 else
	 price=Level;
	 end 
	 

 local stop;
						
						if (Model=="Pips") then 							
								 stop=(PipsAtRisk )*source:pipSize();			 
						 else  						         
								 stop=((PipsAtRisk/PipCost) )*source:pipSize();
						 end
						
					
						local s;
											
		
				
					 if  Side == "Buy" then
					 s=price- stop;
					 else
					 s=price+ stop;
					 end
					 
					 
		core.host:execute("drawLine", 1, source:date(first), s, source:date(period), s, instance.parameters.Stop);	
		core.host:execute("drawLabel1", 2, source:date(period) , core.CR_CHART, s, core.CR_CHART, core.H_Right, core.V_Top,font, instance.parameters.Label, "Stop ("  .. string.format("%." .. 5 .. "f", s  ) .. ")  " );	
		
		 core.host:execute("drawLine", 3, source:date(first), price, source:date(period), price, instance.parameters.Entry);		 
		 core.host:execute("drawLabel1", 4, source:date(period) , core.CR_CHART, price, core.CR_CHART, core.H_Right, core.V_Top,font, instance.parameters.Label,"  Entry (" .. price .. ")" );	


       for i= 1, 10, 1 do
	   
	                 if  Side == "Buy" then
					 PriceLevel=price+ stop*iLevel[i];
					 else
					 PriceLevel=price- stop*iLevel[i];
					 end
					 
       core.host:execute("drawLine", 10+i, source:date(first), PriceLevel, source:date(period), PriceLevel, instance.parameters.Levels);		 
	   core.host:execute("drawLabel1", 20+i, source:date(period) , core.CR_CHART, PriceLevel, core.CR_CHART, core.H_Right, core.V_Top,font, instance.parameters.Label, i.. ". Level (" .. PriceLevel .. ")" );	
       end	   
	
end
function ReleaseInstance()
       core.host:execute("deleteFont", font);
end

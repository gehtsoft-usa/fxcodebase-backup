-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65848

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Colored candles");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 
	indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addBoolean("Use1" , "Use 1. Slot", "", true); 	
	indicator.parameters:addInteger("P1", "1. Candle length (in pips)", "", 1);
	
	indicator.parameters:addBoolean("Use2" , "Use 2. Slot", "", true); 	
	indicator.parameters:addInteger("P2", "2. Candle length (in pips)", "", 2);
	
	indicator.parameters:addBoolean("Use3" , "Use 3. Slot", "", true); 	
	indicator.parameters:addInteger("P3", "3. Candle length (in pips)", "", 3);
	
	indicator.parameters:addBoolean("Use4" , "Use 4. Slot", "", true); 	
	indicator.parameters:addInteger("P4", "4. Candle length (in pips)", "", 4);
	
	indicator.parameters:addBoolean("Use5" , "Use 5. Slot", "", true); 	
	indicator.parameters:addInteger("P5", "5. Candle length (in pips)", "", 5);
	
	indicator.parameters:addBoolean("Use6" , "Use 6. Slot", "", true); 	
	indicator.parameters:addInteger("P6", "6. Candle length (in pips)", "", 6);
	
	indicator.parameters:addBoolean("Use7" , "Use 7. Slot", "", true); 	
	indicator.parameters:addInteger("P7", "7. Candle length (in pips)", "", 7);
	
	indicator.parameters:addBoolean("Use8" , "Use 8. Slot", "", true); 		
	indicator.parameters:addInteger("P8", "8. Candle length (in pips)", "", 8);
	
	indicator.parameters:addBoolean("Use9" , "Use 9. Slot", "", true); 	
	indicator.parameters:addInteger("P9", "9. Candle length (in pips)", "", 9);
	
	indicator.parameters:addBoolean("Use10" , "Use 10. Slot", "", true); 	
	indicator.parameters:addInteger("P10", "10. Candle length (in pips)", "", 10);
	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Greater than Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Down", "Smaller than Color", "", core.rgb(128, 128, 128));
    indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
   
    indicator.parameters:addColor("C1", "1. Candle Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("C2", "2. Candle Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("C3", "3. Candle Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("C4", "4. Candle Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("C5", "5. Candle Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("C6", "6. Candle Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("C7", "7. Candle Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("C8", "8. Candle Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("C9", "9. Candle Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("C10", "10. Candle Color", "", core.rgb(0, 0, 255));
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up,Down, Neutral;
local first;
local source = nil;

local Price;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
local P1, P2, P3, P4, P5, P5, P6, P7 , P8, P9,P10;
local Use1, Use2, Use3, Use4, Use5, Use5, Use6, Use7 , Use8, Use9,Use10;
local min,max;
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	P1= instance.parameters.P1;
	P2= instance.parameters.P2;
	P3= instance.parameters.P3;
	P4= instance.parameters.P4;
	P5= instance.parameters.P5;
	P6= instance.parameters.P6; 
	P7 = instance.parameters.P7;
	P8= instance.parameters.P8;
	P9= instance.parameters.P9;
	P10= instance.parameters.P10;
	
	Use1= instance.parameters.Use1;
	Use2= instance.parameters.Use2;
	Use3= instance.parameters.Use3;
	Use4= instance.parameters.Use4;
	Use5= instance.parameters.Use5;
	Use6= instance.parameters.Use6; 
	Use7 = instance.parameters.Use7;
	Use8= instance.parameters.Use8;
	Use9= instance.parameters.Use9;
	Use10= instance.parameters.Use10;


    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
	Neutral= instance.parameters.Neutral;
   

	source = instance.source;
	 
	first= source:first();
 
	
	max=0;
	min=math.huge;
	
 
	if Use1 then
	
	if max < P1 then
	max=P1;
	end
	
	if min > P1 then
	min=P1;
	end
	
	elseif Use2 then
	
	if max < P2 then
	max=P2;
	end
	
	if min > P2 then
	min=P2;
	end
		
	elseif Use3 then
	
	if max < P3 then
	max=P3;
	end
	
	if min > P3 then
	min=P3;
	end
	
	elseif Use4 then
	
	if max < P4 then
	max=P4;
	end
	
	if min > P4 then
	min=P4;
	end
	
	elseif Use5 then
	
	if max < P5 then
	max=P5;
	end
	
	if min > P5 then
	min=P5;
	end
	
	elseif Use6 then
	
	if max < P6 then
	max=P6;
	end
	
	if min > P6 then
	min=P6;
	end
	
	elseif Use7 then
	
	if max < P7 then
	max=P7;
	end
	
	if min > P7 then
	min=P7;
	end
	
	elseif Use8 then
	
	if max < P8 then
	max=P8;
	end
	
	if min > P8 then
	min=P8;
	end
	
	elseif Use9 then
	
	if max < P9 then
	max=P9;
	end
	
	if min > P9 then
	min=P9;
	end
	
	elseif Use10 then
	
	if max < P10 then
	max=P10;
	end
	
	if min > P10 then
	min=P10;
	end
	
    end
	
 
		
    	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)
	
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
	if max ==0 then
	return;
	end
	
	
			if period < first then
			open:setColor(period, Neutral);	
			return;
			end
	
	
	    Length=(source.high[period]-source.low[period])/source:pipSize();		
 		Length= round(Length, 0);
		
		
		open:setColor(period, Neutral);	
		
		
		if Length > max then
		open:setColor(period, Up);		
		end
		
		if Length < min then
		open:setColor(period, Down);	
	    end
		
		if Length == P1 and Use1 then
		open:setColor(period, instance.parameters.C1);
		end
		
		if Length == P2 and Use2 then
		open:setColor(period, instance.parameters.C2);
		end
		
		if Length == P3 and Use3 then
		open:setColor(period, instance.parameters.C3);
		end
		
		if Length == P4 and Use4 then
		open:setColor(period, instance.parameters.C4);
		end
		
		if Length == P5 and Use5 then
		open:setColor(period, instance.parameters.C5);
		end
		
		if Length == P6 and Use6 then
		open:setColor(period, instance.parameters.C6);
		end
		
		if Length == P7 and Use7 then
		open:setColor(period, instance.parameters.C7);
		end
		
		if Length == P8 and Use8 then
		open:setColor(period, instance.parameters.C8);
		end
		
		if Length == P9 and Use9 then
		open:setColor(period, instance.parameters.C9);
		end
		
		if Length == P10 and Use10 then
		open:setColor(period, instance.parameters.C10);		 
		end
		
		
		

		
 end

 
 function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end


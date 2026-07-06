-- Id: 14269
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15639

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Bar Height");
    indicator:description("High/Low or Open/Close Difference");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
   
   
    indicator.parameters:addGroup("Calculation");  
    indicator.parameters:addString("Type", "H/L - O/C", "", "High/Low");
    indicator.parameters:addStringAlternative("Type", "High/Low", "", "High/Low");
    indicator.parameters:addStringAlternative("Type", "Open/Close", "", "Open/Close");
	indicator.parameters:addStringAlternative("Type", "Open/Close + 2 x Wicks ", "", "Open/Close + 2 x Wicks");
 
	
	indicator.parameters:addString("PIP", "As Pips", "As Pips", "YES");
    indicator.parameters:addStringAlternative("PIP", "Pip", "", "YES");
    indicator.parameters:addStringAlternative("PIP", "Value", "", "NO");
	
	indicator.parameters:addDouble("Limit", "Filter", "Filter", 0);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Neutral", core.rgb(128, 128, 128));
   
 

end



-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Type;
local PIP;
local source = nil;
local Difference = nil; 
local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
local Up,Down,Neutral;
local Limit;
-- Routine
function Prepare(nameOnly)   
    source = instance.source;
	first=source:first()
	
	PIP = instance.parameters.PIP; 
    Type = instance.parameters.Type;
	Limit = instance.parameters.Limit;
	
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Neutral= instance.parameters.Neutral; 
   
    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Type)  .. ", " .. tostring(Limit).. ")";
	instance:name(name);
	if nameOnly then
		return;
	end 
    
	Difference = instance:addInternalStream(first, 0);
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("MACD", "MACD", open, high, low, close);
	   
end


 function Calculate(period, mode)
 
 
    if period >= first and source:hasData(period) then
	    if Type == "High/Low" then
         Difference[period] = source.high[period] -source.low[period];
		 elseif Type == "Open/Close" then
		 Difference[period] = math.abs(source.close[period] -source.open[period]);
		 else
		 Difference[period] = source.high[period] -source.low[period]
		 +  (source.high[period] - math.max(source.close[period],source.open[period] ) )
		 +  ( math.min(source.close[period],source.open[period] ) - source.low[period]  );
		 end
		 if PIP == "YES" then
		 Difference[period]=  Difference[period] / source:pipSize();
		 end
		 
    end
 
    
 
 end
 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 

        open[period]=source.open[period]
		close[period]=source.close[period];
		high[period]=source.high[period];
		low[period]=source.low[period];	                   
		   
		   if period < first then
		   open:setColor(period, Neutral);
		   return;
		   end

    Calculate(period, mode);
	
	
	
	                        if math.abs(Difference[period]) > Limit then 	
								if source.close[period]> source.open[period] then
								open:setColor(period, Up); 
								else
								open:setColor(period, Down); 				
                                end								
							else
							open:setColor(period, Neutral); 
							end
	
	
end

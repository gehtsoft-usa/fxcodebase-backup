-- Id: 6349
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
    indicator:name("Bar Height with Smoothing");
    indicator:description("High/Low or Open/Close Difference");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");  
    indicator.parameters:addString("Type", "H/L - O/C", "", "High/Low");
    indicator.parameters:addStringAlternative("Type", "High/Low", "", "High/Low");
    indicator.parameters:addStringAlternative("Type", "Open/Close", "", "Open/Close");
	indicator.parameters:addStringAlternative("Type", "Open/Close + 2 x Wicks ", "", "Open/Close + 2 x Wicks");
	
	 indicator.parameters:addBoolean("Use", "Use Smoothing", "" , true); 
	indicator.parameters:addInteger("Period", "Averege Period", "First Averege  Period", 20);
	indicator.parameters:addString("Method", "Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");   
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Line Lovor", "", core.rgb(255, 0, 0));
	indicator.parameters:addString("LType", "Line Type", "Bar or Line", "Bar");
    indicator.parameters:addStringAlternative("LType", "Bar", "", "Bar");
    indicator.parameters:addStringAlternative("LType", "Line", "", "Line");
	
	--indicator.parameters:addString("PIP", "Line Type", "Bar or Line", "YES");
    --indicator.parameters:addStringAlternative("PIP", "Pip", "", "YES");
   -- indicator.parameters:addStringAlternative("PIP", "Line", "", "NO");
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local LType;
--local PIP;
local first;
local source = nil;
local Use, Period, Method;
local MA, Raw;

-- Streams block
local Difference = nil;
local Type;
-- Routine
function Prepare(nameOnly)
    Method = instance.parameters.Method;
	Period = instance.parameters.Period;
	Use = instance.parameters.Use;
   -- PIP = instance.parameters.PIP;
    Type = instance.parameters.Type;
    LType = instance.parameters.LType;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Type) .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	Raw = instance:addInternalStream(0, 0);
	
	if Use then
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA= core.indicators:create(Method, Raw, Period);
	first = math.max(first, MA.DATA:first());
	end
	

    if (not (nameOnly)) then
	     if LType== "Bar" then
         Difference = instance:addStream("Difference", core.Bar, name, "Difference", instance.parameters.color, first);
		 else
		 Difference = instance:addStream("Difference", core.Line, name, "Difference", instance.parameters.color, first);
		 end
		 
		 -- if PIP == "YES" then
		  Difference:setPrecision (2);
		 -- else
		 -- Difference:setPrecision (4);
		 -- end
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period >= first and source:hasData(period) then
	    if Type == "High/Low" then
         Raw[period] = (source.high[period] -source.low[period])/  source:pipSize();
		 elseif Type == "Open/Close" then
		 Raw[period] = math.abs(source.close[period] -source.open[period])/  source:pipSize();
		 else
		 Raw[period] = ( source.high[period] -source.low[period]
		 +  (source.high[period] - math.max(source.close[period],source.open[period] ) )
		 +  ( math.min(source.close[period],source.open[period] ) - source.low[period]  )) /  source:pipSize();
		 end
		 
		 
		 if Use then
	     MA:update(mode);
		 Difference[period]= MA.DATA[period];
		 else
		 Difference[period]= Raw[period];
		 end		 
	
    end
end


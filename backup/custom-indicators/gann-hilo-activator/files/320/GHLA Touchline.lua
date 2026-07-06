-- Id: 5025

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=227

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
    indicator:name("GHLA Touchline");
    indicator:description("GHLA");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PERIOD", "Period", "", 50, 1, 2000);
	
	indicator.parameters:addString("Method", "Method", "Method" , "EMA");
	indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");    
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");   
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("GHLA_Up", "Color of the Line Up", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("GHLA_Down", "Color of the Line Down", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local PERIOD;

local first;
local source = nil;

-- Streams block
local GHLA = nil;
local Method;
local HIGH, LOW;
local pdir;
-- Routine
function Prepare(nameOnly)
    PERIOD = instance.parameters.PERIOD;
	Method = instance.parameters.Method;
    source = instance.source;
	
	 pdir = instance:addInternalStream(0, 0);  

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(PERIOD).. ", " .. tostring(Method).. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	

    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	 HIGH= core.indicators:create(Method, source.high, PERIOD);
	 LOW= core.indicators:create(Method, source.low, PERIOD);
	 
	   first = HIGH.DATA:first();
	
     
        GHLA = instance:addStream("GHLA", core.Line, name, "GHLA", instance.parameters.GHLA_Up, first);
		GHLA:setWidth(instance.parameters.width);
        GHLA:setStyle(instance.parameters.style);
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not source:hasData(period) then
	return;
	end
	
	  HIGH:update(mode);
	  LOW:update(mode);
	  
	  local switch = 0;
	  
	   if (source.close[period] > HIGH.DATA[period]) then
            switch = 1;
        elseif (source.close[period] <  LOW.DATA[period]) then
            switch = -1;
        end        
        if (switch ~= 0) then	       
            pdir[period] = switch;
           
        else
            switch = pdir[period - 1];
			pdir[period]=pdir[period - 1];
        end
		
		 if (switch == -1) then
            GHLA[period] = HIGH.DATA[period];
        else
            GHLA[period] = LOW.DATA[period];
        end
	
       if pdir[period] == 1 then
	   GHLA:setColor(period, instance.parameters.GHLA_Up);
	   else
	    GHLA:setColor(period, instance.parameters.GHLA_Down);
	   end
   
     if pdir[period]~=pdir[period-1] then
	GHLA:setBreak (period, true); 
    else	 
	GHLA:setBreak (period, false);
	end  
end


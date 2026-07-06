-- Id: 16866
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64009&p=108740#p108740

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

function Init()
    indicator:name("Corrected Average");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 5);
	
	indicator.parameters:addString("Method", "Method", "Method" , "SMMA");
	indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");    
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");   
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addBoolean("Show" , "Show", "", true);
	
	indicator.parameters:addGroup("Style");

	indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;

-- Streams block
local Line = nil;
local Method;
local name;
local ma;
local Raw;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Method = instance.parameters.Method;
	Show = instance.parameters.Show;
    source = instance.source;
	
	 
	
    Raw = instance:addInternalStream(0, 0);  

    name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(Method).. ")";
    instance:name(name);
    if (not (nameOnly)) then	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
        ma= core.indicators:create(Method, source, Period);
        first = ma.DATA:first();
        Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first);
		Line:setWidth(instance.parameters.width);
        Line:setStyle(instance.parameters.style);	 
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    
    ma:update(mode);
		
    if period < first or not source:hasData(period) then
	return;
	end
	
	
	if period ==first then
	Line[period] = ma.DATA[period];
	else
	      
		    ld_8 =  math.pow(stdev ( period), 2);
			ld_16 = math.pow((Line[period -1] - ma.DATA[period]), 2);
			ld_24 = 0;
			
		if (ld_16 < ld_8 or ld_16 == 0.0) then
		ld_24 = 0;	
		else		
		ld_24 = 1 - ld_8 / ld_16;
		end
		
		Line[period] = Line[period-1] + ld_24 * (ma.DATA[period] - (Line[period - 1]));
	
	end
	 
		
	 
	
end

function stdev ( period) 
 
   local dAmount=0;
   
     local i;
     for i=0,(Period-1),1 do
      dAmount=dAmount+math.pow((source[period-i]-ma.DATA[period]),2);
     end
	 
     return math.sqrt(dAmount/Period);
    

end
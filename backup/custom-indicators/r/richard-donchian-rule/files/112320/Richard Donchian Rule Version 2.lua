-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64641

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
    indicator:name("Richard Donchian Rule");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 4);

	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Top", "Top Line Color", "Line Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Bottom", "Bottom Color",  "Line Color", core.rgb(255, 0, 0));
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 


local first;
local source = nil;
local   Period;

local MinValue, MaxValue;
-- Streams block
 
 
-- Routine
function Prepare(nameOnly) 
    	
	Period= instance.parameters.Period;
	
    source = instance.source;
    first = source:first()+Period;
	
	 
	  
    local name = profile:id() .. "(" .. source:name()   .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	

    MaxValue = instance:addStream("MaxValue", core.Line, name .. ".MaxValue", "MaxValue", instance.parameters.Top, first);
    MaxValue:setVisible(false);
    MinValue = instance:addStream("MinValue", core.Line, name .. ".MinValue", "MinValue", instance.parameters.Top, first);
    MinValue:setVisible(false);
end
 
local ID=0;

function SetOutput(Stream, firstBar, lastBar, Value)
	local i;
	for i=firstBar, lastBar, 1 do
		Stream[i]=Value;
	end
end

function Update(period)

   
	 
	 if period <= first then
	 ID=1
	 return;
	 end
	 
	 
	 min,max=mathex.minmax(source, period-1-Period+1, period-1);
	 
	 if source.high[period]> max then 
	 	ID=ID+1;
	 	core.host:execute("drawLine",ID , source:date(period -Period), source.high[period], source:date(period), source.high[period], instance.parameters.Top);
	 	SetOutput(MaxValue, period-Period, period, source.high[period]);
	 end
	 
	 if source.low[period]< min then 
		 ID=ID+1;
		 core.host:execute("drawLine",ID , source:date(period -Period), source.low[period], source:date(period), source.low[period], instance.parameters.Bottom);
		 SetOutput(MinValue, period-Period, period, source.low[period]);
	 end
	 
	 
	 
   
end


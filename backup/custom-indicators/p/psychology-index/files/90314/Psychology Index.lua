-- Id: 10281
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59730

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
    indicator:name("Psychology Index");
    indicator:description("Psychology Index");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Lookback Period", "Lookback Period", 12);
	indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("PsychologyIndex_color", "Color of PsychologyIndex", "Color of PsychologyIndex", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Upper threshold (%)","", 75);
    indicator.parameters:addDouble("oversold","Lower threshold (%)","", 25);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
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
local PsychologyIndex = nil;
local UpDay;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;  
    source = instance.source;
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period)  .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        UpDay= instance:addInternalStream(0, 0);
        PsychologyIndex = instance:addStream("PsychologyIndex", core.Line, name, "PsychologyIndex", instance.parameters.PsychologyIndex_color, first);
    PsychologyIndex:setPrecision(math.max(2, instance.source:getPrecision()));
		PsychologyIndex:setWidth(instance.parameters.width);
        PsychologyIndex:setStyle(instance.parameters.style);		
        PsychologyIndex:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		PsychologyIndex:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
   
	 
	if(source[period] > source[period-1]) then
	UpDay[period]=1;
	else
	UpDay[period]=0;
	end
	
    if period < first  then
	return;
	end
	
	
        PsychologyIndex[period] = mathex.sum(UpDay, period-Period+1, period)/Period*100;
 
end


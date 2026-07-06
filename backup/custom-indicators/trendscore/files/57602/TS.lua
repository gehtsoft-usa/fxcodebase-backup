-- Id: 8816
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=33942


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
    indicator:name("TrendScore");
    indicator:description("TrendScore");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Start", "Start", "Start", 11);
    indicator.parameters:addInteger("End", "End", "End", 20);
	indicator.parameters:addInteger("Step", "Step", "Step", 1);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("TS_color", "Color of TS", "Color of TS", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
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
local Start;
local End;
local Step;
local first;
local source = nil;

-- Streams block
local TS = nil;

-- Routine
function Prepare(nameOnly)
    Start = instance.parameters.Start;
    End = instance.parameters.End;
	Step = instance.parameters.Step;
    source = instance.source;
    first = source:first()+End;
	
	local i;
	i = math.abs(End -Start+1)/Step;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Start) .. ", " .. tostring(End) .. ", " .. tostring(Step) .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
        TS = instance:addStream("TS", core.Line, name, "TS", instance.parameters.TS_color, first);
    TS:setPrecision(math.max(2, instance.source:getPrecision()));
		TS:addLevel(i, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		TS:addLevel(-i, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
		TS:setWidth(instance.parameters.width);
        TS:setStyle(instance.parameters.style);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first  then
	return;
	end
	
	TS[period]=0;
	
	local i;
	for i = period-Start, period-End, -Step do	
	
	    if source[period] > source[i] then
        TS[period] =  TS[period]+1;
		elseif source[period] < source[i] then
		 TS[period] =  TS[period]-1;
		end 
		
	 end	
  
end


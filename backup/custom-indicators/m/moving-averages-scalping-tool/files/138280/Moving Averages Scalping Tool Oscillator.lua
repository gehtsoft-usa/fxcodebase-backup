-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70538

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
	indicator:name("Moving Averages Scalping Tool  Oscillator")
	indicator:description("")
	indicator:requiredSource(core.Tick)
	indicator:type(core.Oscillator)

	indicator.parameters:addGroup("Calculation")

	indicator.parameters:addInteger("Period1", "1. MA Period", "", 50, 1, 1000)
	indicator.parameters:addInteger("Period2", "2. MA Period", "", 100, 1, 1000)
	indicator.parameters:addInteger("Period3", "3. MA Period", "", 200, 1, 1000)
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Selector")

	indicator.parameters:addBoolean("Off", "Exclude 1. MA filtering", "", true);
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Bar Color", "", core.rgb(0, 255, 0));
 
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source;
local Period1, Period2, Period3,Method;
local Off;
local open = nil;
local close = nil;
local high = nil;
local low = nil;

--local MA = nil;
local MA1,MA2,MA3;
local ma1, ma2, ma3;
local Up, Down;
local Ratio;
local Lines;
local Transparency;
local Trend;
local LastCross;
function Prepare(nameOnly)
	 
	Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
	Period3 = instance.parameters.Period3;
	Method = instance.parameters.Method;
	Off= instance.parameters.Off;
	source = instance.source;

	Up = instance.parameters.Up;
	Down = instance.parameters.Down;

	local name = profile:id() .. "(" .. source:name() .. ", " .. Period1, Period2, Period3 .. ", " .. Method .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA1 = core.indicators:create(Method, source , Period1);
	MA2 = core.indicators:create(Method, source , Period2);
    MA3 = core.indicators:create(Method, source , Period3);
	first = math.max(MA1.DATA:first(),MA2.DATA:first(),MA3.DATA:first());
     
	 
	Trend = instance:addStream("Trend" , core.Bar, "Trend","Trend",instance.parameters.color, first ); 
    Trend:setPrecision(math.max(2, source:getPrecision()));
	 
	ma1 = instance:addInternalStream(0, 0);
	ma2 = instance:addInternalStream(0, 0);
	ma3 = instance:addInternalStream(0, 0);
  

end

-- Indicator calculation routine
function Update(period, mode)
	MA1:update(mode);
	MA2:update(mode);
	MA3:update(mode);
	
	if period < first then
		return
	end
	
	
	ma1[period]=MA1.DATA[period];
	ma2[period]=MA2.DATA[period];
	ma3[period]=MA3.DATA[period];

	
	 Trend[period]=0;
	
	if source[period]> MA1.DATA[period]
	and (MA1.DATA[period]> MA1.DATA[period-1] or Off )
	and MA2.DATA[period]> MA2.DATA[period-1]
	and MA3.DATA[period]> MA3.DATA[period-1]
	and (MA1.DATA[period]> MA2.DATA[period] or Off )
	and MA2.DATA[period]> MA3.DATA[period]
	then
	Trend[period]=1;
	elseif  source[period]< MA1.DATA[period]
 	and (MA1.DATA[period]< MA1.DATA[period-1]  or Off )
	and MA2.DATA[period]< MA2.DATA[period-1]
	and MA3.DATA[period]< MA3.DATA[period-1]
	and (MA1.DATA[period]< MA2.DATA[period] or Off )
	and MA2.DATA[period]< MA3.DATA[period]
	then
	Trend[period]=-1;
	end
	
	 
 
end 
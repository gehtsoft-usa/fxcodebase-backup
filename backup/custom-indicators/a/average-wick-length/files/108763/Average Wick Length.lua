-- Id: 16884
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64019&p=108763#p108763

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
    indicator:name("Average Wick Length");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
 
	indicator.parameters:addString("iMethod", "Calculation Method", "Method" , "Separated");
    indicator.parameters:addStringAlternative("iMethod", "Separated", "Separated" , "Separated");
    indicator.parameters:addStringAlternative("iMethod", "Cumulative", "Cumulative" , "Cumulative");
	 indicator.parameters:addStringAlternative("iMethod", "Delta", "Delta" , "Delta");
 
   	indicator.parameters:addInteger("Period", "MA Period", "Period" , 14);
   	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");

 
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Up Bar color", "Bar Color", core.rgb(0, 255, 0));	
	indicator.parameters:addColor("color2", "Down Bar color", "Bar Color", core.rgb(255, 0, 0));

  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
 
local source;
local iMethod;
local Up, Down, Cumulative;
local RawUp, RawDown, RawCumulative;
local Delta;
local Period, Method, Up_MA, Down_MA, Cumulative_MA;
local first;
-- Routine
function Prepare(nameOnly)
    iMethod= instance.parameters.iMethod;
	Period= instance.parameters.Period;
	Method= instance.parameters.Method;
    source = instance.source;
	
	 local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	
	RawUp = instance:addInternalStream(source:first(), 0);
	RawDown = instance:addInternalStream(source:first(), 0);
	
	
	Up_MA = core.indicators:create(Method, RawUp, Period);
	Down_MA = core.indicators:create(Method, RawDown, Period);

	if iMethod== "Separated"    then
    Up = instance:addStream("Up", core.Bar, name .. ".Up", "Up", instance.parameters.color1, source:first());
    Down = instance:addStream("Down", core.Bar, name .. ".Down", "Down", instance.parameters.color2, source:first());
	else
	Up = instance:addInternalStream(source:first(), 0);
	Down = instance:addInternalStream(source:first(), 0);
	end
     
	
	RawCumulative = instance:addInternalStream(source:first(), 0);
	Cumulative_MA = core.indicators:create(Method, RawCumulative, Period);
	
	if iMethod== "Cumulative" then
    Cumulative = instance:addStream("Cumulative", core.Bar, name .. ".Cumulative", "Cumulative", instance.parameters.color1, source:first());    
	else
	Cumulative = instance:addInternalStream(source:first(), 0);
	end
	
	if iMethod== "Delta" then
    Delta = instance:addStream("Delta", core.Bar, name .. ".Deltae", "Delta", instance.parameters.color1, source:first());    
	else
	Delta = instance:addInternalStream(source:first(), 0);
	end
	
	Cumulative:setPrecision(math.max(2, instance.source:getPrecision()));
	Delta:setPrecision(math.max(2, instance.source:getPrecision()));
	Up:setPrecision(math.max(2, instance.source:getPrecision()));
	Down:setPrecision(math.max(2, instance.source:getPrecision()));
	
	 first  = Up_MA.DATA:first();
	 
end

-- Indicator calculation routine
function Update(period, mode)
    
	RawUp[period]= (source.high[period]- math.max(source.open[period], source.close[period]))/source:pipSize();
	RawDown[period]=- ( math.min(source.open[period], source.close[period]) -source.low[period])/source:pipSize();	 
	RawCumulative[period]= RawUp[period]+math.abs(RawDown[period]);
	
	
	Up_MA:update(mode);
	Down_MA:update(mode);
	Cumulative_MA:update(mode);
	
	if period < first then
	return;
	end
	
	
	Up[period]= Up_MA.DATA[period];
	Down[period]= Down_MA.DATA[period]
	Cumulative[period]= Cumulative_MA.DATA[period]
	Delta[period]=Up[period]+Down[period];
	
	if Delta[period] > 0 then
	Delta:setColor(period, instance.parameters.color1);
	else
	Delta:setColor(period, instance.parameters.color2);
	end
end






